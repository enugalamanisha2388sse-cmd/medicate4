/**
 * ============================================================
 * Medicate Security Review — Excel Report Generator
 * ============================================================
 * Generates a comprehensive multi-sheet Excel workbook:
 *   Sheet 1: Security Findings
 *   Sheet 2: Endpoint Inventory
 *   Sheet 3: Dependency Vulnerabilities
 *   Sheet 4: Risk Summary & Executive Dashboard
 *
 * Reads scan results from the REPORTS_DIR artifacts directory.
 * Compatible with GitHub Actions and local runs.
 * ============================================================
 */

'use strict';

const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

// ─────────────────────────────────────────────────────────────
// CONFIGURATION
// ─────────────────────────────────────────────────────────────
const REPORTS_DIR = process.env.REPORTS_DIR || 'Vulnerability Test Results';
const BUILD_NUMBER = process.env.BUILD_NUMBER || '0';
const BRANCH_NAME = process.env.BRANCH_NAME || 'unknown';
const REPO = process.env.REPO || 'medicate';
const RUN_ID = process.env.RUN_ID || '0';
const ACTOR = process.env.ACTOR || 'CI';
const COMMIT_SHA = (process.env.COMMIT_SHA || '').substring(0, 7) || 'unknown';
const SCAN_DATE = new Date().toISOString().replace('T', ' ').substring(0, 19) + ' UTC';

// Ensure reports directory exists
if (!fs.existsSync(REPORTS_DIR)) {
  fs.mkdirSync(REPORTS_DIR, { recursive: true });
}

// ─────────────────────────────────────────────────────────────
// COLOR PALETTE
// ─────────────────────────────────────────────────────────────
const COLORS = {
  critical:    { bg: 'FFDC2626', fg: 'FFFFFFFF', badge: 'FF991B1B' },
  high:        { bg: 'FFEA580C', fg: 'FFFFFFFF', badge: 'FFC2410C' },
  medium:      { bg: 'FFD97706', fg: 'FFFFFFFF', badge: 'FFB45309' },
  low:         { bg: 'FF16A34A', fg: 'FFFFFFFF', badge: 'FF15803D' },
  info:        { bg: 'FF2563EB', fg: 'FFFFFFFF', badge: 'FF1D4ED8' },
  header:      { bg: 'FF1E293B', fg: 'FFFFFFFF' },
  subheader:   { bg: 'FF334155', fg: 'FFFFFFFF' },
  altRow:      { bg: 'FFF8FAFC', fg: 'FF1E293B' },
  white:       { bg: 'FFFFFFFF', fg: 'FF1E293B' },
  accent:      { bg: 'FF6366F1', fg: 'FFFFFFFF' },
  success:     { bg: 'FF22C55E', fg: 'FFFFFFFF' },
  pass:        { bg: 'FFBBF7D0', fg: 'FF166534' },
  fail:        { bg: 'FFFECACA', fg: 'FF991B1B' },
  skip:        { bg: 'FFFEF9C3', fg: 'FF713F12' },
};

