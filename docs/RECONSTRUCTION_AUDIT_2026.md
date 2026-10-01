# 2026 Reconstruction & Reporting Audit

## Purpose

The reporting layer reconstructs each 2026 report deterministically from:

report type -> report period -> POMDAM -> versioned taxonomy/dimension -> fact value/status -> source cell.

This audit is read-only. It does not modify production data or schema.

## 2026 source coverage

The active imported source reports currently verified in Supabase are:

- GAKKUM: Maret, Agustus, September 2026
- PELANGGARAN: Juli 2026
- SIM_TNI: Juli 2026
- PROVOS: Agustus 2026
- LAKA_LALIN: Februari, September 2026
- TINDAK_PIDANA: Agustus 2026

Expected total fact rows: 12,054.

SIM TNI also contains a separate `DISCOVERED` source-report registry row with no source cells. It is treated as a candidate/non-active source; the imported source report is the active source used by the application.

## Reconstruction invariants

1. Only periods with `report_year = 2026` participate in this audit.
2. Every fact row included in a 2026 report must resolve to a live `report_periods` row.
3. Every fact row must resolve to a live `source_cells` row.
4. Every populated dataset must use the correct POMDAM identity from `pomdams.id`; source spellings/ordering are not application identities.
5. `VALID`, `NOT_REPORTED`, `INVALID_SOURCE`, and `ESTIMATED` remain distinct.
6. `NOT_REPORTED` and `INVALID_SOURCE` are not rendered or aggregated as numeric zero.
7. `VALID` rows must have a numeric value unless the source contract explicitly defines another representation.
8. Report-type routing is explicit; facts must never be attributed to a report type through a loose join.
9. Source provenance is drillable to workbook, sheet and cell coordinates through the authenticated reporting projection.
10. Aggregations are deterministic for the same database snapshot.

## Current verified data-quality shape

The 2026 fact inventory currently has:

- 12,054 fact rows
- 0 missing source-cell references
- 0 dangling source-cell references
- 21 POMDAMs represented in every loaded 2026 dataset
- no `VALID` row with NULL value in the audited inventory
- no non-VALID row carrying a numeric value in the audited inventory
- 12,054 source-cell projection rows
- 0 duplicate source-cell references

Not all fact tables represent the same semantic dimensions, so reconstruction remains dataset-specific.

## Important semantic observation

TINDAK PIDANA contains 8,820 fact rows for August 2026, of which 379 are VALID and 8,441 are NOT_REPORTED. The row count is therefore not a count of reported numeric observations.

## Application status

The live reporting read model is now implemented:

- Reports consumes `report_audit_summary` and `report_provenance`.
- Data Quality consumes `report_audit_summary`.
- Gakkum and Pelanggaran preserve `sourceCellId` through the repository/domain boundary.
- All six dashboard vertical slices remain read-only and status-aware.

## Database release record

The final hardening was applied as the Supabase migration:

`final_reporting_integrity_hardening`
followed by
`harden_reporting_projection`.

The Flutter application repository intentionally does not own database migrations; the migration names above are the authoritative live-database change record for this release gate.
