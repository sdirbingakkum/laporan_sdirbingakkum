import { test as setup, expect } from '@playwright/test';
import fs from 'node:fs';

const authFile = 'playwright/.auth/user.json';
const e2eRole = (process.env.E2E_ROLE ?? 'operator').toLowerCase();

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

  const emailField = page.getByRole('textbox', { name: 'Email', exact: true });
  const passwordField = page.getByRole('textbox', { name: 'Password', exact: true });

  await expect(emailField).toBeVisible({ timeout: 30_000 });
  await expect(passwordField).toBeVisible({ timeout: 30_000 });

  await emailField.fill(email);
  await passwordField.click();
  await passwordField.pressSequentially(password);
  const passwordLength = await passwordField.evaluate((element) => {
    return (element as HTMLInputElement).value.length;
  });

  if (passwordLength === 0) {
    throw new Error('E2E password input remained empty after keyboard entry.');
  }

  await page.getByRole('button', { name: 'Masuk', exact: true }).click();

  const landing = e2eRole === 'operator'
      ? page.getByText('Laporan aktif', { exact: true })
      : page.getByText('LAPORAN SDIRBIN GAKKUM', { exact: true }).first();

  try {
    await expect(landing).toBeVisible({ timeout: 30_000 });
  } catch (firstError) {
    // Supabase auth state can arrive successfully while the Flutter
    // StreamBuilder has not rebuilt the current document yet. A reload
    // checks the persisted session before issuing another sign-in request.
    await page.reload({ waitUntil: 'domcontentloaded', timeout: 30_000 });

    try {
      await expect(landing).toBeVisible({ timeout: 15_000 });
    } catch (secondError) {
      const loginButton = page.getByRole('button', {
        name: 'Masuk',
        exact: true,
      });
      const stillLoggedOut = await loginButton.isVisible().catch(() => false);

      if (!stillLoggedOut) {
        throw firstError;
      }

      await page.getByRole('textbox', { name: 'Email', exact: true }).fill(email);
      const passwordInput = page.getByRole('textbox', {
        name: 'Password',
        exact: true,
      });
      await passwordInput.fill(password);
      await loginButton.click();
      await expect(landing).toBeVisible({ timeout: 30_000 });
    }
  }

  await page.context().storageState({ path: authFile });
});
