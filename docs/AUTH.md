# Authentication & Client Access

The application requires an authenticated Supabase user before protected routes are shown. Read/reporting routes are capability-gated, while direct report input is write-enabled only for users with `MANAGE_REPORT_DATA`.

## Access model

- Unauthenticated `anon` Data API reads are denied.
- Authenticated reads are allowed only for the tables and read models consumed by the Flutter application.
- Anonymous Supabase Auth users are explicitly excluded from those read policies.
- The application does not use a service-role or secret key.
- New application users are not created from the client UI. An administrator provisions users in Supabase Auth and assigns an appropriate application role.

The current policy is intentionally an internal single-access-domain model: every provisioned permanent authenticated user can read the application's reporting dataset. A future multi-organization or row-level ownership model must replace the broad authenticated-read predicate before exposing the application to unrelated users.

## Reporting read models

The following additional application reporting surfaces are protected for permanent authenticated users:

- `source_reports`
- `source_report_pomdams`
- `source_pomdam_occurrences`
- `report_provenance`
- `report_audit_summary`

The private source-cell storage remains outside the public Data API.

## Provenance security boundary

`public.report_provenance` contains only the source-cell fields required for reporting and joins back to the public source-report metadata in the application data layer.

The database trigger that maintains this projection lives in the private schema and is not an API endpoint.

## Password security

Supabase Security Advisor currently reports that leaked-password protection is disabled for Auth password accounts. This setting is controlled by Supabase Auth configuration rather than PostgreSQL RLS and must be enabled in the Supabase Dashboard before broad external onboarding.

## First staging user

Open **Authentication → Users** and create a permanent email/password user. Keep client signup disabled; the Flutter login uses `signInWithPassword`.

The GitHub Pages staging URL is:

`https://sdirbingakkum.github.io/laporan_sdirbingakkum/`

The application will display the login screen until a valid Supabase session exists.

## Database policy verification

Application reporting tables use the `authenticated_reporting_read` policy and explicitly exclude anonymous Auth users.

The deployed client is expected to use only the Supabase publishable key.


## Direct report input

- `ReportInputPage` writes through the authenticated `submit_report()` RPC.
- Only `PUSPOMAD_OPERATOR` and `POMDAM_OPERATOR` roles currently carry `MANAGE_REPORT_DATA`.
- The operator submits one POMDAM and one monthly period at a time.
- Imported Excel-backed rows remain locked from direct overwrite.
- Direct application rows use `source_cell_id = NULL` and are shown as `Input Aplikasi` provenance.
- At the current production state, there are no active operator-role assignments, so the input screen will remain access-denied until an administrator provisions an operator account/role.
