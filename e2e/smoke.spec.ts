import { test, expect, type Page } from '@playwright/test';

const EXPECTED_SHA = process.env.E2E_EXPECTED_SHA;
const E2E_ROLE = (process.env.E2E_ROLE ?? 'operator').toLowerCase();
const SMOKE_ASSERTION_TIMEOUT = 15_000;

type Route = {
  url: string;
  pathname: string;
  heading: string;
};

const routeCatalog: Record<string, Route> = {
  dashboard: {
    url: './',
    pathname: '/laporan_sdirbingakkum/',
    heading: 'Ringkasan laporan',
  },
  gakkum: {
    url: './gakkum',
    pathname: '/laporan_sdirbingakkum/gakkum',
    heading: 'Gakkum',
  },
  pelanggaran: {
    url: './pelanggaran',
    pathname: '/laporan_sdirbingakkum/pelanggaran',
    heading: 'Pelanggaran',
  },
  simTni: {
    url: './sim-tni',
    pathname: '/laporan_sdirbingakkum/sim-tni',
    heading: 'SIM TNI',
  },
  provos: {
    url: './provos',
    pathname: '/laporan_sdirbingakkum/provos',
    heading: 'Provos',
  },
  lakaLalin: {
    url: './laka-lalin',
    pathname: '/laporan_sdirbingakkum/laka-lalin',
    heading: 'Laka Lalu Lintas',
  },
  tindakPidana: {
    url: './tindak-pidana',
    pathname: '/laporan_sdirbingakkum/tindak-pidana',
    heading: 'Tindak Pidana',
  },
  pomdam: {
    url: './pomdam',
    pathname: '/laporan_sdirbingakkum/pomdam',
    heading: 'POMDAM',
  },
  reports: {
    url: './reports',
    pathname: '/laporan_sdirbingakkum/reports',
    heading: 'Laporan',
  },
  dataQuality: {
    url: './data-quality',
    pathname: '/laporan_sdirbingakkum/data-quality',
    heading: 'Kualitas data',
  },
};

const activeRouteKeys =
  E2E_ROLE === 'operator'
    ? [
        'gakkum',
        'pelanggaran',
        'simTni',
        'provos',
        'lakaLalin',
        'tindakPidana',
        'pomdam',
        'reports',
        'dataQuality',
      ]
    : [
        'dashboard',
        'gakkum',
        'pelanggaran',
        'simTni',
        'provos',
        'lakaLalin',
        'tindakPidana',
        'pomdam',
        'reports',
        'dataQuality',
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

async function openRoute(page: Page, route: Route) {
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
      page.getByText(route.heading, { exact: true }).first(),
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
  for (const routeKey of activeRouteKeys) {
    const route = routeCatalog[routeKey];
    test('opens ' + route.heading, async ({ page }) => {
      await openRoute(page, route);
    });
  }
});

