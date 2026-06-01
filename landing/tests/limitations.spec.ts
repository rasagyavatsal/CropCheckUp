import { test, expect } from '@playwright/test';

test('Limitations section has the correct id', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#limitations');
  await expect(section).toBeVisible();
});

test('Limitations section contains introduction copy', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#limitations');
  await expect(section.getByText('CropCheckUp is an AI-assisted screening tool. Results depend on image quality, lighting, leaf visibility, and whether the condition exists in the trained labels.')).toBeVisible();
});

test('Limitations section contains the 4 correct bullet points', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#limitations');

  const bullets = [
    'Use a clear image of one leaf.',
    'Avoid blur, shadows, and cluttered backgrounds.',
    'Confirm serious crop issues with an agriculture expert.',
    'The app can only classify supported labels.'
  ];

  for (const bullet of bullets) {
    await expect(section.getByText(bullet)).toBeVisible();
  }
});
