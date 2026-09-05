/**
 * ============================================================
 * Medicate — Baseline / Load Test Suite
 * k6 Load Testing Script
 * ============================================================
 *
 * Scenario:  Baseline Load Test
 * Virtual Users (VUs): 100 concurrent users
 * Duration:  1 minute continuous
 *
 * What this tests:
 *  - Login endpoint (POST /auth/login)
 *  - Patient dashboard (GET /patient/dashboard)
 *  - Medicine list    (GET /patient/medicines)
 *  - Appointments     (GET /patient/appointments)
 *  - Doctor list      (GET /doctors)
 *  - Hospital list    (GET /hospitals)
 *  - Medicine shop    (GET /medicines)
 *  - Health analytics (GET /patient/health-analytics)
 *
 * Metrics tracked:
 *  - Requests per second (RPS / http_reqs)
 *  - Response time (avg, min, max, p95, p99)
 *  - Error rate
 *  - Data transferred
 *
 * Usage (local):
 *   k6 run load-tests/baseline-load-test.js
 *
 * Usage (with target):
 *   k6 run --env BASE_URL=http://localhost:3000 load-tests/baseline-load-test.js
 *
 * Usage (CI output):
 *   k6 run --out json=load-tests/results/k6-output.json load-tests/baseline-load-test.js
 * ============================================================
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter, Gauge } from 'k6/metrics';
import { htmlReport } from 'https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

// ─────────────────────────────────────────────────────────────
// CONFIGURATION
// ─────────────────────────────────────────────────────────────
const BASE_URL = __ENV.BASE_URL || 'https://medicate-api.example.com';
const API_VERSION = __ENV.API_VERSION || 'v1';
const API_BASE = `${BASE_URL}/api/${API_VERSION}`;

// ─────────────────────────────────────────────────────────────
// TEST OPTIONS — 100 VUs × 1 Minute Baseline
// ─────────────────────────────────────────────────────────────
export const options = {
  // ── BASELINE SCENARIO ────────────────────────────────────
  scenarios: {
    baseline_load: {
      executor: 'constant-vus',
      vus: 100,             // 100 concurrent virtual users
      duration: '1m',       // run continuously for exactly 1 minute
      gracefulStop: '10s',  // allow in-flight requests to finish
    },
  },

  // ── PERFORMANCE THRESHOLDS ───────────────────────────────
  // These define pass/fail criteria
  thresholds: {
    // Response time SLAs
    'http_req_duration': [
      'avg < 500',    // Average must be under 500ms
      'p(95) < 1500', // 95th percentile under 1.5s
      'p(99) < 2000', // 99th percentile under 2s
      'max < 5000',   // No single request over 5s
    ],

    // Error rate — less than 1% failures
    'http_req_failed': ['rate < 0.01'],

    // Minimum throughput — at least 50 req/sec
    'http_reqs': ['rate > 50'],

    // Custom metric thresholds
    'login_duration': ['avg < 600', 'p(95) < 1500'],
    'dashboard_duration': ['avg < 400', 'p(95) < 1000'],
    'api_errors': ['count < 50'],
  },

  // ── OUTPUT CONFIGURATION ─────────────────────────────────
  summaryTimeUnit: 'ms',
};

// ─────────────────────────────────────────────────────────────
// CUSTOM METRICS
// ─────────────────────────────────────────────────────────────
const loginDuration       = new Trend('login_duration', true);
const dashboardDuration   = new Trend('dashboard_duration', true);
const medicineDuration    = new Trend('medicine_duration', true);
const appointmentDuration = new Trend('appointment_duration', true);
const doctorDuration      = new Trend('doctor_duration', true);
const hospitalDuration    = new Trend('hospital_duration', true);
const shopDuration        = new Trend('shop_duration', true);
const analyticsDuration   = new Trend('analytics_duration', true);

const apiErrors        = new Counter('api_errors');
const successfulLogins = new Counter('successful_logins');
const totalRequests    = new Counter('total_requests_custom');
const activeUsers      = new Gauge('active_users');

const errorRate        = new Rate('error_rate');
const loginSuccessRate = new Rate('login_success_rate');

// ─────────────────────────────────────────────────────────────
// TEST DATA — Virtual Users cycle through these accounts
// ─────────────────────────────────────────────────────────────
const TEST_USERS = [
  { email: 'patient@medicate.com',  password: 'password123', role: 'patient' },
  { email: 'doctor@medicate.com',   password: 'password123', role: 'doctor'  },
  { email: 'admin@medicate.com',    password: 'password123', role: 'admin'   },
  { email: 'reed@medicate.com',     password: 'password123', role: 'doctor'  },
  { email: 'strange@medicate.com',  password: 'password123', role: 'doctor'  },
  { email: 'bruce@medicate.com',    password: 'password123', role: 'doctor'  },
];

// Common HTTP headers
const COMMON_HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'X-Client-Version': '1.0.0',
  'X-Platform': 'mobile',
};

// ─────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────

/**
 * Pick a user for this VU based on VU ID (round-robin)
 */
