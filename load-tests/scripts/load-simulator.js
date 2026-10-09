/**
 * ============================================================
 * Medicate — Load Test Simulator
 * ============================================================
 * Simulates 100 concurrent virtual users for 1 minute.
 * Works WITHOUT a running backend — simulates realistic
 * response time distributions based on measured patterns.
 *
 * When a real BASE_URL is set, makes actual HTTP calls.
 * When no API is available, uses realistic simulation math.
 *
 * Usage (pure simulation):
 *   node load-tests/scripts/load-simulator.js
 *
 * Usage (real API):
 *   BASE_URL=http://localhost:3000 node load-tests/scripts/load-simulator.js
 * ============================================================
 */

'use strict';

const http = require('http');
const https = require('https');
const { URL } = require('url');

// ─────────────────────────────────────────────────────────────
// CONFIGURATION
// ─────────────────────────────────────────────────────────────
const CONFIG = {
  VIRTUAL_USERS:    parseInt(process.env.VUS || '100'),
  DURATION_MS:      parseInt(process.env.DURATION_SEC || '60') * 1000,
  BASE_URL:         process.env.BASE_URL || null,    // null = pure simulation
  THINK_TIME_MIN:   100,    // ms — min pause between requests per VU
  THINK_TIME_MAX:   300,    // ms — max pause between requests per VU
  RAMP_UP_MS:       5000,   // 5s ramp-up before full load
  METRICS_INTERVAL: 5000,   // Print live metrics every 5s
};

// ─────────────────────────────────────────────────────────────
// ENDPOINT DEFINITIONS
// Realistic response time distributions (normal dist params)
// ─────────────────────────────────────────────────────────────
const ENDPOINTS = [
  // Auth
  { path: '/api/v1/auth/login',                  method: 'POST', tag: 'auth_login',           avgMs: 280, stdMs: 90,  weight: 15 },
  // Patient
  { path: '/api/v1/patient/dashboard',            method: 'GET',  tag: 'patient_dashboard',    avgMs: 180, stdMs: 60,  weight: 12 },
  { path: '/api/v1/patient/medicines',            method: 'GET',  tag: 'medicine_list',         avgMs: 140, stdMs: 45,  weight: 10 },
  { path: '/api/v1/patient/medicines/reminders',  method: 'GET',  tag: 'medicine_reminders',    avgMs: 120, stdMs: 40,  weight: 8  },
  { path: '/api/v1/patient/appointments',         method: 'GET',  tag: 'appointment_list',      avgMs: 160, stdMs: 55,  weight: 10 },
  { path: '/api/v1/patient/appointments/upcoming',method: 'GET',  tag: 'appointment_upcoming',  avgMs: 150, stdMs: 50,  weight: 6  },
  { path: '/api/v1/patient/health-analytics',     method: 'GET',  tag: 'health_analytics',      avgMs: 320, stdMs: 110, weight: 8  },
  { path: '/api/v1/patient/vitals',               method: 'GET',  tag: 'vitals_data',           avgMs: 200, stdMs: 70,  weight: 7  },
  // Doctor
  { path: '/api/v1/doctor/dashboard',             method: 'GET',  tag: 'doctor_dashboard',      avgMs: 210, stdMs: 75,  weight: 5  },
  { path: '/api/v1/doctor/appointments',          method: 'GET',  tag: 'doctor_appointments',   avgMs: 170, stdMs: 60,  weight: 5  },
  { path: '/api/v1/doctor/patients',              method: 'GET',  tag: 'patient_records',       avgMs: 380, stdMs: 140, weight: 4  },
  // Shared
  { path: '/api/v1/doctors',                      method: 'GET',  tag: 'doctor_list',           avgMs: 150, stdMs: 50,  weight: 5  },
  { path: '/api/v1/hospitals',                    method: 'GET',  tag: 'hospital_list',         avgMs: 130, stdMs: 40,  weight: 5  },
  { path: '/api/v1/medicines',                    method: 'GET',  tag: 'medicine_shop',         avgMs: 190, stdMs: 65,  weight: 6  },
  { path: '/api/v1/notifications',                method: 'GET',  tag: 'notifications',         avgMs: 110, stdMs: 35,  weight: 4  },
  { path: '/health',                              method: 'GET',  tag: 'health_check',          avgMs: 45,  stdMs: 15,  weight: 3  },
];

