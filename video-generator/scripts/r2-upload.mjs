import 'dotenv/config';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { createReadStream } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

const BUCKET = process.env.R2_BUCKET;
export const R2_PUBLIC_URL = process.env.R2_PUBLIC_URL;

export async function uploadToR2(exerciseId, localPath) {
  const key = `exercise-videos/${exerciseId}.mp4`;
  await client.send(new PutObjectCommand({
    Bucket: BUCKET,
    Key: key,
    Body: createReadStream(localPath),
    ContentType: 'video/mp4',
    CacheControl: 'public, max-age=86400',
  }));
  console.log(`  ✓ R2: ${key}`);
}
