'use strict';

const admin = require('firebase-admin');
const logger = require('./logger');

if (!admin.apps.length) {
  const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;

  if (!base64) {
    if (process.env.NODE_ENV === 'production') {
      throw new Error(
        '[Firebase] FIREBASE_SERVICE_ACCOUNT_BASE64 env var is required in production.'
      );
    }
    logger.warn(
      '[Firebase] FIREBASE_SERVICE_ACCOUNT_BASE64 is not set. ' +
      'Auth middleware will not work until this is configured.'
    );
    // Initialize without credentials so the app starts (dev mode only)
    admin.initializeApp({ projectId: 'painrelief-ai' });
  } else {
    const serviceAccount = JSON.parse(
      Buffer.from(base64, 'base64').toString('utf8')
    );
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }
}

module.exports = admin;
