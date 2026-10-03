-- Reproduction of the hardened direct-input contract already applied to the production Supabase project.
create unique index if not exists report_periods_period_dates_unique
  on public.report_periods (period_start, period_end)
  where period_start is not null and period_end is not null;

CREATE OR REPLACE FUNCTION public.create_report_period(p_period_start date, p_period_end date, p_period_label text, p_period_type text DEFAULT 'MONTH'::text)
 RETURNS report_periods
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_row public.report_periods;
  v_label text := nullif(trim(p_period_label), '');
  v_type text := upper(trim(coalesce(p_period_type, 'MONTH')));
begin
  if auth.uid() is null then
    raise exception 'AUTHENTICATION_REQUIRED';
  end if;

  if not private.has_current_capability('MANAGE_REPORT_DATA') then
    raise exception 'REPORT_WRITE_FORBIDDEN';
  end if;

  if p_period_start is null or p_period_end is null or p_period_end < p_period_start then
    raise exception 'INVALID_PERIOD_RANGE';
  end if;

  if v_label is null then
    raise exception 'PERIOD_LABEL_REQUIRED';
  end if;

  if v_type not in ('MONTH','QUARTER','SEMESTER','YEAR','OTHER') then
    raise exception 'INVALID_PERIOD_TYPE';
  end if;

  select *
    into v_row
  from public.report_periods
  where period_start = p_period_start
    and period_end = p_period_end
  order by created_at
  limit 1;

  if v_row.id is not null then
    return v_row;
  end if;

  insert into public.report_periods (
    period_type,
    period_start,
    period_end,
    period_label,
    report_year,
    fiscal_year,
    source_label
  )
  values (
    v_type,
    p_period_start,
    p_period_end,
    v_label,
    extract(year from p_period_start)::integer,
    extract(year from p_period_start)::integer,
    null
  )
  returning * into v_row;

  return v_row;

exception
  when unique_violation then
    select *
      into v_row
    from public.report_periods
    where period_start = p_period_start
      and period_end = p_period_end
    order by created_at
    limit 1;

    if v_row.id is not null then
      return v_row;
    end if;

    raise;
end;
$function$


CREATE OR REPLACE FUNCTION public.get_or_create_monthly_report_period(p_year integer, p_month integer)
 RETURNS report_periods
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_start date;
  v_end date;
  v_label text;
  v_row public.report_periods;
begin
  if auth.uid() is null then
    raise exception 'AUTHENTICATION_REQUIRED';
  end if;

  if not private.has_current_capability('MANAGE_REPORT_DATA') then
    raise exception 'REPORT_WRITE_FORBIDDEN';
  end if;

  if p_year < 2000 or p_year > 2100 then
    raise exception 'INVALID_PERIOD_YEAR';
  end if;

  if p_month < 1 or p_month > 12 then
    raise exception 'INVALID_PERIOD_MONTH';
  end if;

  v_start := make_date(p_year, p_month, 1);
  v_end := (v_start + interval '1 month' - interval '1 day')::date;

  v_label := case p_month
    when 1 then 'Januari'
    when 2 then 'Februari'
    when 3 then 'Maret'
    when 4 then 'April'
    when 5 then 'Mei'
    when 6 then 'Juni'
    when 7 then 'Juli'
    when 8 then 'Agustus'
    when 9 then 'September'
    when 10 then 'Oktober'
    when 11 then 'November'
    when 12 then 'Desember'
  end || ' ' || p_year::text;

  select *
    into v_row
  from public.report_periods
  where period_start = v_start
    and period_end = v_end
  order by created_at
  limit 1;

  if v_row.id is not null then
    return v_row;
  end if;

  insert into public.report_periods (
    period_type,
    period_start,
    period_end,
    period_label,
    report_year,
    fiscal_year,
    source_label
  )
  values (
    'MONTH',
    v_start,
    v_end,
    v_label,
    p_year,
    p_year,
    null
  )
  returning * into v_row;

  return v_row;

exception
  when unique_violation then
    select *
      into v_row
    from public.report_periods
    where period_start = v_start
      and period_end = v_end
    order by created_at
    limit 1;

    if v_row.id is not null then
      return v_row;
    end if;

    raise;
end;
$function$


revoke execute on function public.get_or_create_monthly_report_period(integer, integer) from public;
grant execute on function public.get_or_create_monthly_report_period(integer, integer) to authenticated;

