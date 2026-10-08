const { remote } = require('webdriverio');
const assert = require('assert');

// E2E Mobile App Test using Appium and WebdriverIO
async function runMobileE2ETest() {
    const capabilities = {
        platformName: 'Android',
        'appium:automationName': 'UiAutomator2',
        'appium:deviceName': 'Android Emulator',
        'appium:app': '/path/to/your/medicate/app-debug.apk', // Replace with actual APK path
        'appium:appPackage': 'com.medicate.app', // Replace with actual package name
        'appium:appActivity': '.MainActivity', // Replace with actual main activity
    };

    const wdioOpts = {
        hostname: process.env.APPIUM_HOST || 'localhost',
        port: parseInt(process.env.APPIUM_PORT, 10) || 4723,
        logLevel: 'info',
        capabilities,
    };

    let driver;
    try {
        console.log('Starting E2E Appium Test for Mobile Frontend...');
        driver = await remote(wdioOpts);

        // 1. Wait for app to load and find the login button/input
        const usernameInput = await driver.$('~username-input'); // Using accessibility ID
        await usernameInput.waitForDisplayed({ timeout: 10000 });
        
        const passwordInput = await driver.$('~password-input');
        const loginButton = await driver.$('~login-button');

        // 2. Perform Login Action
        await usernameInput.setValue('testuser@medicate.com');
        await passwordInput.setValue('password123');
        await loginButton.click();

        // 3. Verify Dashboard Loads
        const dashboardHeader = await driver.$('~dashboard-header');
        await dashboardHeader.waitForDisplayed({ timeout: 10000 });
        
        const isDashboardVisible = await dashboardHeader.isDisplayed();
        assert.ok(isDashboardVisible, 'Failed to login and reach mobile dashboard');
        
        console.log('✅ E2E Mobile Login Test Passed Successfully!');
        
    } catch (error) {
        console.error('❌ E2E Mobile Login Test Failed:', error);
    } finally {
        if (driver) {
            await driver.deleteSession();
        }
    }
}

runMobileE2ETest();
