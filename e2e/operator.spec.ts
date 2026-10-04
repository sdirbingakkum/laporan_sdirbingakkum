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

  const metadataGroup = page.getByRole('group', {
    name: /^Periode /,
  }).first();

  const pomdamButton = metadataGroup.getByRole('button', {
    name: /^POMDAM$/,
    exact: true,
  });
  await expect(pomdamButton).toBeVisible({ timeout: 15_000 });
  await pomdamButton.click();

  const pomdamOption = page.getByRole('menuitem', {
    name: 'IM · Iskandar Muda',
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
  await expect(values.nth(0)).toHaveValue('7');

  const submitResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'POST' &&
      response.url().includes('/rpc/submit_report'),
    { timeout: 30_000 },
  );

  await page.getByRole('button', {
    name: 'Simpan & Kirim Laporan',
    exact: true,
  }).click();

  const submitResponse = await submitResponsePromise;
  expect(submitResponse.status()).toBe(200);

  const submitPayload = await submitResponse.json();
  expect(submitPayload.status).toBe('SUBMITTED');
  expect(submitPayload.report_type).toBe('GAKKUM');

  await expect(
    page.getByText(
      'Laporan Statistik Giat Gakkum berhasil disimpan untuk Oktober 2026.',
      { exact: true },
    ).first(),
  ).toBeVisible({ timeout: 15_000 });

  const recordResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'GET' &&
      response.url().includes('/rest/v1/gakkum_records') &&
      response.status() === 200,
    { timeout: 30_000 },
  );

  await page.goto('./gakkum', {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });

  await expect(
    page.getByRole('heading', { name: 'Gakkum', exact: true }),
  ).toBeVisible({ timeout: 30_000 });

  const recordResponse = await recordResponsePromise;
  const rows = (await recordResponse.json()) as Array<{
    value?: number | null;
    data_status?: string;
    source_cell_id?: string | null;
  }>;

  expect(rows).toHaveLength(14);
  expect(rows.filter((row) => row.data_status === 'VALID')).toHaveLength(1);
  expect(rows.filter((row) => row.data_status === 'NOT_REPORTED')).toHaveLength(
    13,
  );
  expect(rows.reduce((total, row) => total + (row.value ?? 0), 0)).toBe(7);
  expect(rows.every((row) => row.source_cell_id == null)).toBe(true);
});

