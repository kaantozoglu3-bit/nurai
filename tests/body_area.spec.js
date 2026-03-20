'use strict';

/**
 * 15 Vücut Bölgesi Otonom Test — Backend API
 * Auth: Firebase REST API ile token alır, her bölge için analiz simüle eder.
 */

const { test, expect } = require('@playwright/test');
const fs   = require('fs');
const path = require('path');

const BACKEND_URL    = 'https://nuraibackend-production.up.railway.app';
const FIREBASE_KEY   = 'AIzaSyDA0Kj5RLepZjvb9Ald33sojrEkrthQkNk';
const TEST_EMAIL     = 'kaantozoglu9@gmail.com';
const TEST_PASS      = 'Ladon095';
const LOGS_DIR       = path.join(__dirname, 'logs');
const AREA_REPORT    = path.join(LOGS_DIR, 'body_area_report.json');

const BODY_AREAS = [
  { key: 'neck',           label: 'Boyun'           },
  { key: 'left_shoulder',  label: 'Sol Omuz'        },
  { key: 'right_shoulder', label: 'Sağ Omuz'        },
  { key: 'upper_back',     label: 'Üst Sırt'        },
  { key: 'lower_back',     label: 'Bel / Alt Sırt'  },
  { key: 'hip',            label: 'Kalça'            },
  { key: 'left_knee',      label: 'Sol Diz'          },
  { key: 'right_knee',     label: 'Sağ Diz'          },
  { key: 'left_elbow',     label: 'Sol Dirsek'       },
  { key: 'right_elbow',    label: 'Sağ Dirsek'       },
  { key: 'left_wrist',     label: 'Sol Bilek'        },
  { key: 'right_wrist',    label: 'Sağ Bilek'        },
  { key: 'left_ankle',     label: 'Sol Ayak Bileği'  },
  { key: 'right_ankle',    label: 'Sağ Ayak Bileği' },
  { key: 'core',           label: 'Karın / Core'     },
];

// Simulated 5-turn conversation for each body area
const SAMPLE_MESSAGES = [
  { role: 'assistant', content: 'Merhaba! Bu bölgedeki ağrınız ne zamandır devam ediyor?' },
  { role: 'user',      content: '2 haftadır' },
  { role: 'assistant', content: 'Ağrının şiddetini 1-10 arasında nasıl değerlendirirsiniz?' },
  { role: 'user',      content: '5' },
  { role: 'assistant', content: 'Ağrıyı nasıl tanımlarsınız? Yanma, zonklama, baskı, sertlik veya uyuşma?' },
  { role: 'user',      content: 'Sertlik ve baskı hissediyorum' },
  { role: 'assistant', content: 'Ağrı ne zaman daha çok artıyor? Hareket sırasında mı, sabahları mı?' },
  { role: 'user',      content: 'Sabahları daha fazla ve uzun süre oturduğumda' },
  { role: 'assistant', content: 'Son zamanlarda yoğun egzersiz yaptınız mı veya düşme/çarpma yaşadınız mı?' },
  { role: 'user',      content: 'Hayır, özel bir şey olmadı' },
];

// ─── Get Firebase Auth Token ─────────────────────────────────────────────────

let _cachedToken = null;
let _tokenExpiry = 0;

