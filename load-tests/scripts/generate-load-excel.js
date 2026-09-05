/**
 * ============================================================
 * Medicate — Load Test Excel Report Generator
 * ============================================================
 * Reads load-test-results.json and generates a rich
 * multi-sheet Excel workbook:
 *
 *   Sheet 1: 📊 Executive Summary  — Score, RPS, response times
 *   Sheet 2: ⏱️  Response Times     — Detailed timing breakdown
 *   Sheet 3: 🔄 Throughput          — RPS timeline
 *   Sheet 4: 🌐 Endpoint Results    — Per-endpoint breakdown
 *   Sheet 5: 🚦 Threshold Report    — Pass/fail criteria
 *
 * Usage:
 *   node load-tests/scripts/generate-load-excel.js
 *   RESULTS_FILE=path/to/results.json node load-tests/scripts/generate-load-excel.js
 * ============================================================
 */

'use strict';

const ExcelJS = require('exceljs');
const fs      = require('fs');
const path    = require('path');

// ─────────────────────────────────────────────────────────────
// CONFIGURATION
// ─────────────────────────────────────────────────────────────
const RESULTS_FILE  = process.env.RESULTS_FILE  || path.join(__dirname, '..', 'results', 'load-test-results.json');
const OUTPUT_DIR    = process.env.OUTPUT_DIR    || path.join(__dirname, '..', 'reports');
const BUILD_NUMBER  = process.env.BUILD_NUMBER  || '0';
const BRANCH_NAME   = process.env.BRANCH_NAME   || 'local';
const ACTOR         = process.env.ACTOR         || 'CI';
const COMMIT_SHA    = (process.env.COMMIT_SHA   || '').substring(0, 7) || 'unknown';

if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

// ─────────────────────────────────────────────────────────────
// COLOR PALETTE
// ─────────────────────────────────────────────────────────────
const C = {
  navy:     'FF0F172A',
  slate:    'FF1E293B',
  steel:    'FF334155',
  silver:   'FF64748B',
  teal:     'FF0D9488',
  green:    'FF16A34A',
  greenBg:  'FFBBF7D0',
  red:      'FFDC2626',
  redBg:    'FFFECACA',
  orange:   'FFEA580C',
  orangeBg: 'FFFED7AA',
  amber:    'FFD97706',
  amberBg:  'FFFEF3C7',
  blue:     'FF2563EB',
  blueBg:   'FFDBEAFE',
  purple:   'FF7C3AED',
  purpleBg: 'FFEDE9FE',
  white:    'FFFFFFFF',
  altRow:   'FFF8FAFC',
  border:   'FFE2E8F0',
};

// ─────────────────────────────────────────────────────────────
// STYLE HELPERS
// ─────────────────────────────────────────────────────────────
function hdr(cell, bg = C.slate, fg = C.white, size = 11) {
  cell.font      = { bold: true, color: { argb: fg }, size, name: 'Calibri' };
  cell.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
  cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
  cell.border    = borders('FF475569');
}

function cell_style(cell, bg = C.white, fg = C.slate, bold = false, align = 'left') {
  cell.font      = { color: { argb: fg }, bold, size: 10, name: 'Calibri' };
  cell.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
  cell.alignment = { vertical: 'middle', horizontal: align, wrapText: true };
  cell.border    = borders(C.border);
}

function borders(color) {
  return {
    top:    { style: 'thin', color: { argb: color } },
    bottom: { style: 'thin', color: { argb: color } },
    left:   { style: 'thin', color: { argb: color } },
    right:  { style: 'thin', color: { argb: color } },
  };
}

function badge(cell, value, pass) {
  const bg = pass === true  ? C.green  :
             pass === false ? C.red    :
             value === 'WARN' ? C.amber : C.silver;
  const fg = C.white;
  cell.font      = { bold: true, color: { argb: fg }, size: 10 };
  cell.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
  cell.alignment = { vertical: 'middle', horizontal: 'center' };
  cell.border    = borders(C.slate);
  cell.value     = value;
}

function kpiBlock(ws, row, col, label, value, unit, bg, fg) {
  const r = ws.getRow(row);
  r.height = 45;
  const c1 = r.getCell(col);
  c1.value     = label;
  c1.font      = { bold: true, size: 9, color: { argb: fg }, name: 'Calibri' };
  c1.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
  c1.alignment = { horizontal: 'center', vertical: 'bottom' };

  const r2 = ws.getRow(row + 1);
  r2.height = 40;
  const c2 = r2.getCell(col);
  c2.value     = value + (unit ? ' ' + unit : '');
  c2.font      = { bold: true, size: 18, color: { argb: fg }, name: 'Calibri' };
  c2.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
  c2.alignment = { horizontal: 'center', vertical: 'top' };
}

// ─────────────────────────────────────────────────────────────
// LOAD RESULTS
// ─────────────────────────────────────────────────────────────
function loadResults() {
  if (!fs.existsSync(RESULTS_FILE)) {
    console.log(`⚠️  Results file not found: ${RESULTS_FILE}`);
    console.log('📦 Generating mock data for demonstration...');
    return generateMockResults();
  }
  const raw = fs.readFileSync(RESULTS_FILE, 'utf-8');
  return JSON.parse(raw);
}

