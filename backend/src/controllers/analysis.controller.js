'use strict';

const { streamChatResponse, getChatResponse } = require('../services/openai.service');

/**
 * POST /api/v1/analysis/chat
 * Streams SSE: data: {"content":"..."}\n\n  ...  data: [DONE]\n\n
 */
async function chat(req, res) {
  const { profile, bodyArea, messages } = req.body;
  if (!bodyArea || !Array.isArray(messages)) {
    return res.status(400).json({ error: 'bodyArea and messages are required.' });
  }
  await streamChatResponse({ profile: profile ?? {}, bodyArea, messages, res });
}

/**
 * POST /api/v1/analysis/chat-sync
 * Non-streaming endpoint for web clients.
 * Returns: { content: "full AI response" }
 */
async function chatSync(req, res) {
  const { profile, bodyArea, messages } = req.body;
  if (!bodyArea || !Array.isArray(messages)) {
    return res.status(400).json({ error: 'bodyArea and messages are required.' });
  }
  try {
    const content = await getChatResponse({ profile: profile ?? {}, bodyArea, messages });
    res.json({ content });
  } catch (err) {
    console.error('[chatSync] error:', err.message);
    res.status(500).json({ error: 'AI yanıtı alınamadı.' });
  }
}

module.exports = { chat, chatSync };
