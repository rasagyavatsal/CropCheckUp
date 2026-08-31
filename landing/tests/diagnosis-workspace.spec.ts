import { test, expect } from '@playwright/test';
import { readFile } from 'node:fs/promises';

const sampleImage = await readFile(new URL('../public/logo-with-back.png', import.meta.url));

test.describe('Browser diagnosis workspace', () => {
  test('offers an upload-only source without a live capture surface', async ({ page }) => {
    await page.goto('/');

    const workspace = page.locator('#diagnose');
    await expect(workspace).toBeVisible();
    await expect(workspace.locator('input[type=file]')).toHaveAttribute('accept', 'image/png,image/jpeg,image/webp');
    await expect(workspace.locator('video')).toHaveCount(0);
    await expect(workspace.getByText('Everything stays in your browser.')).toBeVisible();
  });

  test('rejects unsupported uploads before processing', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.model-status')).toHaveText('Models ready', { timeout: 45_000 });

    await page.locator('#diagnose input[type=file]').setInputFiles({
      name: 'notes.txt',
      mimeType: 'text/plain',
      buffer: Buffer.from('not an image'),
    });

    await expect(page.getByRole('alert')).toContainText('Choose a PNG, JPEG, or WebP image.');
    await expect(page.getByRole('heading', { name: 'Check a leaf' })).toBeVisible();
  });

  test('processes an uploaded image, shows a preview, and saves a diagnosis', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.model-status')).toHaveText('Models ready', { timeout: 45_000 });

    await page.locator('#diagnose input[type=file]').setInputFiles({
      name: 'sample-leaf.png',
      mimeType: 'image/png',
      buffer: sampleImage,
    });
    await expect(page.getByRole('heading', { name: 'Review the processed leaf' })).toBeVisible({ timeout: 60_000 });
    await expect(page.getByAltText('Segmented leaf preview')).toBeVisible();

    await page.getByRole('button', { name: 'Diagnose' }).click();
    await expect(page.locator('.diagnosis-summary')).toBeVisible({ timeout: 60_000 });
    await expect(page.getByText('Raw label:')).toBeVisible();
    await expect(page.getByRole('button', { name: /Open diagnosis for/ })).toBeVisible({ timeout: 10_000 });
  });
});
