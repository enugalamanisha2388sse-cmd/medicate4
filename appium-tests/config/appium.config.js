/**
 * appium-tests/config/appium.config.js
 * Appium Desired Capabilities & Server Configuration
 * SmartMed / Medicate Flutter App — E2E Test Suite
 */

'use strict';

const path = require('path');

// ─── Android Configuration ────────────────────────────────────────────────────
const ANDROID_CAPS = {
  platformName:          'Android',
  'appium:automationName': 'UiAutomator2',
  'appium:deviceName':   process.env.DEVICE_NAME   || 'emulator-5554',
  'appium:platformVersion': process.env.PLATFORM_VER || '13.0',
  'appium:app':          process.env.APP_PATH       ||
                         path.join(__dirname, '..', 'app', 'smartmed-debug.apk'),
  'appium:appPackage':   'com.smartmed.medicate',
  'appium:appActivity':  'com.smartmed.medicate.MainActivity',
  'appium:autoGrantPermissions': true,
  'appium:noReset':      false,
  'appium:fullReset':    false,
  'appium:newCommandTimeout': 60,
  'appium:uiautomator2ServerInstallTimeout': 60000,
  'appium:settings[waitForIdleTimeout]': 100,
  'appium:settings[shouldWaitForQuiescence]': false,   // Flutter-friendly
  'appium:disableWindowAnimation': true,
};

// ─── iOS Configuration ────────────────────────────────────────────────────────
const IOS_CAPS = {
  platformName:            'iOS',
  'appium:automationName': 'XCUITest',
  'appium:deviceName':     process.env.IOS_DEVICE   || 'iPhone 15',
  'appium:platformVersion': process.env.IOS_VER      || '17.0',
  'appium:app':            process.env.IOS_APP_PATH  ||
                           path.join(__dirname, '..', 'app', 'SmartMed.app'),
  'appium:bundleId':       'com.smartmed.medicate',
  'appium:autoAcceptAlerts': true,
  'appium:noReset':        false,
  'appium:newCommandTimeout': 60,
  'appium:settings[waitForIdleTimeout]': 100,
  'appium:settings[shouldWaitForQuiescence]': false,
};

// ─── Server Configuration ─────────────────────────────────────────────────────
const SERVER_CONFIG = {
  host:    process.env.APPIUM_HOST || '127.0.0.1',
  port:    parseInt(process.env.APPIUM_PORT || '4723'),
  path:    '/wd/hub',
  logLevel: 'warn',
};

// ─── Test Credentials ─────────────────────────────────────────────────────────
const CREDENTIALS = {
  patient: {
    email:    process.env.PATIENT_EMAIL || 'patient@medicate.com',
    password: process.env.PATIENT_PASS  || 'password123',
    name:     'Test Patient',
  },
  doctor: {
    email:    process.env.DOCTOR_EMAIL  || 'doctor@medicate.com',
    password: process.env.DOCTOR_PASS   || 'password123',
    name:     'Dr. Test',
  },
  admin: {
    email:    process.env.ADMIN_EMAIL   || 'admin@medicate.com',
    password: process.env.ADMIN_PASS    || 'password123',
    name:     'Admin Test',
  },
  invalid: {
    email:    'invalid@nowhere.com',
    password: 'wrongpass999',
  },
};

// ─── Timeouts ─────────────────────────────────────────────────────────────────
const TIMEOUTS = {
  implicit:   10000,   // ms — element location
  explicit:   15000,   // ms — explicit wait
  pageLoad:   20000,   // ms — page/screen transitions
  animation:  1500,    // ms — Flutter animation settle
  short:      2000,    // ms — brief wait
  long:       30000,   // ms — slow operations (camera, BT, etc.)
};

// ─── Platform Selection ───────────────────────────────────────────────────────
const PLATFORM = (process.env.PLATFORM || 'android').toLowerCase();
const CAPS     = PLATFORM === 'ios' ? IOS_CAPS : ANDROID_CAPS;

module.exports = { CAPS, SERVER_CONFIG, CREDENTIALS, TIMEOUTS, PLATFORM };
