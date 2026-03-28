/**
 * Firebase Storage'a video yükleyici
 * Gereksinimler:
 *   - video-generator/ dizininde service-account.json olmalı
 *     (Firebase Console → Proje Ayarları → Hizmet hesapları → Yeni özel anahtar oluştur)
 *   - veya GOOGLE_APPLICATION_CREDENTIALS env değişkeni set edilmeli
 *   - FIREBASE_STORAGE_BUCKET env değişkeni: "projeadi.appspot.com" formatında
 */

import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

let initialized = false;

function initFirebase() {
  if (initialized) return;

  const serviceAccountPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS ||
    path.join(__dirname, '..', 'service-account.json');

  if (!existsSync(serviceAccountPath)) {
    throw new Error(
      `service-account.json bulunamadı: ${serviceAccountPath}\n` +
      `Firebase Console → Proje Ayarları → Hizmet hesapları → Yeni özel anahtar oluştur`
    );
  }

  const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
  const bucket =
    process.env.FIREBASE_STORAGE_BUCKET ||
    `${serviceAccount.project_id}.appspot.com`;

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: bucket,
  });

  initialized = true;
  console.log(`Firebase başlatıldı — bucket: ${bucket}`);
}

export async function uploadToFirebase(exerciseId, localPath) {
  initFirebase();
  const bucket = admin.storage().bucket();

  await bucket.upload(localPath, {
    destination: `exercise-videos/${exerciseId}.mp4`,
    metadata: {
      contentType: 'video/mp4',
      cacheControl: 'public, max-age=86400',
    },
  });

  console.log(`  ✓ Firebase: exercise-videos/${exerciseId}.mp4`);
}
