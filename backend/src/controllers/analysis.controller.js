'use strict';

const Joi = require('joi');
const { streamChatResponse, getChatResponse } = require('../services/openai.service');
const logger = require('../config/logger');

const VALID_BODY_AREAS = [
  'neck', 'left_shoulder', 'right_shoulder', 'upper_back', 'lower_back',
  'hip', 'left_knee', 'right_knee', 'left_elbow', 'right_elbow',
  'left_wrist', 'right_wrist', 'left_ankle', 'right_ankle', 'core',
];

const messageSchema = Joi.object({
  role: Joi.string().valid('user', 'assistant', 'system').required(),
  content: Joi.string().max(2000).required(),
});

const profileSchema = Joi.object({
  age: Joi.alternatives().try(Joi.number().integer().min(1).max(120), Joi.string()).optional(),
  gender: Joi.string().max(20).optional(),
  height: Joi.alternatives().try(Joi.number(), Joi.string()).optional(),
  weight: Joi.alternatives().try(Joi.number(), Joi.string()).optional(),
  fitnessLevel: Joi.string().max(30).optional(),
  pastInjuries: Joi.array().items(Joi.string().max(100)).max(20).optional(),
  goal: Joi.string().max(200).optional(),
  displayName: Joi.string().max(100).optional(),
}).optional();

const chatSchema = Joi.object({
  bodyArea: Joi.string().valid(...VALID_BODY_AREAS).required(),
  messages: Joi.array().items(messageSchema).min(1).max(50).required(),
  profile: profileSchema,
  sessionId: Joi.string().uuid({ version: 'uuidv4' }).required(),
});

/**
 * POST /api/v1/analysis/chat
 * Streams SSE: data: {"content":"..."}\n\n  ...  data: [DONE]\n\n
 */
async function chat(req, res) {
  const { error, value } = chatSchema.validate(req.body, { stripUnknown: true });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  const { profile, bodyArea, messages } = value;
  try {
    await streamChatResponse({ profile: profile ?? {}, bodyArea, messages, res });
  } catch (err) {
    logger.error('[chat] Streaming error', { message: err.message });
    if (!res.headersSent) {
      res.status(500).json({ error: 'AI bağlantısı kurulamadı.' });
    }
  }
}

/**
 * POST /api/v1/analysis/chat-sync
 * Non-streaming endpoint for web clients.
 * Returns: { content: "full AI response" }
 */
async function chatSync(req, res) {
  const { error, value } = chatSchema.validate(req.body, { stripUnknown: true });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  const { profile, bodyArea, messages } = value;
  try {
    const content = await getChatResponse({ profile: profile ?? {}, bodyArea, messages });
    res.json({ content });
  } catch (err) {
    logger.error('[chatSync] error:', { message: err.message });
    res.status(500).json({ error: 'AI yanıtı alınamadı.' });
  }
}

module.exports = { chat, chatSync };
