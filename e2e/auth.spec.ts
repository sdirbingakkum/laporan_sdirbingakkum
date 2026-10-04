import { test, expect } from '@playwright/test';

test('reporting app requires authentication', async ({ page }) => {
  await page.goto('./', { waitUntil: 'domcontentloaded' });

  await expect(page.getByRole('textbox')).toHaveCount(2, {
    timeout: 60_000,
  });
  await expect(
    page.getByRole('button', { name: 'Masuk', exact: true }),
  ).toBeVisible();
});

test('preserves a protected deep link after authentication', async ({ page }) => {
  const email = process.env.E2E_EMAIL;
  const password = process.env.E2E_PASSWORD;

  if (!email || !password) {
    throw new Error(
      'E2E_EMAIL/E2E_PASSWORD are required for authentication coverage.',
    );
  }

  await page.goto('./gakkum', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByRole('button', { name: 'Masuk', exact: true }),
  ).toBeVisible({ timeout: 30_000 });

  const emailField = page.getByRole('textbox', {
    name: 'Email',
    exact: true,
  });
  const passwordField = page.getByRole('textbox', {
    name: 'Password',
    exact: true,
  });

  await emailField.fill(email);
  await passwordField.click();
  await passwordField.pressSequentially(password);

  await expect(passwordField).toHaveValue(password);

  await Promise.all([
    page.waitForURL(
      (url) =>
        new URL(url).pathname === '/laporan_sdirbingakkum/gakkum',
      { timeout: 30_000 },
    ),
    passwordField.press('Enter'),
  ]);

  await expect(
    page.getByRole('heading', { name: 'Gakkum', exact: true }),
  ).toBeVisible({ timeout: 30_000 });
  expect(new URL(page.url()).pathname).toBe('/laporan_sdirbingakkum/gakkum');
});