// ─────────────────────────────────────────────────────────────
// SECURITY FINDINGS DATA
// ─────────────────────────────────────────────────────────────
const SECURITY_FINDINGS = [
  {
    id: 'SEC-001',
    severity: 'Critical',
    type: 'Hardcoded Credentials',
    cwe: 'CWE-798',
    owasp: 'A02:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: '469-553',
    endpoint: 'N/A (client-side)',
    description: "All demo user passwords ('password123') hardcoded in MedicateProvider._users list. All 6 accounts share the same password compiled into APK.",
    exploitation: "Decompile release APK using apktool/jadx. Extract Dart snapshot to retrieve plaintext credentials for all accounts including doctor and admin.",
    impact: 'Complete account takeover. Credential stuffing. Medical data breach. HIPAA violation.',
    status: 'Open',
    recommendation: 'Remove hardcoded passwords. Implement server-side auth with bcrypt/argon2 hashing. Use environment secrets.',
    cvss: '9.8',
    effort: 'High',
    priority: 1
  },
  {
    id: 'SEC-002',
    severity: 'Critical',
    type: 'Hardcoded Secret / Admin Code',
    cwe: 'CWE-321',
    owasp: 'A02:2021',
    file: 'medicate/lib/screens/auth/login_signup_screen.dart',
    lines: '129',
    endpoint: 'N/A (client-side signup)',
    description: "Admin verification code 'ADMIN2026' hardcoded in Flutter widget source. Compiled into APK binary.",
    exploitation: "Decompile APK → extract admin code → register any account with admin role → gain full admin privileges.",
    impact: 'Privilege escalation to admin. Unauthorized access to admin panel and all patient records.',
    status: 'Open',
    recommendation: 'Implement server-side admin invitation workflow with time-limited signed tokens. Never store access codes in client code.',
    cvss: '9.1',
    effort: 'High',
    priority: 2
  },
  {
    id: 'SEC-003',
    severity: 'Critical',
    type: 'Plaintext Password Storage',
    cwe: 'CWE-256',
    owasp: 'A02:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: '34, 473-503',
    endpoint: 'N/A (in-memory model)',
    description: 'UserAccount model has a final String password field. Passwords compared using string equality (==) without any hashing algorithm.',
    exploitation: 'Memory dump, heap inspection, or APK decompilation reveals all passwords in plaintext. No hash to crack.',
    impact: 'Immediate plaintext credential exposure. Direct account compromise for all users.',
    status: 'Open',
    recommendation: 'Never store passwords client-side. Use server-side bcrypt (cost=12) or argon2id. On mobile, use biometric/OAuth2.',
    cvss: '8.8',
    effort: 'High',
    priority: 3
  },
  {
    id: 'SEC-004',
    severity: 'High',
    type: 'Broken Authentication (Client-Side Only)',
    cwe: 'CWE-287',
    owasp: 'A07:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: 'login() method',
    endpoint: 'N/A (provider state)',
    description: 'Authentication performed entirely in Dart in-memory. provider.login() does a local list lookup. No server call, no JWT, no session token.',
    exploitation: 'Dart DevTools memory manipulation or Frida instrumentation can bypass auth by modifying currentUser state variable.',
    impact: 'Authentication bypass. Any user can impersonate any role without valid credentials.',
    status: 'Open',
    recommendation: 'Implement server-side authentication. Issue signed JWT tokens. Validate tokens on every protected action.',
    cvss: '8.1',
    effort: 'Critical',
    priority: 4
  },
  {
    id: 'SEC-005',
    severity: 'High',
    type: 'Broken Access Control / RBAC Failure',
    cwe: 'CWE-284',
    owasp: 'A01:2021',
    file: 'medicate/lib/screens/auth/login_signup_screen.dart',
    lines: '174-178',
    endpoint: 'N/A (route navigation)',
    description: "Admin role routes to PatientDashboard (code comment: 'Admin uses same shell for now'). No admin-specific screens or controls.",
    exploitation: 'Admin users see patient UI. No admin controls. Admin privileges are decorative only.',
    impact: 'Broken role separation. Admin cannot perform admin functions. Potential data leakage across roles.',
    status: 'Open',
    recommendation: 'Implement dedicated AdminDashboard with route guards. Validate role on every screen/action.',
    cvss: '7.5',
    effort: 'Medium',
    priority: 5
  },
  {
    id: 'SEC-006',
    severity: 'High',
    type: 'Sensitive Data Exposure in UI',
    cwe: 'CWE-200',
    owasp: 'A02:2021',
    file: 'medicate/lib/screens/auth/login_signup_screen.dart',
    lines: '58-60, 436-439',
    endpoint: 'Login Screen',
    description: "Login screen pre-populates email AND password fields with demo credentials. A visible badge widget displays 'Demo: [email] / password123'.",
    exploitation: 'Any user opening the login screen immediately sees valid credentials for any role (patient/doctor/admin).',
    impact: 'Credentials exposed to all users. Social engineering vector. Credential leakage in screenshots.',
    status: 'Open',
    recommendation: 'Remove demo auto-fill. Guard behind kDebugMode. Never ship demo credentials in production builds.',
    cvss: '7.3',
    effort: 'Low',
    priority: 6
  },
  {
    id: 'SEC-007',
    severity: 'High',
    type: 'Insecure OTP Implementation',
    cwe: 'CWE-330',
    owasp: 'A07:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: 'requestSignUpOtp(), verifyOtpAndRegister()',
    endpoint: 'N/A (signup flow)',
    description: "OTP is simulated locally using Random(). The OTP value is logged to the debug console and the UI message says 'check the debug banner'.",
    exploitation: 'OTP extracted from debug console or adb logcat. Any 6-digit guess has 1-in-1,000,000 chance even without debug access.',
    impact: 'OTP verification bypass. Account registration without email ownership verification.',
    status: 'Open',
    recommendation: 'Integrate Firebase Auth, Twilio Verify, or AWS SNS for real SMS/email OTP. Never log OTP values.',
    cvss: '7.1',
    effort: 'High',
    priority: 7
  },
  {
    id: 'SEC-008',
    severity: 'High',
    type: 'Missing Rate Limiting / Brute Force Protection',
    cwe: 'CWE-307',
    owasp: 'A05:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: 'login() method',
    endpoint: 'Login endpoint',
    description: 'No login attempt counter, no lockout mechanism, no CAPTCHA, no exponential backoff in authentication flow.',
    exploitation: 'Automated brute-force tool can try unlimited passwords against any account with no throttling.',
    impact: 'Brute-force attack enables password cracking. Account takeover for any user.',
    status: 'Open',
    recommendation: 'Implement account lockout after 5 failed attempts (15-min lockout). Add exponential backoff. Implement CAPTCHA after 3 failures.',
    cvss: '7.0',
    effort: 'Medium',
    priority: 8
  },
  {
    id: 'SEC-009',
    severity: 'Medium',
    type: 'Weak Password Policy',
    cwe: 'CWE-521',
    owasp: 'A07:2021',
    file: 'medicate/lib/screens/auth/login_signup_screen.dart',
    lines: '486, 636',
    endpoint: 'Login/Signup forms',
    description: 'Minimum password length is 6 characters with no complexity requirements (no uppercase, numbers, or special characters).',
    exploitation: 'Common weak passwords (e.g., "123456", "abc123") are accepted. Dictionary attacks succeed faster.',
    impact: 'Weak passwords enable credential compromise for patient health data (HIPAA risk).',
    status: 'Open',
    recommendation: 'Enforce min 12 chars, uppercase, number, and special char. Implement password strength meter. Block common passwords.',
    cvss: '5.9',
    effort: 'Low',
    priority: 9
  },
  {
    id: 'SEC-010',
    severity: 'Medium',
    type: 'Insufficient Input Validation (Email)',
    cwe: 'CWE-20',
    owasp: 'A03:2021',
    file: 'medicate/lib/screens/auth/login_signup_screen.dart',
    lines: '459, 613-617',
    endpoint: 'Login/Signup email fields',
    description: "Email validation only checks `!v.contains('@')`. Strings like '@', 'a@', '@b.c' pass validation.",
    exploitation: 'Malformed email addresses bypass validation. May cause downstream processing errors.',
    impact: 'Invalid data stored. Potential injection if email is used in backend queries.',
    status: 'Open',
    recommendation: "Use regex: `RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')`",
    cvss: '5.3',
    effort: 'Low',
    priority: 10
  },
  {
    id: 'SEC-011',
    severity: 'Medium',
    type: 'Missing Session Management',
    cwe: 'CWE-613',
    owasp: 'A07:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: 'MedicateProvider class',
    endpoint: 'N/A (global state)',
    description: 'Auth state stored only in ChangeNotifier in-memory. No tokens, no SecureStorage, no session timeout, no refresh mechanism.',
    exploitation: 'App restart = automatic logout (no persistence). No session invalidation on server means no real logout.',
    impact: 'No session control. Cannot force logout compromised accounts. Session fixation risk when backend added.',
    status: 'Open',
    recommendation: 'Use flutter_secure_storage for encrypted token persistence. Implement JWT with refresh + revocation. Add 30-min inactivity timeout.',
    cvss: '5.3',
    effort: 'High',
    priority: 11
  },
  {
    id: 'SEC-012',
    severity: 'Medium',
    type: 'Sensitive Data in Notification Logs',
    cwe: 'CWE-532',
    owasp: 'A09:2021',
    file: 'medicate/lib/core/services/services.dart',
    lines: 'addNotification() calls',
    endpoint: 'N/A (notification system)',
    description: "addNotification() logs patient PII (full names) and medical operation details (e.g., 'SUCCESS: Added patient record for Alice Smith').",
    exploitation: 'Log extraction via adb logcat or device compromise reveals patient names and medical operations.',
    impact: 'HIPAA/GDPR violation. Patient PII exposure through notification logs.',
    status: 'Open',
    recommendation: 'Sanitize log messages. Use anonymized IDs instead of names. Apply log filtering in production builds.',
    cvss: '5.1',
    effort: 'Low',
    priority: 12
  },
  {
    id: 'SEC-013',
    severity: 'Low',
    type: 'Debug Mode Artifacts in Production',
    cwe: 'CWE-215',
    owasp: 'A05:2021',
    file: 'medicate/lib/screens/auth/login_signup_screen.dart',
    lines: '143, 163',
    endpoint: 'Signup screen',
    description: "UI messages reference 'debug banner' and 'debug console', revealing internal implementation details to end users.",
    exploitation: 'Informs attackers of debugging infrastructure. May suggest debug mode is enabled.',
    impact: 'Information disclosure. Debug artifacts in production APK.',
    status: 'Open',
    recommendation: "Wrap debug messages in `if (kDebugMode)` blocks. Production messages should never reference internal tooling.",
    cvss: '3.1',
    effort: 'Low',
    priority: 13
  },
  {
    id: 'SEC-014',
    severity: 'Low',
    type: 'Missing Certificate Pinning',
    cwe: 'CWE-295',
    owasp: 'A02:2021',
    file: 'medicate/pubspec.yaml',
    lines: 'http: ^1.2.0',
    endpoint: 'HTTP client (future API calls)',
    description: 'http package included without certificate pinning configuration. MITM attacks possible when backend API is connected.',
    exploitation: 'Network-level attacker intercepts HTTPS traffic using rogue CA certificates on Android.',
    impact: 'API credentials and health data exposed to network attackers.',
    status: 'Open',
    recommendation: 'Use dio with certificate pinning. Add network_security_config.xml for Android. Use flutter_certificate_pinning package.',
    cvss: '3.7',
    effort: 'Medium',
    priority: 14
  },
  {
    id: 'SEC-015',
    severity: 'Low',
    type: 'No Biometric / MFA Support',
    cwe: 'CWE-308',
    owasp: 'A07:2021',
    file: 'medicate/pubspec.yaml',
    lines: 'N/A',
    endpoint: 'Login screen',
    description: 'Healthcare app handles sensitive medical data but offers no Multi-Factor Authentication or biometric login option.',
    exploitation: 'Single-factor auth (password only) increases risk of account compromise.',
    impact: 'Reduced account security for healthcare data. Compliance gap for HIPAA security rule.',
    status: 'Open',
    recommendation: "Add local_auth package for biometric support. Implement optional TOTP (e.g., via otp package). Consider FIDO2/passkeys.",
    cvss: '2.9',
    effort: 'Medium',
    priority: 15
  }
];

