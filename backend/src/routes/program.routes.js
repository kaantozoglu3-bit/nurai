'use strict';

const express = require('express');
const authMiddleware = require('../middleware/auth.middleware');
const { generateProgramHandler } = require('../controllers/program.controller');

const router = express.Router();

// POST /api/v1/program/generate — requires Firebase auth
router.post('/generate', authMiddleware, generateProgramHandler);

module.exports = router;
