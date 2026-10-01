import { test, expect, type Page } from '@playwright/test';

const routes = [
  { path: './', title: 'Ringkasan sistem laporan' },
  { path: './gakkum', title: 'Giat Gakkum' },
  { path: './pelanggaran', title: 'Pelanggaran' },
  { path: './sim-tni', title: 'SIM TNI' },
  { path: './provos', title: 'Provos' },
  { path: './laka-lalin', title: 'Laka Lalin' },
  { path: './tindak-pidana', title: 'Tindak Pidana' },
  { path: './pomdam', title: 'Metadata POMDAM' },
  { path: './reports', title: 'Metadata laporan' },
  { path: './data-quality', title: 'Data quality contract' },
];

async function choose(page: Page, label: string, option: string) {
  await page.getByRole('combobox', { name: label, exact: true }).click();
  await page.getByText(option, { exact: true }).last().click();
}

test.describe('route smoke', () => {
  for (const route of routes) {
    test('opens ' + route.path, async ({ page }) => {
      await page.goto(route.path, { waitUntil: 'domcontentloaded' });
      await expect(
        page.getByText(route.title, { exact: true }),
      ).toBeVisible({ timeout: 60_000 });
    });
  }
});

test.describe('data contract smoke', () => {
  test('dashboard baseline', async ({ page }) => {
    await page.goto('./');
    await expect(page.getByText('21', { exact: true })).toBeVisible();
    await expect(page.getByText('6', { exact: true })).toBeVisible();
    await expect(page.getByText('42', { exact: true })).toBeVisible();
  });

  test('gakkum baseline', async ({ page }) => {
    await page.goto('./gakkum');
    await expect(page.getByText('Giat Gakkum', { exact: true })).toBeVisible();
    await expect(page.getByText('3104', { exact: true })).toBeVisible();
    await expect(page.getByText('188', { exact: true })).toBeVisible();
    await expect(page.getByText('1', { exact: true })).toBeVisible();
  });

  test('provos baseline', async ({ page }) => {
    await page.goto('./provos');
    await expect(page.getByText('Provos', { exact: true })).toBeVisible();
    await expect(page.getByText('9979', { exact: true })).toBeVisible();
    await expect(page.getByText('3926', { exact: true })).toBeVisible();
    await expect(page.getByText('3923', { exact: true })).toBeVisible();
  });

  test('laka lalin baseline', async ({ page }) => {
    await page.goto('./laka-lalin');
    await expect(page.getByText('Laka Lalin', { exact: true })).toBeVisible();
    await expect(page.getByText('Kejadian', { exact: true })).toBeVisible();
    await expect(page.getByText('Personel', { exact: true })).toBeVisible();
    await expect(page.getByText('Materiil', { exact: true })).toBeVisible();
    await expect(page.getByText('Pangkat korban', { exact: true })).toBeVisible();
    await expect(page.getByText('Akibat korban', { exact: true })).toBeVisible();
  });

  test('tindak pidana preserves zero versus valid facts', async ({ page }) => {
    await page.goto('./tindak-pidana');
    await expect(page.getByText('AUG_2026', { exact: true })).toBeVisible();
    await expect(page.getByText('379', { exact: true })).toBeVisible();
    await expect(page.getByText('8441', { exact: true })).toBeVisible();
    await expect(page.getByText(
      'Fakta VALID ditemukan, tetapi seluruh nilai source yang tersimpan pada filter ini bernilai 0. Ini bukan berarti record-nya tidak ada.',
      { exact: true },
    )).toBeVisible();
  });
});

test.describe('filter regression', () => {
  test('Tindak Pidana IM all personnel', async ({ page }) => {
    await page.goto('./tindak-pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await expect(page.getByText('13', { exact: true })).toBeVisible();
    await expect(page.getByText('407', { exact: true })).toBeVisible();
  });

  test('Tindak Pidana IM + PA', async ({ page }) => {
    await page.goto('./tindak-pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'PA · Perwira');
    await expect(page.getByText('3', { exact: true })).toBeVisible();
    await expect(page.getByText('102', { exact: true })).toBeVisible();
  });

  test('Tindak Pidana IM + BA', async ({ page }) => {
    await page.goto('./tindak-pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'BA · Bintara');
    await expect(page.getByText('6', { exact: true })).toBeVisible();
    await expect(page.getByText('99', { exact: true })).toBeVisible();
  });

  test('Tindak Pidana IM + PNS', async ({ page }) => {
    await page.goto('./tindak-pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'PNS · Pegawai Negeri Sipil');
    await expect(page.getByText('1', { exact: true })).toBeVisible();
    await expect(page.getByText('104', { exact: true })).toBeVisible();
  });
});
