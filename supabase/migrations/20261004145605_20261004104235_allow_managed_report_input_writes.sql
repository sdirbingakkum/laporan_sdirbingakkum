-- Allow capability-gated operators to execute the existing invoker write RPCs.
-- The RLS policies on report_submissions and all fact tables already constrain
-- writes to MANAGE_REPORT_DATA users, POMDAM scope, NULL source_cell_id, and
-- VALID/NOT_REPORTED value semantics.

grant insert on table public.report_periods to authenticated;

drop policy if exists report_periods_insert_managed on public.report_periods;
create policy report_periods_insert_managed
  on public.report_periods
  for insert
  to authenticated
  with check (
    private.has_current_capability('MANAGE_REPORT_DATA')
    and period_start is not null
    and period_end is not null
    and period_end >= period_start
    and period_type = any (array['MONTH','QUARTER','SEMESTER','YEAR','OTHER'])
    and nullif(trim(period_label), '') is not null
  );

grant select, insert, update on table public.report_submissions to authenticated;

grant insert, update on table public.gakkum_records to authenticated;
grant insert, update on table public.violation_records to authenticated;
grant insert, update on table public.sim_records to authenticated;
grant insert, update on table public.provos_strength_records to authenticated;
grant insert, update on table public.provos_education_records to authenticated;
grant insert, update on table public.provos_personnel_records to authenticated;
grant insert, update on table public.laka_accident_records to authenticated;
grant insert, update on table public.laka_victim_outcome_records to authenticated;
grant insert, update on table public.laka_victim_rank_records to authenticated;
grant insert, update on table public.laka_personnel_records to authenticated;
grant insert, update on table public.laka_material_records to authenticated;
grant insert, update on table public.criminal_offense_records to authenticated;