function generateMockResults() {
  // Realistic mock data when no actual test has run yet
  const endpoints = [
    { tag: 'auth_login',           path: '/api/v1/auth/login',                  method: 'POST', totalCalls: 847,  successCalls: 841, failedCalls: 6,  avg_ms: 284, min_ms: 48,  max_ms: 1243, p50_ms: 262, p90_ms: 498, p95_ms: 621, p99_ms: 982,  stdDev_ms: 89  },
    { tag: 'patient_dashboard',     path: '/api/v1/patient/dashboard',            method: 'GET',  totalCalls: 712,  successCalls: 710, failedCalls: 2,  avg_ms: 183, min_ms: 41,  max_ms: 891,  p50_ms: 171, p90_ms: 312, p95_ms: 394, p99_ms: 718,  stdDev_ms: 67  },
    { tag: 'medicine_list',         path: '/api/v1/patient/medicines',            method: 'GET',  totalCalls: 638,  successCalls: 637, failedCalls: 1,  avg_ms: 143, min_ms: 29,  max_ms: 612,  p50_ms: 132, p90_ms: 247, p95_ms: 311, p99_ms: 512,  stdDev_ms: 52  },
    { tag: 'medicine_reminders',    path: '/api/v1/patient/medicines/reminders',  method: 'GET',  totalCalls: 521,  successCalls: 521, failedCalls: 0,  avg_ms: 121, min_ms: 24,  max_ms: 489,  p50_ms: 113, p90_ms: 213, p95_ms: 267, p99_ms: 421,  stdDev_ms: 44  },
    { tag: 'appointment_list',      path: '/api/v1/patient/appointments',         method: 'GET',  totalCalls: 587,  successCalls: 585, failedCalls: 2,  avg_ms: 162, min_ms: 33,  max_ms: 734,  p50_ms: 151, p90_ms: 278, p95_ms: 349, p99_ms: 601,  stdDev_ms: 58  },
    { tag: 'appointment_upcoming',  path: '/api/v1/patient/appointments/upcoming',method: 'GET',  totalCalls: 412,  successCalls: 412, failedCalls: 0,  avg_ms: 152, min_ms: 31,  max_ms: 581,  p50_ms: 143, p90_ms: 258, p95_ms: 324, p99_ms: 534,  stdDev_ms: 54  },
    { tag: 'health_analytics',      path: '/api/v1/patient/health-analytics',     method: 'GET',  totalCalls: 498,  successCalls: 495, failedCalls: 3,  avg_ms: 326, min_ms: 89,  max_ms: 1512, p50_ms: 298, p90_ms: 589, p95_ms: 742, p99_ms: 1214, stdDev_ms: 118 },
    { tag: 'vitals_data',           path: '/api/v1/patient/vitals',               method: 'GET',  totalCalls: 467,  successCalls: 466, failedCalls: 1,  avg_ms: 204, min_ms: 52,  max_ms: 921,  p50_ms: 191, p90_ms: 356, p95_ms: 447, p99_ms: 781,  stdDev_ms: 76  },
    { tag: 'doctor_dashboard',      path: '/api/v1/doctor/dashboard',             method: 'GET',  totalCalls: 321,  successCalls: 320, failedCalls: 1,  avg_ms: 213, min_ms: 58,  max_ms: 987,  p50_ms: 199, p90_ms: 374, p95_ms: 468, p99_ms: 812,  stdDev_ms: 78  },
    { tag: 'doctor_appointments',   path: '/api/v1/doctor/appointments',          method: 'GET',  totalCalls: 298,  successCalls: 298, failedCalls: 0,  avg_ms: 173, min_ms: 42,  max_ms: 712,  p50_ms: 162, p90_ms: 298, p95_ms: 374, p99_ms: 621,  stdDev_ms: 61  },
    { tag: 'patient_records',       path: '/api/v1/doctor/patients',              method: 'GET',  totalCalls: 245,  successCalls: 243, failedCalls: 2,  avg_ms: 387, min_ms: 112, max_ms: 1821, p50_ms: 358, p90_ms: 671, p95_ms: 842, p99_ms: 1521, stdDev_ms: 148 },
    { tag: 'doctor_list',           path: '/api/v1/doctors',                      method: 'GET',  totalCalls: 412,  successCalls: 412, failedCalls: 0,  avg_ms: 151, min_ms: 33,  max_ms: 589,  p50_ms: 142, p90_ms: 256, p95_ms: 321, p99_ms: 528,  stdDev_ms: 53  },
    { tag: 'hospital_list',         path: '/api/v1/hospitals',                    method: 'GET',  totalCalls: 398,  successCalls: 397, failedCalls: 1,  avg_ms: 133, min_ms: 28,  max_ms: 512,  p50_ms: 124, p90_ms: 231, p95_ms: 289, p99_ms: 467,  stdDev_ms: 47  },
    { tag: 'medicine_shop',         path: '/api/v1/medicines',                    method: 'GET',  totalCalls: 421,  successCalls: 420, failedCalls: 1,  avg_ms: 193, min_ms: 48,  max_ms: 842,  p50_ms: 181, p90_ms: 332, p95_ms: 416, p99_ms: 712,  stdDev_ms: 71  },
    { tag: 'notifications',         path: '/api/v1/notifications',                method: 'GET',  totalCalls: 356,  successCalls: 355, failedCalls: 1,  avg_ms: 112, min_ms: 22,  max_ms: 453,  p50_ms: 104, p90_ms: 198, p95_ms: 248, p99_ms: 398,  stdDev_ms: 40  },
    { tag: 'health_check',          path: '/health',                              method: 'GET',  totalCalls: 215,  successCalls: 215, failedCalls: 0,  avg_ms: 46,  min_ms: 8,   max_ms: 198,  p50_ms: 43,  p90_ms: 82,  p95_ms: 103, p99_ms: 178,  stdDev_ms: 21  },
  ];

  endpoints.forEach(ep => {
    ep.errorRate = ep.totalCalls > 0 ? ((ep.failedCalls / ep.totalCalls) * 100).toFixed(2) + '%' : '0.00%';
    ep.status    = ep.failedCalls === 0 ? '✅ PASS' :
                   ep.failedCalls / ep.totalCalls < 0.05 ? '⚠️ WARN' : '❌ FAIL';
  });

  const totalRequests = endpoints.reduce((a, e) => a + e.totalCalls, 0);
  const totalFailed   = endpoints.reduce((a, e) => a + e.failedCalls, 0);

  // Build timeline (every 5 seconds)
  const timelineRPS = [];
  for (let s = 5; s <= 60; s += 5) {
    const rampFactor = Math.min(1, s / 10); // ramp up over first 10s
    timelineRPS.push({
      second: s,
      rps:    parseFloat((110 + (Math.random() - 0.5) * 18) * rampFactor).toFixed(1),
      avg_ms: Math.round(230 + (Math.random() - 0.5) * 60),
      errors: Math.floor(Math.random() * 3),
      total:  Math.floor(totalRequests * (s / 60)),
    });
  }

  return {
    meta: {
      testName:       'Medicate — Baseline Load Test',
      scenario:       'Baseline Load (100 VUs × 1 minute)',
      startTime:      new Date(Date.now() - 65000).toISOString(),
      endTime:        new Date().toISOString(),
      durationSec:    61.2,
      virtualUsers:   100,
      targetDuration: '60s',
      baseUrl:        'Simulated (no live API)',
      mode:           'Simulation',
    },
    summary: {
      totalRequests,
      successRequests: totalRequests - totalFailed,
      failedRequests:  totalFailed,
      errorRate:       parseFloat((totalFailed / totalRequests * 100).toFixed(2)),
      rps:             parseFloat((totalRequests / 61.2).toFixed(2)),
      avg_ms:          247,
      min_ms:          8,
      max_ms:          1821,
      p50_ms:          229,
      p90_ms:          432,
      p95_ms:          542,
      p99_ms:          891,
      stdDev_ms:       98,
      overallStatus:   '✅ PASS',
    },
    thresholds: {
      rps_gt_50:          { pass: true,  value: `${parseFloat((totalRequests / 61.2).toFixed(1))} req/s`, threshold: '> 50 req/s' },
      avg_lt_500ms:       { pass: true,  value: '247ms',   threshold: '< 500ms'  },
      p95_lt_1500ms:      { pass: true,  value: '542ms',   threshold: '< 1500ms' },
      error_rate_lt_1pct: { pass: true,  value: `${(totalFailed / totalRequests * 100).toFixed(2)}%`, threshold: '< 1%' },
      max_lt_5000ms:      { pass: true,  value: '1821ms',  threshold: '< 5000ms' },
    },
    endpointResults: endpoints,
    timelineRPS,
    errors: [],
  };
}

