'use strict';

const OpenAI = require('openai');
const logger = require('../config/logger');

// Groq uses an OpenAI-compatible API — just swap the baseURL and key
const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: 'https://api.groq.com/openai/v1',
});

const MODEL = 'llama-3.3-70b-versatile';
const MAX_TOKENS = 900;
const MODEL_TEMPERATURE = 0.85;

// ─── System Prompt ───────────────────────────────────────────────────────────

const SYSTEM_PROMPT_TEMPLATE = `Sen "Nurai" adlı uzman bir fizyoterapi yapay zeka asistanısın. Kas-iskelet ağrılarını analiz eder ve egzersiz önerirsin.

KULLANICI: age={age} gender={gender} height={height}cm weight={weight}kg fitness={fitnessLevel} injuries={pastInjuries} goal={goal} area={bodyArea}

KURALLAR:
- Kullanıcının dilinde yanıtla (TR/EN)
- Kısa ve odaklı tut (maks 3-4 cümle)
- Tek seferde bir soru sor
- Tıbbi tanı koyma, ilaç önerme
- Sadece {bodyArea} bölgesine odaklan

SORU AKIŞI (sırayla, önceki yanıta göre uyarla):
1. Süre → akut(<7gün)/kronik(1+ay) → strateji belirle
2. Şiddet (1-10) → 8-10=doktor öner+devam, 1-4=koruyucu, 5-7=dengeli
3. Karakter → yanma/zonklama/baskı/sertlik/uyuşma → sinir/iltihap/artrit ipucu
4. Kötüleşme → hareket/dinlenme/sabah/gece/pozisyon → gece/dinlenmede=ciddi uyarı
5. Bölgeye özel:
   - boyun/üst sırt: masabaşı saatleri, telefon bakışı
   - bel: uzun oturma, bacağa yayılma
   - diz: klik sesi, şişlik
   - omuz: kol kaldırma, geceye uyanma
   - kalça: topallama, iç/dış ağrı
6. Son aktivite → düşme/darbe/yoğun egzersiz

KIRMIZI BAYRAKLAR (herhangi biri → "Lütfen acilen doktora gidin"):
- İki bacakta uyuşma/güçsüzlük, mesane/bağırsak kontrolü kaybı, ciddi kaza sonrası ağrı, göğüs+kol/sırt ağrısı, ani şiddetli baş ağrısı+boyun

ANALİZ ÇIKTISI (tüm sorular sonrası bu EXACT format):
---
**Değerlendirme:** [2-3 cümle, basit dilde]
**Güven:** [En olası... / Muhtemelen... / Dışlanamaz...]

**Egzersiz Programı:**
1. [ad] — [nasıl yapılır] — [set/tekrar]
2. [ad] — [nasıl yapılır] — [set/tekrar]
3. [ad] — [nasıl yapılır] — [set/tekrar]

YOUTUBE_EGZERSIZLER: [ad1] | [ad2] | [ad3]

⚠️ Bu tıbbi teşhis değildir. Şiddetli ağrıda uzman görüşü alın.
---

EGZERSİZ KÜTÜPHANESİ (bölge+süreye göre seç):
BOYUN akut: boyun izometrik, nazik rotasyon, üst trapez germe
BOYUN kronik: chin tuck, skapular retraksiyon, levator scapulae germe, torasik mobilizasyon
BOYUN sinir: servikal traksiyon, nerve flossing, McKenzie boyun
BEL akut: McKenzie prone press-up, diz-göğüs, pelvik tilt, kedi-inek
BEL kronik: dead bug, bird dog, glute bridge, yan plank, McGill Big 3
BEL sinir: McKenzie ekstansiyon, siyatik mobilizasyon, piriformis germe
OMUZ akut: sarkaç(Codman), iç/dış rotasyon, kürek sıkıştırma
OMUZ kronik: theraband dış rotasyon, sleeper stretch, duvar tırmanma
OMUZ rotator: empty can, side-lying dış rotasyon, prone Y-T-W
DIZ akut: quad sets, düz bacak kaldırma, buz+istirahat
DIZ kronik: TKE, step-up, VMO squat, bisiklet
DIZ patella: yan bacak kaldırma, clamshell, kalça abdüktör
KALÇA akut: sırtüstü rotasyon, diz-göğüs, Thomas stretch
KALÇA kronik: tek bacak glute bridge, clamshell, lateral band walk, hip flexor germe
ÜST SIRT: foam roller torasik, skapular retraksiyon/depresyon, wall angels, Y-T-W, rhomboid
DİRSEK tenisçi: eksantrik bilek ekstansiyon, tyler twist, önkol germe
DİRSEK golfçü: eksantrik bilek fleksiyon, pronasyon/supinasyon
BİLEK: fleksiyon/ekstansiyon germe, pronasyon/supinasyon, tendon kaydırma, kavrama
AYAK akut: alfabe, theraband dorsifleksiyon, towel scrunching
AYAK kronik: tek ayak denge, BOSU, gastrocnemius/soleus germe
CORE akut: McGill curl-up, pelvik tilt, diyafragmatik nefes
CORE kronik: dead bug, bird dog, plank, hollow body, McGill Big 3

YOUTUBE_EGZERSIZLER satırı daima son satır olmalı.`;

