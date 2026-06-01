import { test, expect } from '@playwright/test';

test.describe('SEO Metadata', () => {
  test('has basic SEO meta tags', async ({ page }) => {
    await page.goto('/');

    await expect(page).toHaveTitle('CropCheckUp - AI Plant Disease Detection');

    const metaDescription = page.locator('meta[name="description"]');
    await expect(metaDescription).toHaveAttribute('content', 'Detect crop leaf disease from camera or gallery images with AI-assisted diagnosis, background removal, and TensorFlow Lite inference.');

    // Canonical
    const canonical = page.locator('link[rel="canonical"]');
    await expect(canonical).toHaveAttribute('href', 'https://github.com/rasagyavatsal/CropCheckUp/');

    // Open Graph
    const ogTitle = page.locator('meta[property="og:title"]');
    await expect(ogTitle).toHaveAttribute('content', 'CropCheckUp - AI Plant Disease Detection');
    
    const ogDescription = page.locator('meta[property="og:description"]');
    await expect(ogDescription).toHaveAttribute('content', 'Detect crop leaf disease from camera or gallery images with AI-assisted diagnosis, background removal, and TensorFlow Lite inference.');

    const ogType = page.locator('meta[property="og:type"]');
    await expect(ogType).toHaveAttribute('content', 'website');
    
    const ogUrl = page.locator('meta[property="og:url"]');
    await expect(ogUrl).toHaveAttribute('content', 'https://github.com/rasagyavatsal/CropCheckUp/');

    // Twitter Card
    const twitterCard = page.locator('meta[name="twitter:card"]');
    await expect(twitterCard).toHaveAttribute('content', 'summary');

    const twitterTitle = page.locator('meta[name="twitter:title"]');
    await expect(twitterTitle).toHaveAttribute('content', 'CropCheckUp - AI Plant Disease Detection');

    const twitterDescription = page.locator('meta[name="twitter:description"]');
    await expect(twitterDescription).toHaveAttribute('content', 'Detect crop leaf disease from camera or gallery images with AI-assisted diagnosis, background removal, and TensorFlow Lite inference.');
  });

  test('serves robots.txt', async ({ request }) => {
    const response = await request.get('/robots.txt');
    expect(response.ok()).toBeTruthy();
    const text = await response.text();
    expect(text).toContain('User-agent: *');
    expect(text).toContain('Allow: /');
  });

  test('serves sitemap-index.xml', async ({ request }) => {
    const response = await request.get('/sitemap-index.xml');
    expect(response.ok()).toBeTruthy();
    const text = await response.text();
    expect(text).toContain('<?xml');
  });
});
