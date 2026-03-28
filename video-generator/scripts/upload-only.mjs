/**
 * Sadece rendered-videos/ klasöründeki .mp4 dosyalarını Cloudflare R2'ye yükler.
 */
import 'dotenv/config';
import { uploadToR2 } from './r2-upload.mjs';
import { readdirSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUTPUT_DIR = path.join(__dirname, '..', 'rendered-videos');

if (!existsSync(OUTPUT_DIR)) {
  console.error('rendered-videos/ klasörü bulunamadı. Önce render çalıştır.');
  process.exit(1);
}

const files = readdirSync(OUTPUT_DIR).filter((f) => f.endsWith('.mp4'));
console.log(`\n📤 Cloudflare R2 Upload — ${files.length} video\n`);

let success = 0;
let failed = 0;

for (let i = 0; i < files.length; i++) {
  const file = files[i];
  const exerciseId = file.replace('.mp4', '');
  const localPath = path.join(OUTPUT_DIR, file);
  process.stdout.write(`[${i + 1}/${files.length}] ${exerciseId} ... `);
  try {
    await uploadToR2(exerciseId, localPath);
    success++;
  } catch (err) {
    console.error(`❌ ${err.message}`);
    failed++;
  }
}

console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
console.log(`✅ Başarılı : ${success}`);
console.log(`❌ Başarısız: ${failed}`);
console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
