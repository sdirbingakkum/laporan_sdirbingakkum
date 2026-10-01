# Application Architecture

The application follows a strict dependency direction:

presentation
  -> application
  -> domain
  -> data / infrastructure
  -> Supabase

## Rules

1. Widgets never query Supabase directly.
2. Domain entities do not depend on Flutter or Supabase.
3. Repositories expose typed domain models.
4. Supabase rows are parsed inside the data layer.
5. Client configuration is provided at build time with --dart-define or --dart-define-from-file.
6. The Flutter client never uses a service-role or secret key.
7. No database schema migration is part of the application repository.
8. Fact ingestion and Step 7 staging remain outside the application workstream.

## First vertical slice

The initial vertical slice is read-only reference data:

Supabase master tables
  -> typed repository
  -> Riverpod provider
  -> responsive Flutter UI

This slice establishes the architecture before implementing dashboard aggregations and import workflows.
