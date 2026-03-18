'use strict';

const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const { chat, chatSync } = require('../controllers/analysis.controller');

// POST /api/v1/analysis/chat  (SSE streaming — mobile)
router.post('/chat', authMiddleware, chat);

// POST /api/v1/analysis/chat-sync  (non-streaming — web)
router.post('/chat-sync', authMiddleware, chatSync);

module.exports = router;