// ─── Prompt Builder ───────────────────────────────────────────────────────────

const BODY_AREA_LABELS = {
  neck: 'Neck',
  left_shoulder: 'Left Shoulder',
  right_shoulder: 'Right Shoulder',
  upper_back: 'Upper Back / Chest',
  lower_back: 'Lower Back',
  hip: 'Hip',
  left_knee: 'Left Knee',
  right_knee: 'Right Knee',
  left_elbow: 'Left Elbow',
  right_elbow: 'Right Elbow',
  left_wrist: 'Left Wrist',
  right_wrist: 'Right Wrist',
  left_ankle: 'Left Ankle',
  right_ankle: 'Right Ankle',
  core: 'Core / Abdomen',
};

/** Strip HTML-like characters and limit length to prevent prompt injection. */
function _sanitize(val) {
  if (val == null) return 'Unknown';
  return String(val).slice(0, 100).replace(/[<>]/g, '');
}

function buildSystemPrompt(profile, bodyArea) {
  const injuries = Array.isArray(profile.pastInjuries)
    ? profile.pastInjuries.map(_sanitize).join(', ')
    : 'None';

  return SYSTEM_PROMPT_TEMPLATE
    .replace('{age}', _sanitize(profile.age))
    .replace('{gender}', _sanitize(profile.gender))
    .replace('{height}', _sanitize(profile.height))
    .replace('{weight}', _sanitize(profile.weight))
    .replace('{fitnessLevel}', _sanitize(profile.fitnessLevel))
    .replace('{pastInjuries}', injuries)
    .replace('{goal}', _sanitize(profile.goal))
    .replace('{bodyArea}', BODY_AREA_LABELS[bodyArea] ?? bodyArea);
}

// ─── Streaming Chat ───────────────────────────────────────────────────────────

async function streamChatResponse({ profile, bodyArea, messages, res }) {
  const systemPrompt = buildSystemPrompt(profile, bodyArea);

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('X-Accel-Buffering', 'no');
  res.flushHeaders();

  try {
    const recentMessages = messages.slice(-10);
    const stream = await client.chat.completions.create({
      model: MODEL,
      stream: true,
      messages: [
        { role: 'system', content: systemPrompt },
        ...recentMessages,
      ],
      max_tokens: MAX_TOKENS,
      temperature: MODEL_TEMPERATURE,
    });

    for await (const chunk of stream) {
      const delta = chunk.choices[0]?.delta?.content;
      if (delta) {
        res.write(`data: ${JSON.stringify({ content: delta })}\n\n`);
      }
    }

    res.write('data: [DONE]\n\n');
  } catch (err) {
    logger.error('[Groq] Streaming error', { message: err.message });
    res.write(`data: ${JSON.stringify({ error: err.message })}\n\n`);
  } finally {
    res.end();
  }
}

// ─── Non-Streaming Chat (for web clients) ─────────────────────────────────────

async function getChatResponse({ profile, bodyArea, messages }) {
  const systemPrompt = buildSystemPrompt(profile, bodyArea);

  const recentMessages = messages.slice(-10);
  const completion = await client.chat.completions.create({
    model: MODEL,
    stream: false,
    messages: [
      { role: 'system', content: systemPrompt },
      ...recentMessages,
    ],
    max_tokens: MAX_TOKENS,
    temperature: MODEL_TEMPERATURE,
  });

  return completion.choices[0]?.message?.content ?? '';
}

module.exports = { streamChatResponse, getChatResponse, buildSystemPrompt };
