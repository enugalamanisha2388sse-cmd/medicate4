# ⚡ Medicate — Baseline Load Test Suite

> **100 Virtual Users × 1 Minute Continuous Load Testing**

Tests the Medicate healthcare API under normal expected concurrent load and measures:
- **Requests per second (RPS)**
- **Response times** (Min / Avg / Max / p50 / p90 / p95 / p99)
- **Error rate**
- **Per-endpoint performance breakdown**

---

## 📁 Structure

```
load-tests/
├── baseline-load-test.js         ← k6 test script (100 VUs × 1 min)
├── package.json                  ← Dependencies + scripts
├── scripts/
│   ├── load-simulator.js         ← Node.js simulator (no k6 needed)
│   └── generate-load-excel.js    ← Excel report generator (5 sheets)
├── results/
│   ├── load-test-results.json    ← Raw results output
│   └── k6-summary.json           ← k6 output (if k6 used)
└── reports/
    ├── Medicate_LoadTest_Baseline_Build-*.xlsx   ← Full Excel report
    └── load-test-latest.xlsx                     ← Latest copy
```

---

## 🚀 Quick Start

### Option A — Node.js Simulator (No API needed)
```powershell
cd load-tests
npm install
npm test
# or: npm run full  (runs test + Excel report in one command)
```

### Option B — k6 (Real load tool)
```bash
# Install k6 first: https://k6.io/docs/getting-started/installation/
npm run k6

# With live API:
BASE_URL=http://localhost:3000 npm run k6:live
```

### Option C — Against Live API
```powershell
cd load-tests
npm install
BASE_URL=http://localhost:3000 VUS=100 DURATION_SEC=60 npm test
```

---

## 📊 What You'll See in the Console

```
╔════════════════════════════════════════════════════╗
║  🏥 MEDICATE — BASELINE LOAD TEST SIMULATOR        ║
╠════════════════════════════════════════════════════╣
║  Virtual Users  : 100                              ║
║  Duration       : 60s                              ║
║  Mode           : Simulation (no API)              ║
║  Endpoints      : 16                               ║
╚════════════════════════════════════════════════════╝

📊 Live Metrics:
⏱   15s | 🔄  118.3 req/s | 📦    1774 total | ❌  0.15% err | ⚡ avg  234ms | p95  521ms
⏱   30s | 🔄  116.8 req/s | 📦    3500 total | ❌  0.14% err | ⚡ avg  241ms | p95  534ms
...
```

### Final Results Table
```
╔════════════════════════════════════════════════════╗
║            📊 LOAD TEST RESULTS                    ║
╠═══════════════════════════╦════════════════════════╣
║  THROUGHPUT               ║  RESPONSE TIMES        ║
╠═══════════════════════════╬════════════════════════╣
║  Total Requests : 6,891   ║  Avg    : 247ms        ║
║  Successful     : 6,868   ║  Min    : 8ms          ║
║  Failed         : 23      ║  Max    : 1821ms       ║
║  Error Rate     : 0.33%   ║  p50    : 229ms        ║
║  RPS            : 112.6   ║  p90    : 432ms        ║
║                           ║  p95    : 542ms        ║
║                           ║  p99    : 891ms        ║
╚═══════════════════════════╩════════════════════════╝

✅ rps gt 50          : 112.6 req/s (target: > 50 req/s)
✅ avg lt 500ms       : 247ms       (target: < 500ms)
✅ p95 lt 1500ms      : 542ms       (target: < 1500ms)
✅ error rate lt 1pct : 0.33%       (target: < 1%)
✅ max lt 5000ms      : 1821ms      (target: < 5000ms)
```

---

## 📊 Excel Workbook — 5 Sheets

| Sheet | Contents |
|-------|---------|
| `📊 Executive Summary` | KPI blocks, configuration, overall status |
| `⏱️ Response Times` | Min/Avg/Max/p50/p90/p95/p99 with color bands + bar chart |
| `🔄 Throughput` | RPS timeline every 5 seconds with visual bars |
| `🌐 Endpoint Results` | All 16 endpoints with per-endpoint stats |
| `🚦 Thresholds` | Pass/Fail per SLA + remediation recommendations |

---

## 🌐 Endpoints Tested (16 total)

