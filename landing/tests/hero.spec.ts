import { test, expect } from '@playwright/test';

test('Hero section contains the product name as a heading', async ({ page }) => {
  await page.goto('/');
  const heading = page.locator('h1', { hasText: 'CropCheckUp' });
  await expect(heading).toBeVisible();
});

test('Hero section contains subheading and description', async ({ page }) => {
  await page.goto('/');
  const subheading = page.locator('p', { hasText: 'AI-assisted crop leaf disease detection from camera or gallery images.' });
  await expect(subheading).toBeVisible();

  const description = page.locator('p', { hasText: 'CropCheckUp analyzes a leaf image, removes the background, prepares the image for a TensorFlow Lite model, and shows the predicted crop condition with confidence and management information.' });
  await expect(description).toBeVisible();
});

test('Hero section contains CTA links', async ({ page }) => {
  await page.goto('/');
  const notebookLink = page.locator('a', { hasText: 'View Kaggle Notebook' });
  await expect(notebookLink).toBeVisible();
  await expect(notebookLink).toHaveAttribute('href', 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup');

  const datasetLink = page.locator('a', { hasText: 'View Dataset' });
  await expect(datasetLink).toBeVisible();
  await expect(datasetLink).toHaveAttribute('href', 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset');
});
