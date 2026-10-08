import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Counter } from 'k6/metrics';

// ============================================================
// Custom Metrics
// ============================================================
const errorRate = new Rate('error_rate');
const successRate = new Rate('success_rate');
const requestCount = new Counter('total_requests');

// ============================================================
// Test Configuration: 100 VUs x 1 Minute Baseline Load Test
// ============================================================
export const options = {
  scenarios: {
    baseline_load: {
      executor: 'constant-vus',
      vus: 100,             // 100 virtual users
      duration: '1m',       // running for 1 minute
    },
  },
  thresholds: {
    http_req_duration: ['avg<500', 'p(95)<2000'], // Avg < 500ms, 95th percentile < 2s
    error_rate: ['rate<0.05'],                     // Error rate < 5%
    http_req_failed: ['rate<0.05'],                // Less than 5% requests fail
  },
};

// ============================================================
// Base URL — update to your deployed API URL
// ============================================================
const BASE_URL = __ENV.API_URL || 'http://localhost:3000';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || 'test-token-placeholder';

const HEADERS = {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${AUTH_TOKEN}`,
};

// ============================================================
// Test Scenarios — simulating real user behavior
// ============================================================
export default function () {
  requestCount.add(1);

  // Scenario 1: GET /api/security/stats (Dashboard load)
  const statsRes = http.get(`${BASE_URL}/api/security/stats`, { headers: HEADERS });
  check(statsRes, {
    'GET /stats - status ok': (r) => r.status === 200 || r.status === 401,
    'GET /stats - response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  errorRate.add(statsRes.status >= 500);
  successRate.add(statsRes.status < 500);
  sleep(0.1);

  // Scenario 2: GET /api/security/events/recent
  const recentRes = http.get(`${BASE_URL}/api/security/events/recent`, { headers: HEADERS });
  check(recentRes, {
    'GET /events/recent - status ok': (r) => r.status === 200 || r.status === 401,
    'GET /events/recent - response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  errorRate.add(recentRes.status >= 500);
  sleep(0.1);

  // Scenario 3: GET /api/security/alerts
  const alertsRes = http.get(`${BASE_URL}/api/security/alerts`, { headers: HEADERS });
  check(alertsRes, {
    'GET /alerts - status ok': (r) => r.status === 200 || r.status === 401,
    'GET /alerts - response time < 1500ms': (r) => r.timings.duration < 1500,
  });
  errorRate.add(alertsRes.status >= 500);
  sleep(0.1);

  // Scenario 4: POST /api/security/events (Log a security event)
  const payload = JSON.stringify({
    type: 'LOAD_TEST_EVENT',
    userId: `user_${Math.floor(Math.random() * 1000)}`,
    status: 'INFO',
    description: 'Load test event from k6',
  });
  const postRes = http.post(`${BASE_URL}/api/security/events`, payload, { headers: HEADERS });
  check(postRes, {
    'POST /events - status ok': (r) => r.status === 201 || r.status === 401,
    'POST /events - response time < 2000ms': (r) => r.timings.duration < 2000,
  });
  errorRate.add(postRes.status >= 500);
  sleep(0.2);
}
