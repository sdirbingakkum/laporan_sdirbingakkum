# Cloud Web Test

The repository now has a GitHub Pages deployment path for testing the Flutter Web build.

## One-time GitHub setup

1. Open repository Settings -> Pages.
2. Under Build and deployment, set Source to GitHub Actions.
3. Open Settings -> Secrets and variables -> Actions.
4. Add the repository secret:

   SUPABASE_PUBLISHABLE_KEY

This is the public/publishable Supabase key used by the client. Never use a Supabase service-role key here.

## Deployment

Every push to main runs the web deployment workflow. It can also be started manually from the Actions tab.

The workflow recreates the missing Flutter web runner with:

    flutter create . --platforms=web

and then builds:

    flutter build web --release

The build uses a repository base path of:

    /laporan_sdirbingakkum/

GitHub Pages is a test/staging surface only. Production hosting can remain on Cloudflare.

## Expected test URL

After the first successful Pages deployment, GitHub exposes the exact deployment URL in the workflow environment. For this repository it is expected to be:

    https://sdirbingakkum.github.io/laporan_sdirbingakkum/

Flutter's default web URL strategy is hash-based, so application routes should be tested from the running app navigation rather than assuming server-side rewrites for arbitrary path URLs.

## Data access

The application continues to use only the Supabase publishable key. If the database security workstream has not yet granted client SELECT access through RLS policies, the deployed UI can load but reporting queries will return the application's normal data-access error state.
