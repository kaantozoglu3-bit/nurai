'use strict';

const Joi = require('joi');
const logger = require('../config/logger');
const { generateProgram } = require('../services/program.service');

const VALID_BODY_AREAS = [
  'neck', 'left_shoulder', 'right_shoulder', 'upper_back', 'lower_back',
  'hip', 'left_knee', 'right_knee', 'left_elbow', 'right_elbow',
  'left_wrist', 'right_wrist', 'left_ankle', 'right_ankle', 'core', 'general',
];

const programSchema = Joi.object({
  targetAreas: Joi.array()
    .items(Joi.string().valid(...VALID_BODY_AREAS))
    .min(1)
    .max(5)
    .required(),
  avgPainScore: Joi.number().min(1).max(10).required(),
  fitnessLevel: Joi.string().valid('beginner', 'intermediate', 'advanced').required(),
});

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

  const { error, value } = programSchema.validate(req.body, { stripUnknown: true });
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }

  const { targetAreas, avgPainScore, fitnessLevel } = value;

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
