import { test, expect } from '@playwright/test';

test('operator can open report input without writing production data', async ({ page }) => {
  await page.goto('./input-laporan', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByText('Input Laporan', { exact: true }).first(),
  ).toBeVisible({ timeout: 30_000 });

  const gakkumSection = page.getByRole('group', {
    name: /^GAKKUM\s+14 kegiatan leaf\./,
  });
  await expect(gakkumSection).toBeVisible({ timeout: 15_000 });

  await expect(
    gakkumSection.getByRole('textbox', {
      name: 'Nilai',
      exact: true,
    }),
  ).toHaveCount(14);

  await expect(
    page.getByRole('button', {
      name: 'Simpan & Kirim Laporan',
      exact: true,
    }),
  ).toBeVisible({ timeout: 15_000 });
});
