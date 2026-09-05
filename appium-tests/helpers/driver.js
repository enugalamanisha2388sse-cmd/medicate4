/**
 * appium-tests/helpers/driver.js
 * Shared Appium Driver Factory & Utility Helpers
 * SmartMed / Medicate Flutter App — E2E Test Suite
 */

'use strict';

const wdio       = require('webdriverio');
const { CAPS, SERVER_CONFIG, TIMEOUTS } = require('../config/appium.config');

// ─── Driver Factory ───────────────────────────────────────────────────────────
async function createDriver() {
  const driver = await wdio.remote({
    ...SERVER_CONFIG,
    capabilities: CAPS,
  });
  await driver.setImplicitTimeout(TIMEOUTS.implicit);
  return driver;
}

// ─── Element Helpers ──────────────────────────────────────────────────────────

/** Find element by accessibility ID (Flutter semantics label) */
async function byId(driver, id, timeout) {
  timeout = timeout || TIMEOUTS.explicit;
  return driver.$('~' + id);
}

/** Find element by XPath */
async function byXPath(driver, xpath) {
  return driver.$(xpath);
}

/** Find element by text content (Android UiSelector) */
async function byText(driver, text) {
  return driver.$('android=new UiSelector().text("' + text + '")');
}

/** Find element by text contains (Android UiSelector) */
async function byTextContains(driver, text) {
  return driver.$('android=new UiSelector().textContains("' + text + '")');
}

/** Find element by class name */
async function byClass(driver, className) {
  return driver.$('android=new UiSelector().className("' + className + '")');
}

/** Find element by resource-id */
async function byResource(driver, resId) {
  return driver.$('android=new UiSelector().resourceId("' + resId + '")');
}

// ─── Action Helpers ───────────────────────────────────────────────────────────

/** Wait then tap element */
async function tap(driver, el) {
  try {
    const e = await el;
    await e.waitForDisplayed({ timeout: TIMEOUTS.explicit });
    await e.click();
    await driver.pause(TIMEOUTS.animation);
  } catch (err) {
    // swallow — non-critical tap may fail in certain states
  }
}

/** Tap element by text */
async function tapByText(driver, text) {
  try {
    const el = await byText(driver, text);
    await el.waitForDisplayed({ timeout: TIMEOUTS.explicit });
    await el.click();
    await driver.pause(TIMEOUTS.animation);
  } catch (_) {}
}

/** Tap element by accessibility ID */
async function tapById(driver, id) {
  try {
    const el = await byId(driver, id);
    await el.waitForDisplayed({ timeout: TIMEOUTS.explicit });
    await el.click();
    await driver.pause(TIMEOUTS.animation);
  } catch (_) {}
}

/** Clear & type into an input */
async function typeInto(driver, el, text) {
  try {
    const e = await el;
    await e.waitForDisplayed({ timeout: TIMEOUTS.explicit });
    await e.clearValue();
    await e.setValue(text);
    await driver.pause(300);
  } catch (_) {}
}

/** Fill text into first visible text input */
async function fillFirstInput(driver, text) {
  try {
    const inputs = await driver.$$('android=new UiSelector().className("android.widget.EditText")');
    if (inputs.length > 0) {
      await inputs[0].clearValue();
      await inputs[0].setValue(text);
    }
  } catch (_) {}
}

/** Fill email & password fields */
async function fillCredentials(driver, email, password) {
  try {
    const inputs = await driver.$$('android=new UiSelector().className("android.widget.EditText")');
    if (inputs[0]) { await inputs[0].clearValue(); await inputs[0].setValue(email); }
    if (inputs[1]) { await inputs[1].clearValue(); await inputs[1].setValue(password); }
    await driver.pause(400);
  } catch (_) {}
}

/** Check if text is visible anywhere on screen */
async function isTextVisible(driver, text) {
  try {
    const el = await byTextContains(driver, text);
    return await el.isDisplayed();
  } catch (_) { return false; }
}

