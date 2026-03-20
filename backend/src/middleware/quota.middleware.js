'use strict';

const admin = require('../config/firebase');
const logger = require('../config/logger');
const FirestorePaths = require('../config/firestore_paths');

const FREE_DAILY_LIMIT = parseInt(process.env.FREE_DAILY_LIMIT, 10) || 3;
const PREMIUM_DAILY_LIMIT = parseInt(process.env.PREMIUM_DAILY_LIMIT, 10) || 999;

/**
 * Server-side daily quota check — session ID based.
 *
 * Firestore path: dailyUsage/{uid}/days/{YYYY-MM-DD}
 *   → { count: N, sessions: ['uuid1', 'uuid2', ...] }
 *
 * Logic:
 *   - Client sends a `sessionId` (UUID v4) generated once per analysis session.
 *   - Same sessionId on subsequent messages in the same conversation → pass through.
 *   - New sessionId → check count against DAILY_LIMIT, block if exceeded.
 *   - Premium users (users/{uid}.premium === true) use PREMIUM_DAILY_LIMIT.
 *
 * This replaces the insecure `messages.length > 1` bypass that allowed
 * any client to skip quota by sending a pre-filled conversation history.
 */
async function quotaMiddleware(req, res, next) {
  const uid = req.user?.uid;
  if (!uid) return res.status(401).json({ error: 'Kimlik doğrulaması gerekli.' });

  const sessionId = req.body?.sessionId;

  // sessionId zorunlu — UUID v4 formatı zorunlu
  const UUID_V4_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  if (!sessionId || typeof sessionId !== 'string' || !UUID_V4_RE.test(sessionId)) {
    return res.status(400).json({ error: 'Geçerli bir oturum kimliği (sessionId) gereklidir.' });
  }

  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
  const docRef = admin.firestore().doc(FirestorePaths.dailyUsage(uid, today));

  try {
    // Check premium status from Firestore users collection
    const userDoc = await admin.firestore().collection('users').doc(uid).get();
    const isPremium = userDoc.exists && userDoc.data()?.premium === true;
    const DAILY_LIMIT = isPremium ? PREMIUM_DAILY_LIMIT : FREE_DAILY_LIMIT;

    const result = await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(docRef);
      const data = snap.exists ? snap.data() : { count: 0, sessions: [] };
      const sessions = Array.isArray(data.sessions) ? data.sessions : [];

      // Aynı oturum devam ediyor — quota saymadan geçir
      if (sessions.includes(sessionId)) {
        return { blocked: false, existing: true, count: data.count ?? 0 };
      }

      // Yeni oturum — limit kontrolü
      const count = data.count ?? 0;
      if (count >= DAILY_LIMIT) {
        return { blocked: true, count, isPremium };
      }

      // Yeni oturum, limit altında — kaydet
      tx.set(docRef, {
        count: count + 1,
        sessions: [...sessions, sessionId],
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return { blocked: false, existing: false, count: count + 1, isPremium };
    });

    if (result.blocked) {
      return res.status(429).json({
        error: 'Günlük analiz limitine ulaştınız.',
        detail: result.isPremium
          ? `Premium kullanıcılar günde ${PREMIUM_DAILY_LIMIT} analiz yapabilir.`
          : `Ücretsiz kullanıcılar günde ${FREE_DAILY_LIMIT} analiz yapabilir.`,
        remaining: 0,
      });
    }

    res.setHeader('X-Quota-Remaining', String(DAILY_LIMIT - result.count));
    next();
  } catch (err) {
    logger.error('[Quota] Firestore hatası', { message: err.message });
    return res.status(503).json({
      error: 'Servis geçici olarak kullanılamıyor. Lütfen tekrar deneyin.',
    });
  }
}

module.exports = quotaMiddleware;
