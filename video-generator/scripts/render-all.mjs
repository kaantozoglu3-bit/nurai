/**
 * Tüm egzersiz videolarını render edip Firebase Storage'a yükler.
 *
 * Kullanım:
 *   node scripts/render-all.mjs              # Tümünü render et
 *   node scripts/render-all.mjs acl          # Sadece ACL videolarını
 *   node scripts/render-all.mjs boyun_sage   # ID prefix filtreyle
 */

import { bundle } from '@remotion/bundler';
import { renderMedia, selectComposition } from '@remotion/renderer';
import { exercises, exerciseCount } from './exercise-data.mjs';
import { uploadToFirebase } from './firebase-upload.mjs';
import { mkdirSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const OUTPUT_DIR = path.join(__dirname, '..', 'rendered-videos');
const ENTRY_POINT = path.join(__dirname, '..', 'src', 'index.tsx');

// Opsiyonel filtre (CLI arg)
const filter = process.argv[2] || '';

const toRender = filter
  ? exercises.filter((e) => e.id.startsWith(filter))
  : exercises;

if (toRender.length === 0) {
  console.error(`Filtre "${filter}" için hiç egzersiz bulunamadı.`);
  process.exit(1);
}

mkdirSync(OUTPUT_DIR, { recursive: true });

console.log(`\n🎬 Nurai Video Generator`);
console.log(`Toplam: ${exerciseCount} egzersiz — Render edilecek: ${toRender.length}`);
console.log(`Çıktı: ${OUTPUT_DIR}\n`);

// Bir kez bundle et
console.log('📦 Bundle hazırlanıyor...');
const bundled = await bundle({
  entryPoint: ENTRY_POINT,
  webpackOverride: (config) => config,
});
console.log('✅ Bundle hazır\n');

let success = 0;
let failed = 0;

for (let i = 0; i < toRender.length; i++) {
  const exercise = toRender[i];
  const outputPath = path.join(OUTPUT_DIR, `${exercise.id}.mp4`);
  const progress = `[${i + 1}/${toRender.length}]`;

  console.log(`${progress} 🎬 ${exercise.exerciseName} (${exercise.bodyArea})`);

  try {
    const composition = await selectComposition({
      serveUrl: bundled,
      id: 'ExerciseVideo',
      inputProps: exercise,
    });

    await renderMedia({
      composition,
      serveUrl: bundled,
      codec: 'h264',
      outputLocation: outputPath,
      inputProps: exercise,
      onProgress: ({ progress: p }) => {
        process.stdout.write(`\r  Render: ${Math.round(p * 100)}%`);
      },
    });

    process.stdout.write('\r');
    console.log(`  ✅ Render tamamlandı → ${exercise.id}.mp4`);

    await uploadToFirebase(exercise.id, outputPath);
    success++;
  } catch (err) {
    console.error(`  ❌ Hata: ${err.message}`);
    failed++;
  }
}

console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
console.log(`✅ Başarılı : ${success}`);
console.log(`❌ Başarısız: ${failed}`);
console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