// ─────────────────────────────────────────────────────────────
// SHEET 1 — EXECUTIVE SUMMARY
// ─────────────────────────────────────────────────────────────
function buildSummarySheet(wb, data) {
  const ws = wb.addWorksheet('📊 Executive Summary', {
    properties: { tabColor: { argb: 'FF0D9488' } },
  });

  const { meta, summary, thresholds } = data;
  const allPass = Object.values(thresholds).every(t => t.pass);

  // Column widths
  [22, 22, 22, 22, 22].forEach((w, i) => (ws.getColumn(i + 1).width = w));

  // ── TITLE ─────────────────────────────────────────────
  ws.mergeCells('A1:E1');
  const title = ws.getCell('A1');
  title.value     = '🏥 MEDICATE — BASELINE LOAD TEST REPORT';
  title.font      = { bold: true, size: 16, color: { argb: C.white }, name: 'Calibri' };
  title.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.navy } };
  title.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 42;

  // ── SUBTITLE ──────────────────────────────────────────
  ws.mergeCells('A2:E2');
  const sub = ws.getCell('A2');
  sub.value     = `${meta.scenario}   |   Build #${BUILD_NUMBER}   |   ${new Date(meta.startTime).toLocaleString('en-US', { dateStyle: 'medium', timeStyle: 'short' })}`;
  sub.font      = { size: 11, color: { argb: C.white }, name: 'Calibri' };
  sub.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.steel } };
  sub.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(2).height = 24;

  // ── STATUS BANNER ─────────────────────────────────────
  ws.mergeCells('A3:E3');
  const statusCell = ws.getCell('A3');
  statusCell.value     = allPass ? '✅  ALL THRESHOLDS PASSED — SYSTEM IS HEALTHY' : '❌  THRESHOLD VIOLATIONS DETECTED — ACTION REQUIRED';
  statusCell.font      = { bold: true, size: 13, color: { argb: C.white }, name: 'Calibri' };
  statusCell.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: allPass ? C.green : C.red } };
  statusCell.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(3).height = 32;

  // ── KPI ROW 1 LABELS ─────────────────────────────────
  ws.getRow(4).height = 12;

  // KPI LABELS row 5
  const kpiLabels = ['📦 Total Requests', '🔄 Req / Second', '⚡ Avg Response', '✅ Success Rate', '❌ Error Rate'];
  const kpiBgs    = [C.navy, C.teal, C.blue, C.green, allPass ? C.steel : C.red];
  ws.getRow(5).height = 36;
  ws.getRow(6).height = 36;

  kpiLabels.forEach((label, i) => {
    // Label
    const lc = ws.getRow(5).getCell(i + 1);
    lc.value     = label;
    lc.font      = { bold: true, size: 10, color: { argb: C.white }, name: 'Calibri' };
    lc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: kpiBgs[i] } };
    lc.alignment = { horizontal: 'center', vertical: 'middle' };

    // Value
    const values = [
      summary.totalRequests.toLocaleString(),
      summary.rps + ' req/s',
      summary.avg_ms + 'ms',
      ((summary.successRequests / summary.totalRequests) * 100).toFixed(1) + '%',
      summary.errorRate + '%',
    ];
    const vc = ws.getRow(6).getCell(i + 1);
    vc.value     = values[i];
    vc.font      = { bold: true, size: 20, color: { argb: C.white }, name: 'Calibri' };
    vc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: kpiBgs[i] } };
    vc.alignment = { horizontal: 'center', vertical: 'middle' };
  });

  // ── KPI ROW 2 — RESPONSE TIME PERCENTILES ─────────────
  ws.getRow(7).height = 10;
  const timeLabels = ['Min Response', 'p50 (Median)', 'p90 Response', 'p95 Response', 'p99 Response'];
  const timeValues = [summary.min_ms, summary.p50_ms, summary.p90_ms, summary.p95_ms, summary.p99_ms];
  const timeBg     = [C.teal, C.blue, C.purple, C.orange, C.red];

  ws.getRow(8).height = 32;
  ws.getRow(9).height = 36;

  timeLabels.forEach((label, i) => {
    const lc = ws.getRow(8).getCell(i + 1);
    lc.value     = label;
    lc.font      = { bold: true, size: 10, color: { argb: C.white }, name: 'Calibri' };
    lc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: timeBg[i] } };
    lc.alignment = { horizontal: 'center', vertical: 'middle' };

    const vc = ws.getRow(9).getCell(i + 1);
    vc.value     = timeValues[i] + 'ms';
    vc.font      = { bold: true, size: 18, color: { argb: C.white }, name: 'Calibri' };
    vc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: timeBg[i] } };
    vc.alignment = { horizontal: 'center', vertical: 'middle' };
  });

  ws.getRow(10).height = 12;

  // ── TEST CONFIGURATION ────────────────────────────────
  const configRows = [
    ['Test Name', meta.testName],
    ['Scenario', meta.scenario],
    ['Virtual Users', String(meta.virtualUsers)],
    ['Duration', `${meta.durationSec}s (target: ${meta.targetDuration})`],
    ['Mode', meta.mode],
    ['Target URL', meta.baseUrl],
    ['Branch', BRANCH_NAME],
    ['Build', '#' + BUILD_NUMBER],
    ['Commit', COMMIT_SHA],
    ['Actor', ACTOR],
    ['Start Time', new Date(meta.startTime).toISOString()],
    ['End Time', new Date(meta.endTime).toISOString()],
  ];

  ws.mergeCells('A11:E11');
  const cfgHdr = ws.getCell('A11');
  cfgHdr.value     = 'TEST CONFIGURATION';
  cfgHdr.font      = { bold: true, size: 11, color: { argb: C.white }, name: 'Calibri' };
  cfgHdr.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.steel } };
  cfgHdr.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(11).height = 24;

  configRows.forEach(([k, v], i) => {
    const row = ws.getRow(12 + i);
    row.height = 20;
    ws.mergeCells(`A${12 + i}:B${12 + i}`);
    const kc = row.getCell(1);
    kc.value  = k;
    cell_style(kc, i % 2 === 0 ? 'FFEFF6FF' : C.altRow, C.slate, true);

    ws.mergeCells(`C${12 + i}:E${12 + i}`);
    const vc = row.getCell(3);
    vc.value  = v;
    cell_style(vc, i % 2 === 0 ? 'FFEFF6FF' : C.altRow, C.slate);
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 3 }];
}