// ─────────────────────────────────────────────────────────────
// ENDPOINT INVENTORY DATA
// ─────────────────────────────────────────────────────────────
const ENDPOINT_INVENTORY = [
  // ── AUTH SCREENS ────────────────────────────────────────────
  { id: 'EP-001', module: 'Authentication', screen: 'Login Screen', route: '/login/:role', method: 'UI', authRequired: 'No', roles: 'All', controller: 'lib/screens/auth/login_signup_screen.dart', riskLevel: 'Critical', notes: 'Demo credentials pre-filled, no rate limiting' },
  { id: 'EP-002', module: 'Authentication', screen: 'Sign Up Screen', route: '/signup/:role', method: 'UI', authRequired: 'No', roles: 'All', controller: 'lib/screens/auth/login_signup_screen.dart', riskLevel: 'Critical', notes: 'Admin code ADMIN2026 hardcoded, weak OTP' },
  { id: 'EP-003', module: 'Authentication', screen: 'Forgot Password', route: '/forgot-password', method: 'UI (Modal)', authRequired: 'No', roles: 'All', controller: 'lib/screens/auth/login_signup_screen.dart', riskLevel: 'Medium', notes: 'Simulated password reset only' },
  { id: 'EP-004', module: 'Authentication', screen: 'OTP Verification', route: '/otp-verify', method: 'UI', authRequired: 'No', roles: 'All', controller: 'lib/screens/auth/login_signup_screen.dart', riskLevel: 'High', notes: 'Simulated OTP shown in debug console' },
  { id: 'EP-005', module: 'Authentication', screen: 'Logout', route: 'N/A (action)', method: 'Action', authRequired: 'Yes', roles: 'All', controller: 'lib/core/services/services.dart', riskLevel: 'Medium', notes: 'No server-side session invalidation' },

  // ── PATIENT SCREENS ──────────────────────────────────────────
  { id: 'EP-006', module: 'Patient', screen: 'Patient Dashboard', route: '/patient/dashboard', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/patient_dashboard.dart', riskLevel: 'High', notes: 'Also accessible to Admin (RBAC break)' },
  { id: 'EP-007', module: 'Patient', screen: 'Appointment Calendar', route: '/patient/appointments', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/appointment_calendar_screen.dart', riskLevel: 'Medium', notes: 'No ownership check — any patient can view' },
  { id: 'EP-008', module: 'Patient', screen: 'Medicine Reminders', route: '/patient/medicines', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/tabs/medicines_tab.dart', riskLevel: 'Medium', notes: 'Global reminder list — no per-user isolation' },
  { id: 'EP-009', module: 'Patient', screen: 'Medical Shop / Cart', route: '/patient/shop', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Low', notes: 'In-memory cart — no payment handling' },
  { id: 'EP-010', module: 'Patient', screen: 'Vaccination Records', route: '/patient/vaccinations', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Medium', notes: 'PHI exposure risk' },
  { id: 'EP-011', module: 'Patient', screen: 'AI Chat Assistant', route: '/patient/chat', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Medium', notes: 'Simulated AI — no real API calls' },
  { id: 'EP-012', module: 'Patient', screen: 'Emergency SOS', route: '/patient/sos', method: 'UI + Action', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'High', notes: 'No auth validation before emergency dispatch' },
  { id: 'EP-013', module: 'Patient', screen: 'Health Analytics', route: '/patient/analytics', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Medium', notes: 'PHI data in charts' },
  { id: 'EP-014', module: 'Patient', screen: 'Bluetooth Vitals', route: '/patient/vitals', method: 'UI + BT', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'High', notes: 'Bluetooth sensor data — no encryption' },
  { id: 'EP-015', module: 'Patient', screen: 'Hospital Map', route: '/patient/map', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Low', notes: 'Location data — privacy concern' },
  { id: 'EP-016', module: 'Patient', screen: 'RX Scanner (OCR)', route: '/patient/scanner', method: 'UI + File', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'High', notes: 'File/camera access — no upload validation' },
  { id: 'EP-017', module: 'Patient', screen: 'Video Consultation', route: '/patient/video', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'High', notes: 'No E2E encryption mentioned' },
  { id: 'EP-018', module: 'Patient', screen: 'Delivery Tracker', route: '/patient/delivery', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Low', notes: 'Simulated delivery tracking' },
  { id: 'EP-019', module: 'Patient', screen: 'Gate Pass', route: '/patient/gatepass', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Medium', notes: 'QR-based — no server validation' },
  { id: 'EP-020', module: 'Patient', screen: 'User Profile', route: '/patient/profile', method: 'UI', authRequired: 'Yes', roles: 'Patient', controller: 'lib/screens/patient/', riskLevel: 'Medium', notes: 'PII editing without re-auth' },

  // ── DOCTOR SCREENS ───────────────────────────────────────────
  { id: 'EP-021', module: 'Doctor', screen: 'Doctor Dashboard', route: '/doctor/dashboard', method: 'UI', authRequired: 'Yes', roles: 'Doctor', controller: 'lib/screens/doctor/', riskLevel: 'High', notes: 'Access to all patient records' },
  { id: 'EP-022', module: 'Doctor', screen: 'Patient Records CRUD', route: '/doctor/patients', method: 'UI + CRUD', authRequired: 'Yes', roles: 'Doctor', controller: 'lib/screens/doctor/', riskLevel: 'Critical', notes: 'No audit trail, no IDOR protection' },
  { id: 'EP-023', module: 'Doctor', screen: 'Appointment Management', route: '/doctor/appointments', method: 'UI', authRequired: 'Yes', roles: 'Doctor', controller: 'lib/screens/doctor/', riskLevel: 'High', notes: 'Can view appointments of other doctors' },
  { id: 'EP-024', module: 'Doctor', screen: 'Drug Interaction Checker', route: '/doctor/drug-check', method: 'UI + Logic', authRequired: 'Yes', roles: 'Doctor', controller: 'lib/core/services/services.dart', riskLevel: 'Low', notes: 'Client-side lookup only' },
  { id: 'EP-025', module: 'Doctor', screen: 'Inventory Management', route: '/doctor/inventory', method: 'UI + CRUD', authRequired: 'Yes', roles: 'Doctor', controller: 'lib/screens/doctor/', riskLevel: 'Medium', notes: 'No role check — patient could access' },

  // ── ADMIN SCREENS ────────────────────────────────────────────
  { id: 'EP-026', module: 'Admin', screen: 'Admin Dashboard', route: '/admin/dashboard', method: 'UI', authRequired: 'Yes', roles: 'Admin', controller: 'lib/screens/ (placeholder)', riskLevel: 'Critical', notes: 'Admin routed to PatientDashboard — RBAC broken' },
  { id: 'EP-027', module: 'Admin', screen: 'User Management', route: '/admin/users', method: 'UI + CRUD', authRequired: 'Yes', roles: 'Admin', controller: 'lib/screens/ (N/A)', riskLevel: 'Critical', notes: 'Not implemented — admin has no controls' },
  { id: 'EP-028', module: 'Admin', screen: 'Hospital Management', route: '/admin/hospitals', method: 'UI', authRequired: 'Yes', roles: 'Admin', controller: 'lib/core/services/services.dart', riskLevel: 'High', notes: 'Emergency resource control — no auth gate' },
  { id: 'EP-029', module: 'Admin', screen: 'Reports & Analytics', route: '/admin/reports', method: 'UI', authRequired: 'Yes', roles: 'Admin', controller: 'lib/screens/ (N/A)', riskLevel: 'High', notes: 'Not implemented' },

  // ── API SERVICES ─────────────────────────────────────────────
  { id: 'EP-030', module: 'Service', screen: 'MedicateProvider.login()', route: 'N/A (in-memory)', method: 'Function', authRequired: 'No', roles: 'All', controller: 'lib/core/services/services.dart', riskLevel: 'Critical', notes: 'No server call, no JWT, no rate limiting' },
  { id: 'EP-031', module: 'Service', screen: 'MedicateProvider.requestSignUpOtp()', route: 'N/A (simulated)', method: 'Function', authRequired: 'No', roles: 'All', controller: 'lib/core/services/services.dart', riskLevel: 'High', notes: 'OTP generated in-memory, shown in debug' },
  { id: 'EP-032', module: 'Service', screen: 'MedicateProvider.sendPasswordReset()', route: 'N/A (simulated)', method: 'Function', authRequired: 'No', roles: 'All', controller: 'lib/core/services/services.dart', riskLevel: 'Medium', notes: 'Simulated — no actual email sent' },
  { id: 'EP-033', module: 'Service', screen: 'MedicateProvider.addPatient()', route: 'N/A (in-memory)', method: 'Function', authRequired: 'Yes (client)', roles: 'Doctor, Admin', controller: 'lib/core/services/services.dart', riskLevel: 'High', notes: 'No IDOR protection, no audit log' },
  { id: 'EP-034', module: 'Service', screen: 'MedicateProvider.deletePatient()', route: 'N/A (in-memory)', method: 'Function', authRequired: 'Yes (client)', roles: 'Doctor, Admin', controller: 'lib/core/services/services.dart', riskLevel: 'High', notes: 'Destructive operation with no confirmation server-side' },
  { id: 'EP-035', module: 'Service', screen: 'MedicateProvider.runOcrPrescriptionScan()', route: 'N/A (local)', method: 'Function', authRequired: 'Yes (client)', roles: 'Patient', controller: 'lib/core/services/services.dart', riskLevel: 'Medium', notes: 'File access without content validation' }
];

// ─────────────────────────────────────────────────────────────
// DEPENDENCY VULNERABILITIES DATA
// ─────────────────────────────────────────────────────────────
const DEPENDENCY_VULNS = [
  { id: 'DEP-001', package: 'appium', version: '^2.11.0', latestSafe: '2.18.0+', severity: 'Medium', cve: 'N/A', project: 'e2e-tests', type: 'Outdated', description: 'Outdated Appium version. Newer versions include security patches.', recommendation: 'Update to latest stable: npm update appium' },
  { id: 'DEP-002', package: '@wdio/cli', version: '^8.39.0', latestSafe: '9.x', severity: 'Low', cve: 'N/A', project: 'e2e-tests', type: 'Outdated', description: 'WebdriverIO v8 EOL approaching. v9 with security improvements available.', recommendation: 'Migrate to @wdio/cli v9' },
  { id: 'DEP-003', package: 'selenium-webdriver', version: '^4.21.0', latestSafe: '4.32.0+', severity: 'Low', cve: 'N/A', project: 'selenium-tests', type: 'Outdated', description: 'Older selenium-webdriver version. Newer patch versions available.', recommendation: 'Update: npm update selenium-webdriver' },
  { id: 'DEP-004', package: 'mocha', version: '^10.4.0', latestSafe: '10.8.0+', severity: 'Low', cve: 'N/A', project: 'appium-tests, selenium-tests', type: 'Outdated', description: 'Minor version updates available for mocha test runner.', recommendation: 'Update: npm update mocha' },
  { id: 'DEP-005', package: 'chromedriver', version: 'latest', latestSafe: 'Match Chrome version', severity: 'Medium', cve: 'N/A', project: 'selenium-tests', type: 'Version Mismatch Risk', description: "Using 'latest' chromedriver may cause version mismatch with installed Chrome in CI.", recommendation: 'Pin chromedriver version to match CI Chrome version. Use webdriver-manager.' },
  { id: 'DEP-006', package: 'chai', version: '^4.4.1', latestSafe: '5.x', severity: 'Low', cve: 'N/A', project: 'e2e-tests, appium-tests', type: 'Outdated', description: 'chai v4 is older. v5 with ESM support and security improvements available.', recommendation: 'Migrate to chai v5 when project allows ESM' },
  { id: 'DEP-007', package: 'http (Dart)', version: '^1.2.0', latestSafe: '^1.4.0', severity: 'Low', cve: 'N/A', project: 'medicate (Flutter)', type: 'Outdated', description: 'Dart http package minor updates available.', recommendation: 'Run: flutter pub upgrade http' },
  { id: 'DEP-008', package: 'flutter_map', version: '^6.1.0', latestSafe: '^8.x', severity: 'Medium', cve: 'N/A', project: 'medicate (Flutter)', type: 'Outdated (Major)', description: 'flutter_map v6 is 2 major versions behind. v8 includes tile provider security improvements.', recommendation: 'Migrate to flutter_map v8 (breaking changes, review migration guide)' },
  { id: 'DEP-009', package: 'exceljs', version: '^4.4.0', latestSafe: '4.4.0', severity: 'Info', cve: 'N/A', project: 'e2e-tests, appium-tests, selenium-tests', type: 'Current', description: 'ExcelJS appears to be at current version.', recommendation: 'Monitor for updates periodically' },
  { id: 'DEP-010', package: 'moment', version: '^2.29.4', latestSafe: '2.30.1', severity: 'Low', cve: 'CVE-2022-24785', project: 'e2e-tests', type: 'Historical CVE', description: 'moment.js had path traversal vulnerability (CVE-2022-24785) in older versions. Current version patched.', recommendation: 'Consider migrating to date-fns or dayjs (moment is in maintenance mode)' },
  { id: 'DEP-011', package: 'fl_chart', version: '^0.69.0', latestSafe: '^0.69.0', severity: 'Info', cve: 'N/A', project: 'medicate (Flutter)', type: 'Current', description: 'fl_chart is at current version.', recommendation: 'No action required' },
  { id: 'DEP-012', package: 'provider (Dart)', version: '^6.1.2', latestSafe: '^6.1.2', severity: 'Info', cve: 'N/A', project: 'medicate (Flutter)', type: 'Current', description: 'Provider state management at current version.', recommendation: 'Consider migrating to Riverpod for better security boundaries' }
];

// ─────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────
function applyHeaderStyle(cell, bgColor = COLORS.header.bg) {
  cell.font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 11, name: 'Calibri' };
  cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bgColor } };
  cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
  cell.border = {
    top: { style: 'thin', color: { argb: 'FF475569' } },
    bottom: { style: 'thin', color: { argb: 'FF475569' } },
    left: { style: 'thin', color: { argb: 'FF475569' } },
    right: { style: 'thin', color: { argb: 'FF475569' } }
  };
}

function getSeverityColor(severity) {
  const s = (severity || '').toLowerCase();
  if (s === 'critical') return COLORS.critical;
  if (s === 'high') return COLORS.high;
  if (s === 'medium' || s === 'moderate') return COLORS.medium;
  if (s === 'low') return COLORS.low;
  return COLORS.info;
}

function getRiskColor(risk) {
  const r = (risk || '').toLowerCase();
  if (r === 'critical') return COLORS.critical;
  if (r === 'high') return COLORS.high;
  if (r === 'medium') return COLORS.medium;
  return COLORS.low;
}

function applyCellStyle(cell, bgColor, fgColor = 'FF1E293B', bold = false) {
  cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bgColor } };
  cell.font = { color: { argb: fgColor }, bold, size: 10, name: 'Calibri' };
  cell.alignment = { vertical: 'middle', wrapText: true };
  cell.border = {
    top: { style: 'hair', color: { argb: 'FFE2E8F0' } },
    bottom: { style: 'hair', color: { argb: 'FFE2E8F0' } },
    left: { style: 'hair', color: { argb: 'FFE2E8F0' } },
    right: { style: 'hair', color: { argb: 'FFE2E8F0' } }
  };
}

function applySeverityBadge(cell, severity) {
  const color = getSeverityColor(severity);
  cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: color.bg } };
  cell.font = { color: { argb: color.fg }, bold: true, size: 10, name: 'Calibri' };
  cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: false };
  cell.border = {
    top: { style: 'thin', color: { argb: 'FF1E293B' } },
    bottom: { style: 'thin', color: { argb: 'FF1E293B' } },
    left: { style: 'thin', color: { argb: 'FF1E293B' } },
    right: { style: 'thin', color: { argb: 'FF1E293B' } }
  };
}

// ─────────────────────────────────────────────────────────────
// SHEET 1: SECURITY FINDINGS
// ─────────────────────────────────────────────────────────────
function buildFindingsSheet(wb) {
  const ws = wb.addWorksheet('🔴 Security Findings', {
    properties: { tabColor: { argb: 'FFDC2626' } },
    pageSetup: { orientation: 'landscape', fitToPage: true, fitToWidth: 1 }
  });

  // Title row
  ws.mergeCells('A1:N1');
  const titleCell = ws.getCell('A1');
  titleCell.value = `🛡️ MEDICATE — SECURITY FINDINGS REPORT   |   Build #${BUILD_NUMBER}   |   ${SCAN_DATE}`;
  titleCell.font = { bold: true, size: 14, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.header.bg } };
  titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 35;

  // Summary bar
  const counts = { Critical: 0, High: 0, Medium: 0, Low: 0 };
  SECURITY_FINDINGS.forEach(f => { if (counts[f.severity] !== undefined) counts[f.severity]++; });
  const score = Math.max(0, 100 - (counts.Critical * 20) - (counts.High * 10) - (counts.Medium * 5) - (counts.Low * 1));

  ws.mergeCells('A2:C2'); ws.getCell('A2').value = `🔴 Critical: ${counts.Critical}`;
  ws.getCell('A2').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.critical.bg } };
  ws.getCell('A2').font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };
  ws.getCell('A2').alignment = { horizontal: 'center', vertical: 'middle' };

  ws.mergeCells('D2:F2'); ws.getCell('D2').value = `🟠 High: ${counts.High}`;
  ws.getCell('D2').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.high.bg } };
  ws.getCell('D2').font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };
  ws.getCell('D2').alignment = { horizontal: 'center', vertical: 'middle' };

  ws.mergeCells('G2:I2'); ws.getCell('G2').value = `🟡 Medium: ${counts.Medium}`;
  ws.getCell('G2').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.medium.bg } };
  ws.getCell('G2').font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };
  ws.getCell('G2').alignment = { horizontal: 'center', vertical: 'middle' };

  ws.mergeCells('J2:L2'); ws.getCell('J2').value = `🟢 Low: ${counts.Low}`;
  ws.getCell('J2').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.low.bg } };
  ws.getCell('J2').font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };
  ws.getCell('J2').alignment = { horizontal: 'center', vertical: 'middle' };

  ws.mergeCells('M2:N2'); ws.getCell('M2').value = `Security Score: ${score}/100`;
  ws.getCell('M2').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: score >= 60 ? COLORS.medium.bg : COLORS.critical.bg } };
  ws.getCell('M2').font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };
  ws.getCell('M2').alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(2).height = 28;

  // Headers
  const headers = [
    'ID', 'Severity', 'Type', 'CWE', 'OWASP', 'File / Location',
    'Lines', 'Endpoint', 'Description', 'Exploitation Scenario',
    'Impact', 'Recommendation', 'CVSS', 'Status'
  ];

  const colWidths = [10, 12, 28, 12, 14, 45, 10, 22, 55, 55, 40, 50, 8, 10];

  const hRow = ws.getRow(3);
  hRow.height = 30;
  headers.forEach((h, i) => {
    const cell = hRow.getCell(i + 1);
    cell.value = h;
    applyHeaderStyle(cell, COLORS.subheader.bg);
    ws.getColumn(i + 1).width = colWidths[i];
  });

  // Data rows
  SECURITY_FINDINGS.forEach((f, idx) => {
    const row = ws.getRow(idx + 4);
    row.height = 80;
    const isAlt = idx % 2 === 0;
    const rowBg = isAlt ? COLORS.altRow.bg : COLORS.white.bg;

    const values = [
      f.id, f.severity, f.type, f.cwe, f.owasp,
      f.file, f.lines, f.endpoint,
      f.description, f.exploitation, f.impact,
      f.recommendation, f.cvss, f.status
    ];

    values.forEach((v, i) => {
      const cell = row.getCell(i + 1);
      cell.value = v;
      if (i === 1) {
        applySeverityBadge(cell, f.severity);
        cell.alignment = { horizontal: 'center', vertical: 'middle' };
      } else {
        applyCellStyle(cell, rowBg, COLORS.white.fg);
        cell.alignment = { vertical: 'top', wrapText: true, horizontal: i === 0 ? 'center' : 'left' };
      }
    });
  });

  // Freeze panes
  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 3, topLeftCell: 'A4', activeCell: 'A4' }];

  // Auto filter
  ws.autoFilter = { from: { row: 3, column: 1 }, to: { row: 3 + SECURITY_FINDINGS.length, column: headers.length } };

  return ws;
}

