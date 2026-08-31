import { test, expect } from '@playwright/test';

test('Limitations section has the correct id', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#limitations')).toBeVisible();
});

test('Limitations section contains introduction copy', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#limitations').getByText('CropCheckUp is an AI-assisted screening tool. Results depend on image quality, lighting, leaf visibility, and whether the condition exists in the trained labels.')).toBeVisible();
});

test('Limitations section describes the three supported-image constraints', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#limitations');
  for (const bullet of [
    'Use a clear image of one leaf.',
    'Avoid blur, shadows, and cluttered backgrounds.',
    'The website can only classify supported labels.',
  ]) {
    await expect(section.getByText(bullet, { exact: false })).toBeVisible();
  }
});
