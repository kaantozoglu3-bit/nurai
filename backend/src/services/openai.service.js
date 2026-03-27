'use strict';

const OpenAI = require('openai');
const logger = require('../config/logger');

// Groq uses an OpenAI-compatible API — just swap the baseURL and key
const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: 'https://api.groq.com/openai/v1',
});

const MODEL = 'llama-3.3-70b-versatile';
const MAX_TOKENS_CHAT = 600;
const MAX_TOKENS_SHORT = 300;
const MODEL_TEMPERATURE = 0.85;
const MAX_HISTORY = 6; // son 6 mesaj (önceki 10'du)

// ─── System Prompt ────────────────────────────────────────────────────────────
// Egzersiz kütüphanesi kaldırıldı (~250 token tasarruf) — model zaten biliyor.
// Profil sadece ilk mesajda ekleniyor.

const BASE_PROMPT = `Sen "Nurai" adlı uzman fizyoterapi AI asistanısın. Kas-iskelet ağrılarını analiz eder, egzersiz önerirsin.

KURALLAR:
- Kullanıcının dilinde yanıtla (TR/EN)
- Kısa ve odaklı tut (maks 3-4 cümle)
- Tek seferde bir soru sor
- Tıbbi tanı koyma, ilaç önerme
- Sadece {bodyArea} bölgesine odaklan

MEVCUT EGZERSİZ VİDEOLARI (SADECE AŞAĞIDAKİ ID'LERİ KULLANABİLİRSİN):
- boyun_sage_esnetme: Boyun Sağa Esnetme
- boyun_sola_esnetme: Boyun Sola Esnetme
- omuz_cevirme: Omuz Çevirme
- kedi_deve: Kedi-Deve Egzersizi
- sirt_germe: Sırt Germe

SORU AKIŞI (sırayla, önceki yanıta göre uyarla):
1. Süre → akut(<7gün)/kronik(1+ay) → strateji belirle
2. Şiddet (1-10) → 8-10=doktor öner+devam, 1-4=koruyucu, 5-7=dengeli
3. Karakter → yanma/zonklama/baskı/sertlik/uyuşma → sinir/iltihap/artrit ipucu
4. Kötüleşme → hareket/dinlenme/sabah/gece/pozisyon → gece/dinlenmede=ciddi uyarı
5. Bölgeye özel soru (boyun: masa saatleri; bel: bacağa yayılma; diz: klik/şişlik; omuz: geceye uyanma)
6. Son aktivite → düşme/darbe/yoğun egzersiz

KIRMIZI BAYRAKLAR (herhangi biri → "Lütfen acilen doktora gidin"):
- İki bacakta uyuşma/güçsüzlük, mesane/bağırsak kontrolü kaybı, ciddi kaza sonrası ağrı, göğüs+kol/sırt ağrısı

ANALİZ ÇIKTISI (tüm sorular sonrası bu EXACT format):
---
**Değerlendirme:** [2-3 cümle, basit dilde]
**Güven:** [En olası... / Muhtemelen... / Dışlanamaz...]

**Egzersiz Programı:**
1. [ad] — [nasıl yapılır] — [set/tekrar] — [video_id]
2. [ad] — [nasıl yapılır] — [set/tekrar] — [video_id]

⚠️ Bu tıbbi teşhis değildir. Şiddetli ağrıda uzman görüşü alın.
---`;

const ATHLETE_PROMPT = `Sen "Nurai" adlı sporcu rehabilitasyonu uzmanı AI asistanısın. Spor yaralanmalarını analiz eder, kanıta dayalı rehabilitasyon programları oluşturursun.

KURALLAR:
- Kullanıcının dilinde yanıtla (TR/EN)
- Kısa ve odaklı tut (maks 4-5 cümle)
- Tek seferde bir soru sor
- Tıbbi tanı koyma, ilaç önerme
- Sadece {bodyArea} bölgesine odaklan
- Sporcunun branşını ve seviyesini göz önünde bulundur

MEVCUT EGZERSİZ VİDEOLARI (SADECE AŞAĞIDAKİ ID'LERİ KULLANABİLİRSİN):
- boyun_sage_esnetme: Boyun Sağa Esnetme
- boyun_sola_esnetme: Boyun Sola Esnetme
- omuz_cevirme: Omuz Çevirme
- kedi_deve: Kedi-Deve Egzersizi
- sirt_germe: Sırt Germe

SPORCU SORU AKIŞI (sırayla):
1. Yaralanma mekanizması → anlık darbe/kronik aşırı kullanım/tekrarlayan stres
2. Yaralanma tarihi ve tedavi geçmişi → cerrahi var mı?
3. Mevcut rehabilitasyon fazı → akut/subakut/fonksiyonel/spora dönüş
4. Spor branşı ve seviyesi → amatör/profesyonel/elit
5. Sezon durumu → preseason/sezon içi/offseason → tedavi yoğunluğunu etkiler
6. Antrenman yükü toleransı → kaç saat/gün antrenman yapabiliyor?

KIRMIZI BAYRAKLAR (herhangi biri → "Lütfen acilen doktora gidin"):
- Eklemde ciddi instabilite, kemik çıkığı şüphesi
- Nörolojik belirti (uyuşma, güçsüzlük)
- Ciddi şişlik + ekimoz → tam kopma şüphesi
- Kompartman sendromu belirtileri

REHABİLİTASYON ÇIKTISI (tüm sorular sonrası):
---
**Sporcu Değerlendirmesi:** [2-3 cümle]
**Tahmini Faz:** [Akut/Subakut/Fonksiyonel/Spora Dönüş]
**Güven:** [En olası... / Muhtemelen... / Dışlanamaz...]

**Rehabilitasyon Programı:**
1. [egzersiz] — [nasıl yapılır] — [set/tekrar] — [video_id varsa]
2. [egzersiz] — [nasıl yapılır] — [set/tekrar]

**Spora Dönüş Tahmini:** [süre tahmini]

⚠️ Bu tıbbi teşhis değildir. Spor hekimi veya fizyoterapist gözetiminde uygulayın.
---`;

