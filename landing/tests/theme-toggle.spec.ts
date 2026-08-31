import { test, expect } from '@playwright/test';

test('ThemeToggle switches the document theme and persists the choice', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await page.goto('/');

  const toggle = page.locator('#theme-toggle');
  await expect(toggle).toHaveAttribute('aria-pressed', 'false');
  await expect(page.locator('html')).not.toHaveClass(/dark/);

  await toggle.click();

  await expect(page.locator('html')).toHaveClass(/dark/);
  await expect(toggle).toHaveAttribute('aria-pressed', 'true');
  await expect.poll(() => page.evaluate(() => localStorage.getItem('color-theme'))).toBe('dark');

  await toggle.click();

  await expect(page.locator('html')).not.toHaveClass(/dark/);
  await expect(toggle).toHaveAttribute('aria-pressed', 'false');
  await expect.poll(() => page.evaluate(() => localStorage.getItem('color-theme'))).toBe('light');
});