| Group | Endpoint | Weight |
|-------|---------|--------|
| Auth | POST `/api/v1/auth/login` | High |
| Patient | GET `/api/v1/patient/dashboard` | High |
| Patient | GET `/api/v1/patient/medicines` | Medium |
| Patient | GET `/api/v1/patient/medicines/reminders` | Medium |
| Patient | GET `/api/v1/patient/appointments` | Medium |
| Patient | GET `/api/v1/patient/appointments/upcoming` | Low |
| Patient | GET `/api/v1/patient/health-analytics` | Medium |
| Patient | GET `/api/v1/patient/vitals` | Medium |
| Doctor | GET `/api/v1/doctor/dashboard` | Low |
| Doctor | GET `/api/v1/doctor/appointments` | Low |
| Doctor | GET `/api/v1/doctor/patients` | Low |
| Shared | GET `/api/v1/doctors` | Low |
| Shared | GET `/api/v1/hospitals` | Low |
| Shared | GET `/api/v1/medicines` | Medium |
| Shared | GET `/api/v1/notifications` | Low |
| System | GET `/health` | Low |

---

## 🚦 Performance SLAs (Thresholds)

| Metric | Target | Why |
|--------|--------|-----|
| RPS | > 50 req/s | Minimum throughput for baseline |
| Avg Response | < 500ms | Good UX for mobile app |
| p95 Response | < 1500ms | 95% of users under 1.5s |
| p99 Response | < 2000ms | Tail latency acceptable |
| Error Rate | < 1% | Less than 1% failures |
| Max Response | < 5000ms | No single request over 5s |

---

## ⚙️ GitHub Actions Workflow

The [load-testing.yml](../.github/workflows/load-testing.yml) workflow has **5 jobs**:

```
setup ──► run-load-test ──► generate-excel-report ──► publish-summary
                                                              │
                                                         fail-gate
```

### Artifacts Downloaded from GitHub Actions

After every run, download from: **Actions → Your Run → Artifacts**

| Artifact Name | Contents | Retention |
|--------------|---------|-----------|
| `⚡ Load-Test-Excel-Report-Build-N` | Excel workbook (5 sheets) | 90 days |
| `⚡ Load-Test-Complete-Bundle-Build-N` | JSON + Excel | 90 days |
| `load-test-raw-results-N` | Raw JSON data | 30 days |

### Manual Workflow Dispatch Options

| Option | Values | Default |
|--------|--------|---------|
| API Base URL | Any URL | Simulation |
| Virtual Users | 50 / 100 / 200 / 500 | 100 |
| Duration | 30s / 60s / 120s / 300s | 60s |
| Use k6 | true / false | false |
| Fail on threshold | true / false | false |

---

## 📈 Interpreting Results

### Requests Per Second (RPS)

| RPS | Interpretation |
|-----|---------------|
| < 50 | ❌ Critically low — server bottleneck |
| 50–100 | ⚠️ Below expected for healthcare app |
| 100–300 | ✅ Good baseline performance |
| 300–1000 | 🚀 Excellent — well-optimized |
| > 1000 | 🏆 Outstanding throughput |

### Response Time Interpretation

| Time | Band | User Experience |
|------|------|----------------|
| 0–200ms | ⚡ Fast | Instant — users perceive as immediate |
| 200–500ms | 🟡 Acceptable | Users perceive slight delay |
| 500ms–1s | 🟠 Slow | Noticeable — users may feel lag |
| 1s–3s | 🔴 Poor | Users notice the wait |
| > 3s | 💀 Critical | Users likely to abandon |

---

## 🔧 Environment Variables

| Variable | Default | Description |
|---------|---------|-------------|
| `BASE_URL` | (none) | Live API URL — if empty, simulation runs |
| `VUS` | 100 | Number of concurrent virtual users |
| `DURATION_SEC` | 60 | Test duration in seconds |
| `RESULTS_FILE` | `results/load-test-results.json` | Input for Excel generator |
| `OUTPUT_DIR` | `reports/` | Excel output directory |
| `BUILD_NUMBER` | 0 | GitHub Actions build number |
| `BRANCH_NAME` | local | Git branch name |

---

*Medicate Load Test Suite v1.0 — Baseline: 100 VUs × 60s*
