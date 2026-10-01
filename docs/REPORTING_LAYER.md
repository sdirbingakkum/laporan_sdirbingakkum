# Reporting Layer Contract

## Goal

Expose a deterministic, status-aware report detail model on top of the existing Supabase normalized schema.

## Request shape

A report detail request is identified by:

- report type code
- period id

Optional filters:
- POMDAM id
- taxonomy/dimension id(s)

## Response shape

The reporting service exposes:

1. Report metadata
2. Period metadata
3. Source-report metadata and import state
4. Dataset-specific fact summaries
5. Status-aware values
6. Live provenance preview
7. Integrity diagnostics

The Flutter implementation lives in:

- `domain/entities/reporting_entities.dart`
- `domain/repositories/reporting_repository.dart`
- `data/repositories/supabase_reporting_repository.dart`
- `application/providers/reporting_providers.dart`

## Rules

The reporting layer is read-only.

Period filtering is mandatory.

Report type routing is explicit and implemented per dataset, not inferred by joining unrelated fact tables to the same period.

The following statuses are first-class:
- VALID
- NOT_REPORTED
- INVALID_SOURCE
- ESTIMATED

Numeric aggregation:
- VALID contributes its numeric value.
- NOT_REPORTED contributes no numeric value.
- INVALID_SOURCE contributes no numeric value.
- ESTIMATED is visible as estimated and must not be silently merged with VALID.

UI semantics:
- zero = source explicitly reports zero
- — = not reported
- ! = invalid source
- ~ = estimated

## Provenance

Every fact row must retain a resolvable `source_cell_id`.

The live database maintains a read-safe `public.report_provenance` projection backed by `private.source_cells`. It is synchronized by a database trigger and exposed only to permanent authenticated users.

The report UI can therefore drill into:

- workbook
- sheet
- sheet index
- cell reference
- raw value
- parsed numeric value
- semantic/row/column labels
- fact data status

without exposing the private source-cell table directly to the public Data API.

## Data Quality

`public.report_audit_summary` is a security-invoker live view over the public reporting facts and the safe provenance projection.

It is consumed by both Reports and Data Quality so that the UI and audit surface read the same backend contract.