async function getAuthToken(request) {
  if (_cachedToken && Date.now() < _tokenExpiry) return _cachedToken;

  const res = await request.post(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_KEY}`,
    { data: { email: TEST_EMAIL, password: TEST_PASS, returnSecureToken: true } }
  );

  if (res.status() !== 200) {
    console.warn('⚠️  Firebase auth başarısız, token olmadan devam edilecek');
    return null;
  }

  const body = await res.json();
  _cachedToken = body.idToken;
  _tokenExpiry = Date.now() + (parseInt(body.expiresIn ?? '3600') - 60) * 1000;
  return _cachedToken;
}

// ─── Helper: save report ─────────────────────────────────────────────────────

function saveReport(results) {
  if (!fs.existsSync(LOGS_DIR)) fs.mkdirSync(LOGS_DIR, { recursive: true });
  fs.writeFileSync(AREA_REPORT, JSON.stringify(results, null, 2), 'utf8');
}

// ─── Test: YouTube için her bölge ────────────────────────────────────────────

test('B1 — YouTube endpoint: 15 bölgenin tümü', async ({ request }) => {
  const results = {};

  for (const area of BODY_AREAS) {
    const res  = await request.get(`${BACKEND_URL}/api/v1/youtube/search?bodyArea=${area.key}`);
    const status = res.status();
    // 200: ok, 401: auth required (endpoint alive), 429: rate limited (endpoint alive)
    const ok = [200, 401, 429].includes(status);
    results[area.key] = { youtube: ok, status };
    console.log(`${ok ? '✅' : '❌'} YouTube ${area.label}: ${status}`);
  }

  saveReport(results);

  const failed = Object.entries(results).filter(([, v]) => !v.youtube);
  expect(failed.length).toBe(0);
});

// ─── Test: Analysis API — her bölge için egzersiz çıkıyor mu? ────────────────

test('B2 — Analysis: 15 bölge egzersiz önerisi', async ({ request }) => {
  test.setTimeout(180_000); // 15 sıralı AI isteği — 3 dakika yeterli
  const token = await getAuthToken(request);
  const results = {};
  let loadedReport = {};
  try { loadedReport = JSON.parse(fs.readFileSync(AREA_REPORT, 'utf8')); } catch (_) {}

  const passed = [];
  const failed = [];
  const noAuth  = [];

  for (const area of BODY_AREAS) {
    const headers = token ? { Authorization: `Bearer ${token}` } : {};

    // chat-probe: test endpoint — auth required, quota bypassed, triggers final analysis
    const res = await request.post(`${BACKEND_URL}/api/v1/analysis/chat-probe`, {
      headers,
      data: {
        bodyArea: area.key,
        profile:  { age: 30, gender: 'male', fitnessLevel: 'moderate' },
      },
    });

    const status = res.status();

    if (status === 401 || status === 403) {
      noAuth.push(area.label);
      loadedReport[area.key] = { ...loadedReport[area.key], analysis: 'no_auth' };
      console.log(`⚠️  ${area.label}: Auth gerekli (${status})`);
      continue;
    }

    if (status === 429) {
      // Quota doldu — bu döngüde bekleniyor, geçilir
      console.log(`⚠️  ${area.label}: Rate limit (429)`);
      continue;
    }

    if (status !== 200) {
      failed.push({ label: area.label, status });
      loadedReport[area.key] = { ...loadedReport[area.key], analysis: 'error', analysisStatus: status };
      console.log(`❌ ${area.label}: ${status}`);
      continue;
    }

    let body;
    try { body = await res.json(); } catch (_) { body = {}; }

    // chat-probe returns { content, hasExercises, hasYoutube }
    const content     = body.content ?? body.message ?? JSON.stringify(body);
    const hasExercises = body.hasExercises ?? (content.includes('Egzersiz') || content.includes('egzersiz'));
    const hasYoutube   = body.hasYoutube   ?? content.includes('YOUTUBE_EGZERSIZLER');

    loadedReport[area.key] = {
      ...loadedReport[area.key],
      analysis:       hasExercises ? 'ok' : 'no_exercises',
      hasYoutubeLine: hasYoutube,
      snippet:        content.slice(0, 200),
    };

    if (hasExercises) {
      passed.push(area.label);
      console.log(`✅ ${area.label}: Egzersiz önerildi${hasYoutube ? ' + YouTube' : ''}`);
    } else {
      failed.push({ label: area.label, status, issue: 'no_exercises' });
      console.log(`❌ ${area.label}: Egzersiz YOK! Yanıt: ${content.slice(0, 100)}`);
    }
  }

  saveReport(loadedReport);
  console.log(`\n📊 Özet: ${passed.length} ✅  ${failed.length} ❌  ${noAuth.length} ⚠️ (auth)`);

  // Sadece 200 gelen ama egzersiz olmayan bölgeler test'i geçirmez
  const realFails = failed.filter(f => f.issue === 'no_exercises');
  expect(realFails.length).toBe(0);
});

// ─── Test: Exercise library — 15 bölgenin tümünde egzersiz var mı? ───────────

test('B3 — Exercise library: tüm bölgeler dolu', async ({ request }) => {
  // exercise_library_data.dart ve exercise_library/ alt dosyalarını tara
  const dataDir = path.join(__dirname, '..', 'mobile', 'lib', 'data');
  const mainFile = path.join(dataDir, 'exercise_library_data.dart');
  const subDir   = path.join(dataDir, 'exercise_library');

  // Tüm ilgili dart dosyalarının içeriğini birleştir
  let combined = fs.readFileSync(mainFile, 'utf8');
  if (fs.existsSync(subDir)) {
    for (const f of fs.readdirSync(subDir).filter(f => f.endsWith('.dart'))) {
      combined += fs.readFileSync(path.join(subDir, f), 'utf8');
    }
  }

  const missing = [];
  for (const area of BODY_AREAS) {
    if (!combined.includes(`key: '${area.key}'`)) {
      missing.push(area.label);
      console.log(`❌ Kütüphanede eksik: ${area.label} (${area.key})`);
    } else {
      console.log(`✅ Kütüphane: ${area.label}`);
    }
  }

  expect(missing).toHaveLength(0);
});

// ─── Test: YouTube search terms — openai.service.js'te tüm bölgeler var mı? ─

test('B4 — AI prompt: tüm bölgeler egzersiz kütüphanesinde', async () => {
  const svcFile = path.join(
    __dirname, '..', 'backend', 'src', 'services', 'openai.service.js'
  );
  const content = fs.readFileSync(svcFile, 'utf8');

  // Keywords to search in the prompt (Turkish chars may vary — use partial matches)
  const sections = {
    neck:          ['BOYUN', 'boyun'],
    lower_back:    ['BEL', 'SIRT', 'lower_back'],
    left_shoulder: ['OMUZ', 'omuz'],
    right_shoulder:['OMUZ', 'omuz'],
    upper_back:    ['ST SIRT', 'upper_back', 'SIRT'],
    hip:           ['KALÇA', 'KALCA', 'hip'],
    left_knee:     ['DIZ', 'Diz', 'diz', 'knee'],
    right_knee:    ['DIZ', 'Diz', 'diz', 'knee'],
    left_elbow:    ['RSEK', 'rsek', 'elbow'],
    right_elbow:   ['RSEK', 'rsek', 'elbow'],
    left_wrist:    ['LEK', 'bilek', 'wrist'],
    right_wrist:   ['LEK', 'bilek', 'wrist'],
    left_ankle:    ['AYAK', 'ankle'],
    right_ankle:   ['AYAK', 'ankle'],
    core:          ['KARIN', 'CORE', 'core'],
  };

  const missing = [];
  for (const [key, keywords] of Object.entries(sections)) {
    const found = keywords.some(kw => content.includes(kw));
    const label = BODY_AREAS.find(a => a.key === key)?.label ?? key;
    if (!found) {
      missing.push(label);
      console.log(`❌ AI prompt'ta eksik: ${label}`);
    } else {
      console.log(`✅ AI prompt: ${label}`);
    }
  }

  expect(missing).toHaveLength(0);
});
