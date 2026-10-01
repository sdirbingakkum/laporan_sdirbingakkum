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
