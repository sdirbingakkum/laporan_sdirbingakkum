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

## Security

Client builds use only the Supabase publishable key. Never put a service-role or secret key in the application.

Build-time configuration:

```bash
flutter run   --dart-define=SUPABASE_URL=https://ybepaqmrrgsaeqnqrsrf.supabase.co   --dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

For production, provide credentials through the deployment/build environment. Do not commit secrets.

## Database contract

The application models the live database schema rather than assumptions from the Excel workbooks. In particular, POMDAM identity is resolved by database IDs/canonical codes; Flutter does not parse Roman numerals or source variants.

See `docs/DATABASE_CONTRACT.md`.

## Local bootstrap

This repository currently contains the application source baseline. Generate Flutter platform runner files with the installed stable Flutter SDK:

```bash
flutter create . --platforms=android,web,windows
flutter pub get
flutter analyze
flutter test
```

Target baseline: Flutter stable 3.47.x. The current package pins are recorded in `pubspec.yaml`.

## Data access note

At repository bootstrap time, the database's public tables have RLS enabled but no anon/authenticated SELECT policies were available for the application to use. The Flutter client intentionally does not bypass RLS. Database access policy work must be completed in the database/security workstream before live dashboard data can be consumed by the client.
