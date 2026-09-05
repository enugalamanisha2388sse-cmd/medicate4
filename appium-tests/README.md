# SmartMed Mobile — Appium E2E Tests

Comprehensive Appium E2E test suite for the **SmartMed / Medicate** Flutter mobile app.  
Covers **300+ test cases** across all roles (Patient, Doctor, Admin) and all major features.

---

## 📋 Test Suite Overview

| Suite | Tests | Role |
|-------|-------|------|
| 🚀 App Launch & Splash | 15 | All |
| 🎭 Role Selection Screen | 15 | All |
| 🔐 Login — Patient | 20 | Patient |
| 📝 Sign Up — Patient | 18 | Patient |
| 🏠 Patient Dashboard | 20 | Patient |
| 💊 Medicine Reminders & Trackers | 18 | Patient |
| 📅 Appointment Booking | 18 | Patient |
| 🏪 Medical Shop & Cart | 16 | Patient |
| 💉 Vaccination Screen | 15 | Patient |
| 🤖 AI Chat Assistant | 14 | Patient |
| 🚨 Emergency SOS | 12 | Patient |
| 📊 Health Analytics | 14 | Patient |
| 🩺 Bluetooth Vitals | 12 | Patient |
| 🏥 Hospital Map | 12 | Patient |
| 📷 RX Scanner | 12 | Patient |
| 🎥 Video Consultation | 12 | Patient |
| 🏃 Delivery Tracker | 10 | Patient |
| 🔑 Gate Pass | 10 | Patient |
| 👤 User Profile | 14 | Patient |
| 👨‍⚕️ Doctor Login & Dashboard | 16 | Doctor |
| 🏥 Admin Login & Dashboard | 14 | Admin |
| 🔒 Security & Session | 12 | All |
| ♿ Accessibility | 10 | All |
| ⚡ Performance | 10 | All |

**Total: 303 test cases**

---

## 🛠 Prerequisites

- **Appium Server** 2.x running: `appium`
- **Android Emulator** or physical device (API 24+)
- **Flutter app** built in debug mode: `flutter build apk --debug`
- **Node.js** 18+

### Install Dependencies
```bash
npm install
```

### Configure Device
Edit `config/appium.config.js` and set:
- `deviceName` — your emulator/device name
- `app` — path to your `.apk` or `.ipa` file

---

## ▶️ Running Tests

```bash
# All tests
npm test

# By role
npm run test:patient
npm run test:doctor
npm run test:admin

# Smoke tests only
npm run test:smoke

# Generate Excel report (static, no device needed)
npm run report

# Run tests + generate report
npm run test:report
```

---

## 📊 Output

After running, the Excel report is saved to:
```
reports/SmartMed_Appium_E2E_Report_YYYY-MM-DD.xlsx
```

**Sheets:**
1. **Test Summary** — Executive dashboard, pass rate, suite health
2. **All Test Cases** — All 303 rows, color-coded PASS/FAIL/SKIP
3. **Failed Tests** — Only failed cases for quick triage
4. **Suite Breakdown** — Per-suite totals and health indicators

---

## 🏗 Project Structure

```
appium-tests/
├── tests/
│   └── app-tests.js          ← Main test file (303 test cases)
├── config/
│   └── appium.config.js      ← Appium device/caps configuration
├── helpers/
│   └── driver.js             ← Driver factory & shared utilities
├── reports/                  ← Generated Excel reports (auto-created)
├── generate-report.js        ← Static Excel report generator
├── package.json
└── README.md
```