/** Wait until text appears on screen */
async function waitForText(driver, text, timeout) {
  timeout = timeout || TIMEOUTS.pageLoad;
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await isTextVisible(driver, text)) return true;
    await driver.pause(500);
  }
  return false;
}

/** Scroll down on the screen */
async function scrollDown(driver) {
  try {
    await driver.touchAction([
      { action: 'press',   x: 540, y: 1600 },
      { action: 'moveTo',  x: 540, y: 400  },
      { action: 'release' },
    ]);
    await driver.pause(600);
  } catch (_) {}
}

/** Scroll up on the screen */
async function scrollUp(driver) {
  try {
    await driver.touchAction([
      { action: 'press',   x: 540, y: 400  },
      { action: 'moveTo',  x: 540, y: 1600 },
      { action: 'release' },
    ]);
    await driver.pause(600);
  } catch (_) {}
}

/** Swipe left (go to next page) */
async function swipeLeft(driver) {
  try {
    await driver.touchAction([
      { action: 'press',   x: 900, y: 800 },
      { action: 'moveTo',  x: 100, y: 800 },
      { action: 'release' },
    ]);
    await driver.pause(600);
  } catch (_) {}
}

/** Press device back button (Android) */
async function pressBack(driver) {
  try {
    await driver.pressKeyCode(4); // KEYCODE_BACK
    await driver.pause(TIMEOUTS.animation);
  } catch (_) {}
}

/** Press device home button (Android) */
async function pressHome(driver) {
  try {
    await driver.pressKeyCode(3); // KEYCODE_HOME
    await driver.pause(TIMEOUTS.animation);
  } catch (_) {}
}

/** Hide keyboard if visible */
async function hideKeyboard(driver) {
  try { await driver.hideKeyboard(); } catch (_) {}
}

/** Get current activity (Android) */
async function getCurrentActivity(driver) {
  try { return await driver.getCurrentActivity(); } catch (_) { return ''; }
}

/** Take screenshot (for debugging) */
async function screenshot(driver, name) {
  try {
    const data = await driver.takeScreenshot();
    const fs   = require('fs');
    const path = require('path');
    const dir  = path.join(__dirname, '..', 'screenshots');
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, (name || 'screen') + '_' + Date.now() + '.png'),
      Buffer.from(data, 'base64'));
  } catch (_) {}
}

// ─── App-level Helpers ────────────────────────────────────────────────────────

/** Full login flow: Role → Email → Password → Sign In */
async function loginAs(driver, role, email, password) {
  try {
    await driver.pause(TIMEOUTS.short);
    await tapByText(driver, role);
    await driver.pause(TIMEOUTS.animation);
    await fillCredentials(driver, email, password);
    await tapByText(driver, 'Sign In');
    await driver.pause(TIMEOUTS.pageLoad);
  } catch (_) {}
}

/** Logout from any dashboard */
async function logout(driver) {
  try {
    // Try tapping profile/menu icon
    await tapById(driver, 'profile_icon');
    await driver.pause(TIMEOUTS.animation);
    await tapByText(driver, 'Logout');
    await driver.pause(TIMEOUTS.pageLoad);
  } catch (_) {
    try {
      await tapByText(driver, 'Logout');
      await driver.pause(TIMEOUTS.pageLoad);
    } catch (__) {}
  }
}

/** Navigate to the home screen via back presses */
async function goHome(driver, maxPresses) {
  maxPresses = maxPresses || 5;
  for (let i = 0; i < maxPresses; i++) {
    try { await pressBack(driver); } catch (_) {}
  }
}

module.exports = {
  createDriver,
  byId, byXPath, byText, byTextContains, byClass, byResource,
  tap, tapByText, tapById,
  typeInto, fillFirstInput, fillCredentials,
  isTextVisible, waitForText,
  scrollDown, scrollUp, swipeLeft,
  pressBack, pressHome, hideKeyboard,
  getCurrentActivity, screenshot,
  loginAs, logout, goHome,
  TIMEOUTS,
};
