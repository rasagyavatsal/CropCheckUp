import { test, expect } from '@playwright/test';

test.describe('Processing Pipeline', () => {
  test('renders the pipeline section', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('section#pipeline')).toBeVisible();
  });

  test('displays all six upload-to-result stages', async ({ page }) => {
    await page.goto('/');
    for (const stage of [
      'Upload image',
      'Background removal',
      '224 x 224 image',
      'RGB tensor',
      'TensorFlow Lite inference',
      'Diagnosis result',
    ]) {
      await expect(page.getByText(stage, { exact: true })).toBeVisible();
    }
  });

  test('displays the preprocessing contract', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByText('The model receives a 224 x 224 RGB image. Pixel values are passed in the 0-255 range because preprocessing is included inside the model.')).toBeVisible();
    await expect(page.getByText('Transparent background pixels are treated as black during tensor conversion.')).toBeVisible();
  });
});
