import { test, expect, type Page } from '@playwright/test';

const EXPECTED_SHA = process.env.E2E_EXPECTED_SHA;
const SMOKE_ASSERTION_TIMEOUT = 15_000;

const routes = [
  { url: './', pathname: '/laporan_sdirbingakkum/', heading: 'Dashboard' },
  { url: './gakkum', pathname: '/laporan_sdirbingakkum/gakkum', heading: 'Gakkum' },
  { url: './pelanggaran', pathname: '/laporan_sdirbingakkum/pelanggaran', heading: 'Pelanggaran' },
  { url: './sim-tni', pathname: '/laporan_sdirbingakkum/sim-tni', heading: 'SIM TNI' },
  { url: './provos', pathname: '/laporan_sdirbingakkum/provos', heading: 'Provos' },
  { url: './laka-lalin', pathname: '/laporan_sdirbingakkum/laka-lalin', heading: 'Laka Lalin' },
  { url: './tindak-pidana', pathname: '/laporan_sdirbingakkum/tindak-pidana', heading: 'Tindak Pidana' },
  { url: './pomdam', pathname: '/laporan_sdirbingakkum/pomdam', heading: 'POMDAM' },
  { url: './reports', pathname: '/laporan_sdirbingakkum/reports', heading: 'Laporan' },
  { url: './data-quality', pathname: '/laporan_sdirbingakkum/data-quality', heading: 'Data Quality' },
];

test.beforeEach(async ({ request }) => {
  if (!EXPECTED_SHA) return;
  const response = await request.get('./deployment.json', { cache: 'no-store' });
  expect(response.ok()).toBeTruthy();
  const marker = (await response.json()) as { commit?: string };
  expect(marker.commit).toBe(EXPECTED_SHA);
});

async function diagnostics(page: Page) {
  const headings = await page.getByRole('heading').allTextContents().catch(() => []);
  return headings.filter((value) => value.trim().length > 0);
}

function filterButton(page: Page, label: string) {
  if (label === 'POMDAM') {
    return page.getByRole('button', {
      name: /^POMDAM\s+Semua POMDAM$/,
    });
  }

  return page.getByRole('button', {
    name: new RegExp('^' + label),
  });
}

async function openRoute(page: Page, route: (typeof routes)[number]) {
  const response = await page.goto(route.url, {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  const status = response?.status();
  if (status === undefined || status >= 400) {
    const headings = await diagnostics(page);
    throw new Error(
      'Deep-link navigation failed: ' +
      'status=' + (status ?? 'no-response') +
      ', finalUrl=' + page.url() +
      ', expectedPath=' + route.pathname +
      ', visibleHeadings=' + JSON.stringify(headings),
    );
  }

  try {
    await expect(
      page.getByRole('heading', { name: route.heading, exact: true }),
    ).toBeVisible({ timeout: SMOKE_ASSERTION_TIMEOUT });
  } catch (error) {
    const headings = await diagnostics(page);
    throw new Error(
      'Route rendered unexpected content: ' +
      'status=' + status +
      ', finalUrl=' + page.url() +
      ', expectedPath=' + route.pathname +
      ', expectedHeading=' + route.heading +
      ', visibleHeadings=' + JSON.stringify(headings) +
      '\n' +
      String(error),
    );
  }

  expect(new URL(page.url()).pathname).toBe(route.pathname);
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
    await expect(filterButton(page, 'Periode')).toBeVisible();
    await expect(filterButton(page, 'POMDAM')).toBeVisible();
  });

  test('Tindak Pidana exposes all four report filters', async ({ page }) => {
    await openRoute(page, routes[6]);
    for (const label of ['Periode', 'Sumber versi', 'POMDAM', 'Personel']) {
      await expect(filterButton(page, label)).toBeVisible();
    }
  });

  test('Gakkum exposes period, POMDAM, and taxonomy level controls', async ({ page }) => {
    await openRoute(page, routes[1]);
    await expect(filterButton(page, 'Periode')).toBeVisible();
    await expect(filterButton(page, 'POMDAM')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Level 1', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Level 2', exact: true })).toBeVisible();
  });

  test('Pelanggaran exposes period, POMDAM, personel, and category controls', async ({ page }) => {
    await openRoute(page, routes[2]);
    for (const label of ['Periode', 'POMDAM', 'Personel']) {
      await expect(filterButton(page, label)).toBeVisible();
    }
    await expect(page.getByRole('checkbox', { name: 'Semua kategori', exact: true })).toBeVisible();
  });

  test('Reports reads the live report audit and provenance surface', async ({ page }) => {
    await openRoute(page, routes[8]);
    await expect(page.getByText('Laporan aktif', { exact: true })).toBeVisible();
    await expect(page.getByText(/Fact rows/).first()).toBeVisible();
    await expect(page.getByText('Source & provenance', { exact: true })).toBeVisible();
    await expect(page.getByText(/\.xlsx/).first()).toBeVisible();
  });


  test('preserves a deep link after re-authentication', async ({ page }) => {
    await openRoute(page, routes[1]);

    await page.getByRole('button', { name: 'Akun', exact: true }).click();
    await page.getByRole('menuitem', { name: 'Keluar', exact: true }).click();

    await expect(page.getByRole('button', { name: 'Masuk', exact: true })).toBeVisible();

    const email = process.env.E2E_EMAIL;
    const password = process.env.E2E_PASSWORD;
    if (!email || !password) {
      throw new Error('E2E credentials are required for re-authentication coverage.');
    }

    await page.getByRole('textbox', { name: 'Email', exact: true }).fill(email);
    await page.getByRole('textbox', { name: 'Password', exact: true }).fill(password);
    await page.getByRole('button', { name: 'Masuk', exact: true }).click();

    await expect(
      page.getByRole('heading', { name: 'Gakkum', exact: true }),
    ).toBeVisible({ timeout: 30_000 });
    expect(new URL(page.url()).pathname).toBe(routes[1].pathname);
  });

  test('Data Quality reads the live audit summary', async ({ page }) => {
    await openRoute(page, routes[9]);
    await expect(page.getByText('Audit integrity: OK', { exact: true })).toBeVisible();
    await expect(page.getByText(/Fact rows/).first()).toBeVisible();
  });
});