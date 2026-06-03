import { test, expect } from '@playwright/test';

test('Footer is present with semantic tag', async ({ page }) => {
  await page.goto('/');
  const footer = page.locator('footer');
  await expect(footer).toBeVisible();
});

test('Footer contains logo/name and description', async ({ page }) => {
  await page.goto('/');
  const footer = page.locator('footer');
  await expect(footer.getByText('CropCheckUp').first()).toBeVisible();
  await expect(footer.getByText('AI-assisted plant disease detection.').first()).toBeVisible();
});

test('Footer contains the correct links', async ({ page }) => {
  await page.goto('/');
  const footer = page.locator('footer');
  
  const kaggleLink = footer.locator('a', { hasText: 'Kaggle Notebook' });
  await expect(kaggleLink).toBeVisible();
  await expect(kaggleLink).toHaveAttribute('href', 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup');
  
  const datasetLink = footer.locator('a', { hasText: 'Dataset' });
  await expect(datasetLink).toBeVisible();
  await expect(datasetLink).toHaveAttribute('href', 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset');
  
  const githubLink = footer.locator('a', { hasText: 'GitHub' });
  await expect(githubLink).toBeVisible();
  await expect(githubLink).toHaveAttribute('href', 'https://github.com/rasagyavatsal/CropCheckUp');
});

test('Footer contains license summary and documentation links', async ({ page }) => {
  await page.goto('/');
  const footer = page.locator('footer');
  
  await expect(footer.getByText('Code: Apache-2.0. Model/data: CC-BY-NC-SA-4.0 non-commercial.')).toBeVisible();
  
  // Checking documentation links (like MODEL_CARD, DATASET_LICENSE, ATTRIBUTION)
  const codeLicense = footer.locator('a', { hasText: 'Code: Apache-2.0' });
  await expect(codeLicense).toHaveAttribute('href', 'https://github.com/rasagyavatsal/CropCheckUp/blob/main/LICENSE');
  
  const dataLicense = footer.locator('a', { hasText: 'Model/data: CC-BY-NC-SA-4.0 non-commercial' });
  await expect(dataLicense).toHaveAttribute('href', 'https://github.com/rasagyavatsal/CropCheckUp/blob/main/DATASET_LICENSE.md');
});
