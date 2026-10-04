import { test, expect, type Page } from '@playwright/test';

function requiredEnv(name: string) {
  const value = process.env[name];
  if (!value) throw new Error(name + ' is required for authorization E2E.');
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
  const passwordField = page.getByRole('textbox', { name: 'Password', exact: true });

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
  const authPayload = (await authResponse.json()) as {
    user?: { email?: string | null };
    error?: string;
    error_description?: string;
  };
  if (authResponse.status() !== 200) {
    throw new Error(
      'Supabase login failed with HTTP ' +
        authResponse.status() +
        ': ' +
        (authPayload.error_description ??
          authPayload.error ??
          'unknown authentication error'),
    );
  }
  expect(authPayload.user?.email).toBe(expectedEmail);

  await page.waitForURL(
    (url) => new URL(url).pathname === expectedPath,
    { timeout: 30_000 },
  );

  const accessResponse = await accessContextPromise;
  const accessPayload = (await accessResponse.json()) as {
    authenticated?: boolean;
    configured?: boolean;
    role?: { code?: string; display_name?: string };
  };
  expect(accessPayload.authenticated).toBe(true);
  expect(accessPayload.configured).toBe(true);
  expect(accessPayload.role?.code).toBe(expectedRoleCode);
  expect(accessPayload.role?.display_name).toBe(expectedRole);
}

test('PUSPOMAD_OPERATOR cannot enter Commander Dashboard', async ({ page }) => {
  test.skip(
    process.env.E2E_AUTHZ_TEST !== 'true',
    'Production authorization E2E is manual-only.',
  );
  const operatorEmail = requiredEnv('E2E_EMAIL');
  await signIn(
    page,
    operatorEmail,
    requiredEnv('E2E_PASSWORD'),
    operatorEmail,
    'PUSPOMAD_OPERATOR',
    'Operator Puspomad',
    '/laporan_sdirbingakkum/reports',
  );
  await page.goto('./', { waitUntil: 'domcontentloaded', timeout: 30_000 });
  await expect.poll(() => new URL(page.url()).pathname, { timeout: 30_000 })
    .toBe('/laporan_sdirbingakkum/reports');
});

test('PUSPOMAD_COMMANDER cannot enter Input Laporan', async ({ page }) => {
  test.skip(
    process.env.E2E_AUTHZ_TEST !== 'true',
    'Production authorization E2E is manual-only.',
  );
  const commanderEmail = requiredEnv('E2E_COMMANDER_EMAIL');
  await signIn(
    page,
    commanderEmail,
    requiredEnv('E2E_COMMANDER_PASSWORD'),
    commanderEmail,
    'PUSPOMAD_COMMANDER',
    'Komandan Puspomad',
    '/laporan_sdirbingakkum/',
  );
  await page.goto('./input-laporan', { waitUntil: 'domcontentloaded', timeout: 30_000 });
  await expect.poll(() => new URL(page.url()).pathname, { timeout: 30_000 })
    .toBe('/laporan_sdirbingakkum/');
});

test('PUSPOMAD_COMMANDER can access Commander Dashboard', async ({ page }) => {
  test.skip(
    process.env.E2E_AUTHZ_TEST !== 'true',
    'Production authorization E2E is manual-only.',
  );
  const commanderEmail = requiredEnv('E2E_COMMANDER_EMAIL');
  await signIn(
    page,
    commanderEmail,
    requiredEnv('E2E_COMMANDER_PASSWORD'),
    commanderEmail,
    'PUSPOMAD_COMMANDER',
    'Komandan Puspomad',
    '/laporan_sdirbingakkum/',
  );
  const snapshotResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === 'POST' &&
      response.url().includes('/rpc/get_commander_cop_snapshot') &&
      response.status() === 200,
    { timeout: 30_000 },
  );
  await page.reload({ waitUntil: 'domcontentloaded', timeout: 30_000 });
  const snapshotResponse = await snapshotResponsePromise;
  const snapshot = (await snapshotResponse.json()) as {
    scope?: { type?: string };
    domains?: Array<{ code?: string }>;
  };
  expect(snapshot.scope?.type).toBe('ALL_POMDAM');
  expect(snapshot.domains?.map((domain) => domain.code)).toEqual(
    expect.arrayContaining([
      'GAKKUM',
      'PELANGGARAN',
      'SIM_TNI',
      'PROVOS',
      'LAKA_LALIN',
      'TINDAK_PIDANA',
    ]),
  );
});