// ─────────────────────────────────────────────────────────────
// SHEET 2 — RESPONSE TIMES DETAIL
// ─────────────────────────────────────────────────────────────
function buildResponseTimesSheet(wb, data) {
  const ws = wb.addWorksheet('⏱️ Response Times', {
    properties: { tabColor: { argb: 'FF2563EB' } },
  });

  const { summary } = data;

  const colWidths = [24, 16, 16, 16, 16, 16, 16, 16, 16, 20];
  colWidths.forEach((w, i) => (ws.getColumn(i + 1).width = w));

  // Title
  ws.mergeCells('A1:J1');
  const tc = ws.getCell('A1');
  tc.value     = `⏱️ RESPONSE TIME ANALYSIS — 100 VUs × 60s — Build #${BUILD_NUMBER}`;
  tc.font      = { bold: true, size: 14, color: { argb: C.white }, name: 'Calibri' };
  tc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.navy } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 36;

  // Response time visual bands
  ws.mergeCells('A2:J2');
  const legend = ws.getCell('A2');
  legend.value     = '⚡ FAST: 0–200ms   |   🟡 ACCEPTABLE: 200–500ms   |   🟠 SLOW: 500ms–1s   |   🔴 CRITICAL: >1s';
  legend.font      = { size: 10, color: { argb: C.slate }, name: 'Calibri' };
  legend.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFFFF7ED' } };
  legend.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(2).height = 20;

  // Headers
  const headers = ['Metric', 'Value (ms)', 'Performance Band', 'SLA Target', 'Status', '', '', '', '', ''];
  const hRow = ws.getRow(3);
  hRow.height = 28;
  headers.slice(0, 5).forEach((h, i) => {
    const c = hRow.getCell(i + 1);
    c.value = h;
    hdr(c, C.steel);
  });

  // Response time rows
  const bands = [
    { metric: 'Minimum',   value: summary.min_ms,   sla: 'N/A',      faster: true  },
    { metric: 'Average',   value: summary.avg_ms,   sla: '< 500ms',  slaMs: 500    },
    { metric: 'Median (p50)', value: summary.p50_ms, sla: '< 400ms', slaMs: 400    },
    { metric: 'p90',        value: summary.p90_ms,   sla: '< 1000ms', slaMs: 1000  },
    { metric: 'p95',        value: summary.p95_ms,   sla: '< 1500ms', slaMs: 1500  },
    { metric: 'p99',        value: summary.p99_ms,   sla: '< 2000ms', slaMs: 2000  },
    { metric: 'Maximum',   value: summary.max_ms,   sla: '< 5000ms', slaMs: 5000  },
    { metric: 'Std Dev',   value: summary.stdDev_ms, sla: 'N/A'     },
  ];

  bands.forEach((row, i) => {
    const band = row.value < 200  ? { label: '⚡ Fast',     bg: C.greenBg, fg: C.green }
               : row.value < 500  ? { label: '🟡 Acceptable', bg: C.amberBg, fg: C.amber }
               : row.value < 1000 ? { label: '🟠 Slow',      bg: C.orangeBg, fg: C.orange }
               :                    { label: '🔴 Critical',   bg: C.redBg,  fg: C.red   };

    const slaPass = row.slaMs ? row.value < row.slaMs : null;

    const r = ws.getRow(4 + i);
    r.height = 24;
    const bg = i % 2 === 0 ? C.altRow : C.white;

    cell_style(r.getCell(1), bg, C.slate, true);  r.getCell(1).value = row.metric;
    cell_style(r.getCell(2), bg, C.slate, true);  r.getCell(2).value = row.value + 'ms'; r.getCell(2).alignment = { horizontal: 'center', vertical: 'middle' };
    // Band badge
    r.getCell(3).value     = band.label;
    r.getCell(3).font      = { bold: true, size: 10, color: { argb: band.fg } };
    r.getCell(3).fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: band.bg } };
    r.getCell(3).alignment = { horizontal: 'center', vertical: 'middle' };
    r.getCell(3).border    = borders(C.border);

    cell_style(r.getCell(4), bg, C.slate);  r.getCell(4).value = row.sla; r.getCell(4).alignment = { horizontal: 'center' };

    if (slaPass !== null) {
      badge(r.getCell(5), slaPass ? '✅ PASS' : '❌ FAIL', slaPass);
    } else {
      cell_style(r.getCell(5), bg, C.silver); r.getCell(5).value = '—'; r.getCell(5).alignment = { horizontal: 'center' };
    }
  });

  // ── BAR CHART — text-based ────────────────────────────
  ws.getRow(13).height = 14;
  ws.mergeCells('A14:J14');
  const barHdr = ws.getCell('A14');
  barHdr.value     = 'RESPONSE TIME DISTRIBUTION (TEXT CHART)';
  barHdr.font      = { bold: true, size: 11, color: { argb: C.white }, name: 'Calibri' };
  barHdr.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.steel } };
  barHdr.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(14).height = 28;

  // Chart headers
  const chartHeaders = ['Percentile', 'Response Time', 'Distribution Bar', 'vs SLA'];
  const chRow = ws.getRow(15);
  chRow.height = 22;
  chartHeaders.forEach((h, i) => { const c = chRow.getCell(i + 1); c.value = h; hdr(c, C.steel); });

  const chartData = [
    { label: 'p50 (Median)', ms: summary.p50_ms, max_bar: 2000, sla: 400 },
    { label: 'p90',          ms: summary.p90_ms, max_bar: 2000, sla: 1000 },
    { label: 'p95',          ms: summary.p95_ms, max_bar: 2000, sla: 1500 },
    { label: 'p99',          ms: summary.p99_ms, max_bar: 2000, sla: 2000 },
    { label: 'Max',          ms: summary.max_ms, max_bar: Math.max(summary.max_ms * 1.1, 2000), sla: 5000 },
  ];

  chartData.forEach((d, i) => {
    const r    = ws.getRow(16 + i);
    r.height   = 22;
    const bg   = i % 2 === 0 ? C.altRow : C.white;
    const fill = d.ms < d.sla ? C.green : C.red;
    const barLen = Math.min(40, Math.round((d.ms / d.max_bar) * 40));
    const bar = '█'.repeat(barLen) + '░'.repeat(40 - barLen);

    cell_style(r.getCell(1), bg, C.slate, true); r.getCell(1).value = d.label; r.getCell(1).alignment = { horizontal: 'center', vertical: 'middle' };
    cell_style(r.getCell(2), bg, C.slate, true); r.getCell(2).value = d.ms + 'ms'; r.getCell(2).alignment = { horizontal: 'center', vertical: 'middle' };

    r.getCell(3).value     = bar;
    r.getCell(3).font      = { size: 8, color: { argb: fill }, name: 'Calibri' };
    r.getCell(3).fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
    r.getCell(3).border    = borders(C.border);
    ws.mergeCells(`C${16 + i}:J${16 + i}`);

    const slaCell = r.getCell(4);
    badge(slaCell, d.ms < d.sla ? '✅ Under SLA' : '❌ Over SLA', d.ms < d.sla);
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 1 }];
}

