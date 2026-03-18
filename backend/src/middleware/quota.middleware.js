'use strict';

const admin = require('../config/firebase');
const logger = require('../config/logger');

const DAILY_LIMIT = 3;

/**
 * Server-side daily quota check.
 * Firestore path: dailyUsage/{uid}/{YYYY-MM-DD}  →  { count: N }
 * Free users: max 3 analyses per day.
 * Returns 429 if limit exceeded, otherwise increments counter and calls next().
 */
async function quotaMiddleware(req, res, next) {
  const uid = req.user?.uid;
  if (!uid) return res.status(401).json({ error: 'Kimlik doğrulaması gerekli.' });

  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
  const docRef = admin.firestore().collection('dailyUsage').doc(uid).collection('days').doc(today);

  try {
    const result = await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(docRef);
      const current = snap.exists ? (snap.data().count ?? 0) : 0;

      if (current >= DAILY_LIMIT) {
        return { blocked: true, count: current };
      }

      tx.set(docRef, { count: current + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      return { blocked: false, count: current + 1 };
    });

    if (result.blocked) {
      return res.status(429).json({
        error: 'Günlük analiz limitine ulaştınız.',
        detail: `Ücretsiz kullanıcılar günde ${DAILY_LIMIT} analiz yapabilir.`,
        remaining: 0,
      });
    }

    res.setHeader('X-Quota-Remaining', String(DAILY_LIMIT - result.count));
    next();
  } catch (err) {
    logger.error('[Quota] Firestore hatası', { message: err.message });
    // Quota check başarısız olursa isteği engelleme, geçir
    next();
  }
}

module.exports = quotaMiddleware;
