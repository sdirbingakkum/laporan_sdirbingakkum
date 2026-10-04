import { test, expect } from '@playwright/test';

test('operator can open report input without writing production data', async ({ page }) => {
  await page.goto('./input-laporan', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByRole('heading', { name: 'Input Laporan', exact: true }),
  ).toBeVisible({ timeout: 30_000 });

  await expect(
    page.getByText('GAKKUM', { exact: true }),
  ).toBeVisible({ timeout: 15_000 });

  await expect(
    page.getByText('14 kegiatan leaf. Parent tidak dimasukkan agar tidak double count.'),
  ).toBeVisible({ timeout: 15_000 });

  await expect(
    page.getByRole('button', {
      name: 'Simpan & Kirim Laporan',
      exact: true,
    }),
  ).toBeVisible({ timeout: 15_000 });
});
