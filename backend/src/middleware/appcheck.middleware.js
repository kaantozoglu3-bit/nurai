'use strict';

const { getAppCheck } = require('firebase-admin/app-check');
const logger = require('../config/logger');

async function appCheckMiddleware(req, res, next) {
  // Skip in development
  if (process.env.NODE_ENV !== 'production') return next();

  const appCheckToken = req.headers['x-firebase-appcheck'];

  // Token yoksa geç — Play Integrity henüz yapılandırılmadı (MVP aşaması).
  // TODO: token yoksa da reddet — Play Store yayınından sonra etkinleştir.
  if (!appCheckToken) {
    logger.warn('[AppCheck] Missing X-Firebase-AppCheck header — passing (soft enforcement)');
    return next();
  }

  // Token varsa doğrula — geçersiz token kesinlikle reddet
  try {
    await getAppCheck().verifyToken(appCheckToken);
    return next();
  } catch (err) {
    logger.warn('[AppCheck] Invalid token', { message: err.message });
    return res.status(401).json({ error: 'Invalid App Check token.' });
  }
}

module.exports = appCheckMiddleware;