CREATE OR REPLACE FUNCTION private.assert_report_input_values(p_entries jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_entry jsonb;
  v_status text;
  v_value_text text;
begin
  if p_entries is null or jsonb_typeof(p_entries) <> 'array' then
    raise exception 'INVALID_INPUT_PAYLOAD';
  end if;

  for v_entry in
    select value
    from jsonb_array_elements(p_entries)
  loop
    if jsonb_typeof(v_entry) <> 'object' then
      raise exception 'INVALID_INPUT_ENTRY';
    end if;

    v_status := v_entry->>'data_status';

    if v_status is null or v_status not in ('VALID','NOT_REPORTED') then
      raise exception 'INVALID_INPUT_STATUS';
    end if;

    if v_status = 'VALID' then
      if not (v_entry ? 'value')
         or v_entry->'value' = 'null'::jsonb
         or jsonb_typeof(v_entry->'value') <> 'number'
      then
        raise exception 'VALID_VALUE_REQUIRED';
      end if;

      v_value_text := v_entry->>'value';

      if v_value_text !~ '^[0-9]+$' then
        raise exception 'INVALID_NON_NEGATIVE_INTEGER';
      end if;

      if v_value_text::numeric > 9223372036854775807::numeric then
        raise exception 'INTEGER_OUT_OF_RANGE';
      end if;
    else
      if v_entry ? 'value' and v_entry->'value' <> 'null'::jsonb then
        raise exception 'NOT_REPORTED_VALUE_MUST_BE_NULL';
      end if;
    end if;
  end loop;
end;
$function$


revoke execute on function private.assert_report_input_values(jsonb) from public;
grant execute on function private.assert_report_input_values(jsonb) to authenticated;

CREATE OR REPLACE FUNCTION public.submit_report(p_report_type text, p_period_id uuid, p_pomdam_id uuid, p_payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_report_type_id uuid;
  v_submission_id uuid;
  v_report_type text := upper(trim(coalesce(p_report_type, '')));
  v_period public.report_periods;
  v_entries jsonb := '[]'::jsonb;
  v_actual bigint;
  v_distinct bigint;
  v_expected bigint;
begin
  if auth.uid() is null then
    raise exception 'AUTHENTICATION_REQUIRED';
  end if;

  if not private.has_current_capability('MANAGE_REPORT_DATA') then
    raise exception 'REPORT_WRITE_FORBIDDEN';
  end if;

  if p_pomdam_id is null or not private.can_read_pomdam(p_pomdam_id) then
    raise exception 'POMDAM_SCOPE_FORBIDDEN';
  end if;

  if v_report_type not in (
    'GAKKUM',
    'PELANGGARAN',
    'SIM_TNI',
    'PROVOS',
    'LAKA_LALIN',
    'TINDAK_PIDANA'
  ) then
    raise exception 'UNKNOWN_REPORT_TYPE';
  end if;

  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'INVALID_INPUT_PAYLOAD';
  end if;

  select id
    into v_report_type_id
  from public.report_types
  where code = v_report_type
    and active = true
  limit 1;

  if v_report_type_id is null then
    raise exception 'UNKNOWN_REPORT_TYPE';
  end if;

  select *
    into v_period
  from public.report_periods
  where id = p_period_id;

  if v_period.id is null then
    raise exception 'UNKNOWN_PERIOD';
  end if;

  if v_report_type = 'GAKKUM'
     and exists (
       select 1
       from public.gakkum_records
       where period_id = p_period_id
         and pomdam_id = p_pomdam_id
         and source_cell_id is not null
     )
  then
    raise exception 'PERIOD_LOCKED_IMPORTED';
  end if;

  if v_report_type = 'PELANGGARAN'
     and exists (
       select 1
       from public.violation_records
       where period_id = p_period_id
         and pomdam_id = p_pomdam_id
         and source_cell_id is not null
     )
  then
    raise exception 'PERIOD_LOCKED_IMPORTED';
  end if;

  if v_report_type = 'SIM_TNI'
     and exists (
       select 1
       from public.sim_records
       where period_id = p_period_id
         and pomdam_id = p_pomdam_id
         and source_cell_id is not null
     )
  then
    raise exception 'PERIOD_LOCKED_IMPORTED';
  end if;

  if v_report_type = 'PROVOS'
     and (
       exists (
         select 1
         from public.provos_strength_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
       or exists (
         select 1
         from public.provos_education_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
       or exists (
         select 1
         from public.provos_personnel_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
     )
  then
    raise exception 'PERIOD_LOCKED_IMPORTED';
  end if;

  if v_report_type = 'LAKA_LALIN'
     and (
       exists (
         select 1
         from public.laka_accident_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
       or exists (
         select 1
         from public.laka_victim_outcome_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
       or exists (
         select 1
         from public.laka_victim_rank_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
       or exists (
         select 1
         from public.laka_personnel_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
       or exists (
         select 1
         from public.laka_material_records
         where period_id = p_period_id
           and pomdam_id = p_pomdam_id
           and source_cell_id is not null
       )
     )
  then
    raise exception 'PERIOD_LOCKED_IMPORTED';
  end if;

  if v_report_type = 'TINDAK_PIDANA'
     and exists (
       select 1
       from public.criminal_offense_records
       where period_id = p_period_id
         and pomdam_id = p_pomdam_id
         and source_cell_id is not null
     )
  then
    raise exception 'PERIOD_LOCKED_IMPORTED';
  end if;

  case v_report_type
    when 'GAKKUM' then
      v_entries := coalesce(p_payload->'entries', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);

      select count(*), count(distinct x.activity_version_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(activity_version_id uuid, value bigint, data_status text, notes text);

      select count(*)
        into v_expected
      from public.gakkum_activity_versions v
      join public.gakkum_activities a
        on a.id = v.activity_id
      where a.active = true
        and v.taxonomy_version = 'CURRENT_2026'
        and not exists (
          select 1
          from public.gakkum_activity_versions child
          where child.parent_version_id = v.id
        );

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_GAKKUM_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.gakkum_activity_versions expected
        join public.gakkum_activities a
          on a.id = expected.activity_id
        where a.active = true
          and expected.taxonomy_version = 'CURRENT_2026'
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(activity_version_id uuid, value bigint, data_status text, notes text)
            where x.activity_version_id = expected.id
          )
          and not exists (
            select 1
            from public.gakkum_activity_versions child
            where child.parent_version_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_GAKKUM_PAYLOAD';
      end if;

    when 'PELANGGARAN' then
      v_entries := coalesce(p_payload->'entries', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);

      select count(*), count(distinct (x.violation_version_id, x.personnel_category_id))
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(
          violation_version_id uuid,
          personnel_category_id uuid,
          value bigint,
          data_status text,
          notes text
        );

      select count(*) * (
        select count(*)
        from public.personnel_categories
        where active = true
      )
        into v_expected
      from (
        select distinct on (v.violation_id)
          v.id
        from public.violation_versions v
        join public.violations vio
          on vio.id = v.violation_id
        where vio.active = true
          and v.source_period = 'CURRENT_2026'
        order by v.violation_id, v.display_order nulls last, v.created_at
      ) current_violations;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_PELANGGARAN_PAYLOAD';
      end if;

      if exists (
        select 1
        from (
          select distinct on (v.violation_id)
            v.id as violation_version_id
          from public.violation_versions v
          join public.violations vio
            on vio.id = v.violation_id
          where vio.active = true
            and v.source_period = 'CURRENT_2026'
          order by v.violation_id, v.display_order nulls last, v.created_at
        ) current_violations
        cross join public.personnel_categories pc
        where pc.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(
                violation_version_id uuid,
                personnel_category_id uuid,
                value bigint,
                data_status text,
                notes text
              )
            where x.violation_version_id = current_violations.violation_version_id
              and x.personnel_category_id = pc.id
          )
      ) then
        raise exception 'INCOMPLETE_PELANGGARAN_PAYLOAD';
      end if;

    when 'SIM_TNI' then
      v_entries := coalesce(p_payload->'entries', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);

      select count(*), count(distinct x.sim_type_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(sim_type_id uuid, value bigint, data_status text, notes text);

      select count(*)
        into v_expected
      from public.sim_types
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_SIM_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.sim_types expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(sim_type_id uuid, value bigint, data_status text, notes text)
            where x.sim_type_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_SIM_PAYLOAD';
      end if;

    when 'PROVOS' then
      v_entries := coalesce(p_payload->'strength', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.strength_measure_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(strength_measure_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.provos_strength_measures
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_PROVOS_STRENGTH_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.provos_strength_measures expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(strength_measure_id uuid, value bigint, data_status text, notes text)
            where x.strength_measure_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_PROVOS_STRENGTH_PAYLOAD';
      end if;

      v_entries := coalesce(p_payload->'education', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.education_status_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(education_status_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.education_statuses
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_PROVOS_EDUCATION_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.education_statuses expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(education_status_id uuid, value bigint, data_status text, notes text)
            where x.education_status_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_PROVOS_EDUCATION_PAYLOAD';
      end if;

      v_entries := coalesce(p_payload->'personnel', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.personnel_category_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(personnel_category_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.personnel_categories
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_PROVOS_PERSONNEL_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.personnel_categories expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(personnel_category_id uuid, value bigint, data_status text, notes text)
            where x.personnel_category_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_PROVOS_PERSONNEL_PAYLOAD';
      end if;

    when 'LAKA_LALIN' then
      v_entries := coalesce(p_payload->'accidents', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.accident_type_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(accident_type_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.accident_types
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_LAKA_ACCIDENT_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.accident_types expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(accident_type_id uuid, value bigint, data_status text, notes text)
            where x.accident_type_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_LAKA_ACCIDENT_PAYLOAD';
      end if;

      v_entries := coalesce(p_payload->'victim_outcomes', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.victim_outcome_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(victim_outcome_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.victim_outcomes
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_LAKA_VICTIM_OUTCOME_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.victim_outcomes expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(victim_outcome_id uuid, value bigint, data_status text, notes text)
            where x.victim_outcome_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_LAKA_VICTIM_OUTCOME_PAYLOAD';
      end if;

      v_entries := coalesce(p_payload->'victim_ranks', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.personnel_category_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(personnel_category_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.personnel_categories
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_LAKA_VICTIM_RANK_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.personnel_categories expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(personnel_category_id uuid, value bigint, data_status text, notes text)
            where x.personnel_category_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_LAKA_VICTIM_RANK_PAYLOAD';
      end if;

      v_entries := coalesce(p_payload->'personnel', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct x.personnel_category_id)
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(personnel_category_id uuid, value bigint, data_status text, notes text);

      select count(*) into v_expected
      from public.personnel_categories
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_LAKA_PERSONNEL_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.personnel_categories expected
        where expected.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(personnel_category_id uuid, value bigint, data_status text, notes text)
            where x.personnel_category_id = expected.id
          )
      ) then
        raise exception 'INCOMPLETE_LAKA_PERSONNEL_PAYLOAD';
      end if;

      v_entries := coalesce(p_payload->'materials', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);
      select count(*), count(distinct (x.vehicle_category_id, x.material_damage_type_id))
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(
          vehicle_category_id uuid,
          material_damage_type_id uuid,
          value bigint,
          data_status text,
          notes text
        );

      select count(*) * (
        select count(*)
        from public.material_damage_types
        where active = true
      )
        into v_expected
      from public.vehicle_categories
      where active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_LAKA_MATERIAL_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.vehicle_categories vehicle
        cross join public.material_damage_types damage
        where vehicle.active = true
          and damage.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(
                vehicle_category_id uuid,
                material_damage_type_id uuid,
                value bigint,
                data_status text,
                notes text
              )
            where x.vehicle_category_id = vehicle.id
              and x.material_damage_type_id = damage.id
          )
      ) then
        raise exception 'INCOMPLETE_LAKA_MATERIAL_PAYLOAD';
      end if;

    when 'TINDAK_PIDANA' then
      v_entries := coalesce(p_payload->'entries', '[]'::jsonb);
      perform private.assert_report_input_values(v_entries);

      select count(*), count(distinct (x.criminal_offense_version_id, x.personnel_category_id))
        into v_actual, v_distinct
      from jsonb_to_recordset(v_entries)
        as x(
          criminal_offense_version_id uuid,
          personnel_category_id uuid,
          value bigint,
          data_status text,
          notes text
        );

      select count(*) * (
        select count(*)
        from public.personnel_categories
        where active = true
      )
        into v_expected
      from public.criminal_offense_versions v
      join public.criminal_offenses o
        on o.id = v.offense_id
      where o.active = true;

      if v_actual <> v_expected or v_distinct <> v_expected then
        raise exception 'INCOMPLETE_TINDAK_PIDANA_PAYLOAD';
      end if;

      if exists (
        select 1
        from public.criminal_offense_versions expected
        join public.criminal_offenses o
          on o.id = expected.offense_id
        cross join public.personnel_categories pc
        where o.active = true
          and pc.active = true
          and not exists (
            select 1
            from jsonb_to_recordset(v_entries)
              as x(
                criminal_offense_version_id uuid,
                personnel_category_id uuid,
                value bigint,
                data_status text,
                notes text
              )
            where x.criminal_offense_version_id = expected.id
              and x.personnel_category_id = pc.id
          )
      ) then
        raise exception 'INCOMPLETE_TINDAK_PIDANA_PAYLOAD';
      end if;
  end case;

  insert into public.report_submissions (
    report_type_id,
    period_id,
    pomdam_id,
    submitted_by,
    status,
    revision,
    submitted_at,
    updated_at
  )
  values (
    v_report_type_id,
    p_period_id,
    p_pomdam_id,
    auth.uid(),
    'SUBMITTED',
    1,
    now(),
    now()
  )
  on conflict (report_type_id, period_id, pomdam_id)
  do update set
    submitted_by = excluded.submitted_by,
    status = 'SUBMITTED',
    revision = public.report_submissions.revision + 1,
    submitted_at = now(),
    updated_at = now()
  returning id into v_submission_id;

  case v_report_type
    when 'GAKKUM' then
      insert into public.gakkum_records (
        period_id,pomdam_id,activity_version_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,activity_version_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'entries','[]'::jsonb))
        as x(activity_version_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,activity_version_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

    when 'PELANGGARAN' then
      insert into public.violation_records (
        period_id,pomdam_id,violation_version_id,personnel_category_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,violation_version_id,personnel_category_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'entries','[]'::jsonb))
        as x(violation_version_id uuid,personnel_category_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,violation_version_id,personnel_category_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

    when 'SIM_TNI' then
      insert into public.sim_records (
        period_id,pomdam_id,sim_type_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,sim_type_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'entries','[]'::jsonb))
        as x(sim_type_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,sim_type_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

    when 'PROVOS' then
      insert into public.provos_strength_records (
        period_id,pomdam_id,strength_measure_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,strength_measure_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'strength','[]'::jsonb))
        as x(strength_measure_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,strength_measure_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

      insert into public.provos_education_records (
        period_id,pomdam_id,education_status_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,education_status_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'education','[]'::jsonb))
        as x(education_status_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,education_status_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

      insert into public.provos_personnel_records (
        period_id,pomdam_id,personnel_category_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,personnel_category_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'personnel','[]'::jsonb))
        as x(personnel_category_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,personnel_category_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

    when 'LAKA_LALIN' then
      insert into public.laka_accident_records (
        period_id,pomdam_id,accident_type_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,accident_type_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'accidents','[]'::jsonb))
        as x(accident_type_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,accident_type_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

      insert into public.laka_victim_outcome_records (
        period_id,pomdam_id,victim_outcome_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,victim_outcome_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'victim_outcomes','[]'::jsonb))
        as x(victim_outcome_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,victim_outcome_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

      insert into public.laka_victim_rank_records (
        period_id,pomdam_id,personnel_category_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,personnel_category_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'victim_ranks','[]'::jsonb))
        as x(personnel_category_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,personnel_category_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

      insert into public.laka_personnel_records (
        period_id,pomdam_id,personnel_category_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,personnel_category_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'personnel','[]'::jsonb))
        as x(personnel_category_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,personnel_category_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

      insert into public.laka_material_records (
        period_id,pomdam_id,vehicle_category_id,material_damage_type_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,vehicle_category_id,material_damage_type_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'materials','[]'::jsonb))
        as x(vehicle_category_id uuid,material_damage_type_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,vehicle_category_id,material_damage_type_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;

    when 'TINDAK_PIDANA' then
      insert into public.criminal_offense_records (
        period_id,pomdam_id,criminal_offense_version_id,personnel_category_id,value,data_status,source_cell_id,notes
      )
      select p_period_id,p_pomdam_id,criminal_offense_version_id,personnel_category_id,
             case when data_status='NOT_REPORTED' then null else value end,
             data_status,null,notes
      from jsonb_to_recordset(coalesce(p_payload->'entries','[]'::jsonb))
        as x(criminal_offense_version_id uuid,personnel_category_id uuid,value bigint,data_status text,notes text)
      on conflict (period_id,pomdam_id,criminal_offense_version_id,personnel_category_id)
      do update set
        value=excluded.value,
        data_status=excluded.data_status,
        source_cell_id=null,
        notes=excluded.notes;
  end case;

  return jsonb_build_object(
    'status','SUBMITTED',
    'submission_id',v_submission_id,
    'report_type',v_report_type,
    'period_id',p_period_id,
    'pomdam_id',p_pomdam_id
  );
end;
$function$