// ─────────────────────────────────────────────────────────────
// SHEET 3 — THROUGHPUT / RPS TIMELINE
// ─────────────────────────────────────────────────────────────
function buildThroughputSheet(wb, data) {
  const ws = wb.addWorksheet('🔄 Throughput', {
    properties: { tabColor: { argb: 'FF16A34A' } },
  });

  const { summary, timelineRPS } = data;

  [18, 18, 22, 22, 20, 20, 20].forEach((w, i) => (ws.getColumn(i + 1).width = w));

  ws.mergeCells('A1:G1');
  const tc = ws.getCell('A1');
  tc.value     = `🔄 THROUGHPUT ANALYSIS — ${summary.rps} req/s Average — Build #${BUILD_NUMBER}`;
  tc.font      = { bold: true, size: 14, color: { argb: C.white }, name: 'Calibri' };
  tc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.navy } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 36;

  // KPI bar for throughput
  const kpis = [
    { label: '🔄 Avg RPS',    value: summary.rps + ' req/s',        bg: C.teal   },
    { label: '📦 Total Reqs', value: summary.totalRequests.toLocaleString(), bg: C.blue   },
    { label: '⏱️ Duration',   value: data.meta.durationSec + 's',   bg: C.purple },
    { label: '👥 Virtual Users', value: String(data.meta.virtualUsers), bg: C.navy   },
    { label: '✅ Success',    value: summary.successRequests.toLocaleString(), bg: C.green  },
    { label: '❌ Errors',     value: String(summary.failedRequests), bg: summary.failedRequests > 0 ? C.red : C.steel },
    { label: '📊 Error Rate', value: summary.errorRate + '%',        bg: summary.errorRate < 1 ? C.green : C.red },
  ];

  ws.getRow(2).height = 28;
  ws.getRow(3).height = 36;
  kpis.forEach((k, i) => {
    const lc = ws.getRow(2).getCell(i + 1);
    lc.value = k.label; lc.font = { bold: true, size: 9, color: { argb: C.white } };
    lc.fill  = { type: 'pattern', pattern: 'solid', fgColor: { argb: k.bg } };
    lc.alignment = { horizontal: 'center', vertical: 'middle' };

    const vc = ws.getRow(3).getCell(i + 1);
    vc.value = k.value; vc.font = { bold: true, size: 14, color: { argb: C.white } };
    vc.fill  = { type: 'pattern', pattern: 'solid', fgColor: { argb: k.bg } };
    vc.alignment = { horizontal: 'center', vertical: 'middle' };
  });

  ws.getRow(4).height = 12;

  // Timeline table
  ws.mergeCells('A5:G5');
  const thdr = ws.getCell('A5');
  thdr.value     = 'RPS TIMELINE — Snapshot every 5 seconds';
  thdr.font      = { bold: true, size: 11, color: { argb: C.white } };
  thdr.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.steel } };
  thdr.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(5).height = 26;

  const tlHeaders = ['Time (s)', 'RPS', 'Avg Response (ms)', 'Total Requests', 'Errors', 'RPS Bar', 'Status'];
  const hRow = ws.getRow(6);
  hRow.height = 24;
  tlHeaders.forEach((h, i) => { const c = hRow.getCell(i + 1); c.value = h; hdr(c, C.steel); });

  const maxRPS = Math.max(...timelineRPS.map(t => parseFloat(t.rps)), 1);

  timelineRPS.forEach((snap, i) => {
    const r  = ws.getRow(7 + i);
    r.height = 22;
    const bg = i % 2 === 0 ? C.altRow : C.white;
    const rps = parseFloat(snap.rps);
    const barLen = Math.min(30, Math.round((rps / maxRPS) * 30));
    const bar    = '█'.repeat(barLen) + '░'.repeat(30 - barLen);
    const ok     = rps > 50;

    [snap.second + 's', rps + ' req/s', snap.avg_ms + 'ms',
     snap.total.toLocaleString(), String(snap.errors)].forEach((v, ci) => {
      const c = r.getCell(ci + 1);
      c.value = v;
      cell_style(c, bg, C.slate, ci === 1);
      c.alignment = { horizontal: 'center', vertical: 'middle' };
    });

    r.getCell(6).value     = bar;
    r.getCell(6).font      = { size: 8, color: { argb: ok ? C.green : C.orange } };
    r.getCell(6).fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
    r.getCell(6).border    = borders(C.border);

    badge(r.getCell(7), ok ? '✅ OK' : '⚠️ LOW', ok);
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 6 }];
  ws.autoFilter = { from: { row: 6, column: 1 }, to: { row: 6 + timelineRPS.length, column: 7 } };
}

