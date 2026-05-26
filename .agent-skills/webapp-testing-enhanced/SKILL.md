---
name: webapp-testing-enhanced
description: Enterprise web application testing with Playwright, Page Object Model patterns, CI/CD integration, accessibility testing, and production e-commerce patterns
---

# Web Application Testing - Enhanced Edition

Comprehensive browser automation testing framework combining **Playwright**, **Page Object Model architecture**, **accessibility testing**, **CI/CD pipeline integration**, and **production e-commerce patterns** from TestDino.

## When to Use This Skill

- ✅ Building cross-browser UI test suites (Chrome, Firefox, Safari, Edge)
- ✅ Setting up **CI/CD pipeline** test automation (GitHub Actions, GitLab CI, Jenkins)
- ✅ Testing **e-commerce workflows** (cart, checkout, payment)
- ✅ Implementing **accessibility compliance** (WCAG 2.1 AA/AAA)
- ✅ Running **autonomous test generation** on new components
- ✅ **Baseline testing** for visual regression
- ✅ Load testing with concurrent users
- ✅ Mobile and responsive design testing

## Core Patterns

### 1. Page Object Model (POM)

Organize selectors and actions by page/component:

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async login(email: string, password: string) {
    await this.page.fill('input[name="email"]', email);
    await this.page.fill('input[name="password"]', password);
    await this.page.click('button:has-text("Sign In")');
    await this.page.waitForNavigation();
  }

  async getErrorMessage() {
    return await this.page.textContent('[role="alert"]');
  }
}
```

Benefits:
- Maintainability: Locators in one place
- Readability: Tests read like user actions
- Reusability: Share pages across test suites
- Scalability: Easy to add new tests

### 2. Playwright Locator Strategies

**Best Practices (in order of reliability):**

1. **Role-based (Most Reliable)**
   ```typescript
   await page.click('button:has-text("Submit")');
   await page.fill('input[type="email"]', 'test@example.com');
   ```

2. **Test IDs (Recommended for Complex UIs)**
   ```typescript
   await page.click('[data-testid="submit-btn"]');
   ```

3. **Accessible Selectors**
   ```typescript
   await page.click('label:has-text("Accept Terms")');
   ```

4. **CSS Selectors (Last Resort)**
   ```typescript
   await page.click('.header .nav-btn:nth-child(3)');
   ```

### 3. Core Assertions

```typescript
// Visibility
await expect(page.locator('button')).toBeVisible();
await expect(page.locator('input')).toBeEnabled();

// Text content
await expect(page.locator('h1')).toContainText('Welcome');
await expect(page.locator('span')).toHaveText('Exact match');

// Count
await expect(page.locator('li')).toHaveCount(5);

// Attributes
await expect(page.locator('a')).toHaveAttribute('href', '/page');

// Values
await expect(page.locator('input')).toHaveValue('John');
```

### 4. E-Commerce Test Patterns (From TestDino)

**Complete Purchase Flow:**

```typescript
test('complete checkout flow', async ({ page }) => {
  // 1. Add to cart
  await page.goto('/products/laptop-pro');
  await page.click('button:has-text("Add to Cart")');
  await expect(page.locator('text=1 item')).toBeVisible();

  // 2. Navigate to cart
  await page.click('[data-testid="cart-link"]');

  // 3. Validate cart contents
  const itemName = await page.textContent('[data-testid="item-name"]');
  expect(itemName).toBe('Laptop Pro');

  // 4. Proceed to checkout
  await page.click('button:has-text("Checkout")');

  // 5. Fill shipping info
  await page.fill('input[name="address"]', '123 Main St');
  await page.fill('input[name="city"]', 'Portland');

  // 6. Select shipping method
  await page.click('label:has-text("Express Shipping")');

  // 7. Enter payment info (use test card)
  const frameHandle = page.frameLocator('iframe[title="Payment form"]');
  await frameHandle.locator('input[placeholder="Card Number"]')
    .fill('4242 4242 4242 4242');

  // 8. Complete purchase
  await page.click('button:has-text("Place Order")');

  // 9. Verify success
  await expect(page).toHaveURL(/\/order-confirmation/);
  const orderNumber = await page.textContent('[data-testid="order-number"]');
  expect(orderNumber).toMatch(/^ORD-\d+$/);
});
```

### 5. Accessibility Testing (WCAG 2.1)

```typescript
import { injectAxe, checkA11y } from 'axe-playwright';

