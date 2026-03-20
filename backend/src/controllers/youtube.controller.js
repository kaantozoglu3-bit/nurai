'use strict';

const { searchVideos, searchVideosByExercises } = require('../services/youtube.service');
const logger = require('../config/logger');

/**
 * GET /api/v1/youtube/search?bodyArea=right_shoulder&exercises=egzersiz1|egzersiz2
 * If exercises param is provided, search by exercise names instead of body area.
 */
async function search(req, res) {
  const { bodyArea, exercises, q } = req.query;

  if (!bodyArea && !exercises) {
    return res.status(400).json({ error: 'bodyArea or exercises query param is required.' });
  }

  try {
    let videos;
    if (exercises) {
      const names = exercises.split('|').map((s) => s.trim()).filter(Boolean);
      videos = await searchVideosByExercises(names);
    } else {
      videos = await searchVideos(bodyArea, q);
    }
    res.set('Cache-Control', 'public, max-age=21600'); // 6 hours
    res.json({ videos });
  } catch (err) {
    logger.error('[YouTube] Search failed', { message: err.message });
    res.status(502).json({ error: 'YouTube search failed.', detail: err.message });
  }
}

module.exports = { search };
