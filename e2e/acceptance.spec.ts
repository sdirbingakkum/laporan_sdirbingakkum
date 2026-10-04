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
  expectedRoleCode: string,
  expectedRole: string,
  expectedPath: string,
) {
  await page.goto('./', { waitUntil: 'domcontentloaded', timeout: 30_000 });

  const loginButton = page.getByRole('button', { name: 'Masuk', exact: true });
  const emailField = page.getByRole('textbox', { name: 'Email', exact: true });
  const passwordField = page.getByRole('textbox', {
    name: 'Password',
    exact: true,
  });

  await expect(loginButton).toBeVisible({ timeout: 30_000 });
  await expect(emailField).toBeVisible({ timeout: 30_000 });
  await expect(passwordField).toBeVisible({ timeout: 30_000 });

  const authResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'POST' &&
      response.url().includes('/auth/v1/token'),
    { timeout: 30_000 },
  );
  const accessContextPromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'POST' &&
      response.url().includes('/rest/v1/rpc/get_my_access_context') &&
      response.status() === 200,
    { timeout: 30_000 },
  );

  await emailField.fill(email);
  await passwordField.click();
  await passwordField.pressSequentially(password);
  await expect(passwordField).toHaveValue(password);

  await loginButton.click();

  const authResponse = await authResponsePromise;
  let authPayload: {
    user?: { email?: string | null };
    error?: string;
    error_description?: string;
    msg?: string;
  };
  try {
    authPayload = (await authResponse.json()) as typeof authPayload;
  } catch (_) {
    authPayload = {};
  }

  if (authResponse.status() !== 200) {
    throw new Error(
      'Supabase password login failed with HTTP ' +
        authResponse.status() +
        ': ' +
        (authPayload.error_description ??
          authPayload.msg ??
          authPayload.error ??
          'unknown authentication error'),
    );
  }

  expect(authPayload.user?.email).toBe(expectedEmail);

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

  const accessResponse = await accessContextPromise;
  const accessPayload = (await accessResponse.json()) as {
    authenticated?: boolean;
    configured?: boolean;
    role?: { code?: string; display_name?: string };
    scope?: { type?: string };
  };
  expect(accessPayload.authenticated).toBe(true);
  expect(accessPayload.configured).toBe(true);
  expect(accessPayload.role?.code).toBe(expectedRoleCode);
  expect(accessPayload.role?.display_name).toBe(expectedRole);
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
      'PUSPOMAD_COMMANDER',
      'Komandan Puspomad',
      '/laporan_sdirbingakkum/',
    );
    expect(new URL(commanderPage.url()).pathname).toBe('/laporan_sdirbingakkum/');

    // Only after Commander identity is proven, perform the controlled Operator write.
    const operatorPage = await operatorContext.newPage();
    const operatorEmail = requiredEnv('E2E_EMAIL');
    await signIn(
      operatorPage,
      operatorEmail,
      requiredEnv('E2E_PASSWORD'),
      operatorEmail,
      'PUSPOMAD_OPERATOR',
      'Operator Puspomad',
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
    expect(new URL(commanderPage.url()).pathname).toBe('/laporan_sdirbingakkum/');
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