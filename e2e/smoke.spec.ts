import { test, expect, type Page } from '@playwright/test';

async function expectSemanticsContains(page: Page, expected: string) {
  await expect
    .poll(
      async () =>
        page.locator('flt-semantics[aria-label]').evaluateAll(
          (elements) =>
            elements
              .map((element) => element.getAttribute('aria-label') ?? '')
              .join('\n'),
        ),
      { timeout: 60_000 },
    )
    .toContain(expected);
}

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

  const destination = page.getByRole('button', {
    name: new RegExp('^' + label + '\\b'),
  }).last();

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
      await expectSemanticsContains(page, route.label);
    });
  }
});

test.describe('data contract smoke', () => {
  test('dashboard baseline', async ({ page }) => {
    await openRoute(page, '/', 'Dashboard');
    await expectSemanticsContains(page, '21 POMDAM');
    await expectSemanticsContains(page, '6 Jenis laporan');
    await expectSemanticsContains(page, '42 Periode');
  });

  test('gakkum baseline', async ({ page }) => {
    await openRoute(page, '/gakkum', 'Gakkum');
    await expectSemanticsContains(page, '3104');
    await expectSemanticsContains(page, '188');
    await expectSemanticsContains(page, 'Invalid source');
  });

  test('provos baseline', async ({ page }) => {
    await openRoute(page, '/provos', 'Provos');
    await expectSemanticsContains(page, '9979');
    await expectSemanticsContains(page, '3926');
    await expectSemanticsContains(page, '3923');
  });

  test('laka lalin baseline', async ({ page }) => {
    await openRoute(page, '/laka-lalin', 'Laka Lalin');
    await expectSemanticsContains(page, 'Kejadian');
    await expectSemanticsContains(page, 'Personel');
    await expectSemanticsContains(page, 'Materiil');
    await expectSemanticsContains(page, 'Pangkat korban');
    await expectSemanticsContains(page, 'Akibat korban');
  });

  test('tindak pidana preserves zero versus valid facts', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await expectSemanticsContains(page, 'AUG_2026');
    await expectSemanticsContains(page, '379 Valid records');
    await expectSemanticsContains(page, '8441 Tidak dilaporkan');
    await expectSemanticsContains(
      page,
      'Fakta VALID ditemukan, tetapi seluruh nilai source',
    );
  });
});

test.describe('filter regression', () => {
  test('Tindak Pidana IM all personnel', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await expectSemanticsContains(page, '13 Valid records');
    await expectSemanticsContains(page, '407 Tidak dilaporkan');
  });

  test('Tindak Pidana IM + PA', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'PA · Perwira');
    await expectSemanticsContains(page, '3 Valid records');
    await expectSemanticsContains(page, '102 Tidak dilaporkan');
  });

  test('Tindak Pidana IM + BA', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'BA · Bintara');
    await expectSemanticsContains(page, '6 Valid records');
    await expectSemanticsContains(page, '99 Tidak dilaporkan');
  });

  test('Tindak Pidana IM + PNS', async ({ page }) => {
    await openRoute(page, '/tindak-pidana', 'Tindak Pidana');
    await choose(page, 'POMDAM', 'IM · Iskandar Muda');
    await choose(page, 'Personel', 'PNS · Pegawai Negeri Sipil');
    await expectSemanticsContains(page, '1 Valid records');
    await expectSemanticsContains(page, '104 Tidak dilaporkan');
  });
});
