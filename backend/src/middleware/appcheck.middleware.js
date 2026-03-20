'use strict';

const { getAppCheck } = require('firebase-admin/app-check');
const logger = require('../config/logger');

async function appCheckMiddleware(req, res, next) {
  // Skip in development
  if (process.env.NODE_ENV !== 'production') return next();

  const appCheckToken = req.headers['x-firebase-appcheck'];
  if (!appCheckToken) {
    logger.warn('[AppCheck] Missing X-Firebase-AppCheck header');
    return res.status(401).json({ error: 'App Check token required.' });
  }

  try {
    await getAppCheck().verifyToken(appCheckToken);
    return next();
  } catch (err) {
    logger.warn('[AppCheck] Invalid token', { message: err.message });
    return res.status(401).json({ error: 'Invalid App Check token.' });
  }
}

module.exports = appCheckMiddleware;
