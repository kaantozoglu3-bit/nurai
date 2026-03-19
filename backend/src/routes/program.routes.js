'use strict';

const express = require('express');
const rateLimit = require('express-rate-limit');
const authMiddleware = require('../middleware/auth.middleware');
const { generateProgramHandler } = require('../controllers/program.controller');

const router = express.Router();

// Strict per-IP limiter for the expensive AI generation endpoint.
// 5 requests per hour prevents abuse while allowing normal usage.
const generateLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Program oluşturma limiti aşıldı. Lütfen 1 saat sonra tekrar deneyin.' },
});

// POST /api/v1/program/generate — requires Firebase auth
router.post('/generate', generateLimiter, authMiddleware, generateProgramHandler);

module.exports = router;
