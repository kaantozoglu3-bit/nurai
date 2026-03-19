'use strict';

const OpenAI = require('openai');
const logger = require('../config/logger');

const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: 'https://api.groq.com/openai/v1',
});

const MODEL = 'llama-3.3-70b-versatile';
const MAX_TOKENS = 4000;
const TEMPERATURE = 0.3; // Low for structured JSON output

// ─── Input sanitisation ───────────────────────────────────────────────────────

const VALID_FITNESS_LEVELS = ['beginner', 'intermediate', 'advanced'];

function _sanitizeArea(val) {
  return String(val ?? '').slice(0, 60).replace(/[<>"'`]/g, '').trim();
}

// ─── Prompt ───────────────────────────────────────────────────────────────────

function _buildPrompt(targetAreas, avgPainScore, fitnessLevel) {
  const areasStr = targetAreas.map(_sanitizeArea).filter(Boolean).join(', ') || 'genel';
  const score = Math.max(1, Math.min(10, Number(avgPainScore) || 5));
  const level = VALID_FITNESS_LEVELS.includes(fitnessLevel) ? fitnessLevel : 'beginner';

  const intensity = score <= 3 ? 'light' : score <= 6 ? 'moderate' : 'gentle (high pain score)';

  return `You are a licensed physiotherapist. Generate a 4-week home rehabilitation exercise program.

TARGET AREAS: ${areasStr}
AVERAGE PAIN SCORE: ${score}/10 — use ${intensity} intensity
FITNESS LEVEL: ${level}

RULES:
- 4 weeks, 5 days per week (Monday to Friday)
- 3 to 5 exercises per day
- Week 1: gentle mobilisation, Week 2: stability, Week 3: strength, Week 4: functional training
- Each exercise: name (Turkish), sets (e.g. "3 set x 10 tekrar"), duration (e.g. "10 dakika"), description (max 2 Turkish sentences), videoQuery (English search term for YouTube)
- All text in Turkish EXCEPT videoQuery which must be in English
- Respond ONLY with valid JSON, no markdown, no explanation

JSON structure:
{
  "weeks": [
    {
      "weekNumber": 1,
      "title": "Hafta başlığı",
      "focus": "Odak noktası",
      "days": [
        {
          "dayNumber": 1,
          "dayName": "Pazartesi",
          "exercises": [
            {
              "name": "Egzersiz adı",
              "sets": "3 set x 10 tekrar",
              "duration": "10 dakika",
              "description": "Açıklama.",
              "videoQuery": "exercise name physiotherapy tutorial"
            }
          ]
        }
      ]
    }
  ]
}`;
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

  const response = await client.chat.completions.create({
    model: MODEL,
    messages: [{ role: 'user', content: prompt }],
    max_tokens: MAX_TOKENS,
    temperature: TEMPERATURE,
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
