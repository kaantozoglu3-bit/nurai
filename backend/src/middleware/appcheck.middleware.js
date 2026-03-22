'use strict';

const { getAppCheck } = require('firebase-admin/app-check');
const logger = require('../config/logger');

async function appCheckMiddleware(req, res, next) {
  // Skip in development
  if (process.env.NODE_ENV !== 'production') return next();

  const appCheckToken = req.headers['x-firebase-appcheck'];

  // APPCHECK_ENFORCE=true ile hard enforcement aktif olur.
  // Play Store yayınından sonra Railway env'e APPCHECK_ENFORCE=true ekle.
  const enforce = process.env.APPCHECK_ENFORCE === 'true';
  if (!appCheckToken) {
    if (enforce) {
      logger.warn('[AppCheck] Missing X-Firebase-AppCheck header — rejecting');
      return res.status(401).json({ error: 'App Check token gerekli.' });
    }
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
