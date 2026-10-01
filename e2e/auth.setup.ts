import { test as setup, expect } from '@playwright/test';
import fs from 'node:fs';

const authFile = 'playwright/.auth/user.json';

setup('authenticate staging user', async ({ page }) => {
  const email = process.env.E2E_EMAIL;
  const password = process.env.E2E_PASSWORD;

  if (!email || !password) {
    throw new Error(
      'Missing E2E_EMAIL/E2E_PASSWORD GitHub Actions secrets. Create a dedicated staging Supabase user for E2E.',
    );
  }

  fs.mkdirSync('playwright/.auth', { recursive: true });

  await page.goto('./', { waitUntil: 'domcontentloaded' });
  await expect(
    page.getByText('Laporan Sdirbin Gakkum', { exact: true }),
  ).toBeVisible();

  await page.getByLabel('Email', { exact: true }).fill(email);
  await page.getByLabel('Password', { exact: true }).fill(password);
  await page.getByRole('button', { name: 'Masuk', exact: true }).click();

  await expect(
    page.getByText('Ringkasan sistem laporan', { exact: true }),
  ).toBeVisible({ timeout: 60_000 });

  await page.context().storageState({ path: authFile });
});