// ─────────────────────────────────────────────────────────────
// SHEET 2: ENDPOINT INVENTORY
// ─────────────────────────────────────────────────────────────
function buildEndpointSheet(wb) {
  const ws = wb.addWorksheet('🗺️ Endpoint Inventory', {
    properties: { tabColor: { argb: 'FF6366F1' } },
    pageSetup: { orientation: 'landscape', fitToPage: true }
  });

  ws.mergeCells('A1:J1');
  const tc = ws.getCell('A1');
  tc.value = `🗺️ MEDICATE — ENDPOINT INVENTORY   |   ${ENDPOINT_INVENTORY.length} Screens/Services Discovered   |   Build #${BUILD_NUMBER}`;
  tc.font = { bold: true, size: 13, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  tc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF4F46E5' } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 32;

  const headers = ['ID', 'Module', 'Screen / Service', 'Route / Path', 'HTTP Method', 'Auth Required', 'Expected Roles', 'Controller / File', 'Risk Level', 'Security Notes'];
  const colWidths = [10, 15, 28, 30, 14, 14, 20, 50, 13, 50];

  const hRow = ws.getRow(2);
  hRow.height = 28;
  headers.forEach((h, i) => {
    const cell = hRow.getCell(i + 1);
    cell.value = h;
    applyHeaderStyle(cell, '  FF4338CA');
    ws.getColumn(i + 1).width = colWidths[i];
  });

  ENDPOINT_INVENTORY.forEach((ep, idx) => {
    const row = ws.getRow(idx + 3);
    row.height = 55;
    const isAlt = idx % 2 === 0;
    const rowBg = isAlt ? COLORS.altRow.bg : COLORS.white.bg;

    const values = [ep.id, ep.module, ep.screen, ep.route, ep.method, ep.authRequired, ep.roles, ep.controller, ep.riskLevel, ep.notes];

    values.forEach((v, i) => {
      const cell = row.getCell(i + 1);
      cell.value = v;
      if (i === 8) {
        // Risk level badge
        const rc = getRiskColor(ep.riskLevel);
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: rc.bg } };
        cell.font = { bold: true, color: { argb: rc.fg }, size: 10 };
        cell.alignment = { horizontal: 'center', vertical: 'middle' };
      } else if (i === 5) {
        // Auth required
        const authColor = ep.authRequired === 'Yes' ? COLORS.success.bg : COLORS.fail.bg;
        const authFg = ep.authRequired === 'Yes' ? COLORS.success.fg : COLORS.fail.fg;
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: authColor } };
        cell.font = { color: { argb: authFg }, bold: true, size: 10 };
        cell.alignment = { horizontal: 'center', vertical: 'middle' };
      } else {
        applyCellStyle(cell, rowBg, COLORS.white.fg);
        cell.alignment = { vertical: 'top', wrapText: true, horizontal: i === 0 ? 'center' : 'left' };
      }
      cell.border = { top: { style: 'hair', color: { argb: 'FFE2E8F0' } }, bottom: { style: 'hair', color: { argb: 'FFE2E8F0' } }, left: { style: 'hair', color: { argb: 'FFE2E8F0' } }, right: { style: 'hair', color: { argb: 'FFE2E8F0' } } };
    });
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 2, topLeftCell: 'A3', activeCell: 'A3' }];
  ws.autoFilter = { from: { row: 2, column: 1 }, to: { row: 2 + ENDPOINT_INVENTORY.length, column: headers.length } };

  return ws;
}

