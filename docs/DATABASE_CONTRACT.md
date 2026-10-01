# Database Contract Snapshot

Verified against Supabase project ybepaqmrrgsaeqnqrsrf on 2026-10-01.

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

## Security snapshot

At bootstrap time, the inspected public reporting tables had RLS enabled but no anon/authenticated SELECT policies available to the client. The Flutter client does not bypass RLS.