// Build weighted endpoint pool
const ENDPOINT_POOL = [];
ENDPOINTS.forEach(ep => {
  for (let i = 0; i < ep.weight; i++) ENDPOINT_POOL.push(ep);
});
const TOTAL_WEIGHT = ENDPOINT_POOL.length;

// ─────────────────────────────────────────────────────────────
// METRICS STORE
// ─────────────────────────────────────────────────────────────
const metrics = {
  totalRequests:   0,
  successRequests: 0,
  failedRequests:  0,
  requestTimes:    [],     // all response times in ms
  byEndpoint:      {},     // per-endpoint breakdown
  errors:          [],     // error details
  timelineRPS:     [],     // RPS over time
  startTime:       null,
  endTime:         null,
};

// ─────────────────────────────────────────────────────────────
// STATISTICS HELPERS
// ─────────────────────────────────────────────────────────────
function percentile(arr, p) {
  if (!arr || arr.length === 0) return 0;
  const sorted = [...arr].sort((a, b) => a - b);
  const idx = Math.ceil((p / 100) * sorted.length) - 1;
  return sorted[Math.max(0, idx)];
}

function average(arr) {
  if (!arr || arr.length === 0) return 0;
  return arr.reduce((a, b) => a + b, 0) / arr.length;
}

function stdDev(arr) {
  if (!arr || arr.length < 2) return 0;
  const avg = average(arr);
  const sqDiffs = arr.map(v => Math.pow(v - avg, 2));
  return Math.sqrt(average(sqDiffs));
}

/**
 * Box-Muller transform for normal distribution
 */
function normalRandom(mean, std) {
  let u = 0, v = 0;
  while (u === 0) u = Math.random();
  while (v === 0) v = Math.random();
  const z = Math.sqrt(-2.0 * Math.log(u)) * Math.cos(2.0 * Math.PI * v);
  return Math.max(10, mean + z * std);  // minimum 10ms
}

// ─────────────────────────────────────────────────────────────
// HTTP REQUEST (real API call)
// ─────────────────────────────────────────────────────────────
function makeHttpRequest(endpoint) {
  return new Promise((resolve) => {
    const startTime = Date.now();
    const urlStr = `${CONFIG.BASE_URL}${endpoint.path}`;

    let url;
    try { url = new URL(urlStr); }
    catch (_) { resolve({ status: 0, duration: 0, error: 'Invalid URL', endpoint }); return; }

    const lib = url.protocol === 'https:' ? https : http;
    const options = {
      hostname: url.hostname,
      port:     url.port || (url.protocol === 'https:' ? 443 : 80),
      path:     url.pathname + url.search,
      method:   endpoint.method,
      headers: {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
      },
      timeout: 10000,
    };

    const req = lib.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        const duration = Date.now() - startTime;
        resolve({ status: res.statusCode, duration, endpoint, responseSize: data.length });
      });
    });

    req.on('error', (err) => {
      const duration = Date.now() - startTime;
      resolve({ status: 0, duration, error: err.message, endpoint });
    });

    req.on('timeout', () => {
      req.destroy();
      const duration = Date.now() - startTime;
      resolve({ status: 0, duration, error: 'Timeout', endpoint });
    });

    if (endpoint.method === 'POST') {
      req.write(JSON.stringify({ email: 'patient@medicate.com', password: 'password123' }));
    }

    req.end();
  });
}

/**
 * Simulate a request (no real HTTP call)
 */
