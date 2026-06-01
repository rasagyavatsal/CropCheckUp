import { test, expect } from '@playwright/test';

test('How it works section has the correct id', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#how-it-works');
  await expect(section).toBeVisible();
});

test('How it works section contains the 5 correct steps', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#how-it-works');

  const steps = [
    {
      title: 'Capture or upload',
      description: 'The user captures a live camera frame or selects an image from the gallery.'
    },
    {
      title: 'Remove background',
      description: 'The app isolates the leaf so the classifier focuses on the plant area.'
    },
    {
      title: 'Resize image',
      description: 'The processed image is resized to 224 x 224 pixels.'
    },
    {
      title: 'Run inference',
      description: 'A TensorFlow Lite model predicts the most likely crop condition.'
    },
    {
      title: 'Show diagnosis',
      description: 'The app displays crop name, condition, confidence, symptoms, causes, and management guidance.'
    }
  ];

  for (const step of steps) {
    await expect(section.locator(`text=${step.title}`)).toBeVisible();
    await expect(section.locator(`text=${step.description}`)).toBeVisible();
  }
});
