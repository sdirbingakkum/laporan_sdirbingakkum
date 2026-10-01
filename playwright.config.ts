import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  workers: process.env.CI ? 1 : undefined,
  timeout: 60_000,
  expect: { timeout: 15_000 },
  maxFailures: process.env.CI ? 1 : undefined,
  globalTimeout: 10 * 60 * 1000,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI
    ? [['html', { open: 'never' }], ['line']]
    : [['list']],
  use: {
    channel: 'chrome',
    baseURL:
      process.env.PLAYWRIGHT_TEST_BASE_URL ??
      'https://sdirbingakkum.github.io/laporan_sdirbingakkum/',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    navigationTimeout: 30_000,
    actionTimeout: 15_000,
  },
  projects: [
    {
      name: 'setup',
      testMatch: /auth\.setup\.ts/,
    },
    {
      name: 'unauthenticated',
      testMatch: /auth\.spec\.ts/,
    },
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'playwright/.auth/user.json',
      },
      dependencies: ['setup'],
      testIgnore: [/auth\.setup\.ts/, /auth\.spec\.ts/],
    },
  ],
});
