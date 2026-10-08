const { Builder, By, until } = require('selenium-webdriver');
const assert = require('assert');

// E2E login test using Selenium WebDriver for web frontend
(async function loginE2ETest() {
    // Initialize Chrome driver
    let driver = await new Builder().forBrowser('chrome').build();
    try {
        console.log('Starting E2E Login Test...');
        // 1. Navigate to the frontend login page
        // (Replace with your actual frontend URL if different)
        await driver.get('http://localhost:3000/login');

        // 2. Wait for login inputs to be visible
        await driver.wait(until.elementLocated(By.id('username')), 5000);

        // 3. Find username, password, and submit button elements
        const usernameInput = await driver.findElement(By.id('username'));
        const passwordInput = await driver.findElement(By.id('password'));
        const loginButton = await driver.findElement(By.id('login-button'));

        // 4. Input credentials
        await usernameInput.sendKeys('testuser@medicate.com');
        await passwordInput.sendKeys('password123');
        
        // 5. Submit form
        await loginButton.click();

        // 6. Wait for successful navigation to dashboard
        await driver.wait(until.urlContains('/dashboard'), 5000);
        const currentUrl = await driver.getCurrentUrl();
        
        // 7. Verify result
        assert.ok(currentUrl.includes('/dashboard'), 'Failed to login and navigate to dashboard');
        console.log('✅ E2E Login Test Passed Successfully!');
        
    } catch (error) {
        console.error('❌ E2E Login Test Failed:', error);
    } finally {
        // Close the browser
        await driver.quit();
    }
})();
