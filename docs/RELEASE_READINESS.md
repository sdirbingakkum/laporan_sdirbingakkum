# Release Readiness Record

## Application

Repository: `sdirbingakkum/laporan_sdirbingakkum`

The release gate is tied to the exact GitHub `main` commit tested by CI/E2E, not to a floating deployment.

## Database

Supabase project: `ybepaqmrrgsaeqnqrsrf`

PostgreSQL: 17.11.

Final reporting hardening migrations applied to the live database:

- `final_reporting_integrity_hardening`
- `harden_reporting_projection`

These migrations add authenticated read policies for reporting source metadata, create the safe `report_provenance` projection maintained from private source cells, remove a duplicate unique index, and provide the security-invoker `report_audit_summary` read model.

## Release gates

The following are verified by the current audit:

- public database tables have RLS enabled
- anonymous public SELECT grants are absent
- permanent authenticated reporting access is policy-controlled
- fact-to-source-cell coverage is complete for the current inventory
- all loaded 2026 datasets represent 21 POMDAMs
- no audited FK or reporting-key or provenance-orphan anomalies were found
- Flutter analysis/tests/build run through GitHub Actions
- GitHub Pages deployment and exact-commit E2E verification are chained
- Reports reads the live audit model and provenance
- Data Quality reads the live audit model

## External Auth configuration gate

Supabase Security Advisor still reports leaked-password protection disabled for Auth password accounts. This is an Auth configuration setting and is not mutable through the connected database tooling used for this audit. It should be enabled in the Supabase Dashboard before broad external onboarding.