test.describe('critical interaction surface smoke', () => {
  test('SIM TNI exposes period and POMDAM filters', async ({ page }) => {
    await openRoute(page, routeCatalog.simTni);
    await expect(
      page.getByRole('button', { name: /^Tahun\s+/ }),
    ).toBeVisible();
    await expect(
      page.getByRole('button', { name: /^Bulan\s+/ }),
    ).toBeVisible();
    await expect(filterButton(page, 'POMDAM')).toBeVisible();
  });

  test('Tindak Pidana exposes all four report filters', async ({ page }) => {
    await openRoute(page, routeCatalog.tindakPidana);
    for (const label of ['Sumber versi', 'POMDAM', 'Personel']) {
      await expect(filterButton(page, label)).toBeVisible();
    }
    await expect(
      page.getByRole('button', { name: /^Tahun\s+/ }),
    ).toBeVisible();
    await expect(
      page.getByRole('button', { name: /^Bulan\s+/ }),
    ).toBeVisible();
  });

  test('Gakkum exposes period, POMDAM, and taxonomy level controls', async ({ page }) => {
    await openRoute(page, routeCatalog.gakkum);
    await expect(
      page.getByRole('button', { name: /^Tahun\s+/ }),
    ).toBeVisible();
    await expect(
      page.getByRole('button', { name: /^Bulan\s+/ }),
    ).toBeVisible();
    await expect(filterButton(page, 'POMDAM')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Level 1', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Level 2', exact: true })).toBeVisible();
  });

  test('Pelanggaran exposes period, POMDAM, personel, and category controls', async ({ page }) => {
    await openRoute(page, routeCatalog.pelanggaran);
    for (const label of ['POMDAM', 'Personel']) {
      await expect(filterButton(page, label)).toBeVisible();
    }
    await expect(
      page.getByRole('button', { name: /^Tahun\s+/ }),
    ).toBeVisible();
    await expect(
      page.getByRole('button', { name: /^Bulan\s+/ }),
    ).toBeVisible();
    await expect(page.getByRole('checkbox', { name: 'Semua kategori', exact: true })).toBeVisible();
  });

  test('Reports reads the live report audit and provenance surface', async ({ page }) => {
    await openRoute(page, routeCatalog.reports);
    await expect(page.getByRole('heading', { name: 'Laporan', exact: true })).toBeVisible();
    await expect(page.getByText(/Fact rows/).first()).toBeVisible();
    await expect(page.getByText(/Source & provenance/).first()).toBeVisible();
    await expect(page.getByText(/\.xlsx/).first()).toBeVisible();
  });


  test('Commander cannot open the report input surface without manage capability', async ({ page }) => {
    test.skip(E2E_ROLE !== 'commander', 'Commander-only authorization test');
    await page.goto('./input-laporan', {
      waitUntil: 'domcontentloaded',
      timeout: 30_000,
    });
    await expect(
      page.getByRole('heading', { name: 'Ringkasan laporan', exact: true }),
    ).toBeVisible({ timeout: 30_000 });
    expect(new URL(page.url()).pathname).toBe('/laporan_sdirbingakkum/');
  });

  test('Commander drill-down can open source sheet inspection', async ({ page }) => {
    test.skip(E2E_ROLE !== 'commander', 'Commander-only drill-down test');
    await page.goto('./commander/drilldown?domain=GAKKUM', {
      waitUntil: 'domcontentloaded',
      timeout: 30_000,
    });

    await expect(
      page.getByText('DIMENSIONS', { exact: true }),
    ).toBeVisible({ timeout: 30_000 });

    const dimension = page
      .getByRole('button', {
        name: /^Patroli Berkendaraan\s+ACTIVITY/,
      })
      .first();
    await expect(dimension).toBeVisible({ timeout: SMOKE_ASSERTION_TIMEOUT });
    await dimension.click();

    const record = page
      .getByRole('button', {
        name: /^Patroli Berkendaraan.*Iskandar Muda/,
      })
      .first();
    await expect(record).toBeVisible({ timeout: SMOKE_ASSERTION_TIMEOUT });
    await record.click();

    const lineage = page.getByRole('group', {
      name: /SOURCE \/ LINEAGE/,
    });
    await expect(lineage).toBeVisible({ timeout: 30_000 });

    const sourceButton = page.getByRole('button', {
      name: 'Buka source sheet',
      exact: true,
    });
    await expect(sourceButton).toBeVisible();
    const sourceContextResponse = page.waitForResponse(
      (response) =>
        response.request().method() === 'POST' &&
        response.url().includes('/rpc/get_commander_source_sheet_context') &&
        response.status() === 200,
    );

    await sourceButton.click();

    const closeInspectorButton = page.getByRole('button', {
      name: 'Tutup source sheet',
      exact: true,
    });
    await expect(closeInspectorButton).toBeVisible({ timeout: 30_000 });

    const response = await sourceContextResponse;
    const payload = (await response.json()) as {
      status?: string;
      context_mode?: string;
      target?: { ref?: string; raw_value?: string };
      workbook?: { name?: string; sheet?: string };
      cells?: unknown[];
    };

    expect(payload.status).toBe('FOUND');
    expect(payload.context_mode).toBe('ALL_POMDAM_CONTEXT');
    expect(payload.target?.ref).toBe('C9');
    expect(payload.target?.raw_value).toBe('146');
    expect(payload.workbook?.name).toBe(
      '1. STATISTIK GIAT GAKKUM(1).xlsx',
    );
    expect(payload.workbook?.sheet).toBe('SEP 26');
    expect(Array.isArray(payload.cells)).toBe(true);
    expect(payload.cells?.length).toBeGreaterThan(0);

    const inspector = page.getByRole('group', {
      name: /^SOURCE SHEET INSPECTOR/,
    }).first();
    await expect(inspector).toBeVisible({ timeout: 30_000 });

    const originalSourceButton = page.getByRole('button', {
      name: 'Periksa file XLSX asli',
      exact: true,
    });
    await expect(originalSourceButton).toBeVisible({ timeout: 30_000 });

    const sourceFileCheckResponse = page.waitForResponse(
      (response) =>
        response.request().method() === 'POST' &&
        response.url().includes('/rpc/get_commander_source_file_context') &&
        response.status() === 200,
    );

    await originalSourceButton.click();

    const sourceFileResponse = await sourceFileCheckResponse;
    const sourceFilePayload = (await sourceFileResponse.json()) as {
      status?: string;
      record_id?: string;
      source_report_id?: string | null;
      file?: unknown;
    };

    expect(sourceFilePayload.status).toBe('NO_SOURCE_FILE');
    expect(sourceFilePayload.record_id).toBeTruthy();
    expect(sourceFilePayload.source_report_id).toBeTruthy();
    expect(sourceFilePayload.file).toBeNull();

    const originalSource = page.getByRole('group', {
      name: /^ORIGINAL XLSX SOURCE/,
    }).first();
    await expect(originalSource).toBeVisible({ timeout: 30_000 });
    await expect(
      page.getByText('FILE NOT AVAILABLE', { exact: true }).last(),
    ).toBeVisible({ timeout: 30_000 });
  });

  test('Data Quality reads the live audit summary', async ({ page }) => {
    await openRoute(page, routeCatalog.dataQuality);
    await expect(
      page
        .getByRole('group', {
          name: /^Audit integrity:\s*(OK|REVIEW)\b/,
        })
        .first(),
    ).toBeVisible({ timeout: 30_000 });
    await expect(page.getByText(/Fact rows/).first()).toBeVisible();
  });
});