'use strict';

const OpenAI = require('openai');
const logger = require('../config/logger');

const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: 'https://api.groq.com/openai/v1',
});

const MODEL = 'llama-3.3-70b-versatile';
const MAX_TOKENS = 3500; // kompakt format: 4w×5d×3ex gerçek ölçüm ~2800 token
const TEMPERATURE = 0.3; // Low for structured JSON output

// ─── Input sanitisation ───────────────────────────────────────────────────────

const VALID_FITNESS_LEVELS = ['beginner', 'intermediate', 'advanced'];
const VALID_BODY_AREAS = new Set([
  'neck', 'left_shoulder', 'right_shoulder', 'upper_back', 'lower_back',
  'hip', 'left_knee', 'right_knee', 'left_elbow', 'right_elbow',
  'left_wrist', 'right_wrist', 'left_ankle', 'right_ankle', 'core', 'general',
]);

function _sanitizeArea(val) {
  const cleaned = String(val ?? '').slice(0, 60).replace(/[<>"'`]/g, '').trim();
  return VALID_BODY_AREAS.has(cleaned) ? cleaned : null;
}

// ─── Prompt ───────────────────────────────────────────────────────────────────

function _buildPrompt(targetAreas, avgPainScore, fitnessLevel) {
  const areasStr = targetAreas.map(_sanitizeArea).filter(Boolean).join(', ') || 'genel';
  const score = Math.max(1, Math.min(10, Number(avgPainScore) || 5));
  const level = VALID_FITNESS_LEVELS.includes(fitnessLevel) ? fitnessLevel : 'beginner';

  const intensity = score <= 3 ? 'light' : score <= 6 ? 'moderate' : 'gentle (high pain score)';

  return `Fizyoterapist. Bölge:${areasStr} Ağrı:${score}/10 Yoğunluk:${intensity} Seviye:${level}
4 hafta, 5 gün/hafta (Pzt-Cum), 3 egzersiz/gün.
H1:mobilizasyon H2:stabilite H3:güçlendirme H4:fonksiyonel
SADECE JSON döndür:
{"weeks":[{"weekNumber":1,"title":"Hafta adı","focus":"Odak","days":[{"dayNumber":1,"dayName":"Pazartesi","exercises":[{"name":"Türkçe ad","sets":"3x10","videoQuery":"english search term"}]}]}]}`;
}

// ─── JSON extraction ──────────────────────────────────────────────────────────

function _extractJson(text) {
  // Strip markdown fences if present
  const stripped = text.replace(/```json|```/g, '').trim();
  const match = stripped.match(/\{[\s\S]*\}/);
  if (!match) throw new Error('No JSON object found in AI response');
  return JSON.parse(match[0]);
}

// ─── Main export ──────────────────────────────────────────────────────────────

async function generateProgram(targetAreas, avgPainScore, fitnessLevel) {
  const prompt = _buildPrompt(targetAreas, avgPainScore, fitnessLevel);

  logger.info('[ProgramService] Generating 4-week program', {
    areas: targetAreas,
    painScore: avgPainScore,
    fitnessLevel,
  });

  const abort = new AbortController();
  const timeoutHandle = setTimeout(() => abort.abort(), 90_000);

  let response;
  try {
    response = await client.chat.completions.create(
      {
        model: MODEL,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: MAX_TOKENS,
        temperature: TEMPERATURE,
        response_format: { type: 'json_object' },
      },
      { signal: abort.signal },
    );
  } finally {
    clearTimeout(timeoutHandle);
  }

  const usage = response.usage;
  logger.info('[ProgramService] tokens', {
    prompt: usage?.prompt_tokens,
    completion: usage?.completion_tokens,
    total: usage?.total_tokens,
  });

  const content = response.choices[0]?.message?.content ?? '';

  let parsed;
  try {
    parsed = _extractJson(content);
  } catch (err) {
    logger.error('[ProgramService] JSON parse failed', { content: content.slice(0, 500) });
    throw new Error('AI yanıtı geçerli JSON içermiyor');
  }

  if (!Array.isArray(parsed.weeks) || parsed.weeks.length === 0) {
    throw new Error('AI yanıtında hafta verisi bulunamadı');
  }

  return parsed;
}

module.exports = { generateProgram };