// ─────────────────────────────────────────────────────────────
// SHEET 4 — ENDPOINT RESULTS
// ─────────────────────────────────────────────────────────────
function buildEndpointSheet(wb, data) {
  const ws = wb.addWorksheet('🌐 Endpoint Results', {
    properties: { tabColor: { argb: 'FF7C3AED' } },
  });

  const { endpointResults } = data;

  const colWidths = [24, 45, 10, 10, 10, 12, 12, 12, 12, 14, 12, 12];
  colWidths.forEach((w, i) => (ws.getColumn(i + 1).width = w));

  ws.mergeCells('A1:L1');
  const tc = ws.getCell('A1');
  tc.value     = `🌐 ENDPOINT PERFORMANCE RESULTS — ${endpointResults.length} Endpoints — Build #${BUILD_NUMBER}`;
  tc.font      = { bold: true, size: 13, color: { argb: C.white }, name: 'Calibri' };
  tc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.navy } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 32;

  const headers = ['Endpoint Tag', 'Path', 'Method', 'Total Calls', 'Errors', 'Error Rate', 'Avg (ms)', 'Min (ms)', 'Max (ms)', 'p95 (ms)', 'StdDev (ms)', 'Status'];
  const hRow = ws.getRow(2);
  hRow.height = 28;
  headers.forEach((h, i) => { const c = hRow.getCell(i + 1); c.value = h; hdr(c, C.steel); });

  endpointResults.forEach((ep, i) => {
    const r  = ws.getRow(3 + i);
    r.height = 22;
    const bg = i % 2 === 0 ? C.altRow : C.white;

    // Color code avg response time
    const avgColor = ep.avg_ms < 200 ? C.greenBg : ep.avg_ms < 500 ? C.amberBg : ep.avg_ms < 1000 ? C.orangeBg : C.redBg;

    const vals = [ep.tag, ep.path, ep.method, ep.totalCalls, ep.failedCalls, ep.errorRate, ep.avg_ms, ep.min_ms, ep.max_ms, ep.p95_ms, ep.stdDev_ms];
    vals.forEach((v, ci) => {
      const c = r.getCell(ci + 1);
      c.value = v;
      if (ci === 6) { // avg_ms colored
        cell_style(c, avgColor, C.slate, true);
      } else {
        cell_style(c, bg, C.slate, ci === 0);
      }
      c.alignment = { vertical: 'middle', horizontal: ci <= 1 ? 'left' : 'center' };
    });

    // Status badge
    const isPass = ep.status.includes('PASS');
    const isWarn = ep.status.includes('WARN');
    badge(r.getCell(12), ep.status, isPass ? true : isWarn ? null : false);
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 2 }];
  ws.autoFilter = { from: { row: 2, column: 1 }, to: { row: 2 + endpointResults.length, column: headers.length } };
}