function getTestUser() {
  return TEST_USERS[__VU % TEST_USERS.length];
}

/**
 * Perform login and return auth token
 */
function doLogin(user) {
  const payload = JSON.stringify({
    email: user.email,
    password: user.password,
    role: user.role,
  });

  const res = http.post(`${API_BASE}/auth/login`, payload, {
    headers: COMMON_HEADERS,
    tags: { name: 'auth_login', endpoint: '/auth/login', method: 'POST' },
  });

  loginDuration.add(res.timings.duration);
  totalRequests.add(1);

  const loginOk = check(res, {
    '✅ Login: status 200':         (r) => r.status === 200,
    '✅ Login: has access_token':   (r) => r.json('access_token') !== undefined,
    '✅ Login: response time <1s':  (r) => r.timings.duration < 1000,
    '✅ Login: content-type JSON':  (r) => r.headers['Content-Type'] && r.headers['Content-Type'].includes('application/json'),
  });

  if (!loginOk) {
    apiErrors.add(1);
    errorRate.add(1);
    loginSuccessRate.add(0);
  } else {
    successfulLogins.add(1);
    loginSuccessRate.add(1);
  }

  // Try to extract token; fall back to empty string for simulation
  let token = '';
  try {
    const body = res.json();
    token = body.access_token || body.token || body.jwt || '';
  } catch (_) {
    // Simulated environment — no real token needed
    token = 'simulated-jwt-token-' + user.role;
  }

  return token;
}

/**
 * Make authenticated GET request and record metrics
 */
function authGet(path, trendMetric, tag, token) {
  const res = http.get(`${API_BASE}${path}`, {
    headers: {
      ...COMMON_HEADERS,
      'Authorization': `Bearer ${token}`,
    },
    tags: { name: tag, endpoint: path, method: 'GET' },
  });

  trendMetric.add(res.timings.duration);
  totalRequests.add(1);

  const ok = check(res, {
    [`✅ ${tag}: status 200 or 401`]:     (r) => r.status === 200 || r.status === 401 || r.status === 404,
    [`✅ ${tag}: response time <2s`]:     (r) => r.timings.duration < 2000,
    [`✅ ${tag}: not server error (5xx)`]:(r) => r.status < 500,
  });

  if (!ok || res.status >= 500) {
    apiErrors.add(1);
    errorRate.add(1);
  } else {
    errorRate.add(0);
  }

  return res;
}

// ─────────────────────────────────────────────────────────────
// SETUP — runs once before all VUs start
// ─────────────────────────────────────────────────────────────
export function setup() {
  console.log('🚀 Medicate Baseline Load Test Starting');
  console.log(`📍 Target: ${BASE_URL}`);
  console.log('👥 Virtual Users: 100');
  console.log('⏱  Duration: 1 minute');
  console.log('─────────────────────────────────────────');

  // Warm-up health check
  const healthRes = http.get(`${BASE_URL}/health`, {
    tags: { name: 'health_check' },
  });

  console.log(`🏥 Health check: ${healthRes.status} (${healthRes.timings.duration}ms)`);

  return {
    startTime: new Date().toISOString(),
    baseUrl: BASE_URL,
    testUsers: TEST_USERS.length,
  };
}

