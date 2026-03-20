'use strict';

/**
 * Rapor Ajanı — test_results.json okur, logs/hourly_report.md yazar.
 * Kullanım: node report.js
 */

const fs   = require('fs');
const path = require('path');

const RESULTS_PATH = path.join(__dirname, 'logs', 'test_results.json');
const REPORT_PATH  = path.join(__dirname, 'logs', 'hourly_report.md');

if (!fs.existsSync(RESULTS_PATH)) {
  console.error('test_results.json bulunamadı — önce testleri çalıştır.');
  process.exit(1);
}

const data  = JSON.parse(fs.readFileSync(RESULTS_PATH, 'utf8'));
const suites = data.suites ?? [];
const stats  = data.stats ?? {};

const passed = stats.expected ?? 0;
const failed = stats.unexpected ?? 0;
const total  = passed + failed;
const ts     = new Date().toLocaleString('tr-TR');

const lines = [];
lines.push(`# Nurai Otonom Test Raporu`);
lines.push(`**Zaman:** ${ts}`);
lines.push(`**Sonuç:** ${passed}/${total} geçti${failed > 0 ? ` — ⚠️ ${failed} başarısız` : ' — ✅ tümü başarılı'}`);
lines.push('');
lines.push('## Test Sonuçları');

// Her test case
for (const suite of suites) {
  for (const spec of (suite.specs ?? [])) {
    for (const test of (spec.tests ?? [])) {
      const ok     = test.results?.every(r => r.status === 'passed') ?? false;
      const icon   = ok ? '✅' : '❌';
      const title  = spec.title;
      lines.push(`- ${icon} ${title}`);
    }
  }
}

lines.push('');
lines.push('---');
lines.push(`*Oluşturan: Nurai Rapor Ajanı — ${ts}*`);

fs.writeFileSync(REPORT_PATH, lines.join('\n'), 'utf8');
console.log(`Rapor yazıldı: ${REPORT_PATH}`);
console.log(`${passed}/${total} test geçti`);
if (failed > 0) process.exit(1);
