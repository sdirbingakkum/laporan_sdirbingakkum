# Cloud Web Test

The repository has a GitHub Pages deployment path for testing the Flutter Web build.

## Deployment

Every push to main runs:

1. Flutter CI
2. Flutter Web deployment
3. E2E staging against the exact deployed commit

The deployment writes `deployment.json` with the commit SHA, and E2E waits for that exact SHA before running Playwright.

The build uses:

    /laporan_sdirbingakkum/

GitHub Pages is a test/staging surface only. Production hosting can remain on Cloudflare.

## Expected test URL

    https://sdirbingakkum.github.io/laporan_sdirbingakkum/

Flutter web path URL strategy is enabled, and the deployment creates deep-link entrypoints for all application routes.

## E2E coverage

The smoke suite verifies:

- authentication guard
- all application deep links
- critical filters on reporting dashboards
- live Reports read model
- live Data Quality read model

## Data access

The application uses only the Supabase publishable key. Public anonymous Data API access is denied by RLS/grants; permanent authenticated users receive the application reporting read surface.
