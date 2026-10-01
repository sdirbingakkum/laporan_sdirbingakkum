-- 2026 Reconstruction Audit
-- READ ONLY. Execute in Supabase SQL editor / controlled audit tooling.
-- Do not convert non-reported states to numeric zero.

WITH expected_sources AS (
  SELECT * FROM (VALUES
    ('GAKKUM','Maret 2026'),
    ('GAKKUM','Agustus 2026'),
    ('GAKKUM','September 2026'),
    ('PELANGGARAN','Juli 2026'),
    ('SIM_TNI','Juli 2026'),
    ('PROVOS','Agustus 2026'),
    ('LAKA_LALIN','Februari 2026'),
    ('LAKA_LALIN','September 2026'),
    ('TINDAK_PIDANA','Agustus 2026')
  ) v(report_type, period_label)
),
resolved_sources AS (
  SELECT rt.code report_type, rp.period_label, sr.id source_report_id,
         sr.workbook_name, sr.sheet_name, sr.source_sheet_index,
         sr.import_status, sr.period_resolution_status
  FROM public.source_reports sr
  JOIN public.report_types rt ON rt.id=sr.report_type_id
  JOIN public.report_periods rp ON rp.id=sr.period_id
  WHERE rp.report_year=2026
),
source_gate AS (
  SELECT e.report_type,e.period_label,
         count(rs.source_report_id) source_reports,
         count(*) FILTER (WHERE rs.import_status IS DISTINCT FROM 'IMPORTED') bad_import_status
  FROM expected_sources e
  LEFT JOIN resolved_sources rs
    ON rs.report_type=e.report_type AND rs.period_label=e.period_label
  GROUP BY e.report_type,e.period_label
),
facts AS (
  SELECT 'GAKKUM' report_type, period_id,pomdam_id,source_cell_id,data_status,value FROM public.gakkum_records
  UNION ALL SELECT 'PELANGGARAN',period_id,pomdam_id,source_cell_id,data_status,value FROM public.violation_records
  UNION ALL SELECT 'SIM_TNI',period_id,pomdam_id,source_cell_id,data_status,value FROM public.sim_records
  UNION ALL SELECT 'PROVOS',period_id,pomdam_id,source_cell_id,data_status,value FROM public.provos_strength_records
  UNION ALL SELECT 'PROVOS',period_id,pomdam_id,source_cell_id,data_status,value FROM public.provos_personnel_records
  UNION ALL SELECT 'PROVOS',period_id,pomdam_id,source_cell_id,data_status,value FROM public.provos_education_records
  UNION ALL SELECT 'LAKA_LALIN',period_id,pomdam_id,source_cell_id,data_status,value FROM public.laka_accident_records
  UNION ALL SELECT 'LAKA_LALIN',period_id,pomdam_id,source_cell_id,data_status,value FROM public.laka_material_records
  UNION ALL SELECT 'LAKA_LALIN',period_id,pomdam_id,source_cell_id,data_status,value FROM public.laka_personnel_records
  UNION ALL SELECT 'LAKA_LALIN',period_id,pomdam_id,source_cell_id,data_status,value FROM public.laka_victim_rank_records
  UNION ALL SELECT 'LAKA_LALIN',period_id,pomdam_id,source_cell_id,data_status,value FROM public.laka_victim_outcome_records
  UNION ALL SELECT 'TINDAK_PIDANA',period_id,pomdam_id,source_cell_id,data_status,value FROM public.criminal_offense_records
),
fact_audit AS (
  SELECT
    f.report_type,rp.period_label,
    count(*) fact_rows,
    count(DISTINCT f.pomdam_id) pomdams,
    count(*) FILTER (WHERE f.source_cell_id IS NULL) no_source_cell,
    count(*) FILTER (WHERE sc.id IS NULL) dangling_source_cell,
    count(*) FILTER (WHERE f.data_status='VALID') valid_rows,
    count(*) FILTER (WHERE f.data_status='NOT_REPORTED') not_reported_rows,
    count(*) FILTER (WHERE f.data_status='INVALID_SOURCE') invalid_source_rows,
    count(*) FILTER (WHERE f.data_status='ESTIMATED') estimated_rows,
    count(*) FILTER (WHERE f.data_status='VALID' AND f.value IS NULL) valid_null_value,
    count(*) FILTER (WHERE f.data_status<>'VALID' AND f.value IS NOT NULL) nonvalid_with_value
  FROM facts f
  JOIN public.report_periods rp
    ON rp.id=f.period_id AND rp.report_year=2026
  LEFT JOIN private.source_cells sc
    ON sc.id=f.source_cell_id
  GROUP BY f.report_type,rp.period_label
)
SELECT
  e.report_type,
  e.period_label,
  coalesce(s.source_reports,0) source_reports,
  coalesce(s.bad_import_status,0) bad_import_status,
  coalesce(a.fact_rows,0) fact_rows,
  coalesce(a.pomdams,0) pomdams,
  coalesce(a.no_source_cell,0) no_source_cell,
  coalesce(a.dangling_source_cell,0) dangling_source_cell,
  coalesce(a.valid_rows,0) valid_rows,
  coalesce(a.not_reported_rows,0) not_reported_rows,
  coalesce(a.invalid_source_rows,0) invalid_source_rows,
  coalesce(a.estimated_rows,0) estimated_rows,
  coalesce(a.valid_null_value,0) valid_null_value,
  coalesce(a.nonvalid_with_value,0) nonvalid_with_value
FROM expected_sources e
LEFT JOIN source_gate s USING(report_type,period_label)
LEFT JOIN fact_audit a USING(report_type,period_label)
ORDER BY e.report_type,e.period_label;
