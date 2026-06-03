import { test, expect } from '@playwright/test';

test('DatasetReferences section contains the required copy', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('section#dataset');
  await expect(section).toBeVisible();

  const text = page.locator('section#dataset p', { hasText: 'The model development workflow is documented in the Kaggle notebook. The dataset used for CropCheckUp experiments and training is available on Kaggle.' });
  await expect(text).toBeVisible();
});

test('DatasetReferences section contains links to Kaggle resources', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('section#dataset');
  
  const notebookLink = section.locator('a', { hasText: 'Kaggle Notebook' });
  await expect(notebookLink).toBeVisible();
  await expect(notebookLink).toHaveAttribute('href', 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup');
  await expect(notebookLink).toHaveAttribute('target', '_blank');
  await expect(notebookLink).toHaveAttribute('rel', 'noopener noreferrer');

  const datasetLink = section.locator('a', { hasText: 'CropCheckUp Dataset' });
  await expect(datasetLink).toBeVisible();
  await expect(datasetLink).toHaveAttribute('href', 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset');
  await expect(datasetLink).toHaveAttribute('target', '_blank');
  await expect(datasetLink).toHaveAttribute('rel', 'noopener noreferrer');
});

test('DatasetReferences section contains helper texts for resources', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('section#dataset');

  const notebookHelper = section.locator('p', { hasText: 'Model development workflow and experimentation.' });
  await expect(notebookHelper).toBeVisible();

  const datasetHelper = section.locator('p', { hasText: 'Image dataset used for CropCheckUp experiments and training.' });
  await expect(datasetHelper).toBeVisible();
});

test('DatasetReferences section contains source dataset attribution and licenses', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('section#dataset');
  
  await expect(section.getByText('PlantVillage')).toBeVisible();
  await expect(section.getByText('CC-BY-NC-SA-4.0').first()).toBeVisible();
  await expect(section.getByText('Mango Leaf Disease')).toBeVisible();
  await expect(section.getByText('CC-BY-NC-4.0')).toBeVisible();
});

test('DatasetReferences section contains the derived dataset/model license statement', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('section#dataset');
  
  await expect(section.getByText('CropCheckUp derived dataset and bundled model artifacts are licensed CC-BY-NC-SA-4.0 for non-commercial use.')).toBeVisible();
});
