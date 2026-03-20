'use strict';

const logger = require('../config/logger');
const { generateProgram } = require('../services/program.service');

/**
 * POST /api/v1/program/generate
 *
 * Body: {
 *   targetAreas: string[],   // e.g. ['neck', 'lower_back']
 *   avgPainScore: number,     // 1-10
 *   fitnessLevel: string,     // 'beginner' | 'intermediate' | 'advanced'
 * }
 *
 * Returns: { program: { weeks: [...] } }
 */
async function generateProgramHandler(req, res) {
  const uid = req.user?.uid;
  const { targetAreas, avgPainScore, fitnessLevel } = req.body;

  // Input validation
  if (!Array.isArray(targetAreas) || targetAreas.length === 0) {
    return res.status(400).json({ error: 'targetAreas array required.' });
  }
  if (typeof avgPainScore !== 'number' || avgPainScore < 1 || avgPainScore > 10) {
    return res.status(400).json({ error: 'avgPainScore must be a number between 1 and 10.' });
  }
  const VALID_FITNESS_LEVELS = ['beginner', 'intermediate', 'advanced'];
  if (!fitnessLevel || !VALID_FITNESS_LEVELS.includes(fitnessLevel)) {
    return res.status(400).json({
      error: `fitnessLevel must be one of: ${VALID_FITNESS_LEVELS.join(', ')}.`,
    });
  }

  logger.info('[ProgramController] Generate request', { uid, targetAreas, avgPainScore });

  try {
    const program = await generateProgram(targetAreas, avgPainScore, fitnessLevel);
    res.set('Cache-Control', 'no-store');
    return res.json({ program });
  } catch (err) {
    logger.error('[ProgramController] Generate failed', { uid, message: err.message });
    return res.status(500).json({ error: 'Program oluşturulurken hata oluştu. Lütfen tekrar deneyin.' });
  }
}

module.exports = { generateProgramHandler };
