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

The reporting service returns:

1. Report metadata
2. Period metadata
3. Ordered POMDAM reference list
4. Dataset-specific dimension definitions
5. Rows keyed by stable database IDs
6. Value + data status
7. Provenance summary and drill-down reference
8. Audit diagnostics

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

Provenance:
Every fact row must retain a resolvable `source_cell_id`. A detail view should be able to show workbook, sheet, sheet index, cell reference, raw value and parsing/status metadata without changing the fact record.