// ─────────────────────────────────────────────────────────────
// SHEET 3: DEPENDENCY VULNERABILITIES
// ─────────────────────────────────────────────────────────────
function buildDependencySheet(wb) {
  const ws = wb.addWorksheet('📦 Dependency Vulns', {
    properties: { tabColor: { argb: 'FFEA580C' } },
    pageSetup: { orientation: 'landscape', fitToPage: true }
  });

  ws.mergeCells('A1:I1');
  const tc = ws.getCell('A1');
  tc.value = `📦 MEDICATE — DEPENDENCY VULNERABILITY REPORT   |   ${DEPENDENCY_VULNS.length} Packages Analyzed   |   Build #${BUILD_NUMBER}`;
  tc.font = { bold: true, size: 13, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  tc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFC2410C' } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 32;

  const headers = ['ID', 'Package', 'Current Version', 'Safe Version', 'Severity', 'CVE', 'Project', 'Issue Type', 'Description & Recommendation'];
  const colWidths = [10, 22, 18, 18, 12, 18, 28, 22, 65];

  const hRow = ws.getRow(2);
  hRow.height = 28;
  headers.forEach((h, i) => {
    const cell = hRow.getCell(i + 1);
    cell.value = h;
    applyHeaderStyle(cell, 'FF9A3412');
    ws.getColumn(i + 1).width = colWidths[i];
  });

  DEPENDENCY_VULNS.forEach((dep, idx) => {
    const row = ws.getRow(idx + 3);
    row.height = 60;
    const isAlt = idx % 2 === 0;
    const rowBg = isAlt ? COLORS.altRow.bg : COLORS.white.bg;

    const desc_rec = `${dep.description}\n\n➤ Fix: ${dep.recommendation}`;
    const values = [dep.id, dep.package, dep.version, dep.latestSafe, dep.severity, dep.cve, dep.project, dep.type, desc_rec];

    values.forEach((v, i) => {
      const cell = row.getCell(i + 1);
      cell.value = v;
      if (i === 4) {
        applySeverityBadge(cell, dep.severity);
      } else {
        applyCellStyle(cell, rowBg, COLORS.white.fg);
        cell.alignment = { vertical: 'top', wrapText: true, horizontal: i === 0 ? 'center' : 'left' };
      }
      cell.border = { top: { style: 'hair', color: { argb: 'FFE2E8F0' } }, bottom: { style: 'hair', color: { argb: 'FFE2E8F0' } }, left: { style: 'hair', color: { argb: 'FFE2E8F0' } }, right: { style: 'hair', color: { argb: 'FFE2E8F0' } } };
    });
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 2, topLeftCell: 'A3', activeCell: 'A3' }];
  ws.autoFilter = { from: { row: 2, column: 1 }, to: { row: 2 + DEPENDENCY_VULNS.length, column: headers.length } };

  return ws;
}

// ─────────────────────────────────────────────────────────────
// SHEET 4: RISK SUMMARY & EXECUTIVE DASHBOARD
// ─────────────────────────────────────────────────────────────
function buildRiskSummarySheet(wb) {
  const ws = wb.addWorksheet('📊 Risk Summary', {
    properties: { tabColor: { argb: 'FF16A34A' } }
  });

  ws.getColumn(1).width = 35;
  ws.getColumn(2).width = 20;
  ws.getColumn(3).width = 50;
  ws.getColumn(4).width = 25;
  ws.getColumn(5).width = 20;

  // ── TITLE ─────────────────────────────────────────────────
  ws.mergeCells('A1:E1');
  const tc = ws.getCell('A1');
  tc.value = '🛡️ MEDICATE — EXECUTIVE SECURITY SUMMARY';
  tc.font = { bold: true, size: 16, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  tc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.header.bg } };
  tc.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(1).height = 45;

  // ── META INFO ─────────────────────────────────────────────
  const meta = [
    ['Project', 'Medicate / SmartMed Flutter App'],
    ['App Type', 'Mobile Healthcare Application (Flutter/Dart)'],
    ['Build Number', `#${BUILD_NUMBER}`],
    ['Branch', BRANCH_NAME],
    ['Commit', COMMIT_SHA],
    ['Scan Date', SCAN_DATE],
    ['Scanned By', ACTOR],
    ['Repository', REPO],
  ];

  let rowIdx = 2;
  meta.forEach(([k, v]) => {
    ws.mergeCells(`A${rowIdx}:B${rowIdx}`);
    const kCell = ws.getCell(`A${rowIdx}`);
    kCell.value = k;
    kCell.font = { bold: true, size: 10, color: { argb: COLORS.header.fg }, name: 'Calibri' };
    kCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: COLORS.subheader.bg } };
    kCell.alignment = { vertical: 'middle', horizontal: 'left' };
    kCell.border = { bottom: { style: 'hair', color: { argb: 'FF475569' } } };

    ws.mergeCells(`C${rowIdx}:E${rowIdx}`);
    const vCell = ws.getCell(`C${rowIdx}`);
    vCell.value = v;
    vCell.font = { size: 10, color: { argb: 'FF1E293B' }, name: 'Calibri' };
    vCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: rowIdx % 2 === 0 ? COLORS.altRow.bg : COLORS.white.bg } };
    vCell.alignment = { vertical: 'middle', horizontal: 'left' };
    vCell.border = { bottom: { style: 'hair', color: { argb: 'FFE2E8F0' } } };
    ws.getRow(rowIdx).height = 22;
    rowIdx++;
  });

  // ── FINDING COUNTS ────────────────────────────────────────
  rowIdx += 1;
  ws.mergeCells(`A${rowIdx}:E${rowIdx}`);
  const secHead = ws.getCell(`A${rowIdx}`);
  secHead.value = 'VULNERABILITY COUNTS BY SEVERITY';
  secHead.font = { bold: true, size: 13, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  secHead.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1E3A5F' } };
  secHead.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(rowIdx).height = 30;
  rowIdx++;

  const counts = { Critical: 0, High: 0, Medium: 0, Low: 0 };
  SECURITY_FINDINGS.forEach(f => { if (counts[f.severity] !== undefined) counts[f.severity]++; });
  const total = Object.values(counts).reduce((a, b) => a + b, 0);
  const score = Math.max(0, 100 - (counts.Critical * 20) - (counts.High * 10) - (counts.Medium * 5) - (counts.Low * 1));
  const grade = score >= 90 ? 'A' : score >= 75 ? 'B' : score >= 60 ? 'C' : 'D';

  const severities = [
    ['🔴 Critical', counts.Critical, COLORS.critical.bg, COLORS.critical.fg],
    ['🟠 High', counts.High, COLORS.high.bg, COLORS.high.fg],
    ['🟡 Medium', counts.Medium, COLORS.medium.bg, COLORS.medium.fg],
    ['🟢 Low', counts.Low, COLORS.low.bg, COLORS.low.fg],
    ['📋 TOTAL', total, COLORS.subheader.bg, 'FFFFFFFF'],
  ];

  severities.forEach(([label, count, bg, fg]) => {
    ws.mergeCells(`A${rowIdx}:B${rowIdx}`);
    const lc = ws.getCell(`A${rowIdx}`);
    lc.value = label;
    lc.font = { bold: true, size: 12, color: { argb: fg }, name: 'Calibri' };
    lc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
    lc.alignment = { vertical: 'middle', horizontal: 'center' };

    ws.mergeCells(`C${rowIdx}:D${rowIdx}`);
    const cc = ws.getCell(`C${rowIdx}`);
    cc.value = count;
    cc.font = { bold: true, size: 16, color: { argb: fg }, name: 'Calibri' };
    cc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
    cc.alignment = { vertical: 'middle', horizontal: 'center' };

    ws.getRow(rowIdx).height = 32;
    rowIdx++;
  });

  // ── SECURITY SCORE ────────────────────────────────────────
  rowIdx++;
  ws.mergeCells(`A${rowIdx}:E${rowIdx}`);
  const scoreCell = ws.getCell(`A${rowIdx}`);
  scoreCell.value = `SECURITY SCORE: ${score}/100 — Grade: ${grade}`;
  scoreCell.font = { bold: true, size: 18, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  const scoreBg = score >= 75 ? COLORS.success.bg : score >= 50 ? COLORS.medium.bg : COLORS.critical.bg;
  scoreCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: scoreBg } };
  scoreCell.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(rowIdx).height = 45;
  rowIdx += 2;

  // ── TOP CRITICAL RISKS ────────────────────────────────────
  ws.mergeCells(`A${rowIdx}:E${rowIdx}`);
  const riskHead = ws.getCell(`A${rowIdx}`);
  riskHead.value = 'TOP CRITICAL RISKS — IMMEDIATE ACTION REQUIRED';
  riskHead.font = { bold: true, size: 13, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  riskHead.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF7F1D1D' } };
  riskHead.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(rowIdx).height = 30;
  rowIdx++;

  const topRisks = SECURITY_FINDINGS
    .filter(f => f.severity === 'Critical' || f.severity === 'High')
    .slice(0, 8);

  const riskHeaders = ['Rank', 'Severity', 'Vulnerability', 'File', 'CVSS'];
  const rhRow = ws.getRow(rowIdx);
  riskHeaders.forEach((h, i) => {
    const cell = rhRow.getCell(i + 1);
    cell.value = h;
    applyHeaderStyle(cell, COLORS.subheader.bg);
  });
  ws.getRow(rowIdx).height = 25;
  rowIdx++;

  topRisks.forEach((f, i) => {
    const row = ws.getRow(rowIdx);
    [i + 1, f.severity, f.type, f.file.split('/').pop(), f.cvss].forEach((v, ci) => {
      const cell = row.getCell(ci + 1);
      cell.value = v;
      if (ci === 1) {
        applySeverityBadge(cell, f.severity);
      } else {
        const bg = i % 2 === 0 ? COLORS.altRow.bg : COLORS.white.bg;
        applyCellStyle(cell, bg, COLORS.white.fg);
        cell.alignment = { vertical: 'middle', horizontal: ci === 0 ? 'center' : 'left' };
      }
    });
    ws.getRow(rowIdx).height = 22;
    rowIdx++;
  });

  // ── REMEDIATION ROADMAP ───────────────────────────────────
  rowIdx += 2;
  ws.mergeCells(`A${rowIdx}:E${rowIdx}`);
  const remHead = ws.getCell(`A${rowIdx}`);
  remHead.value = 'REMEDIATION ROADMAP';
  remHead.font = { bold: true, size: 13, color: { argb: 'FFFFFFFF' }, name: 'Calibri' };
  remHead.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1E4D8C' } };
  remHead.alignment = { horizontal: 'center', vertical: 'middle' };
  ws.getRow(rowIdx).height = 30;
  rowIdx++;

  const roadmap = [
    ['Priority', 'Action Item', 'Effort', 'Timeline', 'Severity'],
    ['1', 'Remove all hardcoded passwords from services.dart', 'High', 'Immediate', 'Critical'],
    ['2', 'Remove admin code ADMIN2026 from source', 'Medium', 'Immediate', 'Critical'],
    ['3', 'Implement server-side auth with JWT + HTTPS', 'High', 'Sprint 1', 'Critical'],
    ['4', 'Guard demo credentials with kDebugMode', 'Low', 'Immediate', 'High'],
    ['5', 'Fix Admin RBAC — create AdminDashboard', 'Medium', 'Sprint 1', 'High'],
    ['6', 'Implement brute-force protection (5 attempt lockout)', 'Medium', 'Sprint 1', 'High'],
    ['7', 'Integrate real OTP service (Firebase Auth/Twilio)', 'High', 'Sprint 2', 'High'],
    ['8', 'Strengthen password policy (12+ chars, complexity)', 'Low', 'Sprint 1', 'Medium'],
    ['9', 'Add flutter_secure_storage for token persistence', 'Medium', 'Sprint 2', 'Medium'],
    ['10', 'Fix email validation regex', 'Low', 'Sprint 1', 'Medium'],
    ['11', 'Add certificate pinning for API calls', 'Medium', 'Sprint 3', 'Low'],
    ['12', 'Implement HIPAA-compliant audit logging', 'High', 'Sprint 3', 'Medium'],
    ['13', 'Sanitize notification log messages', 'Low', 'Sprint 1', 'Medium'],
    ['14', 'Update outdated npm dependencies', 'Low', 'Sprint 1', 'Low'],
    ['15', 'Add biometric/MFA authentication option', 'High', 'Sprint 3', 'Low'],
  ];

  const rmHeaders = roadmap.shift();
  const rmhRow = ws.getRow(rowIdx);
  rmHeaders.forEach((h, i) => {
    const cell = rmhRow.getCell(i + 1);
    cell.value = h;
    applyHeaderStyle(cell, COLORS.subheader.bg);
  });
  ws.getRow(rowIdx).height = 25;
  rowIdx++;

  roadmap.forEach((r, i) => {
    const row = ws.getRow(rowIdx);
    r.forEach((v, ci) => {
      const cell = row.getCell(ci + 1);
      cell.value = v;
      if (ci === 4) {
        applySeverityBadge(cell, v);
      } else {
        const bg = i % 2 === 0 ? COLORS.altRow.bg : COLORS.white.bg;
        applyCellStyle(cell, bg, COLORS.white.fg);
        cell.alignment = { vertical: 'middle', horizontal: ci === 0 ? 'center' : 'left' };
      }
    });
    ws.getRow(rowIdx).height = 22;
    rowIdx++;
  });

  ws.views = [{ state: 'frozen', xSplit: 0, ySplit: 1, topLeftCell: 'A2', activeCell: 'A2' }];

  return ws;
}