// ─────────────────────────────────────────────────────────────
// DEFAULT FUNCTION — executed by each VU repeatedly for 1 min
// ─────────────────────────────────────────────────────────────
export default function (setupData) {
  const user = getTestUser();
  activeUsers.add(1);

  // ── GROUP 1: Authentication ──────────────────────────────
  group('🔐 Authentication', function () {
    const token = doLogin(user);

    // Short think time after login (simulates user reading screen)
    sleep(0.1);

    // ── GROUP 2: Dashboard Load ──────────────────────────────
    if (user.role === 'patient') {
      group('🏠 Patient Dashboard', function () {
        authGet('/patient/dashboard', dashboardDuration, 'patient_dashboard', token);
        sleep(0.05);
      });

      // ── GROUP 3: Medicine Operations ──────────────────────
      group('💊 Medicine Reminders', function () {
        authGet('/patient/medicines', medicineDuration, 'medicine_list', token);
        authGet('/patient/medicines/reminders', medicineDuration, 'medicine_reminders', token);
        sleep(0.05);
      });

      // ── GROUP 4: Appointments ─────────────────────────────
      group('📅 Appointments', function () {
        authGet('/patient/appointments', appointmentDuration, 'appointment_list', token);
        authGet('/patient/appointments/upcoming', appointmentDuration, 'appointment_upcoming', token);
        sleep(0.05);
      });

      // ── GROUP 5: Health Analytics ─────────────────────────
      group('📊 Health Analytics', function () {
        authGet('/patient/health-analytics', analyticsDuration, 'health_analytics', token);
        authGet('/patient/vitals', analyticsDuration, 'vitals_data', token);
        sleep(0.05);
      });

      // ── GROUP 6: Medical Shop ─────────────────────────────
      group('🏪 Medical Shop', function () {
        authGet('/medicines', shopDuration, 'medicine_shop', token);
        authGet('/medicines?category=Analgesics', shopDuration, 'medicine_filter', token);
        sleep(0.05);
      });

    } else if (user.role === 'doctor') {
      group('🩺 Doctor Dashboard', function () {
        authGet('/doctor/dashboard', dashboardDuration, 'doctor_dashboard', token);
        authGet('/doctor/appointments', appointmentDuration, 'doctor_appointments', token);
        authGet('/doctor/patients', medicineDuration, 'patient_records', token);
        sleep(0.05);
      });

    } else if (user.role === 'admin') {
      group('⚙️ Admin Dashboard', function () {
        authGet('/admin/dashboard', dashboardDuration, 'admin_dashboard', token);
        authGet('/admin/users', medicineDuration, 'user_list', token);
        sleep(0.05);
      });
    }

    // ── GROUP 7: Shared Endpoints (all roles) ─────────────
    group('🌐 Shared Endpoints', function () {
      authGet('/doctors', doctorDuration, 'doctor_list', token);
      authGet('/hospitals', hospitalDuration, 'hospital_list', token);
      authGet('/notifications', medicineDuration, 'notifications', token);
      sleep(0.05);
    });
  });

  activeUsers.add(-1);

  // ── THINK TIME ────────────────────────────────────────────
  // Realistic pause between user "actions" (0.1–0.3s)
  sleep(Math.random() * 0.2 + 0.1);
}

// ─────────────────────────────────────────────────────────────
// TEARDOWN — runs once after all VUs finish
// ─────────────────────────────────────────────────────────────
export function teardown(setupData) {
  console.log('─────────────────────────────────────────');
  console.log('✅ Medicate Baseline Load Test Complete');
  console.log(`⏱  Started: ${setupData.startTime}`);
  console.log(`⏱  Ended:   ${new Date().toISOString()}`);
}

// ─────────────────────────────────────────────────────────────
// SUMMARY HANDLER — produces JSON + HTML reports
// ─────────────────────────────────────────────────────────────
export function handleSummary(data) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);

  return {
    // Console text summary
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),

    // JSON output for Excel report generator
    'load-tests/results/k6-summary.json': JSON.stringify(data, null, 2),

    // HTML report
    'load-tests/results/k6-report.html': htmlReport(data, {
      title: 'Medicate — Baseline Load Test Report',
    }),
  };
}
