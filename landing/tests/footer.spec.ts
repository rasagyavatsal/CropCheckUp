import { test, expect } from '@playwright/test';

test('Footer is present with semantic tag', async ({ page }) => {
  await page.goto('/');
  const footer = page.locator('footer');
  await expect(footer).toBeVisible();
});

test('Footer contains logo/name and description', async ({ page }) => {
  await page.goto('/');
  const footer = page.locator('footer');
  await expect(footer.getByText('CropCheckUp')).toBeVisible();
  await expect(footer.getByText('AI-assisted plant disease detection.')).toBeVisible();
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
