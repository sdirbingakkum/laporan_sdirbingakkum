import { test, expect, type Page } from '@playwright/test';

const EXPECTED_SHA = process.env.E2E_EXPECTED_SHA;

test.beforeEach(async ({ request }) => {
  if (!EXPECTED_SHA) return;
  const response = await request.get('./deployment.json', { cache: 'no-store' });
  expect(response.ok()).toBeTruthy();
  const marker = (await response.json()) as { commit?: string };
  expect(marker.commit).toBe(EXPECTED_SHA);
});

const routes = [
  { path: '/', label: 'Dashboard' },
  { path: '/gakkum', label: 'Gakkum' },
  { path: '/pelanggaran', label: 'Pelanggaran' },
  { path: '/sim-tni', label: 'SIM TNI' },
  { path: '/provos', label: 'Provos' },
  { path: '/laka-lalin', label: 'Laka Lalin' },
  { path: '/tindak-pidana', label: 'Tindak Pidana' },
  { path: '/pomdam', label: 'POMDAM' },
  { path: '/reports', label: 'Laporan' },
  { path: '/data-quality', label: 'Data Quality' },
];

async function openRoute(page: Page, path: string, label: string) {
  await page.goto('./', { waitUntil: 'domcontentloaded' });

  if (path === '/') {
    return;
  }

  const destination = page.getByText(label, { exact: true }).last();

  await expect(destination).toBeVisible({ timeout: 30_000 });
  await destination.click();

  await expect
    .poll(() => new URL(page.url()).pathname)
    .toBe('/laporan_sdirbingakkum' + path);
}

async function choose(page: Page, label: string, option: string) {
  const combo = page.getByRole('combobox', {
    name: label,
    exact: true,
  });
  await expect(combo).toBeVisible();
  await combo.click();
  await page.getByText(option, { exact: true }).last().click();
}

test.describe('route smoke', () => {
  for (const route of routes) {
    test('opens ' + route.label, async ({ page }) => {
      await openRoute(page, route.path, route.label);
    });
  }
});

test.describe('data contract smoke', () => {
  test('dashboard baseline', async ({ page }) => {
    await openRoute(page, '/', 'Dashboard');
    await expect(page.getByText('21', { exact: true })).toBeVisible();
    await expect(page.getByText('6', { exact: true })).toBeVisible();
    await expect(page.getByText('42', { exact: true })).toBeVisible();
  });

  test('gakkum baseline', async ({ page }) => {
    await openRoute(page, '/gakkum', 'Gakkum');
    await expect(page.getByText('3104', { exact: true })).toBeVisible();
    await expect(page.getByText('188', { exact: true })).toBeVisible();
    await expect(page.getByText('1', { exact: true })).toBeVisible();
  });

  test('provos baseline', async ({ page }) => {
    await openRoute(page, '/provos', 'Provos');
    await expect(page.getByText('9979', { exact: true })).toBeVisible();
    await expect(page.getByText('3926', { exact: true })).toBeVisible();
    await expect(page.getByText('3923', { exact: true })).toBeVisible();
  });

  test('laka lalin baseline', async ({ page }) => {
    await openRoute(page, '/laka-lalin', 'Laka Lalin');
    await expect(page.getByText('Kejadian', { exact: true })).toBeVisible();
    await expect(page.getByText('Personel', { exact: true })).toBeVisible();
    await expect(page.getByText('Materiil', { exact: true })).toBeVisible();
    await expect(page.getByText('Pangkat korban', { exact: true })).toBeVisible();
    await expect(page.getByText('Akibat korban', { exact: true })).toBeVisible();
  });

  test('tindak pidana preserves zero versus valid facts', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await expect(page.getByText('AUG_2026', { exact: true })).toBeVisible();
    await expect(page.getByText('379', { exact: true })).toBeVisible();
    await expect(page.getByText('8441', { exact: true })).toBeVisible();
    await expect(
      page.getByText(
        'Fakta VALID ditemukan, tetapi seluruh nilai source yang tersimpan pada filter ini bernilai 0. Ini bukan berarti record-nya tidak ada.',
        { exact: true },
      ),
    ).toBeVisible();
  });
});

test.describe('filter regression', () => {
  test('Tindak Pidana IM all personnel', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await expect(page.getByText('13', { exact: true })).toBeVisible();
    await expect(page.getByText('407', { exact: true })).toBeVisible();
  });

  test('Tindak Pidana IM + PA', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'PA · Perwira');
    await expect(page.getByText('3', { exact: true })).toBeVisible();
    await expect(page.getByText('102', { exact: true })).toBeVisible();
  });

  test('Tindak Pidana IM + BA', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'BA · Bintara');
    await expect(page.getByText('6', { exact: true })).toBeVisible();
    await expect(page.getByText('99', { exact: true })).toBeVisible();
  });

  test('Tindak Pidana IM + PNS', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'PNS · Pegawai Negeri Sipil');
    await expect(page.getByText('1', { exact: true })).toBeVisible();
    await expect(page.getByText('104', { exact: true })).toBeVisible();
  });
});
