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

  const textboxes = page.getByRole('textbox');
  await expect(textboxes).toHaveCount(2, { timeout: 30_000 });

  await textboxes.nth(0).fill(email);

  const passwordField = textboxes.nth(1);
  await passwordField.click();
  await passwordField.pressSequentially(password);
  const passwordLength = await passwordField.evaluate((element) => {
    return (element as HTMLInputElement).value.length;
  });

  if (passwordLength === 0) {
    throw new Error('E2E password input remained empty after keyboard entry.');
  }

  await page.getByRole('button', { name: 'Masuk', exact: true }).click();

  await expect(
    page.getByRole('button', { name: 'Gakkum', exact: true }),
  ).toBeVisible({ timeout: 60_000 });

  await page.context().storageState({ path: authFile });
});