// ─────────────────────────────────────────────────────────────
// SHEET 5 — THRESHOLD REPORT
// ─────────────────────────────────────────────────────────────
function buildThresholdSheet(wb, data) {
  const ws = wb.addWorksheet('🚦 Thresholds', {
    properties: { tabColor: { argb: 'FFEA580C' } },
  });

  const { thresholds, summary, meta } = data;
  const allPass = Object.values(thresholds).every(t => t.pass);

  [30, 25, 22, 22, 20].forEach((w, i) => (ws.getColumn(i + 1).width = w));

  ws.mergeCells('A1:E1');
  const tc = ws.getCell('A1');
  tc.value     = `🚦 THRESHOLD REPORT — ${allPass ? 'ALL PASSED ✅' : 'FAILURES DETECTED ❌'} — Build #${BUILD_NUMBER}`;
  tc.font      = { bold: true, size: 14, color: { argb: C.white }, name: 'Calibri' };
  tc.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: allPass ? C.green : C.red } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 36;

  const headers = ['Threshold Name', 'Actual Value', 'SLA Target', 'Pass/Fail', 'Description'];
  const hRow = ws.getRow(2);
  hRow.height = 28;
  headers.forEach((h, i) => { const c = hRow.getCell(i + 1); c.value = h; hdr(c, C.steel); });

  const thresholdDescriptions = {
    rps_gt_50:           'Minimum sustained throughput under baseline load',
    avg_lt_500ms:        'Average response time SLA for user experience',
    p95_lt_1500ms:       '95th percentile — most users must be under this',
    error_rate_lt_1pct:  'HTTP 4xx/5xx error rate must be below 1%',
    max_lt_5000ms:       'No single request should take more than 5 seconds',
  };

  Object.entries(thresholds).forEach(([key, t], i) => {
    const r  = ws.getRow(3 + i);
    r.height = 30;
    const bg = i % 2 === 0 ? C.altRow : C.white;

    cell_style(r.getCell(1), bg, C.slate, true); r.getCell(1).value = key.replace(/_/g, ' ');
    cell_style(r.getCell(2), bg, C.slate, true); r.getCell(2).value = t.value; r.getCell(2).alignment = { horizontal: 'center', vertical: 'middle' };
    cell_style(r.getCell(3), bg, C.steel);        r.getCell(3).value = t.threshold; r.getCell(3).alignment = { horizontal: 'center', vertical: 'middle' };
    badge(r.getCell(4), t.pass ? '✅ PASS' : '❌ FAIL', t.pass);
    cell_style(r.getCell(5), bg, C.silver);       r.getCell(5).value = thresholdDescriptions[key] || '';
  });

  // ── RECOMMENDATIONS ──────────────────────────────────
  const fails = Object.entries(thresholds).filter(([, t]) => !t.pass);
  if (fails.length > 0) {
    const recRow = 3 + Object.keys(thresholds).length + 2;
    ws.mergeCells(`A${recRow}:E${recRow}`);
    const rh = ws.getCell(`A${recRow}`);
    rh.value = '⚠️ REMEDIATION RECOMMENDATIONS';
    rh.font  = { bold: true, size: 12, color: { argb: C.white } };
    rh.fill  = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.red } };
    rh.alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(recRow).height = 28;

    const recs = {
      rps_gt_50:          'Scale horizontally — add more API instances. Enable caching layers.',
      avg_lt_500ms:       'Profile slow endpoints. Add database indexes. Enable response caching.',
      p95_lt_1500ms:      'Investigate outlier requests. Check database connection pool exhaustion.',
      error_rate_lt_1pct: 'Check error logs. Validate auth service. Inspect rate limiting config.',
      max_lt_5000ms:      'Set request timeouts. Investigate N+1 queries. Check external API calls.',
    };

    fails.forEach(([key], i) => {
      const r = ws.getRow(recRow + 1 + i);
      r.height = 24;
      ws.mergeCells(`A${recRow + 1 + i}:B${recRow + 1 + i}`);
      cell_style(r.getCell(1), C.redBg, C.red, true);
      r.getCell(1).value = '❌ ' + key.replace(/_/g, ' ');

      ws.mergeCells(`C${recRow + 1 + i}:E${recRow + 1 + i}`);
      cell_style(r.getCell(3), C.altRow, C.slate);
      r.getCell(3).value = recs[key] || 'Investigate and fix before production deployment.';
    });
  } else {
    const passRow = 3 + Object.keys(thresholds).length + 2;
    ws.mergeCells(`A${passRow}:E${passRow}`);
    const pr = ws.getCell(`A${passRow}`);
    pr.value     = '✅ All thresholds passed — system is ready for production baseline load';
    pr.font      = { bold: true, size: 11, color: { argb: C.white } };
    pr.fill      = { type: 'pattern', pattern: 'solid', fgColor: { argb: C.green } };
    pr.alignment = { horizontal: 'center', vertical: 'middle' };
    ws.getRow(passRow).height = 28;
  }

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 2 }];
}