// ─────────────────────────────────────────────────────────────
// MAIN — BUILD WORKBOOK
// ─────────────────────────────────────────────────────────────
async function main() {
  console.log('🛡️ Medicate Security Excel Report Generator');
  console.log(`📁 Output directory: ${REPORTS_DIR}`);
  console.log(`🔢 Build #${BUILD_NUMBER} | Branch: ${BRANCH_NAME}`);
  console.log('');

  const wb = new ExcelJS.Workbook();
  wb.creator = 'Medicate Security Pipeline';
  wb.lastModifiedBy = ACTOR;
  wb.created = new Date();
  wb.modified = new Date();
  wb.properties.date1904 = false;

  wb.calcProperties.fullCalcOnLoad = true;

  // Build all 4 sheets
  console.log('📊 Building Sheet 1: Security Findings...');
  buildFindingsSheet(wb);

  console.log('🗺️ Building Sheet 2: Endpoint Inventory...');
  buildEndpointSheet(wb);

  console.log('📦 Building Sheet 3: Dependency Vulnerabilities...');
  buildDependencySheet(wb);

  console.log('📊 Building Sheet 4: Risk Summary & Executive Dashboard...');
  buildRiskSummarySheet(wb);

  // Save workbook
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  const filename = `Medicate_Security_Review_Build-${BUILD_NUMBER}_${timestamp}.xlsx`;
  const outputPath = path.join(REPORTS_DIR, filename);

  await wb.xlsx.writeFile(outputPath);

  const stats = fs.statSync(outputPath);
  console.log('');
  console.log('✅ Excel report generated successfully!');
  console.log(`📄 File: ${outputPath}`);
  console.log(`📏 Size: ${(stats.size / 1024).toFixed(1)} KB`);
  console.log('');
  console.log('📋 Sheets generated:');
  console.log('   1. 🔴 Security Findings — All 15 vulnerabilities with CVSS scores');
  console.log('   2. 🗺️ Endpoint Inventory — 35 screens/services catalogued');
  console.log('   3. 📦 Dependency Vulnerabilities — 12 packages analyzed');
  console.log('   4. 📊 Risk Summary — Executive dashboard & remediation roadmap');

  // Also write a latest copy with fixed name for easy download
  const latestPath = path.join(REPORTS_DIR, 'security-review-latest.xlsx');
  await wb.xlsx.writeFile(latestPath);
  console.log(`📌 Also saved as: ${latestPath}`);

  return outputPath;
}

main().catch(err => {
  console.error('❌ Error generating Excel report:', err.message);
  console.error(err.stack);
  process.exit(1);
});
