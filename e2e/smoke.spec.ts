import { test, expect, type Page } from '@playwright/test';

const EXPECTED_SHA = process.env.E2E_EXPECTED_SHA;

const routes = [
  { url: './', pathname: '/laporan_sdirbingakkum/', heading: 'Dashboard' },
  { url: './gakkum', pathname: '/laporan_sdirbingakkum/gakkum', heading: 'Giat Gakkum' },
  { url: './pelanggaran', pathname: '/laporan_sdirbingakkum/pelanggaran', heading: 'Pelanggaran' },
  { url: './sim-tni', pathname: '/laporan_sdirbingakkum/sim-tni', heading: 'SIM TNI' },
  { url: './provos', pathname: '/laporan_sdirbingakkum/provos', heading: 'Provos' },
  { url: './laka-lalin', pathname: '/laporan_sdirbingakkum/laka-lalin', heading: 'Laka Lalin' },
  { url: './tindak-pidana', pathname: '/laporan_sdirbingakkum/tindak-pidana', heading: 'Tindak Pidana' },
  { url: './pomdam', pathname: '/laporan_sdirbingakkum/pomdam', heading: 'POMDAM' },
  { url: './reports', pathname: '/laporan_sdirbingakkum/reports', heading: 'Metadata laporan' },
  { url: './data-quality', pathname: '/laporan_sdirbingakkum/data-quality', heading: 'Data quality contract' },
];

test.beforeEach(async ({ request }) => {
  if (!EXPECTED_SHA) return;
  const response = await request.get('./deployment.json', { cache: 'no-store' });
  expect(response.ok()).toBeTruthy();
  const marker = (await response.json()) as { commit?: string };
  expect(marker.commit).toBe(EXPECTED_SHA);
});

async function openRoute(page: Page, route: (typeof routes)[number]) {
  await page.goto(route.url, { waitUntil: 'domcontentloaded' });
  await expect(
    page.getByRole('heading', { name: route.heading, exact: true }),
  ).toBeVisible({ timeout: 60_000 });
  await expect
    .poll(() => new URL(page.url()).pathname)
    .toBe(route.pathname);
}

test.describe('deep-link route smoke', () => {
  for (const route of routes) {
    test('opens ' + route.heading, async ({ page }) => {
      await openRoute(page, route);
    });
  }
});

test.describe('critical interaction surface smoke', () => {
  test('SIM TNI exposes period and POMDAM filters', async ({ page }) => {
    await openRoute(page, routes[3]);
    await expect(page.getByRole('combobox', { name: 'Periode', exact: true })).toBeVisible();
    await expect(page.getByRole('combobox', { name: 'POMDAM', exact: true })).toBeVisible();
  });

  test('Tindak Pidana exposes all four report filters', async ({ page }) => {
    await openRoute(page, routes[6]);
    for (const label of ['Periode', 'Sumber versi', 'POMDAM', 'Personel']) {
      await expect(page.getByRole('combobox', { name: label, exact: true })).toBeVisible();
    }
  });

  test('Gakkum exposes period, POMDAM, and taxonomy level controls', async ({ page }) => {
    await openRoute(page, routes[1]);
    await expect(page.getByRole('combobox', { name: 'Periode', exact: true })).toBeVisible();
    await expect(page.getByRole('combobox', { name: 'POMDAM', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Level 1', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Level 2', exact: true })).toBeVisible();
  });

  test('Pelanggaran exposes period, POMDAM, personel, and category controls', async ({ page }) => {
    await openRoute(page, routes[2]);
    for (const label of ['Periode', 'POMDAM', 'Personel']) {
      await expect(page.getByRole('combobox', { name: label, exact: true })).toBeVisible();
    }
    await expect(page.getByRole('button', { name: 'Semua kategori', exact: true })).toBeVisible();
  });
});