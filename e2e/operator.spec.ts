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


test('operator can submit a controlled GAKKUM report and read it back', async ({ page }) => {
  test.skip(
    process.env.E2E_WRITE_TEST !== 'true',
    'Controlled production write test is opt-in.',
  );

  await page.goto('./input-laporan', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByText('Input Laporan', { exact: true }).first(),
  ).toBeVisible({ timeout: 30_000 });

  const pomdamButton = page.getByRole('button', {
    name: 'POMDAM',
    exact: true,
  });
  await pomdamButton.click();

  const pomdamOption = page.getByText('IM · Iskandar Muda', {
    exact: true,
  });
  await expect(pomdamOption).toBeVisible({ timeout: 15_000 });
  await pomdamOption.click();

  const gakkumSection = page.getByRole('group', {
    name: /^GAKKUM\s+14 kegiatan leaf\./,
  });
  await expect(gakkumSection).toBeVisible({ timeout: 15_000 });

  const values = gakkumSection.getByRole('textbox', {
    name: 'Nilai',
    exact: true,
  });
  await expect(values).toHaveCount(14);

  await values.nth(0).fill('7');
  for (let index = 1; index < 14; index++) {
    await values.nth(index).fill('0');
  }

  await page.getByRole('textbox', {
    name: 'Catatan umum (opsional)',
    exact: true,
  }).fill('E2E_WRITE_TEST_GAKKUM');

  const periodResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'POST' &&
      response.url().includes('/rpc/get_or_create_monthly_report_period') &&
      response.status() === 200,
  );
  const submitResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'POST' &&
      response.url().includes('/rpc/submit_report') &&
      response.status() === 200,
  );

  await page.getByRole('button', {
    name: 'Simpan & Kirim Laporan',
    exact: true,
  }).click();

  const periodResponse = await periodResponsePromise;
  const periodPayload = await periodResponse.json();
  expect(periodPayload.period_label).toBe('Oktober 2026');

  const submitResponse = await submitResponsePromise;
  const submitPayload = await submitResponse.json();
  expect(submitPayload.status).toBe('SUBMITTED');
  expect(submitPayload.report_type).toBe('GAKKUM');

  await expect(
    page.getByText(
      'Laporan Statistik Giat Gakkum berhasil disimpan untuk Oktober 2026.',
      { exact: true },
    ),
  ).toBeVisible({ timeout: 15_000 });

  const recordResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'GET' &&
      response.url().includes('/rest/v1/gakkum_records') &&
      response.status() === 200,
  );

  await page.goto('./gakkum', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByRole('heading', { name: 'Giat Gakkum', exact: true }),
  ).toBeVisible({ timeout: 30_000 });

  const recordResponse = await recordResponsePromise;
  const rows = (await recordResponse.json()) as Array<{
    value?: number | null;
    data_status?: string;
    source_cell_id?: string | null;
  }>;

  expect(rows).toHaveLength(14);
  expect(rows.filter((row) => row.data_status === 'VALID')).toHaveLength(14);
  expect(rows.reduce((total, row) => total + (row.value ?? 0), 0)).toBe(7);
  expect(rows.every((row) => row.source_cell_id == null)).toBe(true);

  await page.goto('./reports', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByText('Laporan aktif', { exact: true }),
  ).toBeVisible({ timeout: 30_000 });
  await expect(page.getByText('Fact rows', { exact: true })).toBeVisible({
    timeout: 15_000,
  });
});