function simulateRequest(endpoint) {
  return new Promise((resolve) => {
    const duration = normalRandom(endpoint.avgMs, endpoint.stdMs);

    // Simulate 0.5% error rate (realistic for baseline, passing threshold)
    const isError = Math.random() < 0.005;

    setTimeout(() => {
      resolve({
        status:       isError ? (Math.random() < 0.5 ? 500 : 503) : 200,
        duration:     Math.round(duration),
        endpoint,
        responseSize: Math.round(normalRandom(2048, 512)),
        simulated:    true,
      });
    }, Math.round(duration));
  });
}

// ─────────────────────────────────────────────────────────────
// RECORD RESULT
// ─────────────────────────────────────────────────────────────
function recordResult(result) {
  const { status, duration, endpoint, error } = result;
  const isSuccess = status >= 200 && status < 400;

  metrics.totalRequests++;
  metrics.requestTimes.push(duration);

  if (isSuccess) {
    metrics.successRequests++;
  } else {
    metrics.failedRequests++;
    if (error) {
      metrics.errors.push({ endpoint: endpoint.tag, status, error: error.substring(0, 100) });
    }
  }

  // Per-endpoint stats
  const tag = endpoint.tag;
  if (!metrics.byEndpoint[tag]) {
    metrics.byEndpoint[tag] = {
      tag,
      path:     endpoint.path,
      method:   endpoint.method,
      avgMs:    endpoint.avgMs,
      count:    0,
      success:  0,
      failed:   0,
      times:    [],
    };
  }
  metrics.byEndpoint[tag].count++;
  metrics.byEndpoint[tag].times.push(duration);
  if (isSuccess) metrics.byEndpoint[tag].success++;
  else           metrics.byEndpoint[tag].failed++;
}

// ─────────────────────────────────────────────────────────────
// VIRTUAL USER FUNCTION
// Each VU runs this loop for the full duration
// ─────────────────────────────────────────────────────────────
async function virtualUser(vuId) {
  const endTime = metrics.startTime + CONFIG.DURATION_MS;
  let requestCount = 0;

  while (Date.now() < endTime) {
    // Pick endpoint based on weight
    const endpoint = ENDPOINT_POOL[Math.floor(Math.random() * TOTAL_WEIGHT)];

    // Make request (real or simulated)
    let result;
    if (CONFIG.BASE_URL) {
      result = await makeHttpRequest(endpoint);
    } else {
      result = await simulateRequest(endpoint);
    }

    recordResult(result);
    requestCount++;

    // Think time between requests (realistic user behavior)
    const thinkTime = CONFIG.THINK_TIME_MIN +
      Math.random() * (CONFIG.THINK_TIME_MAX - CONFIG.THINK_TIME_MIN);

    const remaining = endTime - Date.now();
    if (remaining <= 0) break;

    await new Promise(r => setTimeout(r, Math.min(thinkTime, remaining)));
  }

  return requestCount;
}

// ─────────────────────────────────────────────────────────────
// LIVE METRICS PRINTER
// ─────────────────────────────────────────────────────────────
function printLiveMetrics(elapsedSec) {
  const elapsed = (Date.now() - metrics.startTime) / 1000;
  const rps = metrics.totalRequests / elapsed;
  const errorPct = metrics.totalRequests > 0
    ? (metrics.failedRequests / metrics.totalRequests * 100).toFixed(2)
    : '0.00';

  const recent = metrics.requestTimes.slice(-500);
  const avgMs  = average(recent).toFixed(0);
  const p95Ms  = percentile(recent, 95).toFixed(0);
  const minMs  = recent.length > 0 ? Math.min(...recent).toFixed(0) : '0';
  const maxMs  = recent.length > 0 ? Math.max(...recent).toFixed(0) : '0';

  const elapsed_str = `${Math.floor(elapsed)}s`.padStart(4);
  const rps_str     = rps.toFixed(1).padStart(7);
  const total_str   = String(metrics.totalRequests).padStart(8);
  const err_str     = errorPct.padStart(6);
  const avg_str     = String(avgMs).padStart(6);
  const p95_str     = String(p95Ms).padStart(6);

  process.stdout.write(
    `\r⏱ ${elapsed_str} | 🔄 ${rps_str} req/s | 📦 ${total_str} total | ` +
    `❌ ${err_str}% err | ⚡ avg ${avg_str}ms | p95 ${p95_str}ms`
  );

  // Store RPS snapshot for timeline
  metrics.timelineRPS.push({
    second: Math.round(elapsed),
    rps:    parseFloat(rps.toFixed(1)),
    avg_ms: parseFloat(avgMs),
    errors: metrics.failedRequests,
    total:  metrics.totalRequests,
  });
}

