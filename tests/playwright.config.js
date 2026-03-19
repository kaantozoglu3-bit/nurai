// @ts-check
'use strict';

/** @type {import('@playwright/test').PlaywrightTestConfig} */
module.exports = {
  testDir: '.',
  testMatch: ['nurai.spec.js'],
  timeout: 90000,
  retries: 1,
  workers: 1, // sıralı çalış — Flutter web tek port

  use: {
    baseURL: 'http://localhost:8181',
    headless: false,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
    // Sistem Chrome kullan — Flutter CanvasKit için GPU gerekli
    channel: 'chrome',
    launchOptions: {
      args: [
        '--no-sandbox',
        '--enable-gpu',
        '--ignore-gpu-blocklist',
        '--enable-webgl',
        '--use-gl=desktop',
      ],
    },
  },

  reporter: [
    ['list'],
    ['json', { outputFile: 'logs/test_results.json' }],
    ['html', { outputFolder: 'logs/report', open: 'never' }],
  ],
};
