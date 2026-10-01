# Laporan Sdirbin Gakkum — Flutter Application

Application track for the Laporan Sdirbin Gakkum reporting system.

## Scope

This repository owns the Flutter application only:

- Android
- Windows
- Web
- Presentation / UX
- Domain models
- Application services
- Data repositories
- Supabase client integration
- Dashboard and reporting views
- Import/upload workflows
- Error/loading/empty states
- Tests and CI

The Excel ingestion, Step 7 staging, source reconstruction, provenance reconciliation, and fact-table finalization remain outside this repository's application track.

## Backend

Supabase project:

ybepaqmrrgsaeqnqrsrf

The application reads the existing schema. It must not create, alter, or delete database schema as part of the normal Flutter workflow.

## Architecture

presentation
↓
application
↓
domain
↓
data / infrastructure
↓
Supabase

UI code must not issue Supabase queries directly.

## Current vertical slices

The application currently includes:

1. Read-only reference-data access for POMDAM, report types, and report periods.
2. Gakkum dashboard read model with explicit period, POMDAM, and taxonomy-level filtering.
3. Fidelity-aware aggregation that keeps VALID, NOT_REPORTED, INVALID_SOURCE, and ESTIMATED distinct.
4. Responsive navigation for desktop/tablet/mobile layouts.

Dashboard fact queries are period-scoped to avoid accidental cross-history reads and to respect Supabase Data API row limits.

## Security

Client builds use only the Supabase publishable key. Never put a service-role or secret key in the application.

Build-time configuration:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://ybepaqmrrgsaeqnqrsrf.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

For production, provide credentials through the deployment/build environment. Do not commit secrets.

## Database contract

The application models the live database schema rather than assumptions from the Excel workbooks. POMDAM identity is resolved by database IDs/canonical codes; Flutter does not parse Roman numerals or source variants.

See `docs/DATABASE_CONTRACT.md`.

## Local bootstrap

Generate platform runner files with the installed stable Flutter SDK:

```bash
flutter create . --platforms=android,web,windows
flutter pub get
flutter analyze
flutter test
```

CI currently validates with Flutter 3.47.3.

## Data access note

At repository bootstrap time, the database's public reporting tables had RLS enabled but no anon/authenticated SELECT policies were available to the client. The Flutter client intentionally does not bypass RLS. Database access policies must be completed in the database/security workstream before live client queries can return reporting data.