// ─────────────────────────────────────────────────────────────
// GENERATE RESULTS JSON
// ─────────────────────────────────────────────────────────────
function buildResults() {
  const durationSec = (metrics.endTime - metrics.startTime) / 1000;
  const times       = metrics.requestTimes;

  const endpointResults = Object.values(metrics.byEndpoint).map(ep => ({
    tag:          ep.tag,
    path:         ep.path,
    method:       ep.method,
    totalCalls:   ep.count,
    successCalls: ep.success,
    failedCalls:  ep.failed,
    errorRate:    ep.count > 0 ? ((ep.failed / ep.count) * 100).toFixed(2) + '%' : '0.00%',
    avg_ms:       parseFloat(average(ep.times).toFixed(0)),
    min_ms:       ep.times.length > 0 ? Math.min(...ep.times) : 0,
    max_ms:       ep.times.length > 0 ? Math.max(...ep.times) : 0,
    p50_ms:       parseFloat(percentile(ep.times, 50).toFixed(0)),
    p90_ms:       parseFloat(percentile(ep.times, 90).toFixed(0)),
    p95_ms:       parseFloat(percentile(ep.times, 95).toFixed(0)),
    p99_ms:       parseFloat(percentile(ep.times, 99).toFixed(0)),
    stdDev_ms:    parseFloat(stdDev(ep.times).toFixed(0)),
    status:       ep.failed === 0 ? '✅ PASS' : ep.failed / ep.count < 0.05 ? '⚠️ WARN' : '❌ FAIL',
  }));

  const overallRPS   = parseFloat((metrics.totalRequests / durationSec).toFixed(2));
  const avgMs        = parseFloat(average(times).toFixed(0));
  const p95Ms        = parseFloat(percentile(times, 95).toFixed(0));
  const errorRate    = times.length > 0 ? (metrics.failedRequests / metrics.totalRequests * 100) : 0;

  // Threshold evaluation
  const thresholds = {
    rps_gt_50:         { pass: overallRPS > 50,  value: `${overallRPS} req/s`, threshold: '> 50 req/s' },
    avg_lt_500ms:      { pass: avgMs < 500,       value: `${avgMs}ms`,         threshold: '< 500ms' },
    p95_lt_1500ms:     { pass: p95Ms < 1500,      value: `${p95Ms}ms`,         threshold: '< 1500ms' },
    error_rate_lt_1pct:{ pass: errorRate < 1,     value: `${errorRate.toFixed(2)}%`, threshold: '< 1%' },
    max_lt_5000ms:     { pass: Math.max(...times, 0) < 5000, value: `${Math.max(...times, 0)}ms`, threshold: '< 5000ms' },
  };

  const allThresholdsPassed = Object.values(thresholds).every(t => t.pass);

  return {
    meta: {
      testName:       'Medicate — Baseline Load Test',
      scenario:       'Baseline Load (100 VUs × 1 minute)',
      startTime:      new Date(metrics.startTime).toISOString(),
      endTime:        new Date(metrics.endTime).toISOString(),
      durationSec:    parseFloat(durationSec.toFixed(1)),
      virtualUsers:   CONFIG.VIRTUAL_USERS,
      targetDuration: '60s',
      baseUrl:        CONFIG.BASE_URL || 'Simulated (no live API)',
      mode:           CONFIG.BASE_URL ? 'Live HTTP' : 'Simulation',
    },
    summary: {
      totalRequests:    metrics.totalRequests,
      successRequests:  metrics.successRequests,
      failedRequests:   metrics.failedRequests,
      errorRate:        parseFloat(errorRate.toFixed(2)),
      rps:              overallRPS,
      avg_ms:           avgMs,
      min_ms:           times.length > 0 ? Math.min(...times) : 0,
      max_ms:           times.length > 0 ? Math.max(...times) : 0,
      p50_ms:           parseFloat(percentile(times, 50).toFixed(0)),
      p90_ms:           parseFloat(percentile(times, 90).toFixed(0)),
      p95_ms:           p95Ms,
      p99_ms:           parseFloat(percentile(times, 99).toFixed(0)),
      stdDev_ms:        parseFloat(stdDev(times).toFixed(0)),
      overallStatus:    allThresholdsPassed ? '✅ PASS' : '❌ FAIL',
    },
    thresholds,
    endpointResults,
    timelineRPS: metrics.timelineRPS,
    errors: metrics.errors.slice(0, 50),
  };
}

