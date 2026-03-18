'use strict';

const express = require('express');
const router = express.Router();
const admin = require('../config/firebase');
const authMiddleware = require('../middleware/auth.middleware');

const db = admin.firestore();

/**
 * POST /api/v1/users/profile
 * Kullanıcı profil bilgilerini Firestore'a kaydeder (upsert).
 * Body: { age, gender, height_cm, weight_kg, fitness_level, past_injuries, other_injury, goal }
 */
router.post('/profile', authMiddleware, async (req, res) => {
  const uid = req.user.uid;
  const {
    age,
    gender,
    height_cm,
    weight_kg,
    fitness_level,
    past_injuries,
    other_injury,
    goal,
  } = req.body;

  const profileData = {
    uid,
    age: age ?? null,
    gender: gender ?? null,
    height_cm: height_cm ?? null,
    weight_kg: weight_kg ?? null,
    fitness_level: fitness_level ?? null,
    past_injuries: Array.isArray(past_injuries) ? past_injuries : [],
    other_injury: other_injury ?? null,
    goal: goal ?? null,
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  try {
    await db.collection('user_profiles').doc(uid).set(profileData, { merge: true });
    res.json({ success: true });
  } catch (err) {
    console.error('[UserRoutes] Firestore kayıt hatası:', err.message);
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
    const doc = await db.collection('user_profiles').doc(uid).get();
    if (!doc.exists) return res.status(404).json({ error: 'Profil bulunamadı.' });
    res.json({ profile: doc.data() });
  } catch (err) {
    console.error('[UserRoutes] Firestore okuma hatası:', err.message);
    res.status(500).json({ error: 'Profil okunamadı.' });
  }
});

module.exports = router;
