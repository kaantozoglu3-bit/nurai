'use strict';

require('dotenv').config();
require('./src/config/firebase'); // initialize Firebase Admin early

const app = require('./src/app');

const PORT = process.env.PORT ?? 3000;

// Beklenmedik hataları yakala — process'in kapanmasını önler
process.on('uncaughtException', (err) => {
  console.error('[server] Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason) => {
  console.error('[server] Unhandled Rejection:', reason);
});

app.listen(PORT, () => {
  console.log(`[server] PainRelief AI backend running on http://localhost:${PORT}`);
  console.log(`[server] Groq key:   ${process.env.GROQ_API_KEY ? 'set ✓' : 'NOT SET ✗'}`);
  console.log(`[server] Firebase:   ${process.env.FIREBASE_SERVICE_ACCOUNT_BASE64 ? 'set ✓' : 'NOT SET (dev mode)'}`);
  console.log('[server] Press Ctrl+C to stop.');
});
