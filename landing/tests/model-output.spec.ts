import { test, expect } from '@playwright/test';

test('Model output section has the correct id', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#model-output');
  await expect(section).toBeVisible();
});

test('Model output section contains explanatory copy', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#model-output');
  
  await expect(section.getByText(/classifier returns the highest-scoring label/i)).toBeVisible();
  await expect(section.getByText(/Labels follow a crop and condition format/i)).toBeVisible();
  await expect(section.getByText(/app converts raw labels into readable/i)).toBeVisible();
});

test('Model output section contains example result block', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#model-output');
  
  await expect(section.getByText('Raw label', { exact: true })).toBeVisible();
  await expect(section.getByText(/Tomato___Late_blight/i)).toBeVisible();
  await expect(section.getByText(/Displayed result/i)).toBeVisible();
  await expect(section.getByText(/Tomato - Late blight/i)).toBeVisible();
});

test('Model output section contains output list', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#model-output');
  
  const listItems = [
    'Crop name',
    'Disease or healthy status',
    'Confidence percentage',
    'Symptoms',
    'Possible causes',
    'Management guidance',
    'Processed leaf preview'
  ];

  for (const item of listItems) {
    await expect(section.getByText(item)).toBeVisible();
  }
});

test('Model output section contains label-set note', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#model-output');
  
  await expect(section.getByText('The current label file contains 68 crop and condition labels.')).toBeVisible();
});
