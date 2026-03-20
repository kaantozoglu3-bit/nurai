'use strict';

const express = require('express');
const router = express.Router();
const Joi = require('joi');
const admin = require('../config/firebase');
const authMiddleware = require('../middleware/auth.middleware');
const logger = require('../config/logger');
const FirestorePaths = require('../config/firestore_paths');

const db = admin.firestore();

const profileSchema = Joi.object({
  age: Joi.number().integer().min(10).max(120).allow(null).optional(),
  gender: Joi.string().valid('male', 'female', 'other').allow(null).optional(),
  height_cm: Joi.number().min(50).max(300).allow(null).optional(),
  weight_kg: Joi.number().min(20).max(500).allow(null).optional(),
  fitness_level: Joi.string().valid('sedentary', 'light', 'moderate', 'active', 'very_active').allow(null).optional(),
  past_injuries: Joi.array().items(Joi.string().max(100)).max(20).optional(),
  other_injury: Joi.string().max(500).allow(null, '').optional(),
  goal: Joi.string().max(500).allow(null, '').optional(),
});

/**
 * POST /api/v1/users/profile
 * Kullanıcı profil bilgilerini Firestore'a kaydeder (upsert).
 * Body: { age, gender, height_cm, weight_kg, fitness_level, past_injuries, other_injury, goal }
 */
router.post('/profile', authMiddleware, async (req, res) => {
  const { error, value } = profileSchema.validate(req.body, { abortEarly: false, stripUnknown: true });
  if (error) {
    return res.status(400).json({
      error: 'Geçersiz profil verisi.',
      detail: error.details.map((d) => d.message),
    });
  }

  const uid = req.user.uid;
  const profileData = {
    uid,
    age: value.age ?? null,
    gender: value.gender ?? null,
    height_cm: value.height_cm ?? null,
    weight_kg: value.weight_kg ?? null,
    fitness_level: value.fitness_level ?? null,
    past_injuries: Array.isArray(value.past_injuries) ? value.past_injuries : [],
    other_injury: value.other_injury ?? null,
    goal: value.goal ?? null,
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  try {
    await db.doc(FirestorePaths.userProfile(uid)).set(profileData, { merge: true });
    res.json({ success: true });
  } catch (err) {
    logger.error('[UserRoutes] Firestore kayıt hatası', { message: err.message });
    res.status(500).json({ error: 'Profil kaydedilemedi.' });
  }
});

/**
 * GET /api/v1/users/profile
 * Firestore'dan kullanıcı profilini getirir.
 */
router.get('/profile', authMiddleware, async (req, res) => {
  const uid = req.user.uid;
  try {
    const doc = await db.doc(FirestorePaths.userProfile(uid)).get();
    if (!doc.exists) return res.status(404).json({ error: 'Profil bulunamadı.' });
    res.json({ profile: doc.data() });
  } catch (err) {
    logger.error('[UserRoutes] Firestore okuma hatası', { message: err.message });
    res.status(500).json({ error: 'Profil okunamadı.' });
  }
});

module.exports = router;