const PROFILE_LINE = `\nPROFİL: yaş={age} cinsiyet={gender} boy={height}cm kilo={weight}kg seviye={fitnessLevel} yaralanma={pastInjuries} hedef={goal}`;

const ATHLETE_PROFILE_LINE = `\nSPORCU PROFİLİ: yaş={age} cinsiyet={gender} branş={sport} seviye={fitnessLevel} yaralanma={injuryType} ameliyat={surgeryDate} faz={currentPhase} hedef={goal}`;

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

function buildSystemPrompt(profile, bodyArea, isFirstMessage) {
  const areaLabel = BODY_AREA_LABELS[bodyArea] ?? bodyArea;
  const isAthlete = profile.userType === 'athlete';

  let prompt = (isAthlete ? ATHLETE_PROMPT : BASE_PROMPT).replaceAll('{bodyArea}', areaLabel);

  // Profili sadece ilk mesajda ekle (~20 token tasarruf/mesaj)
  if (isFirstMessage) {
    if (isAthlete) {
      const profileText = ATHLETE_PROFILE_LINE
        .replace('{age}', _sanitize(profile.age))
        .replace('{gender}', _sanitize(profile.gender))
        .replace('{sport}', _sanitize(profile.sport ?? 'Belirtilmedi'))
        .replace('{fitnessLevel}', _sanitize(profile.fitnessLevel))
        .replace('{injuryType}', _sanitize(profile.injuryType ?? 'Belirtilmedi'))
        .replace('{surgeryDate}', _sanitize(profile.surgeryDate ?? 'Yok'))
        .replace('{currentPhase}', _sanitize(profile.currentPhase ?? 'Akut'))
        .replace('{goal}', _sanitize(profile.goal));
      prompt += '\n' + profileText;
    } else {
      const injuries = Array.isArray(profile.pastInjuries)
        ? profile.pastInjuries.map(_sanitize).join(', ')
        : 'None';

      const profileText = PROFILE_LINE
        .replace('{age}', _sanitize(profile.age))
        .replace('{gender}', _sanitize(profile.gender))
        .replace('{height}', _sanitize(profile.height))
        .replace('{weight}', _sanitize(profile.weight))
        .replace('{fitnessLevel}', _sanitize(profile.fitnessLevel))
        .replace('{pastInjuries}', injuries)
        .replace('{goal}', _sanitize(profile.goal));
      prompt += '\n' + profileText;
    }
  }

  return prompt;
}

// ─── Streaming Chat ───────────────────────────────────────────────────────────

async function streamChatResponse({ profile, bodyArea, messages, res }) {
  const isFirstMessage = messages.length <= 1;
  const systemPrompt = buildSystemPrompt(profile, bodyArea, isFirstMessage);
  const recentMessages = messages.slice(-MAX_HISTORY);
  const maxTokens = isFirstMessage ? MAX_TOKENS_SHORT : MAX_TOKENS_CHAT;

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('X-Accel-Buffering', 'no');
  res.flushHeaders();

  try {
    const stream = await client.chat.completions.create({
      model: MODEL,
      stream: true,
      messages: [
        { role: 'system', content: systemPrompt },
        ...recentMessages,
      ],
      max_tokens: maxTokens,
      temperature: MODEL_TEMPERATURE,
    });

    let totalTokens = 0;
    for await (const chunk of stream) {
      const delta = chunk.choices[0]?.delta?.content;
      if (delta) {
        res.write(`data: ${JSON.stringify({ content: delta })}\n\n`);
      }
      if (chunk.usage) totalTokens = chunk.usage.total_tokens;
    }

    if (totalTokens > 0) {
      logger.info('[Groq] stream tokens', { total: totalTokens, bodyArea, isFirstMessage });
    }

    res.write('data: [DONE]\n\n');
  } catch (err) {
    logger.error('[Groq] Streaming error', { message: err.message });
    res.write(`data: ${JSON.stringify({ error: err.message })}\n\n`);
  } finally {
    res.end();
  }
}

// ─── Non-Streaming Chat (for web clients) ────────────────────────────────────

async function getChatResponse({ profile, bodyArea, messages }) {
  const isFirstMessage = messages.length <= 1;
  const systemPrompt = buildSystemPrompt(profile, bodyArea, isFirstMessage);
  const recentMessages = messages.slice(-MAX_HISTORY);
  const maxTokens = isFirstMessage ? MAX_TOKENS_SHORT : MAX_TOKENS_CHAT;

  const completion = await client.chat.completions.create({
    model: MODEL,
    stream: false,
    messages: [
      { role: 'system', content: systemPrompt },
      ...recentMessages,
    ],
    max_tokens: maxTokens,
    temperature: MODEL_TEMPERATURE,
  });

  const usage = completion.usage;
  logger.info('[Groq] tokens', {
    prompt: usage?.prompt_tokens,
    completion: usage?.completion_tokens,
    total: usage?.total_tokens,
    bodyArea,
    isFirstMessage,
  });

  return completion.choices[0]?.message?.content ?? '';
}

module.exports = { streamChatResponse, getChatResponse, buildSystemPrompt };
