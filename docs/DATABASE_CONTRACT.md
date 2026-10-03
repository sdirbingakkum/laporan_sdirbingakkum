# Database Contract Snapshot

Verified against Supabase project ybepaqmrrgsaeqnqrsrf on 2026-10-04.

## pomdams

- id uuid
- report_order smallint
- roman_numeral text nullable
- roman_value smallint nullable
- code text
- short_name text
- kodam_name text
- kodam_full_name text
- pomdam_full_name text
- active boolean
- valid_from date nullable
- valid_to date nullable
- created_at timestamptz

Important: the live table does not contain updated_at.

## Other application reference tables

- pomdam_aliases
- report_types
- report_periods
- personnel_categories
- sim_types
- accident_types
- victim_outcomes
- vehicle_categories
- material_damage_types
- provos_strength_measures
- education_statuses

## Versioned taxonomy

- gakkum_activities + gakkum_activity_versions
- violations + violation_versions
- criminal_offenses + criminal_offense_versions

A source number is not treated as a stable identity across periods.

## Fact semantics

Fact tables preserve:

- value
- data_status
- source_cell_id
- notes

Supported data_status values:

- VALID
- NOT_REPORTED
- INVALID_SOURCE
- ESTIMATED

The application never collapses those statuses into zero.

## Application provenance contract

Imported rows preserve `source_cell_id` for workbook/sheet/cell drill-down. Direct application submissions intentionally use `source_cell_id = NULL`; their audit identity is the `report_submissions` row (report type + period + POMDAM + revision + submitter/time).

The public reporting read model exposes a restricted `report_provenance` projection for imported workbook/sheet/cell drill-down without exposing `private.source_cells`. App-native rows must render as `Input Aplikasi`, not as an Excel cell.

## Security snapshot

Verified live:

- all public tables have RLS enabled
- no `anon` SELECT grants on public tables
- authenticated reporting SELECT is explicit
- anonymous Auth users are excluded by policy
- provenance projection is authenticated-only

Supabase Auth leaked-password protection remains a separate Auth configuration gate.


## Direct input contract

- The operator submits exactly one POMDAM at a time.
- A monthly period is canonicalized by year/month and cannot be duplicated by label variants.
- Every active catalog dimension required by the selected report type must be present in the submission payload.
- Blank input is `NOT_REPORTED`; zero is `VALID` zero; only non-negative integers are accepted.
- Direct input cannot set `source_cell_id`, `INVALID_SOURCE`, or `ESTIMATED`.