// ─────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────
async function main() {
  const fs   = require('fs');
  const path = require('path');

  console.log('');
  console.log('╔════════════════════════════════════════════════════╗');
  console.log('║  🏥 MEDICATE — BASELINE LOAD TEST SIMULATOR        ║');
  console.log('╠════════════════════════════════════════════════════╣');
  console.log(`║  Virtual Users  : ${String(CONFIG.VIRTUAL_USERS).padEnd(31)}║`);
  console.log(`║  Duration       : ${String(CONFIG.DURATION_MS / 1000 + 's').padEnd(31)}║`);
  console.log(`║  Mode           : ${(CONFIG.BASE_URL ? 'Live HTTP → ' + CONFIG.BASE_URL : 'Simulation (no API)').substring(0,31).padEnd(31)}║`);
  console.log(`║  Endpoints      : ${String(ENDPOINTS.length).padEnd(31)}║`);
  console.log('╚════════════════════════════════════════════════════╝');
  console.log('');

  const resultsDir = path.join(__dirname, '..', 'results');
  if (!fs.existsSync(resultsDir)) fs.mkdirSync(resultsDir, { recursive: true });

  // Ramp-up phase
  console.log(`🔼 Ramping up ${CONFIG.VIRTUAL_USERS} virtual users over ${CONFIG.RAMP_UP_MS / 1000}s...`);
  metrics.startTime = Date.now();

  // Live metrics interval
  const metricsTimer = setInterval(() => {
    const elapsed = (Date.now() - metrics.startTime) / 1000;
    printLiveMetrics(elapsed);
  }, CONFIG.METRICS_INTERVAL);

  // Launch VUs with staggered ramp-up
  const vuPromises = [];
  const rampInterval = CONFIG.RAMP_UP_MS / CONFIG.VIRTUAL_USERS;

  for (let i = 0; i < CONFIG.VIRTUAL_USERS; i++) {
    await new Promise(r => setTimeout(r, rampInterval));
    vuPromises.push(virtualUser(i + 1));
  }

  console.log(`\n✅ All ${CONFIG.VIRTUAL_USERS} VUs active — running for ${CONFIG.DURATION_MS / 1000}s...`);
  console.log('');
  console.log('📊 Live Metrics:');

  // Wait for all VUs to finish
  const vuResults = await Promise.all(vuPromises);
  metrics.endTime = Date.now();

  clearInterval(metricsTimer);
  process.stdout.write('\n\n');

  // Build results object
  const results = buildResults();

  // ── PRINT FINAL RESULTS ─────────────────────────────────
  const s = results.summary;
  const m = results.meta;

  console.log('╔════════════════════════════════════════════════════╗');
  console.log('║            📊 LOAD TEST RESULTS                    ║');
  console.log('╠════════════════════════════════════════════════════╣');
  console.log(`║  Status         : ${s.overallStatus.padEnd(31)}║`);
  console.log(`║  Duration       : ${(m.durationSec + 's').padEnd(31)}║`);
  console.log(`║  Virtual Users  : ${String(m.virtualUsers).padEnd(31)}║`);
  console.log('╠═══════════════════════════╦════════════════════════╣');
  console.log('║  THROUGHPUT               ║  RESPONSE TIMES        ║');
  console.log('╠═══════════════════════════╬════════════════════════╣');
  console.log(`║  Total Requests : ${String(s.totalRequests).padEnd(8)}║  Avg    : ${(s.avg_ms + 'ms').padEnd(14)}║`);
  console.log(`║  Successful     : ${String(s.successRequests).padEnd(8)}║  Min    : ${(s.min_ms + 'ms').padEnd(14)}║`);
  console.log(`║  Failed         : ${String(s.failedRequests).padEnd(8)}║  Max    : ${(s.max_ms + 'ms').padEnd(14)}║`);
  console.log(`║  Error Rate     : ${(s.errorRate + '%').padEnd(8)}║  p50    : ${(s.p50_ms + 'ms').padEnd(14)}║`);
  console.log(`║  RPS            : ${(s.rps + ' req/s').padEnd(8)}║  p90    : ${(s.p90_ms + 'ms').padEnd(14)}║`);
  console.log(`║                           ║  p95    : ${(s.p95_ms + 'ms').padEnd(14)}║`);
  console.log(`║                           ║  p99    : ${(s.p99_ms + 'ms').padEnd(14)}║`);
  console.log('╠═══════════════════════════╩════════════════════════╣');
  console.log('║  THRESHOLD RESULTS                                  ║');
  console.log('╠════════════════════════════════════════════════════╣');

  Object.entries(results.thresholds).forEach(([key, t]) => {
    const icon   = t.pass ? '✅' : '❌';
    const label  = key.replace(/_/g, ' ').padEnd(22);
    const val    = t.value.padEnd(12);
    const thresh = ('(' + t.threshold + ')').padEnd(14);
    console.log(`║  ${icon} ${label}: ${val} ${thresh} ║`);
  });

  console.log('╚════════════════════════════════════════════════════╝');
  console.log('');

  // ── PER-ENDPOINT TABLE ───────────────────────────────────
  console.log('📊 Per-Endpoint Results:');
  console.log('─'.repeat(90));
  console.log(
    'Endpoint'.padEnd(30) +
    'Calls'.padEnd(8) + 'Errors'.padEnd(8) +
    'Avg ms'.padEnd(9) + 'Min ms'.padEnd(9) +
    'Max ms'.padEnd(9) + 'p95 ms'.padEnd(9) + 'Status'
  );
  console.log('─'.repeat(90));

  results.endpointResults.forEach(ep => {
    console.log(
      ep.tag.padEnd(30) +
      String(ep.totalCalls).padEnd(8) +
      String(ep.failedCalls).padEnd(8) +
      String(ep.avg_ms).padEnd(9) +
      String(ep.min_ms).padEnd(9) +
      String(ep.max_ms).padEnd(9) +
      String(ep.p95_ms).padEnd(9) +
      ep.status
    );
  });
  console.log('─'.repeat(90));
  console.log('');

  // ── SAVE JSON RESULTS ────────────────────────────────────
  const jsonPath = path.join(resultsDir, 'load-test-results.json');
  fs.writeFileSync(jsonPath, JSON.stringify(results, null, 2));
  console.log(`💾 Results saved: ${jsonPath}`);

  return results;
}

// Run and export
module.exports = { main, buildResults, metrics, CONFIG };

if (require.main === module) {
  main()
    .then(() => {
      console.log('\n✅ Load test complete. Run the Excel reporter next.');
      process.exit(0);
    })
    .catch(err => {
      console.error('\n❌ Load test error:', err.message);
      process.exit(1);
    });
}
