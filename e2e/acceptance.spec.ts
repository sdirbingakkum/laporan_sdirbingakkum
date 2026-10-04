import { test, expect, type Page } from '@playwright/test';

const ACCEPTANCE_MARKER = 'E2E-ACCEPTANCE-GAKKUM-IM-2026-10';

function requiredEnv(name: string) {
  const value = process.env[name];
  if (!value) throw new Error(name + ' is required for acceptance E2E.');
  return value;
}

async function signIn(
  page: Page,
  email: string,
  password: string,
  expectedEmail: string,
  expectedRole: string,
  landingText: string,
  expectedPath: string,
) {
  await page.goto('./', { waitUntil: 'domcontentloaded', timeout: 30_000 });

  const loginButton = page.getByRole('button', { name: 'Masuk', exact: true });
  if (await loginButton.isVisible().catch(() => false)) {
    await page.getByRole('textbox', { name: 'Email', exact: true }).fill(email);
    await page.getByRole('textbox', { name: 'Password', exact: true }).fill(password);
    await loginButton.click();
  }

  await page.waitForURL(
    (url) => new URL(url).pathname === expectedPath,
    { timeout: 30_000 },
  ).catch(async (error) => {
    const bodyText = await page.locator('body').innerText().catch(() => '');
    throw new Error(
      'Login did not reach expected path "' +
        expectedPath +
        '". Current URL: ' +
        page.url() +
        '. Page text: ' +
        bodyText.slice(0, 800) +
        '. Cause: ' +
        String(error),
    );
  });

  await expect(page.getByText(landingText, { exact: true }).first()).toBeVisible({ timeout: 30_000 });

  const accountButton = page.getByRole('button', { name: 'Akun', exact: true });
  await expect(accountButton).toBeVisible({ timeout: 15_000 });
  await accountButton.click();
  await expect(page.getByText(expectedEmail, { exact: true })).toBeVisible({ timeout: 15_000 });
  await expect(page.getByText(expectedRole, { exact: true })).toBeVisible({ timeout: 15_000 });
  await page.keyboard.press('Escape');
}

test('operator write reaches Commander Dashboard read model', async ({ browser }) => {
  test.skip(
    process.env.E2E_ACCEPTANCE_TEST !== 'true',
    'Production acceptance write test is manual-only.',
  );

  const commanderContext = await browser.newContext();
  const operatorContext = await browser.newContext();

  try {
    // Verify Commander identity BEFORE any write occurs.
    const commanderPage = await commanderContext.newPage();
    const commanderEmail = requiredEnv('E2E_COMMANDER_EMAIL');
    await signIn(
      commanderPage,
      commanderEmail,
      requiredEnv('E2E_COMMANDER_PASSWORD'),
      commanderEmail,
      'Komandan Puspomad',
      'LAPORAN SDIRBIN GAKKUM',
      '/laporan_sdirbingakkum/',
    );
    expect(new URL(commanderPage.url()).pathname).toBe('/laporan_sdirbingakkum/');

    // Only after Commander identity is proven, perform the controlled Operator write.
    const operatorPage = await operatorContext.newPage();
    await signIn(
      operatorPage,
      requiredEnv('E2E_EMAIL'),
      requiredEnv('E2E_PASSWORD'),
      'operator@puspomad.mil.id',
      'Operator Puspomad',
      'Laporan aktif',
      '/laporan_sdirbingakkum/reports',
    );

    await operatorPage.goto('./input-laporan', { waitUntil: 'domcontentloaded', timeout: 30_000 });
    await expect(operatorPage.getByText('Input Laporan', { exact: true }).first()).toBeVisible({ timeout: 30_000 });

    const metadataGroup = operatorPage.getByRole('group', { name: /^Periode / }).first();
    const pomdamButton = metadataGroup.getByRole('button', { name: /^POMDAM$/, exact: true });
    await expect(pomdamButton).toBeVisible({ timeout: 15_000 });
    await pomdamButton.click();
    const pomdamOption = operatorPage.getByRole('menuitem', { name: 'IM · Iskandar Muda', exact: true });
    await expect(pomdamOption).toBeVisible({ timeout: 15_000 });
    await pomdamOption.click();

    const gakkumSection = operatorPage.getByRole('group', { name: /^GAKKUM\s+14 kegiatan leaf\./ });
    await expect(gakkumSection).toBeVisible({ timeout: 15_000 });
    const values = gakkumSection.getByRole('textbox', { name: 'Nilai', exact: true });
    await expect(values).toHaveCount(14);
    await values.nth(0).fill('7');
    await operatorPage.getByRole('textbox', { name: 'Catatan umum (opsional)', exact: true }).fill(ACCEPTANCE_MARKER);

    const submitResponsePromise = operatorPage.waitForResponse(
      (response) => response.request().method() === 'POST' && response.url().includes('/rpc/submit_report') && response.status() === 200,
      { timeout: 30_000 },
    );
    await operatorPage.getByRole('button', { name: 'Simpan & Kirim Laporan', exact: true }).click();
    const submitResponse = await submitResponsePromise;
    const submitPayload = (await submitResponse.json()) as { status?: string; report_type?: string };
    expect(submitPayload.status).toBe('SUBMITTED');
    expect(submitPayload.report_type).toBe('GAKKUM');
    await expect(operatorPage.getByText('Laporan Statistik Giat Gakkum berhasil disimpan untuk Oktober 2026.', { exact: true }).first()).toBeVisible({ timeout: 15_000 });

    // Refresh the already-authenticated Commander context and assert the live read model.
    const dashboardResponsePromise = commanderPage.waitForResponse(
      (response) => response.request().method() === 'POST' && response.url().includes('/rpc/get_commander_cop_snapshot') && response.status() === 200,
      { timeout: 30_000 },
    );
    await commanderPage.reload({ waitUntil: 'domcontentloaded', timeout: 30_000 });
    await expect(commanderPage.getByText('LAPORAN SDIRBIN GAKKUM', { exact: true }).first()).toBeVisible({ timeout: 30_000 });
    const dashboardResponse = await dashboardResponsePromise;
    const snapshot = (await dashboardResponse.json()) as {
      scope?: { type?: string };
      domains?: Array<{ code?: string; as_of?: { label?: string }; primary_metric?: { value?: number | null } }>;
    };
    expect(snapshot.scope?.type).toBe('ALL_POMDAM');
    const gakkum = snapshot.domains?.find((domain) => domain.code === 'GAKKUM');
    expect(gakkum).toBeTruthy();
    expect(gakkum?.as_of?.label).toBe('Oktober 2026');
    expect(gakkum?.primary_metric?.value).toBe(7);
  } finally {
    await operatorContext.close();
    await commanderContext.close();
  }
});