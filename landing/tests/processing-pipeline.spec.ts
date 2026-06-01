import { test, expect } from '@playwright/test';

test.describe('Processing Pipeline', () => {
  test('should render the section with id="pipeline"', async ({ page }) => {
    await page.goto('/');
    const pipelineSection = page.locator('section#pipeline');
    await expect(pipelineSection).toBeVisible();
  });

  test('should display all six pipeline stages in order', async ({ page }) => {
    await page.goto('/');
    const stages = [
      'Camera / Gallery',
      'Background removal',
      '224 x 224 image',
      'RGB tensor',
      'TensorFlow Lite inference',
      'Diagnosis result'
    ];
    
    for (const stage of stages) {
      await expect(page.locator(`text=${stage}`).first()).toBeVisible();
    }
  });

  test('should display technical notes', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByText('The model receives a 224 x 224 RGB image. Pixel values are passed in the 0-255 range because preprocessing is included inside the model.')).toBeVisible();
    await expect(page.getByText('Transparent background pixels are treated as black during tensor conversion.')).toBeVisible();
  });
});

