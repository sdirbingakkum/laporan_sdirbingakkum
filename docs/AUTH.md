# Authentication & Client Access

The application is read-only and requires an authenticated Supabase user before any application route is shown.

## Access model

- Unauthenticated `anon` Data API reads are denied.
- Authenticated reads are allowed only for the tables currently consumed by the Flutter application.
- Anonymous Supabase Auth users are explicitly excluded from those read policies.
- The application does not use a service-role or secret key.
- New application users are not created from the client UI. An administrator provisions users in Supabase Auth.

The current policy is intentionally an internal single-access-domain model: every provisioned permanent authenticated user can read the application's reporting dataset. A future multi-organization or row-level ownership model must replace the broad authenticated-read predicate before exposing the application to unrelated users.

## First staging user

The live project currently has no Auth users. Add the first permanent user from the Supabase Dashboard:

1. Open **Authentication → Users**.
2. Create a user with email/password.
3. Keep client signup disabled; the Flutter login uses `signInWithPassword`.
4. Open the GitHub repository settings and configure the `SUPABASE_PUBLISHABLE_KEY` Actions secret for the web deployment workflow.
5. Enable GitHub Pages with **Build and deployment → Source: GitHub Actions**.

The GitHub Pages staging URL is:

`https://sdirbingakkum.github.io/laporan_sdirbingakkum/`

The application will display the login screen until a valid Supabase session exists.

## Database policy verification

The following application-read tables have the `authenticated_reporting_read` policy:

- pomdams
- pomdam_aliases
- report_types
- report_periods
- personnel_categories
- sim_types
- accident_types
- victim_outcomes
- vehicle_categories
- material_damage_types
- education_statuses
- provos_strength_measures
- gakkum_activities
- gakkum_activity_versions
- gakkum_records
- violations
- violation_versions
- violation_records

The policy checks the JWT `is_anonymous` claim and allows only permanent authenticated users.

## Future hardening

When the application gains multiple organizational users, introduce an explicit authorization model (for example, an application-access table or app metadata role) and replace `using (true)`-style dataset-wide reads with an authorization predicate.