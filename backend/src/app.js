'use strict';

require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const logger = require('./config/logger');
const appCheckMiddleware = require('./middleware/appcheck.middleware');
const analysisRoutes = require('./routes/analysis.routes');
const youtubeRoutes = require('./routes/youtube.routes');
const userRoutes = require('./routes/user.routes');
const programRoutes = require('./routes/program.routes');

const app = express();

// Trust Railway's reverse proxy so rate-limit sees real client IPs
app.set('trust proxy', 1);

// ─── Security ─────────────────────────────────────────────────────────────────
app.use(helmet());

const _configuredOrigins = (process.env.ALLOWED_ORIGINS ?? '').split(',').map(s => s.trim()).filter(Boolean);
const allowedOrigins = process.env.NODE_ENV === 'production'
  ? _configuredOrigins.length > 0
    ? _configuredOrigins
    : [process.env.ALLOWED_ORIGIN || 'https://nurai.app']
  : [
      ..._configuredOrigins,
      /^http:\/\/localhost(:\d+)?$/,
      process.env.ALLOWED_ORIGIN,
    ].filter(Boolean);

app.use(cors({
  origin: (origin, cb) => {
    // Allow requests with no origin (mobile apps, Postman)
    if (!origin) return cb(null, true);
    const allowed = allowedOrigins.some((o) =>
      o instanceof RegExp ? o.test(origin) : o === origin
    );
    if (allowed) return cb(null, true);
    cb(new Error(`CORS: origin ${origin} not allowed`));
  },
  credentials: true,
}));

// ─── App Check ────────────────────────────────────────────────────────────────
// Skipped in dev (NODE_ENV !== 'production'); enforced in production.
app.use('/api', appCheckMiddleware);

// ─── Rate limiting ────────────────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests. Please try again later.' },
});
app.use('/api', limiter);

// ─── Body parsing ─────────────────────────────────────────────────────────────
app.use(express.json({ limit: '16kb' }));

// ─── Logging ──────────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// ─── Health check ─────────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/api/v1/analysis', analysisRoutes);
app.use('/api/v1/youtube', youtubeRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/program', programRoutes);

// ─── 404 ──────────────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ error: 'Not found.' }));

// ─── Error handler ────────────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  logger.error('[App] Unhandled error', { message: err.message, stack: err.stack });
  res.status(500).json({ error: 'Internal server error.' });
});

module.exports = app;
