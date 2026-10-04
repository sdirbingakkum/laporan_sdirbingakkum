import { test, expect, type Page } from '@playwright/test';

const ACCEPTANCE_MARKER = 'E2E-ACCEPTANCE-GAKKUM-IM-2026-10';

async function signIn(page: Page, email: string, password: string, landingText: string) {
  await page.goto('./', { waitUntil: 'domcontentloaded', timeout: 30_000 });
  const loginButton = page.getByRole('button', { name: 'Masuk', exact: true });
  if (await loginButton.isVisible().catch(() => false)) {
    await page.getByRole('textbox', { name: 'Email', exact: true }).fill(email);
    await page.getByRole('textbox', { name: 'Password', exact: true }).fill(password);
    await loginButton.click();
  }
  await expect(page.getByText(landingText, { exact: true }).first()).toBeVisible({ timeout: 30_000 });
}

function requiredEnv(name: string) {
  const value = process.env[name];
  if (!value) throw new Error(name + ' is required for acceptance E2E.');
  return value;
}

test('operator write reaches Commander Dashboard read model', async ({ browser }) => {
  test.skip(
    process.env.E2E_ACCEPTANCE_TEST !== 'true',
    'Production acceptance write test is manual-only.',
  );

  const operatorContext = await browser.newContext();
  const commanderContext = await browser.newContext();

  try {
    const operatorPage = await operatorContext.newPage();
    await signIn(operatorPage, requiredEnv('E2E_EMAIL'), requiredEnv('E2E_PASSWORD'), 'Laporan aktif');

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

    const commanderPage = await commanderContext.newPage();
    await signIn(commanderPage, requiredEnv('E2E_COMMANDER_EMAIL'), requiredEnv('E2E_COMMANDER_PASSWORD'), 'LAPORAN SDIRBIN GAKKUM');
    const dashboardResponsePromise = commanderPage.waitForResponse(
      (response) => response.request().method() === 'POST' && response.url().includes('/rpc/get_commander_cop_snapshot') && response.status() === 200,
      { timeout: 30_000 },
    );
    await commanderPage.goto('./', { waitUntil: 'domcontentloaded', timeout: 30_000 });
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
    await expect(commanderPage.getByText('GAKKUM', { exact: true }).first()).toBeVisible({ timeout: 15_000 });
  } finally {
    await operatorContext.close();
    await commanderContext.close();
  }});
