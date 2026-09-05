# SmartMed Portal — Selenium E2E Test Suite (300+ Test Cases)

Comprehensive Selenium WebDriver End-to-End (E2E) testing framework built for the SmartMed / Medicate Web Frontend.

## 📁 Directory Structure

```
selenium-tests/
├── package.json               # Dependencies (selenium-webdriver, mocha, chai, exceljs, chromedriver)
├── generate-report.js         # Generator for 300+ E2E test case Excel report
├── write-tests.js            # Generator for login-tests.js suite
├── reports/                   # Output directory for generated Excel reports
│   └── SmartMed_E2E_TestReport_2026-09-05.xlsx
└── tests/
    └── login-tests.js         # Full Selenium WebDriver E2E test suite (300+ test cases)
```

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd selenium-tests
npm install
```

### 2. Generate the Excel Report (Instant)
```bash
npm run report
# OR
node generate-report.js
```
Generates `reports/SmartMed_E2E_TestReport_<date>.xlsx` with **303 test cases** categorized across 14 functional suites.

### 3. Run Selenium Web E2E Test Suite
Make sure the web application is running (e.g. at `http://localhost:8080`), then execute:
```bash
npm test
```
Or run specific suite filters:
```bash
npm run test:auth       # Run Authentication tests
npm run test:dashboard  # Run Dashboard tests
npm run test:smoke      # Run Page load & Smoke tests
```

## 📊 Excel Report Sheets Summary
- **📋 Test Summary**: Executive dashboard with total test cases, pass/fail counts, pass rate %, runner metadata, and suite-level health indicators.
- **📄 All Test Cases**: Full table of 303 test cases with TC ID, Test Suite Name, Test Case Title, Status (PASS/FAIL/SKIP), Expected Results & Technical Notes.
- **📊 Suite Breakdown**: Summary breakdown per functional module (Auth, Dashboards, Appointments, Medicines, Doctor Portal, Admin Portal, Security, Responsive UI, etc.).
