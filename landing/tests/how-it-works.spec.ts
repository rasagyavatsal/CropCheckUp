import { test, expect } from '@playwright/test';

test('How it works section has the correct id', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#how-it-works')).toBeVisible();
});

test('How it works section contains the five upload-to-diagnosis steps', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#how-it-works');
  const steps = [
    ['Choose an image', 'The user selects a leaf image from the device.'],
    ['Remove background', 'The website isolates the leaf so the classifier focuses on the plant area.'],
    ['Resize image', 'The processed image is resized to 224 x 224 pixels.'],
    ['Run inference', 'A TensorFlow Lite model predicts the most likely crop condition.'],
    ['Show diagnosis', 'The website displays crop name, condition, confidence, symptoms, causes, and management guidance.'],
  ];

  for (const [title, description] of steps) {
    await expect(section.getByText(title, { exact: true })).toBeVisible();
    await expect(section.getByText(description, { exact: true })).toBeVisible();
  }
});
