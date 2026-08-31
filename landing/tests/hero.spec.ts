import { test, expect } from '@playwright/test';

test('Hero section contains the product name as a heading', async ({ page }) => {
  await page.goto('/');
  const heading = page.locator('h1', { hasText: 'CropCheckUp' });
  await expect(heading).toBeVisible();
});

test('Hero section contains subheading and upload-first description', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('p', { hasText: 'AI-assisted crop leaf disease detection.' })).toBeVisible();
  await expect(page.locator('p', { hasText: 'Upload a leaf image and CropCheckUp removes the background, prepares the image for a TensorFlow Lite model, and shows the predicted crop condition with confidence and management information.' })).toBeVisible();
});

test('Hero section links to diagnosis and project resources', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('a', { hasText: 'Check a leaf' })).toHaveAttribute('href', '#diagnose');
  await expect(page.locator('a', { hasText: 'View Kaggle Notebook' })).toHaveAttribute('href', 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup');
  await expect(page.locator('a', { hasText: 'View Dataset' })).toHaveAttribute('href', 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset');
});

test('Hero section previews the browser diagnosis workflow', async ({ page }) => {
  await page.goto('/');
  const visual = page.locator('.hero-browser-card');
  await expect(visual).toBeVisible();
  await expect(visual.getByText('Upload one clear leaf photo')).toBeVisible();
  await expect(visual.getByText('Local processing')).toBeVisible();
  await expect(visual.getByText('Private result')).toBeVisible();
});
