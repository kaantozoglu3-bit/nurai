'use strict';

const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const { search } = require('../controllers/youtube.controller');

// GET /api/v1/youtube/search?bodyArea=right_shoulder
router.get('/search', authMiddleware, search);

module.exports = router;