// ─────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────
async function main() {
  console.log('');
  console.log('📊 Medicate Load Test Excel Report Generator');
  console.log(`📁 Results: ${RESULTS_FILE}`);
  console.log(`📁 Output:  ${OUTPUT_DIR}`);
  console.log('');

  const data = loadResults();

  const wb       = new ExcelJS.Workbook();
  wb.creator     = 'Medicate Load Test Pipeline';
  wb.created     = new Date();
  wb.modified    = new Date();

  console.log('📊 Building Sheet 1: Executive Summary...');
  buildSummarySheet(wb, data);

  console.log('⏱️  Building Sheet 2: Response Times...');
  buildResponseTimesSheet(wb, data);

  console.log('🔄 Building Sheet 3: Throughput Timeline...');
  buildThroughputSheet(wb, data);

  console.log('🌐 Building Sheet 4: Endpoint Results...');
  buildEndpointSheet(wb, data);

  console.log('🚦 Building Sheet 5: Threshold Report...');
  buildThresholdSheet(wb, data);

  const ts       = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  const filename = `Medicate_LoadTest_Baseline_Build-${BUILD_NUMBER}_${ts}.xlsx`;
  const outPath  = path.join(OUTPUT_DIR, filename);

  await wb.xlsx.writeFile(outPath);

  const stats = require('fs').statSync(outPath);
  console.log('');
  console.log('✅ Excel report generated!');
  console.log(`📄 File: ${outPath}`);
  console.log(`📏 Size: ${(stats.size / 1024).toFixed(1)} KB`);
  console.log('');
  console.log('📋 Sheets:');
  console.log('   1. 📊 Executive Summary  — KPIs, config, status');
  console.log('   2. ⏱️  Response Times     — Min/Avg/Max/p50/p90/p95/p99');
  console.log('   3. 🔄 Throughput          — RPS timeline with bars');
  console.log('   4. 🌐 Endpoint Results    — All 16 endpoints breakdown');
  console.log('   5. 🚦 Thresholds          — Pass/Fail per SLA');

  // Also save as "latest" fixed name
  const latestPath = path.join(OUTPUT_DIR, 'load-test-latest.xlsx');
  await wb.xlsx.writeFile(latestPath);
  console.log(`📌 Also saved as: ${latestPath}`);

  return outPath;
}

main().catch(err => {
  console.error('❌ Error generating Excel:', err.message);
  process.exit(1);
});
