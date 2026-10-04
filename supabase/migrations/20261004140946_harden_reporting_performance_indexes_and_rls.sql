-- Production performance hardening after acceptance verification.
-- Covers report_submissions foreign keys, RLS initplan evaluation,
-- and redundant identical unique indexes.

CREATE INDEX IF NOT EXISTS report_submissions_pomdam_id_idx
  ON public.report_submissions (pomdam_id);

CREATE INDEX IF NOT EXISTS report_submissions_submitted_by_idx
  ON public.report_submissions (submitted_by);

DROP POLICY IF EXISTS report_submissions_insert_managed
  ON public.report_submissions;

CREATE POLICY report_submissions_insert_managed
  ON public.report_submissions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    private.has_current_capability('MANAGE_REPORT_DATA')
    AND private.can_read_pomdam(pomdam_id)
    AND (submitted_by = (select auth.uid()))
  );

DROP POLICY IF EXISTS report_submissions_update_managed
  ON public.report_submissions;

CREATE POLICY report_submissions_update_managed
  ON public.report_submissions
  FOR UPDATE
  TO authenticated
  USING (
    private.has_current_capability('MANAGE_REPORT_DATA')
    AND private.can_read_pomdam(pomdam_id)
  )
  WITH CHECK (
    private.has_current_capability('MANAGE_REPORT_DATA')
    AND private.can_read_pomdam(pomdam_id)
    AND (submitted_by = (select auth.uid()))
  );

-- The UNIQUE constraints already enforce these exact logical identities.
DROP INDEX IF EXISTS public.criminal_offense_entry_identity_uq;
DROP INDEX IF EXISTS public.gakkum_records_entry_identity_uq;
DROP INDEX IF EXISTS public.laka_accident_entry_identity_uq;
DROP INDEX IF EXISTS public.laka_material_entry_identity_uq;
DROP INDEX IF EXISTS public.laka_personnel_entry_identity_uq;
DROP INDEX IF EXISTS public.laka_victim_outcome_entry_identity_uq;
DROP INDEX IF EXISTS public.laka_victim_rank_entry_identity_uq;
DROP INDEX IF EXISTS public.provos_education_entry_identity_uq;
DROP INDEX IF EXISTS public.provos_personnel_entry_identity_uq;
DROP INDEX IF EXISTS public.provos_strength_entry_identity_uq;
DROP INDEX IF EXISTS public.sim_records_entry_identity_uq;
DROP INDEX IF EXISTS public.violation_records_entry_identity_uq;