test('page has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  await injectAxe(page);

  // Check entire page
  await checkA11y(page, null, {
    detailedReport: true,
    detailedReportOptions: {
      html: true
    }
  });
});

// Keyboard navigation
test('keyboard navigation works', async ({ page }) => {
  await page.goto('/');

  // Tab through all interactive elements
  await page.keyboard.press('Tab');
  await expect(page.locator(':focus')).toBeFocused();

  // Verify focus is visible
  const focusedElement = await page.evaluate(() => {
    const el = document.activeElement;
    const styles = window.getComputedStyle(el);
    return styles.outline !== 'none' || styles.boxShadow !== 'none';
  });
  expect(focusedElement).toBeTruthy();
});

// Screen reader compatibility
test('form has proper labels', async ({ page }) => {
  await page.goto('/contact-form');

  const inputs = await page.locator('input').count();
  for (let i = 0; i < inputs; i++) {
    const input = page.locator('input').nth(i);
    const ariaLabel = await input.getAttribute('aria-label');
    const forAttr = await input.getAttribute('id');

    const hasLabel = ariaLabel ||
                     (forAttr && await page.locator(`label[for="${forAttr}"]`).count() > 0);
    expect(hasLabel).toBeTruthy();
  }
});
```

### 6. CI/CD Pipeline Integration

**GitHub Actions Example:**

```yaml
name: Playwright Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        browser: [chromium, firefox, webkit]

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run tests
        run: npx playwright test --project=${{ matrix.browser }}

      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report-${{ matrix.browser }}
          path: playwright-report/
```

**Parallel Execution:**

```typescript
// playwright.config.ts
export default defineConfig({
  fullyParallel: true,
  workers: process.env.CI ? 1 : undefined,
  retries: process.env.CI ? 2 : 0,

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 12'] } },
  ],
});
```

### 7. Advanced Patterns

**Waiting for Network:**

```typescript
// Wait for specific API response
await Promise.all([
  page.waitForResponse(response =>
    response.url().includes('/api/products') && response.status() === 200
  ),
  page.click('button:has-text("Load More")')
]);
```

**Visual Regression Testing:**

```typescript
test('homepage looks correct', async ({ page }) => {
  await page.goto('/');

  // Capture full page
  await expect(page).toHaveScreenshot('homepage.png');

  // Capture specific element
  await expect(page.locator('header')).toHaveScreenshot('header.png');
});
```

**Debugging:**

```typescript
// Pause execution for inspection
await page.pause();

// Generate trace for later analysis
const context = await browser.newContext();
await context.tracing.start({ screenshots: true, snapshots: true });
// ... run tests ...
await context.tracing.stop({ path: 'trace.zip' });

// View: npx playwright show-trace trace.zip
```

## Tool & Framework References

- **Playwright Docs:** https://playwright.dev
- **Axe Accessibility:** https://github.com/abhinaba-ghosh/axe-playwright
- **WCAG Guidelines:** https://www.w3.org/WAI/WCAG21/quickref/
- **TestDino Patterns:** 82 production e-commerce test examples
- **Playwright Inspector:** Built-in debugging tool

## Common Use Cases

1. **Pre-deployment Testing** → Run full suite in CI/CD before release
2. **Regression Testing** → Detect breaking changes automatically
3. **Cross-browser Validation** → Ensure consistency across browsers
4. **Accessibility Audits** → Verify WCAG compliance
5. **Performance Baselines** → Track visual stability
6. **Load Testing** → Simulate concurrent users
7. **Mobile Testing** → Verify responsive design

## Integration with Claude Code

Use this skill when:
- Testing new features before deployment
- Debugging failing tests with detailed reports
- Implementing accessibility improvements
- Setting up CI/CD test automation
- Validating e-commerce workflows

---

**This is an enhanced version combining Playwright best practices, POM architecture, CI/CD integration, accessibility testing, and production e-commerce patterns.**
