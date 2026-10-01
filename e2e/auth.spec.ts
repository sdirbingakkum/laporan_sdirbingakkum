import { test, expect } from '@playwright/test';

test('reporting routes require authentication', async ({ page }) => {
  await page.goto('./gakkum', { waitUntil: 'domcontentloaded' });
  await expect(
    page.getByText('Laporan Sdirbin Gakkum', { exact: true }),
  ).toBeVisible({ timeout: 60_000 });
  await expect(page.getByLabel('Email', { exact: true })).toBeVisible();
  await expect(page.getByLabel('Password', { exact: true })).toBeVisible();
});
