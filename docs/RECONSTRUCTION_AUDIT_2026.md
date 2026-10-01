# 2026 Reconstruction & Reporting Audit

## Purpose

The reporting layer must reconstruct each 2026 report deterministically from:

report type -> report period -> POMDAM -> versioned taxonomy/dimension -> fact value/status -> source cell.

This audit is read-only. It does not modify production data or schema.

## 2026 source coverage

Expected source reports currently verified in Supabase:

- GAKKUM: Maret, Agustus, September 2026
- PELANGGARAN: Juli 2026
- SIM_TNI: Juli 2026
- PROVOS: Agustus 2026
- LAKA_LALIN: Februari, September 2026
- TINDAK_PIDANA: Agustus 2026

Expected total fact rows: 12,054.

## Reconstruction invariants

1. Only periods with `report_year = 2026` participate in this audit.
2. Every fact row included in a 2026 report must resolve to a live `report_periods` row.
3. Every fact row must resolve to a live `source_cells` row.
4. Every populated dataset must use the correct POMDAM identity from `pomdams.id`; source spellings/ordering are not application identities.
5. `VALID`, `NOT_REPORTED`, `INVALID_SOURCE`, and `ESTIMATED` remain distinct.
6. `NOT_REPORTED` and `INVALID_SOURCE` are not rendered or aggregated as numeric zero.
7. `VALID` rows must have a numeric value unless the source contract explicitly defines another representation.
8. Report-type routing is explicit; facts must never be attributed to a report type through a loose join.
9. Source provenance is drillable to workbook, sheet and cell coordinates through `source_reports` + `source_cells`.
10. Aggregations are deterministic for the same database snapshot.

## Current verified data-quality shape

The 2026 fact inventory currently has:
- 12,054 fact rows
- 0 missing source-cell references
- 0 dangling source-cell references
- 21 POMDAMs represented in every loaded 2026 dataset
- no `VALID` row with NULL value in the audited inventory
- no non-VALID row carrying a numeric value in the audited inventory

Not all fact tables represent the same semantic dimensions, so reconstruction must remain dataset-specific rather than forcing a universal row shape.

## Important semantic observation

TINDAK PIDANA contains 8,820 fact rows for August 2026, of which 379 are VALID and 8,441 are NOT_REPORTED. The row count is therefore not a count of reported numeric observations.

## Application boundary

Flutter consumes read models only. The application must not create/alter/delete reporting schema during normal use.

The next implementation step is a report-detail read model/service that exposes:
- report metadata
- available periods
- ordered POMDAM list
- dataset-specific taxonomy/dimensions
- status-aware values
- provenance drill-down
- reconstruction/audit diagnostics

No UI shortcut should bypass these domain contracts.
