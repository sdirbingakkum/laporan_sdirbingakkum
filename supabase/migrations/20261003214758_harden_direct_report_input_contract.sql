-- Reconciled production schema baseline.
-- Captures current production schema/configuration for reproducible fresh environments.
-- Historical migration names are retained separately as no-op ledger entries.
create extension if not exists pgcrypto;
create schema if not exists private;
grant usage on schema public to authenticated;
grant usage on schema private to authenticated;
revoke usage on schema private from anon;
create table if not exists "private"."app_capabilities" (
  "capability_code" text not null,
  "display_name" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "private"."app_role_capabilities" (
  "role_code" text not null,
  "capability_code" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "private"."app_roles" (
  "role_code" text not null,
  "display_name" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now(),
  "scope_type" text not null
);
create table if not exists "private"."app_user_pomdam_scopes" (
  "user_id" uuid not null,
  "pomdam_id" uuid not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "private"."app_user_roles" (
  "user_id" uuid not null,
  "role_code" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now(),
  "updated_at" timestamp with time zone not null default now()
);
create table if not exists "private"."source_cells" (
  "id" uuid not null default gen_random_uuid(),
  "source_report_id" uuid not null,
  "cell_ref" text not null,
  "row_number" integer not null,
  "column_letter" text not null,
  "raw_value" text,
  "formula_text" text,
  "parsed_numeric" bigint,
  "data_status" text not null default 'VALID'::text,
  "semantic_role" text,
  "row_label" text,
  "column_label" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "private"."source_terms" (
  "id" uuid not null default gen_random_uuid(),
  "source_report_id" uuid,
  "source_value" text not null,
  "normalized_value" text,
  "entity_type" text,
  "entity_key" text,
  "resolution_status" text not null default 'UNRESOLVED'::text,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "private"."step7_fact_stage" (
  "id" uuid not null default gen_random_uuid(),
  "report_type" text not null,
  "source_sheet_index" integer not null,
  "cell_ref" text,
  "source_row" integer,
  "source_column" text,
  "dimension_1" text,
  "dimension_2" text,
  "dimension_3" text,
  "dimension_4" text,
  "source_number" integer,
  "source_label" text,
  "raw_value" text,
  "parsed_numeric" bigint,
  "data_status" text not null,
  "semantic_role" text not null default 'FACT'::text,
  "row_label" text,
  "column_label" text,
  "notes" text,
  "created_at" timestamp with time zone not null default now(),
  "formula_text" text,
  "cell_present" boolean not null default true
);
create table if not exists "private"."step7_rejections" (
  "id" uuid not null default gen_random_uuid(),
  "report_type" text not null,
  "source_sheet_index" integer not null,
  "cell_ref" text,
  "source_row" integer,
  "source_number" integer,
  "source_label" text,
  "reason_code" text not null,
  "reason_detail" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."accident_types" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."criminal_offense_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "criminal_offense_version_id" uuid not null,
  "personnel_category_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."criminal_offense_versions" (
  "id" uuid not null default gen_random_uuid(),
  "offense_id" uuid not null,
  "source_number" integer not null,
  "source_label" text not null,
  "source_period" text,
  "valid_from" date,
  "valid_to" date,
  "display_order" integer not null,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."criminal_offenses" (
  "id" uuid not null default gen_random_uuid(),
  "canonical_key" text not null,
  "canonical_name" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."education_statuses" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."gakkum_activities" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "canonical_name" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."gakkum_activity_versions" (
  "id" uuid not null default gen_random_uuid(),
  "activity_id" uuid not null,
  "parent_version_id" uuid,
  "source_code" text,
  "source_label" text not null,
  "level" smallint not null default 0,
  "display_order" integer not null default 0,
  "valid_from" date,
  "valid_to" date,
  "created_at" timestamp with time zone not null default now(),
  "taxonomy_version" text not null default 'CURRENT_2026'::text
);
create table if not exists "public"."gakkum_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "activity_version_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."laka_accident_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "accident_type_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."laka_material_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "vehicle_category_id" uuid not null,
  "material_damage_type_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."laka_personnel_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "personnel_category_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."laka_victim_outcome_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "victim_outcome_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."laka_victim_rank_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "personnel_category_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."material_damage_types" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."personnel_categories" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."pomdam_aliases" (
  "id" uuid not null default gen_random_uuid(),
  "pomdam_id" uuid not null,
  "source_value" text not null,
  "alias_type" text not null,
  "source_period" text,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."pomdams" (
  "id" uuid not null default gen_random_uuid(),
  "report_order" smallint not null,
  "roman_numeral" text,
  "roman_value" smallint,
  "code" text not null,
  "short_name" text not null,
  "kodam_name" text not null,
  "kodam_full_name" text not null,
  "pomdam_full_name" text not null,
  "active" boolean not null default true,
  "valid_from" date,
  "valid_to" date,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."provos_education_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "education_status_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."provos_personnel_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "personnel_category_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."provos_strength_measures" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."provos_strength_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "strength_measure_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."report_periods" (
  "id" uuid not null default gen_random_uuid(),
  "period_type" text not null,
  "period_start" date,
  "period_end" date,
  "period_label" text not null,
  "report_year" integer,
  "fiscal_year" integer,
  "source_label" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."report_provenance" (
  "source_cell_id" uuid not null,
  "source_report_id" uuid not null,
  "cell_ref" text not null,
  "row_number" integer not null,
  "column_letter" text not null,
  "raw_value" text,
  "formula_text" text,
  "parsed_numeric" bigint,
  "data_status" text not null,
  "semantic_role" text,
  "row_label" text,
  "column_label" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."report_submissions" (
  "id" uuid not null default gen_random_uuid(),
  "report_type_id" uuid not null,
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "submitted_by" uuid not null,
  "status" text not null default 'SUBMITTED'::text,
  "revision" integer not null default 1,
  "submitted_at" timestamp with time zone not null default now(),
  "created_at" timestamp with time zone not null default now(),
  "updated_at" timestamp with time zone not null default now()
);
create table if not exists "public"."report_types" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "description" text,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."sim_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "sim_type_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."sim_types" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "display_name" text not null,
  "source_label" text,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."source_pomdam_occurrences" (
  "id" uuid not null default gen_random_uuid(),
  "source_report_id" uuid not null,
  "pomdam_id" uuid,
  "source_value" text not null,
  "source_row" integer,
  "source_column" text,
  "cell_ref" text not null,
  "orientation" text not null,
  "block_index" integer not null,
  "block_role" text not null,
  "position" integer not null,
  "order_expected_code" text,
  "position_matches_report_order" boolean,
  "mapping_status" text not null,
  "mapping_note" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."source_report_files" (
  "id" uuid not null default gen_random_uuid(),
  "source_report_id" uuid not null,
  "bucket_id" text not null default 'source-workbooks'::text,
  "object_path" text not null,
  "original_filename" text not null,
  "content_type" text not null default 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'::text,
  "byte_size" bigint,
  "file_sha256" text,
  "availability_status" text not null default 'MISSING'::text,
  "access_scope" text not null default 'ALL_POMDAM_SHARED'::text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."source_report_pomdams" (
  "id" uuid not null default gen_random_uuid(),
  "source_report_id" uuid not null,
  "pomdam_id" uuid not null,
  "source_value" text not null,
  "source_column" text,
  "source_position" integer,
  "header_row" integer,
  "resolution_status" text not null default 'RESOLVED'::text,
  "notes" text,
  "created_at" timestamp with time zone not null default now(),
  "source_row" integer,
  "orientation" text,
  "block_role" text,
  "position_matches_report_order" boolean,
  "mapping_status" text,
  "mapping_note" text
);
create table if not exists "public"."source_reports" (
  "id" uuid not null default gen_random_uuid(),
  "report_type_id" uuid not null,
  "period_id" uuid,
  "workbook_name" text not null,
  "sheet_name" text not null,
  "raw_period_label" text,
  "period_resolution_status" text not null default 'PENDING_REVIEW'::text,
  "source_fingerprint" text,
  "data_fingerprint" text,
  "duplicate_of_id" uuid,
  "import_status" text not null default 'DISCOVERED'::text,
  "notes" text,
  "created_at" timestamp with time zone not null default now(),
  "source_sheet_index" integer,
  "sheet_state" text not null default 'visible'::text,
  "sheet_role" text not null default 'DATA'::text,
  "row_count" integer,
  "column_count" integer,
  "nonempty_cell_count" integer,
  "formula_count" integer,
  "formula_error_count" integer,
  "sheet_name_period_label" text,
  "body_period_label" text,
  "period_resolution_note" text
);
create table if not exists "public"."vehicle_categories" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."victim_outcomes" (
  "id" uuid not null default gen_random_uuid(),
  "code" text not null,
  "name" text not null,
  "display_order" smallint not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."violation_records" (
  "id" uuid not null default gen_random_uuid(),
  "period_id" uuid not null,
  "pomdam_id" uuid not null,
  "violation_version_id" uuid not null,
  "personnel_category_id" uuid not null,
  "value" bigint,
  "data_status" text not null default 'VALID'::text,
  "source_cell_id" uuid,
  "notes" text,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."violation_versions" (
  "id" uuid not null default gen_random_uuid(),
  "violation_id" uuid not null,
  "source_code" text not null,
  "source_label" text not null,
  "source_period" text,
  "valid_from" date,
  "valid_to" date,
  "display_order" integer,
  "created_at" timestamp with time zone not null default now()
);
create table if not exists "public"."violations" (
  "id" uuid not null default gen_random_uuid(),
  "canonical_code" text not null,
  "canonical_name" text not null,
  "category" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now()
);
do $$ begin if not exists (select 1 from pg_constraint where conname='app_capabilities_pkey' and conrelid='private.app_capabilities'::regclass) then alter table "private"."app_capabilities" add constraint "app_capabilities_pkey" PRIMARY KEY (capability_code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_role_capabilities_pkey' and conrelid='private.app_role_capabilities'::regclass) then alter table "private"."app_role_capabilities" add constraint "app_role_capabilities_pkey" PRIMARY KEY (role_code, capability_code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_roles_pkey' and conrelid='private.app_roles'::regclass) then alter table "private"."app_roles" add constraint "app_roles_pkey" PRIMARY KEY (role_code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_user_pomdam_scopes_pkey' and conrelid='private.app_user_pomdam_scopes'::regclass) then alter table "private"."app_user_pomdam_scopes" add constraint "app_user_pomdam_scopes_pkey" PRIMARY KEY (user_id, pomdam_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_user_roles_pkey' and conrelid='private.app_user_roles'::regclass) then alter table "private"."app_user_roles" add constraint "app_user_roles_pkey" PRIMARY KEY (user_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_cells_pkey' and conrelid='private.source_cells'::regclass) then alter table "private"."source_cells" add constraint "source_cells_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_terms_pkey' and conrelid='private.source_terms'::regclass) then alter table "private"."source_terms" add constraint "source_terms_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='step7_fact_stage_pkey' and conrelid='private.step7_fact_stage'::regclass) then alter table "private"."step7_fact_stage" add constraint "step7_fact_stage_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='step7_rejections_pkey' and conrelid='private.step7_rejections'::regclass) then alter table "private"."step7_rejections" add constraint "step7_rejections_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='accident_types_pkey' and conrelid='public.accident_types'::regclass) then alter table "public"."accident_types" add constraint "accident_types_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_pkey' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_versions_pkey' and conrelid='public.criminal_offense_versions'::regclass) then alter table "public"."criminal_offense_versions" add constraint "criminal_offense_versions_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offenses_pkey' and conrelid='public.criminal_offenses'::regclass) then alter table "public"."criminal_offenses" add constraint "criminal_offenses_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='education_statuses_pkey' and conrelid='public.education_statuses'::regclass) then alter table "public"."education_statuses" add constraint "education_statuses_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activities_pkey' and conrelid='public.gakkum_activities'::regclass) then alter table "public"."gakkum_activities" add constraint "gakkum_activities_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_pkey' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_pkey' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_pkey' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_pkey' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_pkey' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_pkey' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_pkey' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='material_damage_types_pkey' and conrelid='public.material_damage_types'::regclass) then alter table "public"."material_damage_types" add constraint "material_damage_types_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='personnel_categories_pkey' and conrelid='public.personnel_categories'::regclass) then alter table "public"."personnel_categories" add constraint "personnel_categories_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdam_aliases_pkey' and conrelid='public.pomdam_aliases'::regclass) then alter table "public"."pomdam_aliases" add constraint "pomdam_aliases_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdams_pkey' and conrelid='public.pomdams'::regclass) then alter table "public"."pomdams" add constraint "pomdams_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_pkey' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_pkey' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_measures_pkey' and conrelid='public.provos_strength_measures'::regclass) then alter table "public"."provos_strength_measures" add constraint "provos_strength_measures_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_pkey' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_periods_pkey' and conrelid='public.report_periods'::regclass) then alter table "public"."report_periods" add constraint "report_periods_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_provenance_pkey' and conrelid='public.report_provenance'::regclass) then alter table "public"."report_provenance" add constraint "report_provenance_pkey" PRIMARY KEY (source_cell_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_pkey' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_types_pkey' and conrelid='public.report_types'::regclass) then alter table "public"."report_types" add constraint "report_types_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_pkey' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_types_pkey' and conrelid='public.sim_types'::regclass) then alter table "public"."sim_types" add constraint "sim_types_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_pkey' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_pkey' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_pkey' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_pkey' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='vehicle_categories_pkey' and conrelid='public.vehicle_categories'::regclass) then alter table "public"."vehicle_categories" add constraint "vehicle_categories_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='victim_outcomes_pkey' and conrelid='public.victim_outcomes'::regclass) then alter table "public"."victim_outcomes" add constraint "victim_outcomes_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_pkey' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_versions_pkey' and conrelid='public.violation_versions'::regclass) then alter table "public"."violation_versions" add constraint "violation_versions_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violations_pkey' and conrelid='public.violations'::regclass) then alter table "public"."violations" add constraint "violations_pkey" PRIMARY KEY (id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_cells_source_report_id_cell_ref_key' and conrelid='private.source_cells'::regclass) then alter table "private"."source_cells" add constraint "source_cells_source_report_id_cell_ref_key" UNIQUE (source_report_id, cell_ref); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='accident_types_code_key' and conrelid='public.accident_types'::regclass) then alter table "public"."accident_types" add constraint "accident_types_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_period_id_pomdam_id_criminal_offen_key' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_period_id_pomdam_id_criminal_offen_key" UNIQUE (period_id, pomdam_id, criminal_offense_version_id, personnel_category_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_versions_offense_id_source_period_key' and conrelid='public.criminal_offense_versions'::regclass) then alter table "public"."criminal_offense_versions" add constraint "criminal_offense_versions_offense_id_source_period_key" UNIQUE (offense_id, source_period); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_versions_source_period_source_number_key' and conrelid='public.criminal_offense_versions'::regclass) then alter table "public"."criminal_offense_versions" add constraint "criminal_offense_versions_source_period_source_number_key" UNIQUE (source_period, source_number); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offenses_canonical_key_key' and conrelid='public.criminal_offenses'::regclass) then alter table "public"."criminal_offenses" add constraint "criminal_offenses_canonical_key_key" UNIQUE (canonical_key); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='education_statuses_code_key' and conrelid='public.education_statuses'::regclass) then alter table "public"."education_statuses" add constraint "education_statuses_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activities_code_key' and conrelid='public.gakkum_activities'::regclass) then alter table "public"."gakkum_activities" add constraint "gakkum_activities_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_activity_id_source_label_valid_fro_key' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_activity_id_source_label_valid_fro_key" UNIQUE (activity_id, source_label, valid_from, valid_to); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_period_id_pomdam_id_activity_version_id_key' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_period_id_pomdam_id_activity_version_id_key" UNIQUE (period_id, pomdam_id, activity_version_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_period_id_pomdam_id_accident_type_id_key' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_period_id_pomdam_id_accident_type_id_key" UNIQUE (period_id, pomdam_id, accident_type_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_period_id_pomdam_id_vehicle_category__key' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_period_id_pomdam_id_vehicle_category__key" UNIQUE (period_id, pomdam_id, vehicle_category_id, material_damage_type_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_period_id_pomdam_id_personnel_catego_key' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_period_id_pomdam_id_personnel_catego_key" UNIQUE (period_id, pomdam_id, personnel_category_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_period_id_pomdam_id_victim_outc_key' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_period_id_pomdam_id_victim_outc_key" UNIQUE (period_id, pomdam_id, victim_outcome_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_period_id_pomdam_id_personnel_cate_key' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_period_id_pomdam_id_personnel_cate_key" UNIQUE (period_id, pomdam_id, personnel_category_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='material_damage_types_code_key' and conrelid='public.material_damage_types'::regclass) then alter table "public"."material_damage_types" add constraint "material_damage_types_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='personnel_categories_code_key' and conrelid='public.personnel_categories'::regclass) then alter table "public"."personnel_categories" add constraint "personnel_categories_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdam_aliases_pomdam_id_source_value_key' and conrelid='public.pomdam_aliases'::regclass) then alter table "public"."pomdam_aliases" add constraint "pomdam_aliases_pomdam_id_source_value_key" UNIQUE (pomdam_id, source_value); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdams_code_key' and conrelid='public.pomdams'::regclass) then alter table "public"."pomdams" add constraint "pomdams_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdams_report_order_key' and conrelid='public.pomdams'::regclass) then alter table "public"."pomdams" add constraint "pomdams_report_order_key" UNIQUE (report_order); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_period_id_pomdam_id_education_stat_key' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_period_id_pomdam_id_education_stat_key" UNIQUE (period_id, pomdam_id, education_status_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_period_id_pomdam_id_personnel_cate_key' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_period_id_pomdam_id_personnel_cate_key" UNIQUE (period_id, pomdam_id, personnel_category_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_measures_code_key' and conrelid='public.provos_strength_measures'::regclass) then alter table "public"."provos_strength_measures" add constraint "provos_strength_measures_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_period_id_pomdam_id_strength_measur_key' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_period_id_pomdam_id_strength_measur_key" UNIQUE (period_id, pomdam_id, strength_measure_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_periods_identity_key' and conrelid='public.report_periods'::regclass) then alter table "public"."report_periods" add constraint "report_periods_identity_key" UNIQUE NULLS NOT DISTINCT (period_type, period_start, period_end, period_label); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_periods_period_type_period_start_period_end_period_l_key' and conrelid='public.report_periods'::regclass) then alter table "public"."report_periods" add constraint "report_periods_period_type_period_start_period_end_period_l_key" UNIQUE (period_type, period_start, period_end, period_label); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_report_type_id_period_id_pomdam_id_key' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_report_type_id_period_id_pomdam_id_key" UNIQUE (report_type_id, period_id, pomdam_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_types_code_key' and conrelid='public.report_types'::regclass) then alter table "public"."report_types" add constraint "report_types_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_period_id_pomdam_id_sim_type_id_key' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_period_id_pomdam_id_sim_type_id_key" UNIQUE (period_id, pomdam_id, sim_type_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_types_code_key' and conrelid='public.sim_types'::regclass) then alter table "public"."sim_types" add constraint "sim_types_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_source_report_id_cell_ref_key' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_source_report_id_cell_ref_key" UNIQUE (source_report_id, cell_ref); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_bucket_id_object_path_key' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_bucket_id_object_path_key" UNIQUE (bucket_id, object_path); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_source_report_id_key' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_source_report_id_key" UNIQUE (source_report_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_source_report_id_pomdam_id_key' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_source_report_id_pomdam_id_key" UNIQUE (source_report_id, pomdam_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_unique_sheet_snapshot' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_unique_sheet_snapshot" UNIQUE (workbook_name, sheet_name, source_fingerprint); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='vehicle_categories_code_key' and conrelid='public.vehicle_categories'::regclass) then alter table "public"."vehicle_categories" add constraint "vehicle_categories_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='victim_outcomes_code_key' and conrelid='public.victim_outcomes'::regclass) then alter table "public"."victim_outcomes" add constraint "victim_outcomes_code_key" UNIQUE (code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_period_id_pomdam_id_violation_version_id__key' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_period_id_pomdam_id_violation_version_id__key" UNIQUE (period_id, pomdam_id, violation_version_id, personnel_category_id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_versions_violation_id_source_label_source_period_key' and conrelid='public.violation_versions'::regclass) then alter table "public"."violation_versions" add constraint "violation_versions_violation_id_source_label_source_period_key" UNIQUE (violation_id, source_label, source_period); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violations_canonical_code_key' and conrelid='public.violations'::regclass) then alter table "public"."violations" add constraint "violations_canonical_code_key" UNIQUE (canonical_code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_roles_role_code_check' and conrelid='private.app_roles'::regclass) then alter table "private"."app_roles" add constraint "app_roles_role_code_check" CHECK (role_code = ANY (ARRAY['PUSPOMAD_COMMANDER'::text, 'PUSPOMAD_DEPUTY_COMMANDER'::text, 'PUSPOMAD_DIRBINGAKKUM'::text, 'PUSPOMAD_OPERATOR'::text, 'POMDAM_COMMANDER'::text, 'POMDAM_OPERATOR'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_roles_scope_type_check' and conrelid='private.app_roles'::regclass) then alter table "private"."app_roles" add constraint "app_roles_scope_type_check" CHECK (scope_type = ANY (ARRAY['ALL_POMDAM'::text, 'POMDAM'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_cells_data_status_check' and conrelid='private.source_cells'::regclass) then alter table "private"."source_cells" add constraint "source_cells_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_cells_row_number_check' and conrelid='private.source_cells'::regclass) then alter table "private"."source_cells" add constraint "source_cells_row_number_check" CHECK (row_number > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_terms_resolution_status_check' and conrelid='private.source_terms'::regclass) then alter table "private"."source_terms" add constraint "source_terms_resolution_status_check" CHECK (resolution_status = ANY (ARRAY['CONFIRMED'::text, 'HIGH_CONFIDENCE'::text, 'RESOLVED_ALIAS'::text, 'HISTORICAL'::text, 'CONTEXT_DEPENDENT'::text, 'UNRESOLVED'::text, 'SOURCE_TYPO'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='step7_fact_stage_data_status_check' and conrelid='private.step7_fact_stage'::regclass) then alter table "private"."step7_fact_stage" add constraint "step7_fact_stage_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='accident_types_display_order_check' and conrelid='public.accident_types'::regclass) then alter table "public"."accident_types" add constraint "accident_types_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_check' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_data_status_check' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_value_check' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_versions_date_order' and conrelid='public.criminal_offense_versions'::regclass) then alter table "public"."criminal_offense_versions" add constraint "criminal_offense_versions_date_order" CHECK (valid_from IS NULL OR valid_to IS NULL OR valid_from <= valid_to); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_versions_source_number_check' and conrelid='public.criminal_offense_versions'::regclass) then alter table "public"."criminal_offense_versions" add constraint "criminal_offense_versions_source_number_check" CHECK (source_number > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='education_statuses_display_order_check' and conrelid='public.education_statuses'::regclass) then alter table "public"."education_statuses" add constraint "education_statuses_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_date_order' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_date_order" CHECK (valid_from IS NULL OR valid_to IS NULL OR valid_from <= valid_to); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_level_check' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_level_check" CHECK (level >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_taxonomy_version_check' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_taxonomy_version_check" CHECK (taxonomy_version = ANY (ARRAY['CURRENT_2026'::text, 'HISTORICAL_2023_2024'::text, 'HISTORICAL_2025'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_check' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_data_status_check' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_value_check' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_check' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_data_status_check' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_value_check' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_check' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_data_status_check' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_value_check' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_check' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_data_status_check' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_value_check' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_check' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_data_status_check' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_value_check' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_check' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_data_status_check' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_value_check' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='material_damage_types_display_order_check' and conrelid='public.material_damage_types'::regclass) then alter table "public"."material_damage_types" add constraint "material_damage_types_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='personnel_categories_display_order_check' and conrelid='public.personnel_categories'::regclass) then alter table "public"."personnel_categories" add constraint "personnel_categories_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdam_aliases_alias_type_check' and conrelid='public.pomdam_aliases'::regclass) then alter table "public"."pomdam_aliases" add constraint "pomdam_aliases_alias_type_check" CHECK (alias_type = ANY (ARRAY['LEGACY'::text, 'SOURCE_VARIANT'::text, 'SOURCE_TYPO'::text, 'CONFLICTING_SOURCE'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdams_check' and conrelid='public.pomdams'::regclass) then alter table "public"."pomdams" add constraint "pomdams_check" CHECK (roman_numeral IS NULL AND roman_value IS NULL OR roman_numeral IS NOT NULL AND roman_value IS NOT NULL AND roman_value > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdams_report_order_check' and conrelid='public.pomdams'::regclass) then alter table "public"."pomdams" add constraint "pomdams_report_order_check" CHECK (report_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdams_valid_date_order' and conrelid='public.pomdams'::regclass) then alter table "public"."pomdams" add constraint "pomdams_valid_date_order" CHECK (valid_from IS NULL OR valid_to IS NULL OR valid_from <= valid_to); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_check' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_data_status_check' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_value_check' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_check' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_data_status_check' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_value_check' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_measures_display_order_check' and conrelid='public.provos_strength_measures'::regclass) then alter table "public"."provos_strength_measures" add constraint "provos_strength_measures_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_check' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_data_status_check' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_value_check' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_periods_date_order' and conrelid='public.report_periods'::regclass) then alter table "public"."report_periods" add constraint "report_periods_date_order" CHECK (period_start IS NULL OR period_end IS NULL OR period_start <= period_end); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_periods_period_type_check' and conrelid='public.report_periods'::regclass) then alter table "public"."report_periods" add constraint "report_periods_period_type_check" CHECK (period_type = ANY (ARRAY['MONTH'::text, 'QUARTER'::text, 'SEMESTER'::text, 'YEAR'::text, 'OTHER'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_revision_check' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_revision_check" CHECK (revision > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_status_check' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_status_check" CHECK (status = ANY (ARRAY['DRAFT'::text, 'SUBMITTED'::text, 'REOPENED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_check' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_data_status_check' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_value_check' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_types_display_order_check' and conrelid='public.sim_types'::regclass) then alter table "public"."sim_types" add constraint "sim_types_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_block_index_check' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_block_index_check" CHECK (block_index > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_block_role_check' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_block_role_check" CHECK (block_role = ANY (ARRAY['PRIMARY_HEADER'::text, 'SECONDARY_HEADER'::text, 'PARTIAL_HEADER'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_mapping_status_check' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_mapping_status_check" CHECK (mapping_status = ANY (ARRAY['RESOLVED'::text, 'SOURCE_VARIANT'::text, 'SOURCE_TYPO'::text, 'REORDERED'::text, 'PARTIAL'::text, 'UNRESOLVED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_orientation_check' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_orientation_check" CHECK (orientation = ANY (ARRAY['HORIZONTAL'::text, 'VERTICAL'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_position_check' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_position_check" CHECK ("position" > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_access_scope_check' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_access_scope_check" CHECK (access_scope = 'ALL_POMDAM_SHARED'::text); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_availability_status_check' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_availability_status_check" CHECK (availability_status = ANY (ARRAY['MISSING'::text, 'AVAILABLE'::text, 'RETIRED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_bucket_id_check' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_bucket_id_check" CHECK (bucket_id = 'source-workbooks'::text); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_object_path_check' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_object_path_check" CHECK (object_path <> ''::text); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_object_path_check1' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_object_path_check1" CHECK (object_path !~ '(^|/)\.\.?(/|$)'::text); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_original_filename_check' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_original_filename_check" CHECK (original_filename ~* '\\.xlsx$'::text); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_block_role_check' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_block_role_check" CHECK (block_role IS NULL OR (block_role = ANY (ARRAY['PRIMARY_HEADER'::text, 'SECONDARY_HEADER'::text]))); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_mapping_status_check' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_mapping_status_check" CHECK (mapping_status IS NULL OR (mapping_status = ANY (ARRAY['RESOLVED'::text, 'SOURCE_VARIANT'::text, 'SOURCE_TYPO'::text, 'REORDERED'::text, 'UNRESOLVED'::text]))); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_orientation_check' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_orientation_check" CHECK (orientation IS NULL OR (orientation = ANY (ARRAY['HORIZONTAL'::text, 'VERTICAL'::text]))); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_resolution_status_check' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_resolution_status_check" CHECK (resolution_status = ANY (ARRAY['RESOLVED'::text, 'AMBIGUOUS'::text, 'UNRESOLVED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_source_position_check' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_source_position_check" CHECK (source_position IS NULL OR source_position > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_column_count_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_column_count_check" CHECK (column_count IS NULL OR column_count >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_formula_count_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_formula_count_check" CHECK (formula_count IS NULL OR formula_count >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_formula_error_count_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_formula_error_count_check" CHECK (formula_error_count IS NULL OR formula_error_count >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_import_status_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_import_status_check" CHECK (import_status = ANY (ARRAY['DISCOVERED'::text, 'IMPORTED'::text, 'REJECTED'::text, 'SUPERSEDED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_nonempty_count_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_nonempty_count_check" CHECK (nonempty_cell_count IS NULL OR nonempty_cell_count >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_period_resolution_status_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_period_resolution_status_check" CHECK (period_resolution_status = ANY (ARRAY['RESOLVED'::text, 'PENDING_REVIEW'::text, 'AMBIGUOUS'::text, 'INVALID_SOURCE'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_row_count_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_row_count_check" CHECK (row_count IS NULL OR row_count >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_sheet_role_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_sheet_role_check" CHECK (sheet_role = ANY (ARRAY['DATA'::text, 'COVER'::text, 'CONFIG'::text, 'PERIOD_SUMMARY'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_sheet_state_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_sheet_state_check" CHECK (sheet_state = ANY (ARRAY['visible'::text, 'hidden'::text, 'veryHidden'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_source_sheet_index_check' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_source_sheet_index_check" CHECK (source_sheet_index IS NULL OR source_sheet_index > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='vehicle_categories_display_order_check' and conrelid='public.vehicle_categories'::regclass) then alter table "public"."vehicle_categories" add constraint "vehicle_categories_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='victim_outcomes_display_order_check' and conrelid='public.victim_outcomes'::regclass) then alter table "public"."victim_outcomes" add constraint "victim_outcomes_display_order_check" CHECK (display_order > 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_check' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_check" CHECK ((data_status = ANY (ARRAY['VALID'::text, 'ESTIMATED'::text])) AND value IS NOT NULL OR (data_status = ANY (ARRAY['NOT_REPORTED'::text, 'INVALID_SOURCE'::text])) AND value IS NULL); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_data_status_check' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_data_status_check" CHECK (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text, 'INVALID_SOURCE'::text, 'ESTIMATED'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_value_check' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_value_check" CHECK (value IS NULL OR value >= 0); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_versions_date_order' and conrelid='public.violation_versions'::regclass) then alter table "public"."violation_versions" add constraint "violation_versions_date_order" CHECK (valid_from IS NULL OR valid_to IS NULL OR valid_from <= valid_to); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violations_category_check' and conrelid='public.violations'::regclass) then alter table "public"."violations" add constraint "violations_category_check" CHECK (category = ANY (ARRAY['B'::text, 'C'::text, 'OTHER'::text])); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_role_capabilities_capability_code_fkey' and conrelid='private.app_role_capabilities'::regclass) then alter table "private"."app_role_capabilities" add constraint "app_role_capabilities_capability_code_fkey" FOREIGN KEY (capability_code) REFERENCES private.app_capabilities(capability_code) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_role_capabilities_role_code_fkey' and conrelid='private.app_role_capabilities'::regclass) then alter table "private"."app_role_capabilities" add constraint "app_role_capabilities_role_code_fkey" FOREIGN KEY (role_code) REFERENCES private.app_roles(role_code) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_user_pomdam_scopes_pomdam_id_fkey' and conrelid='private.app_user_pomdam_scopes'::regclass) then alter table "private"."app_user_pomdam_scopes" add constraint "app_user_pomdam_scopes_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_user_pomdam_scopes_user_id_fkey' and conrelid='private.app_user_pomdam_scopes'::regclass) then alter table "private"."app_user_pomdam_scopes" add constraint "app_user_pomdam_scopes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_user_roles_role_code_fkey' and conrelid='private.app_user_roles'::regclass) then alter table "private"."app_user_roles" add constraint "app_user_roles_role_code_fkey" FOREIGN KEY (role_code) REFERENCES private.app_roles(role_code); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='app_user_roles_user_id_fkey' and conrelid='private.app_user_roles'::regclass) then alter table "private"."app_user_roles" add constraint "app_user_roles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_cells_source_report_id_fkey' and conrelid='private.source_cells'::regclass) then alter table "private"."source_cells" add constraint "source_cells_source_report_id_fkey" FOREIGN KEY (source_report_id) REFERENCES source_reports(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_terms_source_report_id_fkey' and conrelid='private.source_terms'::regclass) then alter table "private"."source_terms" add constraint "source_terms_source_report_id_fkey" FOREIGN KEY (source_report_id) REFERENCES source_reports(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_criminal_offense_version_id_fkey' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_criminal_offense_version_id_fkey" FOREIGN KEY (criminal_offense_version_id) REFERENCES criminal_offense_versions(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_period_id_fkey' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_personnel_category_id_fkey' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_personnel_category_id_fkey" FOREIGN KEY (personnel_category_id) REFERENCES personnel_categories(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_pomdam_id_fkey' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_records_source_cell_id_fkey' and conrelid='public.criminal_offense_records'::regclass) then alter table "public"."criminal_offense_records" add constraint "criminal_offense_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='criminal_offense_versions_offense_id_fkey' and conrelid='public.criminal_offense_versions'::regclass) then alter table "public"."criminal_offense_versions" add constraint "criminal_offense_versions_offense_id_fkey" FOREIGN KEY (offense_id) REFERENCES criminal_offenses(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_activity_id_fkey' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES gakkum_activities(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_activity_versions_parent_version_id_fkey' and conrelid='public.gakkum_activity_versions'::regclass) then alter table "public"."gakkum_activity_versions" add constraint "gakkum_activity_versions_parent_version_id_fkey" FOREIGN KEY (parent_version_id) REFERENCES gakkum_activity_versions(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_activity_version_id_fkey' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_activity_version_id_fkey" FOREIGN KEY (activity_version_id) REFERENCES gakkum_activity_versions(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_period_id_fkey' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_pomdam_id_fkey' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='gakkum_records_source_cell_id_fkey' and conrelid='public.gakkum_records'::regclass) then alter table "public"."gakkum_records" add constraint "gakkum_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_accident_type_id_fkey' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_accident_type_id_fkey" FOREIGN KEY (accident_type_id) REFERENCES accident_types(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_period_id_fkey' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_pomdam_id_fkey' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_accident_records_source_cell_id_fkey' and conrelid='public.laka_accident_records'::regclass) then alter table "public"."laka_accident_records" add constraint "laka_accident_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_material_damage_type_id_fkey' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_material_damage_type_id_fkey" FOREIGN KEY (material_damage_type_id) REFERENCES material_damage_types(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_period_id_fkey' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_pomdam_id_fkey' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_source_cell_id_fkey' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_material_records_vehicle_category_id_fkey' and conrelid='public.laka_material_records'::regclass) then alter table "public"."laka_material_records" add constraint "laka_material_records_vehicle_category_id_fkey" FOREIGN KEY (vehicle_category_id) REFERENCES vehicle_categories(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_period_id_fkey' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_personnel_category_id_fkey' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_personnel_category_id_fkey" FOREIGN KEY (personnel_category_id) REFERENCES personnel_categories(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_pomdam_id_fkey' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_personnel_records_source_cell_id_fkey' and conrelid='public.laka_personnel_records'::regclass) then alter table "public"."laka_personnel_records" add constraint "laka_personnel_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_period_id_fkey' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_pomdam_id_fkey' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_source_cell_id_fkey' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_outcome_records_victim_outcome_id_fkey' and conrelid='public.laka_victim_outcome_records'::regclass) then alter table "public"."laka_victim_outcome_records" add constraint "laka_victim_outcome_records_victim_outcome_id_fkey" FOREIGN KEY (victim_outcome_id) REFERENCES victim_outcomes(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_period_id_fkey' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_personnel_category_id_fkey' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_personnel_category_id_fkey" FOREIGN KEY (personnel_category_id) REFERENCES personnel_categories(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_pomdam_id_fkey' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='laka_victim_rank_records_source_cell_id_fkey' and conrelid='public.laka_victim_rank_records'::regclass) then alter table "public"."laka_victim_rank_records" add constraint "laka_victim_rank_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='pomdam_aliases_pomdam_id_fkey' and conrelid='public.pomdam_aliases'::regclass) then alter table "public"."pomdam_aliases" add constraint "pomdam_aliases_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_education_status_id_fkey' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_education_status_id_fkey" FOREIGN KEY (education_status_id) REFERENCES education_statuses(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_period_id_fkey' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_pomdam_id_fkey' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_education_records_source_cell_id_fkey' and conrelid='public.provos_education_records'::regclass) then alter table "public"."provos_education_records" add constraint "provos_education_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_period_id_fkey' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_personnel_category_id_fkey' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_personnel_category_id_fkey" FOREIGN KEY (personnel_category_id) REFERENCES personnel_categories(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_pomdam_id_fkey' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_personnel_records_source_cell_id_fkey' and conrelid='public.provos_personnel_records'::regclass) then alter table "public"."provos_personnel_records" add constraint "provos_personnel_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_period_id_fkey' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_pomdam_id_fkey' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_source_cell_id_fkey' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='provos_strength_records_strength_measure_id_fkey' and conrelid='public.provos_strength_records'::regclass) then alter table "public"."provos_strength_records" add constraint "provos_strength_records_strength_measure_id_fkey" FOREIGN KEY (strength_measure_id) REFERENCES provos_strength_measures(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_provenance_source_cell_id_fkey' and conrelid='public.report_provenance'::regclass) then alter table "public"."report_provenance" add constraint "report_provenance_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_provenance_source_report_id_fkey' and conrelid='public.report_provenance'::regclass) then alter table "public"."report_provenance" add constraint "report_provenance_source_report_id_fkey" FOREIGN KEY (source_report_id) REFERENCES source_reports(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_period_id_fkey' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_pomdam_id_fkey' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_report_type_id_fkey' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_report_type_id_fkey" FOREIGN KEY (report_type_id) REFERENCES report_types(id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='report_submissions_submitted_by_fkey' and conrelid='public.report_submissions'::regclass) then alter table "public"."report_submissions" add constraint "report_submissions_submitted_by_fkey" FOREIGN KEY (submitted_by) REFERENCES auth.users(id); end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_period_id_fkey' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_pomdam_id_fkey' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_sim_type_id_fkey' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_sim_type_id_fkey" FOREIGN KEY (sim_type_id) REFERENCES sim_types(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='sim_records_source_cell_id_fkey' and conrelid='public.sim_records'::regclass) then alter table "public"."sim_records" add constraint "sim_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_pomdam_id_fkey' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_pomdam_occurrences_source_report_id_fkey' and conrelid='public.source_pomdam_occurrences'::regclass) then alter table "public"."source_pomdam_occurrences" add constraint "source_pomdam_occurrences_source_report_id_fkey" FOREIGN KEY (source_report_id) REFERENCES source_reports(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_files_source_report_id_fkey' and conrelid='public.source_report_files'::regclass) then alter table "public"."source_report_files" add constraint "source_report_files_source_report_id_fkey" FOREIGN KEY (source_report_id) REFERENCES source_reports(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_pomdam_id_fkey' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_report_pomdams_source_report_id_fkey' and conrelid='public.source_report_pomdams'::regclass) then alter table "public"."source_report_pomdams" add constraint "source_report_pomdams_source_report_id_fkey" FOREIGN KEY (source_report_id) REFERENCES source_reports(id) ON DELETE CASCADE; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_duplicate_of_id_fkey' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_duplicate_of_id_fkey" FOREIGN KEY (duplicate_of_id) REFERENCES source_reports(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_period_id_fkey' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='source_reports_report_type_id_fkey' and conrelid='public.source_reports'::regclass) then alter table "public"."source_reports" add constraint "source_reports_report_type_id_fkey" FOREIGN KEY (report_type_id) REFERENCES report_types(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_period_id_fkey' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_period_id_fkey" FOREIGN KEY (period_id) REFERENCES report_periods(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_personnel_category_id_fkey' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_personnel_category_id_fkey" FOREIGN KEY (personnel_category_id) REFERENCES personnel_categories(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_pomdam_id_fkey' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_pomdam_id_fkey" FOREIGN KEY (pomdam_id) REFERENCES pomdams(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_source_cell_id_fkey' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_source_cell_id_fkey" FOREIGN KEY (source_cell_id) REFERENCES private.source_cells(id) ON DELETE SET NULL; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_records_violation_version_id_fkey' and conrelid='public.violation_records'::regclass) then alter table "public"."violation_records" add constraint "violation_records_violation_version_id_fkey" FOREIGN KEY (violation_version_id) REFERENCES violation_versions(id) ON DELETE RESTRICT; end if; end $$;
do $$ begin if not exists (select 1 from pg_constraint where conname='violation_versions_violation_id_fkey' and conrelid='public.violation_versions'::regclass) then alter table "public"."violation_versions" add constraint "violation_versions_violation_id_fkey" FOREIGN KEY (violation_id) REFERENCES violations(id) ON DELETE RESTRICT; end if; end $$;
CREATE INDEX app_role_capabilities_capability_idx ON private.app_role_capabilities USING btree (capability_code);
CREATE INDEX app_user_pomdam_scopes_pomdam_id_idx ON private.app_user_pomdam_scopes USING btree (pomdam_id);
CREATE INDEX app_user_pomdam_scopes_user_active_idx ON private.app_user_pomdam_scopes USING btree (user_id, pomdam_id) WHERE (active = true);
CREATE INDEX app_user_roles_role_code_idx ON private.app_user_roles USING btree (role_code);
CREATE INDEX idx_source_cells_report ON private.source_cells USING btree (source_report_id);
CREATE INDEX idx_source_cells_status ON private.source_cells USING btree (data_status);
CREATE INDEX idx_source_terms_report ON private.source_terms USING btree (source_report_id);
CREATE UNIQUE INDEX uq_source_terms_semantic ON private.source_terms USING btree (source_value, COALESCE(entity_type, ''::text), COALESCE(entity_key, ''::text));
CREATE INDEX idx_step7_stage_cell ON private.step7_fact_stage USING btree (report_type, source_sheet_index, cell_ref);
CREATE INDEX idx_step7_stage_lookup ON private.step7_fact_stage USING btree (report_type, source_sheet_index);
CREATE INDEX idx_step7_rejections_sheet ON private.step7_rejections USING btree (report_type, source_sheet_index);
CREATE INDEX idx_criminal_offense_records_offense_version ON public.criminal_offense_records USING btree (criminal_offense_version_id);
CREATE INDEX idx_criminal_offense_records_source_cell ON public.criminal_offense_records USING btree (source_cell_id);
CREATE INDEX idx_criminal_records_personnel ON public.criminal_offense_records USING btree (personnel_category_id);
CREATE INDEX idx_criminal_records_pomdam ON public.criminal_offense_records USING btree (pomdam_id);
CREATE INDEX idx_gakkum_activity_versions_parent ON public.gakkum_activity_versions USING btree (parent_version_id);
CREATE INDEX idx_gakkum_records_activity_version ON public.gakkum_records USING btree (activity_version_id);
CREATE INDEX idx_gakkum_records_pomdam ON public.gakkum_records USING btree (pomdam_id);
CREATE INDEX idx_gakkum_records_source_cell ON public.gakkum_records USING btree (source_cell_id);
CREATE INDEX idx_laka_accident_pomdam ON public.laka_accident_records USING btree (pomdam_id);
CREATE INDEX idx_laka_accident_records_source_cell ON public.laka_accident_records USING btree (source_cell_id);
CREATE INDEX idx_laka_accident_records_type ON public.laka_accident_records USING btree (accident_type_id);
CREATE INDEX idx_laka_material_pomdam ON public.laka_material_records USING btree (pomdam_id);
CREATE INDEX idx_laka_material_records_damage_type ON public.laka_material_records USING btree (material_damage_type_id);
CREATE INDEX idx_laka_material_records_source_cell ON public.laka_material_records USING btree (source_cell_id);
CREATE INDEX idx_laka_material_vehicle ON public.laka_material_records USING btree (vehicle_category_id);
CREATE INDEX idx_laka_personnel_pomdam ON public.laka_personnel_records USING btree (pomdam_id);
CREATE INDEX idx_laka_personnel_records_personnel ON public.laka_personnel_records USING btree (personnel_category_id);
CREATE INDEX idx_laka_personnel_records_source_cell ON public.laka_personnel_records USING btree (source_cell_id);
CREATE INDEX idx_laka_victim_outcome_pomdam ON public.laka_victim_outcome_records USING btree (pomdam_id);
CREATE INDEX idx_laka_victim_outcome_records_outcome ON public.laka_victim_outcome_records USING btree (victim_outcome_id);
CREATE INDEX idx_laka_victim_outcome_records_source_cell ON public.laka_victim_outcome_records USING btree (source_cell_id);
CREATE INDEX idx_laka_victim_rank_pomdam ON public.laka_victim_rank_records USING btree (pomdam_id);
CREATE INDEX idx_laka_victim_rank_records_personnel ON public.laka_victim_rank_records USING btree (personnel_category_id);
CREATE INDEX idx_laka_victim_rank_records_source_cell ON public.laka_victim_rank_records USING btree (source_cell_id);
CREATE INDEX idx_provos_education_pomdam ON public.provos_education_records USING btree (pomdam_id);
CREATE INDEX idx_provos_education_records_source_cell ON public.provos_education_records USING btree (source_cell_id);
CREATE INDEX idx_provos_education_records_status ON public.provos_education_records USING btree (education_status_id);
CREATE INDEX idx_provos_personnel_category ON public.provos_personnel_records USING btree (personnel_category_id);
CREATE INDEX idx_provos_personnel_pomdam ON public.provos_personnel_records USING btree (pomdam_id);
CREATE INDEX idx_provos_personnel_records_source_cell ON public.provos_personnel_records USING btree (source_cell_id);
CREATE INDEX idx_provos_strength_pomdam ON public.provos_strength_records USING btree (pomdam_id);
CREATE INDEX idx_provos_strength_records_measure ON public.provos_strength_records USING btree (strength_measure_id);
CREATE INDEX idx_provos_strength_records_source_cell ON public.provos_strength_records USING btree (source_cell_id);
CREATE UNIQUE INDEX report_periods_period_dates_unique ON public.report_periods USING btree (period_start, period_end) WHERE ((period_start IS NOT NULL) AND (period_end IS NOT NULL));
CREATE INDEX idx_report_provenance_report ON public.report_provenance USING btree (source_report_id);
CREATE INDEX report_submissions_period_pomdam_idx ON public.report_submissions USING btree (period_id, pomdam_id);
CREATE INDEX report_submissions_pomdam_id_idx ON public.report_submissions USING btree (pomdam_id);
CREATE INDEX report_submissions_submitted_by_idx ON public.report_submissions USING btree (submitted_by);
CREATE INDEX idx_sim_records_pomdam ON public.sim_records USING btree (pomdam_id);
CREATE INDEX idx_sim_records_sim_type ON public.sim_records USING btree (sim_type_id);
CREATE INDEX idx_sim_records_source_cell ON public.sim_records USING btree (source_cell_id);
CREATE INDEX idx_source_pomdam_occurrences_pomdam ON public.source_pomdam_occurrences USING btree (pomdam_id);
CREATE INDEX idx_source_pomdam_occurrences_report ON public.source_pomdam_occurrences USING btree (source_report_id);
CREATE INDEX idx_source_pomdam_occurrences_status ON public.source_pomdam_occurrences USING btree (mapping_status);
CREATE INDEX source_report_files_available_idx ON public.source_report_files USING btree (bucket_id, object_path) WHERE (availability_status = 'AVAILABLE'::text);
CREATE INDEX source_report_files_source_report_id_idx ON public.source_report_files USING btree (source_report_id);
CREATE INDEX idx_source_report_pomdams_pomdam ON public.source_report_pomdams USING btree (pomdam_id);
CREATE INDEX idx_source_reports_duplicate ON public.source_reports USING btree (duplicate_of_id);
CREATE INDEX idx_source_reports_period ON public.source_reports USING btree (period_id);
CREATE INDEX idx_source_reports_type ON public.source_reports USING btree (report_type_id);
CREATE INDEX idx_violation_records_personnel ON public.violation_records USING btree (personnel_category_id);
CREATE INDEX idx_violation_records_pomdam ON public.violation_records USING btree (pomdam_id);
CREATE INDEX idx_violation_records_source_cell ON public.violation_records USING btree (source_cell_id);
CREATE INDEX idx_violation_records_violation_version ON public.violation_records USING btree (violation_version_id);
CREATE OR REPLACE FUNCTION private.has_current_capability(p_capability_code text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select exists (
    select 1
    from private.app_user_roles ur
    join private.app_role_capabilities rc
      on rc.role_code = ur.role_code
     and rc.active = true
    join private.app_capabilities c
      on c.capability_code = rc.capability_code
     and c.active = true
    where ur.user_id = (select auth.uid())
      and ur.active = true
      and rc.capability_code = p_capability_code
  )
$function$;

CREATE OR REPLACE FUNCTION private.can_read_pomdam(p_pomdam_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select case
    when (select auth.uid()) is null then false
    when exists (
      select 1
      from private.app_user_roles ur
      join private.app_roles r
        on r.role_code = ur.role_code
       and r.active = true
      where ur.user_id = (select auth.uid())
        and ur.active = true
        and r.scope_type = 'ALL_POMDAM'
    ) then true
    when p_pomdam_id is null then exists (
      select 1
      from private.app_user_pomdam_scopes s
      where s.user_id = (select auth.uid())
        and s.active = true
    )
    else exists (
      select 1
      from private.app_user_pomdam_scopes s
      where s.user_id = (select auth.uid())
        and s.pomdam_id = p_pomdam_id
        and s.active = true
    )
  end
$function$;

CREATE OR REPLACE FUNCTION private.current_user_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select ur.role_code
  from private.app_user_roles ur
  join private.app_roles r
    on r.role_code = ur.role_code
   and r.active = true
  where ur.user_id = (select auth.uid())
    and ur.active = true
  limit 1
$function$;

CREATE OR REPLACE FUNCTION private.assert_can_read_pomdam(p_pomdam_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not private.can_read_pomdam(p_pomdam_id) then
    raise exception 'Access to requested POMDAM scope is not authorized'
      using errcode='42501';
  end if;
  return true;
end
$function$;

CREATE OR REPLACE FUNCTION private.assert_commander_access(p_pomdam_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not private.has_current_capability('VIEW_COMMANDER_COP') then
    raise exception 'Commander access is not authorized'
      using errcode='42501';
  end if;

  if p_pomdam_id is null then
    if not exists (
      select 1
      from private.app_user_roles ur
      join private.app_roles r
        on r.role_code = ur.role_code
       and r.active = true
      join private.app_role_capabilities rc
        on rc.role_code = r.role_code
       and rc.capability_code = 'VIEW_COMMANDER_COP'
       and rc.active = true
      where ur.user_id = (select auth.uid())
        and ur.active = true
        and r.scope_type = 'ALL_POMDAM'
    ) then
      raise exception 'All-POMDAM Commander scope is not authorized'
        using errcode='42501';
    end if;
  elsif not private.can_read_pomdam(p_pomdam_id) then
    raise exception 'Access to requested POMDAM scope is not authorized'
      using errcode='42501';
  end if;

  return true;
end
$function$;

CREATE OR REPLACE FUNCTION private.assert_current_role()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if (select auth.uid()) is null or (select private.current_user_role()) is null then
    raise exception 'Application authorization context is not configured'
      using errcode='42501';
  end if;
  return true;
end
$function$;

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
$function$;

CREATE OR REPLACE FUNCTION private.can_read_source_file_object(p_object_path text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select
    (select auth.uid()) is not null
    and private.has_current_capability('VIEW_COMMANDER_COP')
    and exists (
      select 1
      from public.source_report_files f
      join public.source_reports sr
        on sr.id = f.source_report_id
      where f.bucket_id = 'source-workbooks'
        and f.object_path = p_object_path
        and f.availability_status = 'AVAILABLE'
        and f.access_scope = 'ALL_POMDAM_SHARED'
        and exists (
          select 1
          from private.app_user_roles ur
          join private.app_roles r
            on r.role_code = ur.role_code
           and r.active = true
           and r.scope_type = 'ALL_POMDAM'
          where ur.user_id = (select auth.uid())
            and ur.active = true
        )
    )
$function$;

CREATE OR REPLACE FUNCTION private.can_read_source_report(p_source_report_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select case
    when (select auth.uid()) is null then false
    when exists (
      select 1
      from private.app_user_roles ur
      join private.app_roles r
        on r.role_code = ur.role_code
       and r.active = true
      where ur.user_id = (select auth.uid())
        and ur.active = true
        and r.scope_type = 'ALL_POMDAM'
    ) then true
    when not exists (
      select 1
      from public.source_report_pomdams x
      where x.source_report_id = p_source_report_id
    ) then false
    else not exists (
      select 1
      from public.source_report_pomdams x
      where x.source_report_id = p_source_report_id
        and not private.can_read_pomdam(x.pomdam_id)
    )
  end
$function$;

CREATE OR REPLACE FUNCTION private.get_commander_fact_provenance_impl(p_domain_code text, p_record_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_domain text := upper(trim(p_domain_code));
  v_pomdam_id uuid;
  v_period_id uuid;
  v_source_cell_id uuid;
  v_payload jsonb;
begin
  if not private.has_current_capability('VIEW_COMMANDER_COP') then
    raise exception 'Commander access is not authorized'
      using errcode='42501';
  end if;

  if v_domain not in (
    'GAKKUM','PELANGGARAN','SIM_TNI','PROVOS','LAKA_LALIN','TINDAK_PIDANA'
  ) then
    raise exception 'Unsupported Commander drill-down domain'
      using errcode='22023';
  end if;

  if v_domain='GAKKUM' then
    select r.pomdam_id,r.period_id,r.source_cell_id
      into v_pomdam_id,v_period_id,v_source_cell_id
    from public.gakkum_records r
    where r.id=p_record_id;
  elsif v_domain='PELANGGARAN' then
    select r.pomdam_id,r.period_id,r.source_cell_id
      into v_pomdam_id,v_period_id,v_source_cell_id
    from public.violation_records r
    where r.id=p_record_id;
  elsif v_domain='SIM_TNI' then
    select r.pomdam_id,r.period_id,r.source_cell_id
      into v_pomdam_id,v_period_id,v_source_cell_id
    from public.sim_records r
    where r.id=p_record_id;
  elsif v_domain='PROVOS' then
    select x.pomdam_id,x.period_id,x.source_cell_id
      into v_pomdam_id,v_period_id,v_source_cell_id
    from (
      select r.id,r.pomdam_id,r.period_id,r.source_cell_id from public.provos_strength_records r
      union all
      select r.id,r.pomdam_id,r.period_id,r.source_cell_id from public.provos_personnel_records r
      union all
      select r.id,r.pomdam_id,r.period_id,r.source_cell_id from public.provos_education_records r
    ) x
    where x.id=p_record_id;
  elsif v_domain='LAKA_LALIN' then
    select r.pomdam_id,r.period_id,r.source_cell_id
      into v_pomdam_id,v_period_id,v_source_cell_id
    from public.laka_accident_records r
    where r.id=p_record_id;
  else
    select r.pomdam_id,r.period_id,r.source_cell_id
      into v_pomdam_id,v_period_id,v_source_cell_id
    from public.criminal_offense_records r
    where r.id=p_record_id;
  end if;

  if v_pomdam_id is null
     or not private.can_read_pomdam(v_pomdam_id) then
    raise exception 'Fact record is not accessible for the current scope'
      using errcode='42501';
  end if;

  select jsonb_build_object(
    'record_id', p_record_id,
    'domain', v_domain,
    'pomdam', jsonb_build_object(
      'id', p.id,
      'code', p.code,
      'short_name', p.short_name,
      'full_name', p.pomdam_full_name
    ),
    'period', jsonb_build_object(
      'id', rp.id,
      'label', rp.period_label,
      'start', rp.period_start,
      'end', rp.period_end
    ),
    'source', case
      when sc.id is null then
        jsonb_build_object(
          'status', 'NO_SOURCE_CELL',
          'source_cell_id', null,
          'source_report_id', null
        )
      else
        jsonb_build_object(
          'status', 'FOUND',
          'source_cell_id', sc.id,
          'source_report_id', sc.source_report_id,
          'cell', jsonb_build_object(
            'ref', sc.cell_ref,
            'row_number', sc.row_number,
            'column_letter', sc.column_letter,
            'raw_value', sc.raw_value,
            'formula_text', sc.formula_text,
            'parsed_numeric', sc.parsed_numeric,
            'data_status', sc.data_status,
            'semantic_role', sc.semantic_role,
            'row_label', sc.row_label,
            'column_label', sc.column_label
          ),
          'workbook', case
            when sr.id is null then null
            else jsonb_build_object(
              'id', sr.id,
              'name', sr.workbook_name,
              'sheet', sr.sheet_name,
              'sheet_index', sr.source_sheet_index,
              'import_status', sr.import_status,
              'sheet_state', sr.sheet_state,
              'sheet_role', sr.sheet_role,
              'period_resolution_status', sr.period_resolution_status
            )
          end
        )
    end
  )
  into v_payload
  from public.pomdams p
  join public.report_periods rp on rp.id=v_period_id
  left join private.source_cells sc on sc.id=v_source_cell_id
  left join public.source_reports sr on sr.id=sc.source_report_id
  where p.id=v_pomdam_id;

  if v_payload is null then
    raise exception 'Fact record is not accessible for the current scope'
      using errcode='42501';
  end if;

  return v_payload;
end
$function$;

CREATE OR REPLACE FUNCTION private.get_commander_source_file_context_impl(p_domain_code text, p_record_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_domain text := upper(trim(p_domain_code));
  v_trace jsonb;
  v_source jsonb;
  v_source_report_id uuid;
  v_file jsonb;
begin
  if not private.has_current_capability('VIEW_COMMANDER_COP') then
    raise exception 'Commander access is not authorized'
      using errcode = '42501';
  end if;

  v_trace := private.get_commander_fact_provenance_impl(
    p_domain_code,
    p_record_id
  );

  v_source := v_trace->'source';
  v_source_report_id :=
    nullif(v_source->>'source_report_id', '')::uuid;

  if v_source_report_id is null then
    return jsonb_build_object(
      'schema_version', 1,
      'status', 'NO_SOURCE_CELL',
      'record_id', p_record_id,
      'domain', v_domain,
      'source_report_id', null,
      'file', null
    );
  end if;

  select jsonb_build_object(
    'id', f.id,
    'bucket_id', f.bucket_id,
    'object_path', f.object_path,
    'original_filename', f.original_filename,
    'content_type', f.content_type,
    'byte_size', f.byte_size,
    'file_sha256', f.file_sha256,
    'availability_status', f.availability_status,
    'access_scope', f.access_scope,
    'created_at', f.created_at
  )
  into v_file
  from public.source_report_files f
  where f.source_report_id = v_source_report_id;

  if v_file is null then
    return jsonb_build_object(
      'schema_version', 1,
      'status', 'NO_SOURCE_FILE',
      'record_id', p_record_id,
      'domain', v_domain,
      'source_report_id', v_source_report_id,
      'workbook', v_source->'workbook',
      'file', null
    );
  end if;

  if v_file->>'access_scope' <> 'ALL_POMDAM_SHARED'
     or not exists (
       select 1
       from private.app_user_roles ur
       join private.app_roles r
         on r.role_code = ur.role_code
        and r.active = true
        and r.scope_type = 'ALL_POMDAM'
       where ur.user_id = (select auth.uid())
         and ur.active = true
     ) then
    return jsonb_build_object(
      'schema_version', 1,
      'status', 'SOURCE_FILE_SCOPE_RESTRICTED',
      'record_id', p_record_id,
      'domain', v_domain,
      'source_report_id', v_source_report_id,
      'workbook', v_source->'workbook',
      'file', null,
      'access_scope', v_file->>'access_scope'
    );
  end if;

  if v_file->>'availability_status' <> 'AVAILABLE' then
    return jsonb_build_object(
      'schema_version', 1,
      'status', 'NO_SOURCE_FILE',
      'record_id', p_record_id,
      'domain', v_domain,
      'source_report_id', v_source_report_id,
      'workbook', v_source->'workbook',
      'file', jsonb_build_object(
        'id', v_file->'id',
        'original_filename', v_file->'original_filename',
        'content_type', v_file->'content_type',
        'byte_size', v_file->'byte_size',
        'availability_status', v_file->'availability_status',
        'access_scope', v_file->'access_scope'
      )
    );
  end if;

  return jsonb_build_object(
    'schema_version', 1,
    'status', 'FOUND',
    'record_id', p_record_id,
    'domain', v_domain,
    'source_report_id', v_source_report_id,
    'workbook', v_source->'workbook',
    'file', v_file
  );
end
$function$;

CREATE OR REPLACE FUNCTION private.get_commander_source_sheet_context_impl(p_domain_code text, p_record_id uuid, p_row_radius integer DEFAULT 4)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_trace jsonb;
  v_source jsonb;
  v_cell jsonb;
  v_workbook jsonb;
  v_source_cell_id uuid;
  v_source_report_id uuid;
  v_pomdam_id uuid;
  v_target_row integer;
  v_target_column text;
  v_row_radius integer := greatest(0, least(coalesce(p_row_radius, 4), 8));
  v_all_scope boolean;
  v_cells jsonb := '[]'::jsonb;
begin
  if not private.has_current_capability('VIEW_COMMANDER_COP') then
    raise exception 'Commander access is not authorized'
      using errcode='42501';
  end if;

  v_trace := private.get_commander_fact_provenance_impl(
    p_domain_code,
    p_record_id
  );

  v_source := v_trace->'source';
  v_source_cell_id := nullif(v_source->>'source_cell_id','')::uuid;
  v_source_report_id := nullif(v_source->>'source_report_id','')::uuid;
  v_cell := v_source->'cell';
  v_workbook := v_source->'workbook';
  v_target_row := (v_cell->>'row_number')::integer;
  v_target_column := nullif(v_cell->>'column_letter','');

  if v_source_cell_id is null
     or v_source_report_id is null
     or v_target_row is null
     or v_target_column is null then
    return jsonb_build_object(
      'schema_version', 1,
      'status', 'NO_SOURCE_CELL',
      'record_id', p_record_id,
      'domain', upper(trim(p_domain_code)),
      'context_mode', 'NONE',
      'workbook', coalesce(v_workbook, 'null'::jsonb),
      'target', coalesce(v_cell, 'null'::jsonb),
      'cells', '[]'::jsonb
    );
  end if;

  select exists (
    select 1
    from private.app_user_roles ur
    join private.app_roles r
      on r.role_code = ur.role_code
     and r.active = true
     and r.scope_type = 'ALL_POMDAM'
    where ur.user_id = (select auth.uid())
      and ur.active = true
  )
  into v_all_scope;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', sc.id,
        'source_report_id', sc.source_report_id,
        'cell_ref', sc.cell_ref,
        'row_number', sc.row_number,
        'column_letter', sc.column_letter,
        'raw_value', sc.raw_value,
        'formula_text', sc.formula_text,
        'parsed_numeric', sc.parsed_numeric,
        'data_status', sc.data_status,
        'semantic_role', sc.semantic_role,
        'row_label', sc.row_label,
        'column_label', sc.column_label,
        'is_target', sc.id = v_source_cell_id
      )
      order by sc.row_number, sc.column_letter
    ),
    '[]'::jsonb
  )
  into v_cells
  from private.source_cells sc
  where sc.source_report_id = v_source_report_id
    and sc.row_number between v_target_row - v_row_radius
                            and v_target_row + v_row_radius
    and (
      v_all_scope
      or sc.column_letter = v_target_column
    );

  return jsonb_build_object(
    'schema_version', 1,
    'status', 'FOUND',
    'record_id', p_record_id,
    'domain', upper(trim(p_domain_code)),
    'context_mode',
      case when v_all_scope then 'ALL_POMDAM_CONTEXT'
           else 'POMDAM_CELL_CONTEXT'
      end,
    'workbook', v_workbook,
    'target', v_cell,
    'row_radius', v_row_radius,
    'cells', v_cells
  );
end
$function$;

CREATE OR REPLACE FUNCTION private.get_my_access_context_impl()
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with me as (
    select (select auth.uid()) as user_id
  ),
  role_info as (
    select
      ur.role_code,
      r.display_name,
      r.scope_type
    from private.app_user_roles ur
    join private.app_roles r
      on r.role_code = ur.role_code
     and r.active = true
    where ur.user_id = (select user_id from me)
      and ur.active = true
    limit 1
  ),
  role_capabilities as (
    select coalesce(
      jsonb_agg(rc.capability_code order by rc.capability_code)
        filter (where c.active = true and rc.active = true),
      '[]'::jsonb
    ) as capabilities
    from private.app_role_capabilities rc
    join private.app_capabilities c
      on c.capability_code = rc.capability_code
    where rc.role_code = (select role_code from role_info)
  ),
  scoped_pomdams as (
    select s.pomdam_id
    from private.app_user_pomdam_scopes s
    where s.user_id = (select user_id from me)
      and s.active = true
    order by s.pomdam_id
  )
  select case
    when (select user_id from me) is null then
      jsonb_build_object(
        'schema_version', 2,
        'authenticated', false,
        'configured', false,
        'role', null,
        'scope', jsonb_build_object(
          'type', null,
          'pomdam_ids', jsonb_build_array()
        ),
        'capabilities', jsonb_build_array()
      )
    when not exists (select 1 from role_info) then
      jsonb_build_object(
        'schema_version', 2,
        'authenticated', true,
        'configured', false,
        'role', null,
        'scope', jsonb_build_object(
          'type', null,
          'pomdam_ids', jsonb_build_array()
        ),
        'capabilities', jsonb_build_array()
      )
    when (select scope_type from role_info) = 'ALL_POMDAM' then
      jsonb_build_object(
        'schema_version', 2,
        'authenticated', true,
        'configured', true,
        'role', jsonb_build_object(
          'code', (select role_code from role_info),
          'display_name', (select display_name from role_info)
        ),
        'scope', jsonb_build_object(
          'type', 'ALL_POMDAM',
          'pomdam_ids', jsonb_build_array()
        ),
        'capabilities', (select capabilities from role_capabilities)
      )
    else
      jsonb_build_object(
        'schema_version', 2,
        'authenticated', true,
        'configured', exists (select 1 from scoped_pomdams),
        'role', jsonb_build_object(
          'code', (select role_code from role_info),
          'display_name', (select display_name from role_info)
        ),
        'scope', jsonb_build_object(
          'type', 'POMDAM',
          'pomdam_ids', coalesce(
            (select jsonb_agg(pomdam_id) from scoped_pomdams),
            jsonb_build_array()
          )
        ),
        'capabilities', (select capabilities from role_capabilities)
      )
  end
$function$;

CREATE OR REPLACE FUNCTION private.sync_report_provenance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM public.report_provenance
    WHERE source_cell_id = OLD.id;
    RETURN OLD;
  END IF;

  INSERT INTO public.report_provenance (
    source_cell_id,
    source_report_id,
    cell_ref,
    row_number,
    column_letter,
    raw_value,
    formula_text,
    parsed_numeric,
    data_status,
    semantic_role,
    row_label,
    column_label,
    created_at
  )
  VALUES (
    NEW.id,
    NEW.source_report_id,
    NEW.cell_ref,
    NEW.row_number,
    NEW.column_letter,
    NEW.raw_value,
    NEW.formula_text,
    NEW.parsed_numeric,
    NEW.data_status,
    NEW.semantic_role,
    NEW.row_label,
    NEW.column_label,
    NEW.created_at
  )
  ON CONFLICT (source_cell_id) DO UPDATE SET
    source_report_id = EXCLUDED.source_report_id,
    cell_ref = EXCLUDED.cell_ref,
    row_number = EXCLUDED.row_number,
    column_letter = EXCLUDED.column_letter,
    raw_value = EXCLUDED.raw_value,
    formula_text = EXCLUDED.formula_text,
    parsed_numeric = EXCLUDED.parsed_numeric,
    data_status = EXCLUDED.data_status,
    semantic_role = EXCLUDED.semantic_role,
    row_label = EXCLUDED.row_label,
    column_label = EXCLUDED.column_label;

  RETURN NEW;
END;
$function$;

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
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_domain_drilldown(p_domain_code text, p_pomdam_id uuid DEFAULT NULL::uuid, p_dimension_code text DEFAULT NULL::text, p_limit integer DEFAULT 50)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);

with requested as (
  select upper(trim(p_domain_code)) as domain_code,
         greatest(1, least(coalesce(p_limit, 50), 200)) as row_limit
),
latest as (
  select rp.id, rp.period_label, rp.period_start, rp.period_end
  from public.report_periods rp
  cross join requested q
  where (
    q.domain_code='GAKKUM'
    and exists (
      select 1 from public.gakkum_records r
      where r.period_id=rp.id
        and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
    )
  ) or (
    q.domain_code='PELANGGARAN'
    and exists (
      select 1 from public.violation_records r
      where r.period_id=rp.id
        and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
    )
  ) or (
    q.domain_code='SIM_TNI'
    and exists (
      select 1 from public.sim_records r
      where r.period_id=rp.id
        and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
    )
  ) or (
    q.domain_code='PROVOS'
    and (
      exists (select 1 from public.provos_strength_records r
              where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
      or exists (select 1 from public.provos_personnel_records r
                 where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
      or exists (select 1 from public.provos_education_records r
                 where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
    )
  ) or (
    q.domain_code='LAKA_LALIN'
    and exists (
      select 1 from public.laka_accident_records r
      where r.period_id=rp.id
        and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
    )
  ) or (
    q.domain_code='TINDAK_PIDANA'
    and exists (
      select 1 from public.criminal_offense_records r
      where r.period_id=rp.id
        and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
    )
  )
  order by rp.period_start desc nulls last, rp.created_at desc
  limit 1
),
facts as (
  select
    r.id record_id, r.pomdam_id, r.period_id,
    coalesce(v.source_code, a.code) dimension_code,
    coalesce(v.source_label, a.canonical_name) dimension_name,
    'ACTIVITY' dimension_group,
    null::text secondary_code, null::text secondary_name,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.gakkum_records r
  join public.gakkum_activity_versions v on v.id=r.activity_version_id
  join public.gakkum_activities a on a.id=v.activity_id
  join requested q on q.domain_code='GAKKUM'
  join latest l on l.id=r.period_id
  where not exists (
    select 1
    from public.gakkum_records cr
    join public.gakkum_activity_versions cv on cv.id=cr.activity_version_id
    where cr.period_id=r.period_id
      and cr.pomdam_id=r.pomdam_id
      and cv.parent_version_id=v.id
  )
    and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    coalesce(v.source_code, vio.canonical_code),
    coalesce(v.source_label, vio.canonical_name),
    'VIOLATION',
    pc.code, pc.name,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.violation_records r
  join public.violation_versions v on v.id=r.violation_version_id
  join public.violations vio on vio.id=v.violation_id
  left join public.personnel_categories pc on pc.id=r.personnel_category_id
  join requested q on q.domain_code='PELANGGARAN'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    st.code, st.display_name,
    'SIM_TYPE',
    null::text, null::text,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.sim_records r
  join public.sim_types st on st.id=r.sim_type_id
  join requested q on q.domain_code='SIM_TNI'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    sm.code, sm.name,
    'STRENGTH',
    null::text, null::text,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.provos_strength_records r
  join public.provos_strength_measures sm on sm.id=r.strength_measure_id
  join requested q on q.domain_code='PROVOS'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    pc.code, pc.name,
    'PERSONNEL',
    null::text, null::text,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.provos_personnel_records r
  join public.personnel_categories pc on pc.id=r.personnel_category_id
  join requested q on q.domain_code='PROVOS'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    es.code, es.name,
    'EDUCATION',
    null::text, null::text,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.provos_education_records r
  join public.education_statuses es on es.id=r.education_status_id
  join requested q on q.domain_code='PROVOS'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    at.code, at.name,
    'ACCIDENT_TYPE',
    null::text, null::text,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.laka_accident_records r
  join public.accident_types at on at.id=r.accident_type_id
  join requested q on q.domain_code='LAKA_LALIN'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)

  union all

  select
    r.id, r.pomdam_id, r.period_id,
    co.canonical_key, co.canonical_name,
    'OFFENSE',
    pc.code, pc.name,
    r.value, r.data_status, r.source_cell_id, r.notes
  from public.criminal_offense_records r
  join public.criminal_offense_versions cv on cv.id=r.criminal_offense_version_id
  join public.criminal_offenses co on co.id=cv.offense_id
  left join public.personnel_categories pc on pc.id=r.personnel_category_id
  join requested q on q.domain_code='TINDAK_PIDANA'
  join latest l on l.id=r.period_id
  where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
),
dimension_rows as (
  select
    f.dimension_code,
    max(f.dimension_name) dimension_name,
    f.dimension_group,
    count(*)::bigint fact_rows,
    count(*) filter(where f.data_status='VALID')::bigint valid_rows,
    count(*) filter(where f.data_status='NOT_REPORTED')::bigint not_reported_rows,
    count(*) filter(where f.data_status='INVALID_SOURCE')::bigint invalid_source_rows,
    count(*) filter(where f.data_status='ESTIMATED')::bigint estimated_rows,
    coalesce(sum(f.value) filter(where f.data_status='VALID'),0)::bigint valid_total
  from facts f
  where p_dimension_code is null or f.dimension_code=p_dimension_code
  group by f.dimension_code, f.dimension_group
),
record_rows as (
  select
    f.record_id,
    f.pomdam_id,
    p.code pomdam_code,
    p.short_name pomdam_short_name,
    f.period_id,
    l.period_label,
    f.dimension_code,
    f.dimension_name,
    f.dimension_group,
    f.secondary_code,
    f.secondary_name,
    f.value,
    f.data_status,
    f.source_cell_id,
    f.notes
  from facts f
  join public.pomdams p on p.id=f.pomdam_id
  join latest l on l.id=f.period_id
  where p_dimension_code is null or f.dimension_code=p_dimension_code
  order by p.report_order, f.dimension_group, f.dimension_code, f.record_id
  limit (select row_limit from requested)
)
select jsonb_build_object(
  'schema_version', 1,
  'domain', (select domain_code from requested),
  'domain_name', case (select domain_code from requested)
    when 'GAKKUM' then 'GAKKUM'
    when 'PELANGGARAN' then 'PELANGGARAN'
    when 'SIM_TNI' then 'SIM TNI'
    when 'PROVOS' then 'PROVOS'
    when 'LAKA_LALIN' then 'LAKA LALIN'
    when 'TINDAK_PIDANA' then 'TINDAK PIDANA'
    else (select domain_code from requested)
  end,
  'scope', jsonb_build_object(
    'type', case when p_pomdam_id is null then 'ALL_POMDAM' else 'POMDAM' end,
    'pomdam_id', p_pomdam_id,
    'pomdam', (
      select jsonb_build_object(
        'id', p.id,
        'code', p.code,
        'short_name', p.short_name,
        'full_name', p.pomdam_full_name
      )
      from public.pomdams p
      where p.id=p_pomdam_id
    )
  ),
  'as_of', (
    select jsonb_build_object(
      'id', id,
      'label', period_label,
      'start', period_start,
      'end', period_end
    )
    from latest
  ),
  'selected_dimension_code', p_dimension_code,
  'dimensions', coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'code', dimension_code,
        'name', dimension_name,
        'group', dimension_group,
        'fact_rows', fact_rows,
        'valid_rows', valid_rows,
        'not_reported_rows', not_reported_rows,
        'invalid_source_rows', invalid_source_rows,
        'estimated_rows', estimated_rows,
        'valid_total', valid_total
      )
      order by dimension_group, valid_total desc, dimension_code
    )
    from dimension_rows
  ), '[]'::jsonb),
  'records', coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'record_id', record_id,
        'pomdam_id', pomdam_id,
        'pomdam_code', pomdam_code,
        'pomdam_short_name', pomdam_short_name,
        'period_id', period_id,
        'period_label', period_label,
        'dimension_code', dimension_code,
        'dimension_name', dimension_name,
        'dimension_group', dimension_group,
        'secondary_code', secondary_code,
        'secondary_name', secondary_name,
        'value', value,
        'data_status', data_status,
        'source_cell_id', source_cell_id,
        'notes', notes
      )
    )
    from record_rows
  ), '[]'::jsonb),
  'rules', jsonb_build_object(
    'not_reported_is_zero', false,
    'fact_rows_are_operational_counts', false,
    'source_cell_is_scoped_to_fact', true
  )
)
from requested;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_fact_provenance(p_domain_code text, p_record_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select private.get_commander_fact_provenance_impl(p_domain_code,p_record_id)
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_gakkum_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with latest as (
  select rp.id, rp.period_label, rp.period_start, rp.period_end
  from report_periods rp
  where exists (
    select 1 from gakkum_records r
    where r.period_id=rp.id
      and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
  )
  order by rp.period_start desc nulls last, rp.created_at desc
  limit 1
),
leaf as (
  select r.period_id,r.pomdam_id,r.value,r.data_status,r.activity_version_id
  from gakkum_records r
  join gakkum_activity_versions v on v.id=r.activity_version_id
  where not exists (
    select 1 from gakkum_records cr
    join gakkum_activity_versions cv on cv.id=cr.activity_version_id
    where cr.period_id=r.period_id
      and cr.pomdam_id=r.pomdam_id
      and cv.parent_version_id=v.id
  )
  and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
),
current_stats as (
  select
    count(*)::bigint fact_rows,
    count(*) filter(where l.data_status='VALID')::bigint valid_rows,
    count(*) filter(where l.data_status='NOT_REPORTED')::bigint not_reported_rows,
    count(*) filter(where l.data_status='INVALID_SOURCE')::bigint invalid_source_rows,
    count(*) filter(where l.data_status='ESTIMATED')::bigint estimated_rows,
    coalesce(sum(l.value) filter(where l.data_status='VALID'),0)::bigint value
  from leaf l join latest x on x.id=l.period_id
),
history as (
  select rp.id,rp.period_label,rp.period_start,
    coalesce(sum(l.value) filter(where l.data_status='VALID'),0)::bigint value
  from report_periods rp
  join leaf l on l.period_id=rp.id
  group by rp.id,rp.period_label,rp.period_start
),
top_items as (
  select jsonb_agg(
    jsonb_build_object('code',a.code,'name',a.canonical_name,'value',x.value)
    order by x.value desc,a.canonical_name
  ) items
  from (
    select r.activity_version_id,
           coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
    from gakkum_records r
    join latest lp on lp.id=r.period_id
    join gakkum_activity_versions v on v.id=r.activity_version_id
    where (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
      and not exists(
        select 1 from gakkum_records cr
        join gakkum_activity_versions cv on cv.id=cr.activity_version_id
        where cr.period_id=r.period_id and cr.pomdam_id=r.pomdam_id
          and cv.parent_version_id=v.id
      )
    group by r.activity_version_id
    order by value desc
    limit 5
  ) x
  join gakkum_activity_versions v on v.id=x.activity_version_id
  join gakkum_activities a on a.id=v.activity_id
)
select jsonb_build_object(
  'code','GAKKUM',
  'name','Statistik Giat Gakkum',
  'as_of',coalesce((select jsonb_build_object('id',l.id,'label',l.period_label,'start',l.period_start,'end',l.period_end) from latest l),'null'::jsonb),
  'primary_metric',jsonb_build_object('value',s.value,'label','Kegiatan valid','unit','kegiatan'),
  'supporting_metrics',jsonb_build_object('top_categories',coalesce(t.items,'[]'::jsonb)),
  'trend',jsonb_build_object(
    'available',(select count(*)>=2 from history),
    'series',coalesce((
      select jsonb_agg(jsonb_build_object('period_id',h.id,'period_label',h.period_label,'period_start',h.period_start,'value',h.value) order by h.period_start desc)
      from (select * from history order by period_start desc nulls last limit 12) h
    ),'[]'::jsonb)
  ),
  'data_trust',jsonb_build_object(
    'fact_rows',s.fact_rows,'valid_rows',s.valid_rows,'not_reported_rows',s.not_reported_rows,
    'invalid_source_rows',s.invalid_source_rows,'estimated_rows',s.estimated_rows,
    'valid_pct',case when s.fact_rows=0 then null else round(s.valid_rows::numeric/s.fact_rows*100,2) end
  ),
  'aggregation_rule','SUM VALID leaf records; parent record excluded when child records exist'
)
from current_stats s cross join top_items t;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_laka_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with latest as (
 select rp.id,rp.period_label,rp.period_start,rp.period_end
 from report_periods rp
 where exists(select 1 from laka_accident_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
 order by rp.period_start desc nulls last,rp.created_at desc limit 1
),
stats as (
 select count(*)::bigint fact_rows,
 count(*) filter(where r.data_status='VALID')::bigint valid_rows,
 count(*) filter(where r.data_status='NOT_REPORTED')::bigint not_reported_rows,
 count(*) filter(where r.data_status='INVALID_SOURCE')::bigint invalid_source_rows,
 count(*) filter(where r.data_status='ESTIMATED')::bigint estimated_rows,
 coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
 from laka_accident_records r join latest l on l.id=r.period_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
victims as (
 select
  coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint total,
  coalesce(sum(r.value) filter(where r.data_status='VALID' and vo.code='MD'),0)::bigint md,
  coalesce(sum(r.value) filter(where r.data_status='VALID' and vo.code='LB'),0)::bigint lb,
  coalesce(sum(r.value) filter(where r.data_status='VALID' and vo.code='LR'),0)::bigint lr
 from laka_victim_outcome_records r
 join victim_outcomes vo on vo.id=r.victim_outcome_id
 join latest l on l.id=r.period_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
by_type as (
 select jsonb_agg(jsonb_build_object('code',q.code,'name',q.name,'value',q.value) order by q.value desc,q.display_order) items
 from (
   select at.code,at.name,at.display_order,
          coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
   from laka_accident_records r join latest l on l.id=r.period_id join accident_types at on at.id=r.accident_type_id
   where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
   group by at.code,at.name,at.display_order
 ) q
),
history as (
 select rp.id,rp.period_label,rp.period_start,coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
 from report_periods rp join laka_accident_records r on r.period_id=rp.id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
 group by rp.id,rp.period_label,rp.period_start
)
select jsonb_build_object(
 'code','LAKA_LALIN','name','Statistik Laka Lalin',
 'as_of',(select jsonb_build_object('id',l.id,'label',l.period_label,'start',l.period_start,'end',l.period_end) from latest l),
 'primary_metric',jsonb_build_object('value',s.value,'label','Kejadian valid','unit','kejadian'),
 'supporting_metrics',jsonb_build_object('victims',v.total,'meninggal_dunia',v.md,'luka_berat',v.lb,'luka_ringan',v.lr,'accident_types',coalesce(b.items,'[]'::jsonb)),
 'trend',jsonb_build_object(
   'available',(select count(*)>=2 from history),
   'series',coalesce((select jsonb_agg(jsonb_build_object('period_id',h.id,'period_label',h.period_label,'period_start',h.period_start,'value',h.value) order by h.period_start desc) from (select * from history order by period_start desc nulls last limit 12) h),'[]'::jsonb)
 ),
 'data_trust',jsonb_build_object(
   'fact_rows',s.fact_rows,'valid_rows',s.valid_rows,'not_reported_rows',s.not_reported_rows,
   'invalid_source_rows',s.invalid_source_rows,'estimated_rows',s.estimated_rows,
   'valid_pct',case when s.fact_rows=0 then null else round(s.valid_rows::numeric/s.fact_rows*100,2) end
 ),
 'aggregation_rule','Primary KPI sums only laka_accident_records VALID values; victims, victim rank, and material are separate measures'
)
from stats s cross join victims v cross join by_type b;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_pelanggaran_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with latest as (
 select rp.id,rp.period_label,rp.period_start,rp.period_end
 from report_periods rp
 where exists(select 1 from violation_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
 order by rp.period_start desc nulls last,rp.created_at desc limit 1
),
stats as (
 select count(*)::bigint fact_rows,
 count(*) filter(where r.data_status='VALID')::bigint valid_rows,
 count(*) filter(where r.data_status='NOT_REPORTED')::bigint not_reported_rows,
 count(*) filter(where r.data_status='INVALID_SOURCE')::bigint invalid_source_rows,
 count(*) filter(where r.data_status='ESTIMATED')::bigint estimated_rows,
 coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
 from violation_records r join latest l on l.id=r.period_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
history as (
 select rp.id,rp.period_label,rp.period_start,coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
 from report_periods rp join violation_records r on r.period_id=rp.id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
 group by rp.id,rp.period_label,rp.period_start
),
top_items as (
 select jsonb_agg(jsonb_build_object('code',q.code,'name',q.name,'category',q.category,'value',q.value)
                  order by q.value desc,q.code) items
 from (
   select vio.canonical_code code,vio.canonical_name name,vio.category,
          coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
   from violation_records r
   join latest l on l.id=r.period_id
   join violation_versions vv on vv.id=r.violation_version_id
   join violations vio on vio.id=vv.violation_id
   where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
   group by vio.canonical_code,vio.canonical_name,vio.category
   order by value desc,vio.canonical_code limit 5
 ) q
)
select jsonb_build_object(
 'code','PELANGGARAN','name','Statistik Pelanggaran',
 'as_of',(select jsonb_build_object('id',l.id,'label',l.period_label,'start',l.period_start,'end',l.period_end) from latest l),
 'primary_metric',jsonb_build_object('value',s.value,'label','Pelanggaran valid','unit','pelanggaran'),
 'supporting_metrics',jsonb_build_object('top_categories',coalesce(t.items,'[]'::jsonb)),
 'trend',jsonb_build_object(
   'available',(select count(*)>=2 from history),
   'series',coalesce((select jsonb_agg(jsonb_build_object('period_id',h.id,'period_label',h.period_label,'period_start',h.period_start,'value',h.value) order by h.period_start desc) from (select * from history order by period_start desc nulls last limit 12) h),'[]'::jsonb)
 ),
 'data_trust',jsonb_build_object(
   'fact_rows',s.fact_rows,'valid_rows',s.valid_rows,'not_reported_rows',s.not_reported_rows,
   'invalid_source_rows',s.invalid_source_rows,'estimated_rows',s.estimated_rows,
   'valid_pct',case when s.fact_rows=0 then null else round(s.valid_rows::numeric/s.fact_rows*100,2) end
 ),
 'aggregation_rule','SUM VALID values across violation x personnel cells; fact rows are not operational counts'
)
from stats s cross join top_items t;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_provos_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with latest as (
 select rp.id,rp.period_label,rp.period_start,rp.period_end
 from report_periods rp
 where exists(select 1 from provos_strength_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
    or exists(select 1 from provos_personnel_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
    or exists(select 1 from provos_education_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
 order by rp.period_start desc nulls last,rp.created_at desc limit 1
),
strength as (
 select
  coalesce(sum(r.value) filter(where r.data_status='VALID' and sm.code='DSPP'),0)::bigint dspp,
  coalesce(sum(r.value) filter(where r.data_status='VALID' and sm.code='NYATA'),0)::bigint nyata
 from provos_strength_records r join latest l on l.id=r.period_id join provos_strength_measures sm on sm.id=r.strength_measure_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
trust as (
 select
   ((select count(*) from provos_strength_records r join latest l on l.id=r.period_id where p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
   +(select count(*) from provos_personnel_records r join latest l on l.id=r.period_id where p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
   +(select count(*) from provos_education_records r join latest l on l.id=r.period_id where p_pomdam_id is null or r.pomdam_id=p_pomdam_id))::bigint fact_rows,
   ((select count(*) from provos_strength_records r join latest l on l.id=r.period_id where r.data_status='VALID' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_personnel_records r join latest l on l.id=r.period_id where r.data_status='VALID' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_education_records r join latest l on l.id=r.period_id where r.data_status='VALID' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)))::bigint valid_rows,
   ((select count(*) from provos_strength_records r join latest l on l.id=r.period_id where r.data_status='NOT_REPORTED' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_personnel_records r join latest l on l.id=r.period_id where r.data_status='NOT_REPORTED' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_education_records r join latest l on l.id=r.period_id where r.data_status='NOT_REPORTED' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)))::bigint not_reported_rows,
   ((select count(*) from provos_strength_records r join latest l on l.id=r.period_id where r.data_status='INVALID_SOURCE' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_personnel_records r join latest l on l.id=r.period_id where r.data_status='INVALID_SOURCE' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_education_records r join latest l on l.id=r.period_id where r.data_status='INVALID_SOURCE' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)))::bigint invalid_source_rows,
   ((select count(*) from provos_strength_records r join latest l on l.id=r.period_id where r.data_status='ESTIMATED' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_personnel_records r join latest l on l.id=r.period_id where r.data_status='ESTIMATED' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
   +(select count(*) from provos_education_records r join latest l on l.id=r.period_id where r.data_status='ESTIMATED' and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)))::bigint estimated_rows
),
education as (
 select
  coalesce(sum(r.value) filter(where r.data_status='VALID' and es.code='SUDAH'),0)::bigint sudah,
  coalesce(sum(r.value) filter(where r.data_status='VALID' and es.code='BELUM'),0)::bigint belum
 from provos_education_records r join latest l on l.id=r.period_id join education_statuses es on es.id=r.education_status_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
history as (
 select rp.id,rp.period_label,rp.period_start,
   coalesce(sum(r.value) filter(where r.data_status='VALID' and sm.code='DSPP'),0)::bigint dspp,
   coalesce(sum(r.value) filter(where r.data_status='VALID' and sm.code='NYATA'),0)::bigint nyata
 from report_periods rp join provos_strength_records r on r.period_id=rp.id
 join provos_strength_measures sm on sm.id=r.strength_measure_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
 group by rp.id,rp.period_label,rp.period_start
),
ratio as (
 select case when dspp=0 then null else round(nyata::numeric/dspp::numeric*100,2) end ratio_pct from strength
)
select jsonb_build_object(
 'code','PROVOS','name','Rekapitulasi Provos TNI AD',
 'as_of',(select jsonb_build_object('id',l.id,'label',l.period_label,'start',l.period_start,'end',l.period_end) from latest l),
 'primary_metric',jsonb_build_object(
   'value',ratio.ratio_pct,
   'numerator',s.nyata,'denominator',s.dspp,
   'ratio_pct',ratio.ratio_pct,
   'label','NYATA / DSPP','unit','percent'
 ),
 'supporting_metrics',jsonb_build_object(
   'nyata',s.nyata,'dspp',s.dspp,
   'education',jsonb_build_object('sudah',e.sudah,'belum',e.belum),
   'personnel',(select coalesce(jsonb_agg(jsonb_build_object('code',pc.code,'value',coalesce(x.value,0)) order by pc.display_order),'[]'::jsonb)
                from personnel_categories pc
                left join lateral(
                  select sum(r.value) filter(where r.data_status='VALID')::bigint value
                  from provos_personnel_records r join latest l on l.id=r.period_id
                  where r.personnel_category_id=pc.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
                ) x on true)
 ),
 'trend',jsonb_build_object(
   'available',(select count(*)>=2 from history),
   'metric','NYATA / DSPP ratio',
   'series',coalesce((select jsonb_agg(jsonb_build_object('period_id',h.id,'period_label',h.period_label,'period_start',h.period_start,'value_pct',case when h.dspp=0 then null else round(h.nyata::numeric/h.dspp::numeric*100,2) end) order by h.period_start desc)
                      from (select * from history order by period_start desc nulls last limit 12) h),'[]'::jsonb)
 ),
 'data_trust',jsonb_build_object(
   'fact_rows',t.fact_rows,'valid_rows',t.valid_rows,'not_reported_rows',t.not_reported_rows,
   'invalid_source_rows',t.invalid_source_rows,'estimated_rows',t.estimated_rows,
   'valid_pct',case when t.fact_rows=0 then null else round(t.valid_rows::numeric/t.fact_rows*100,2) end
 ),
 'aggregation_rule','NYATA / DSPP uses only valid strength records; personnel and education are separate sections'
)
from strength s cross join trust t cross join education e cross join ratio;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_sim_tni_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with latest as (
 select rp.id,rp.period_label,rp.period_start,rp.period_end
 from report_periods rp
 where exists(select 1 from sim_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
 order by rp.period_start desc nulls last,rp.created_at desc limit 1
),
stats as (
 select count(*)::bigint fact_rows,
 count(*) filter(where r.data_status='VALID')::bigint valid_rows,
 count(*) filter(where r.data_status='NOT_REPORTED')::bigint not_reported_rows,
 count(*) filter(where r.data_status='INVALID_SOURCE')::bigint invalid_source_rows,
 count(*) filter(where r.data_status='ESTIMATED')::bigint estimated_rows,
 coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
 from sim_records r join latest l on l.id=r.period_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
history as (
 select rp.id,rp.period_label,rp.period_start,coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
 from report_periods rp join sim_records r on r.period_id=rp.id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
 group by rp.id,rp.period_label,rp.period_start
),
by_type as (
 select jsonb_agg(jsonb_build_object('code',q.code,'name',q.name,'value',q.value) order by q.value desc,q.display_order) items
 from (
   select st.code,st.display_name name,st.display_order,
          coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
   from sim_records r join latest l on l.id=r.period_id join sim_types st on st.id=r.sim_type_id
   where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
   group by st.code,st.display_name,st.display_order
 ) q
)
select jsonb_build_object(
 'code','SIM_TNI','name','Rekapitulasi SIM TNI',
 'as_of',(select jsonb_build_object('id',l.id,'label',l.period_label,'start',l.period_start,'end',l.period_end) from latest l),
 'primary_metric',jsonb_build_object('value',s.value,'label','SIM valid','unit','SIM'),
 'supporting_metrics',jsonb_build_object('by_type',coalesce(b.items,'[]'::jsonb)),
 'trend',jsonb_build_object(
   'available',(select count(*)>=2 from history),
   'series',coalesce((select jsonb_agg(jsonb_build_object('period_id',h.id,'period_label',h.period_label,'period_start',h.period_start,'value',h.value) order by h.period_start desc) from (select * from history order by period_start desc nulls last limit 12) h),'[]'::jsonb)
 ),
 'data_trust',jsonb_build_object(
   'fact_rows',s.fact_rows,'valid_rows',s.valid_rows,'not_reported_rows',s.not_reported_rows,
   'invalid_source_rows',s.invalid_source_rows,'estimated_rows',s.estimated_rows,
   'valid_pct',case when s.fact_rows=0 then null else round(s.valid_rows::numeric/s.fact_rows*100,2) end
 ),
 'aggregation_rule','SUM VALID value by SIM type'
)
from stats s cross join by_type b;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_source_file_context(p_domain_code text, p_record_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select private.get_commander_source_file_context_impl(
    p_domain_code,
    p_record_id
  )
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_source_sheet_context(p_domain_code text, p_record_id uuid, p_row_radius integer DEFAULT 4)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select private.get_commander_source_sheet_context_impl(
    p_domain_code,
    p_record_id,
    p_row_radius
  );
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_tindak_pidana_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with latest as (
 select rp.id,rp.period_label,rp.period_start,rp.period_end
 from report_periods rp
 where exists(select 1 from criminal_offense_records r where r.period_id=rp.id and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id))
 order by rp.period_start desc nulls last,rp.created_at desc limit 1
),
period_source as (
 select r.period_id,cov.source_period,
        count(*)::bigint rows,
        count(*) filter(where r.data_status='VALID')::bigint valid_rows,
        count(*) filter(where r.data_status='NOT_REPORTED')::bigint not_reported_rows,
        count(*) filter(where r.data_status='INVALID_SOURCE')::bigint invalid_source_rows,
        count(*) filter(where r.data_status='ESTIMATED')::bigint estimated_rows,
        coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value,
        count(*) filter(where r.data_status='VALID' and coalesce(r.value,0)<>0)::bigint valid_nonzero_rows
 from criminal_offense_records r
 join criminal_offense_versions cov on cov.id=r.criminal_offense_version_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
 group by r.period_id,cov.source_period
),
current as (
 select
  ps.period_id,
  count(*)::int source_period_count,
  coalesce(sum(ps.rows),0)::bigint fact_rows,
  coalesce(sum(ps.valid_rows),0)::bigint valid_rows,
  coalesce(sum(ps.not_reported_rows),0)::bigint not_reported_rows,
  coalesce(sum(ps.invalid_source_rows),0)::bigint invalid_source_rows,
  coalesce(sum(ps.estimated_rows),0)::bigint estimated_rows,
  case when count(*)=1 then max(ps.value) else null end value,
  coalesce(sum(ps.valid_nonzero_rows),0)::bigint valid_nonzero_rows
 from period_source ps join latest l on l.id=ps.period_id
 group by ps.period_id
),
history as (
 select rp.id,rp.period_label,rp.period_start,
        count(*)::int source_period_count,
        case when count(*)=1 then max(ps.value) else null end value
 from report_periods rp
 join period_source ps on ps.period_id=rp.id
 group by rp.id,rp.period_label,rp.period_start
),
source_current as (
 select case when count(distinct cov.source_period)=1 then min(cov.source_period) else null end source_period,
        count(distinct cov.source_period)::int source_period_count
 from criminal_offense_records r join latest l on l.id=r.period_id
 join criminal_offense_versions cov on cov.id=r.criminal_offense_version_id
 where p_pomdam_id is null or r.pomdam_id=p_pomdam_id
),
top_items as (
 select jsonb_agg(jsonb_build_object('number',q.source_number,'name',q.name,'value',q.value) order by q.value desc,q.source_number) items
 from (
   select cov.source_number,co.canonical_name name,
          coalesce(sum(r.value) filter(where r.data_status='VALID'),0)::bigint value
   from criminal_offense_records r
   join latest l on l.id=r.period_id
   join criminal_offense_versions cov on cov.id=r.criminal_offense_version_id
   join criminal_offenses co on co.id=cov.offense_id
   cross join source_current sc
   where sc.source_period_count=1 and cov.source_period=sc.source_period
     and r.data_status='VALID' and coalesce(r.value,0)<>0
     and (p_pomdam_id is null or r.pomdam_id=p_pomdam_id)
   group by cov.source_number,co.canonical_name
   order by value desc,cov.source_number
   limit 5
 ) q
)
select jsonb_build_object(
 'code','TINDAK_PIDANA','name','Rekap Tindak Pidana',
 'as_of',(select jsonb_build_object('id',l.id,'label',l.period_label,'start',l.period_start,'end',l.period_end) from latest l),
 'primary_metric',jsonb_build_object('value',c.value,'label','Kasus tercatat pada data valid','unit','kasus'),
 'supporting_metrics',jsonb_build_object(
   'valid_nonzero_rows',c.valid_nonzero_rows,
   'selected_source_period',sc.source_period,
   'source_period_count',sc.source_period_count,
   'top_categories',coalesce(t.items,'[]'::jsonb)
 ),
 'trend',jsonb_build_object(
   'available',(select count(*)>=2 from history where value is not null),
   'series',coalesce((select jsonb_agg(jsonb_build_object('period_id',h.id,'period_label',h.period_label,'period_start',h.period_start,'value',h.value,'source_period_count',h.source_period_count) order by h.period_start desc) from (select * from history order by period_start desc nulls last limit 12) h),'[]'::jsonb)
 ),
 'data_trust',jsonb_build_object(
   'fact_rows',c.fact_rows,'valid_rows',c.valid_rows,'not_reported_rows',c.not_reported_rows,
   'invalid_source_rows',c.invalid_source_rows,'estimated_rows',c.estimated_rows,
   'valid_pct',case when c.fact_rows=0 then null else round(c.valid_rows::numeric/c.fact_rows*100,2) end,
   'not_reported_pct',case when c.fact_rows=0 then null else round(c.not_reported_rows::numeric/c.fact_rows*100,2) end
 ),
 'aggregation_rule','SUM VALID values only when exactly one source_period exists; multiple source periods make primary value ambiguous'
)
from current c cross join source_current sc cross join top_items t;
$function$;

CREATE OR REPLACE FUNCTION public.get_commander_cop_snapshot(p_pomdam_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
select private.assert_commander_access(p_pomdam_id);
with
d as (
  select * from (
    values
      ('GAKKUM', public.get_commander_gakkum_snapshot(p_pomdam_id)),
      ('PELANGGARAN', public.get_commander_pelanggaran_snapshot(p_pomdam_id)),
      ('SIM_TNI', public.get_commander_sim_tni_snapshot(p_pomdam_id)),
      ('PROVOS', public.get_commander_provos_snapshot(p_pomdam_id)),
      ('LAKA_LALIN', public.get_commander_laka_snapshot(p_pomdam_id)),
      ('TINDAK_PIDANA', public.get_commander_tindak_pidana_snapshot(p_pomdam_id))
  ) v(code, payload)
),
domain_array as (
  select jsonb_agg(payload order by case code
    when 'GAKKUM' then 1 when 'PELANGGARAN' then 2 when 'SIM_TNI' then 3
    when 'PROVOS' then 4 when 'LAKA_LALIN' then 5 when 'TINDAK_PIDANA' then 6 end) domains
  from d
),
att as (
 select coalesce(jsonb_agg(
   jsonb_build_object(
     'domain',code,
     'severity',case when kind='INVALID_SOURCE' then 'ERROR' else 'ATTENTION' end,
     'kind',kind,
     'count',cnt,
     'message',msg
   ) order by priority,code,kind
 ),'[]'::jsonb) items
 from (
   select 1 priority,'GAKKUM' code,'INVALID_SOURCE' kind,
          (payload->'data_trust'->>'invalid_source_rows')::bigint cnt,
          (payload->'data_trust'->>'invalid_source_rows')||' invalid source row(s)' msg
   from d where code='GAKKUM' and (payload->'data_trust'->>'invalid_source_rows')::bigint>0
   union all
   select 2,'GAKKUM','NOT_REPORTED',
          (payload->'data_trust'->>'not_reported_rows')::bigint,
          (payload->'data_trust'->>'not_reported_rows')||' row(s) not reported'
   from d where code='GAKKUM' and (payload->'data_trust'->>'not_reported_rows')::bigint>0
   union all
   select 2,'PELANGGARAN','NOT_REPORTED',
          (payload->'data_trust'->>'not_reported_rows')::bigint,
          (payload->'data_trust'->>'not_reported_rows')||' row(s) not reported'
   from d where code='PELANGGARAN' and (payload->'data_trust'->>'not_reported_rows')::bigint>0
   union all
   select 1,'SIM_TNI','INVALID_SOURCE',
          (payload->'data_trust'->>'invalid_source_rows')::bigint,
          (payload->'data_trust'->>'invalid_source_rows')||' invalid source row(s)'
   from d where code='SIM_TNI' and (payload->'data_trust'->>'invalid_source_rows')::bigint>0
   union all
   select 1,'LAKA_LALIN','INVALID_SOURCE',
          (payload->'data_trust'->>'invalid_source_rows')::bigint,
          (payload->'data_trust'->>'invalid_source_rows')||' invalid source row(s)'
   from d where code='LAKA_LALIN' and (payload->'data_trust'->>'invalid_source_rows')::bigint>0
   union all
   select 2,'LAKA_LALIN','NOT_REPORTED',
          (payload->'data_trust'->>'not_reported_rows')::bigint,
          (payload->'data_trust'->>'not_reported_rows')||' row(s) not reported'
   from d where code='LAKA_LALIN' and (payload->'data_trust'->>'not_reported_rows')::bigint>0
   union all
   select 1,'TINDAK_PIDANA','NOT_REPORTED',
          (payload->'data_trust'->>'not_reported_rows')::bigint,
          coalesce((payload->'data_trust'->>'not_reported_pct'),'0')||'% NOT_REPORTED'
   from d where code='TINDAK_PIDANA' and (payload->'data_trust'->>'not_reported_rows')::bigint>0
   union all
   select 1,'TINDAK_PIDANA','SOURCE_PERIOD_AMBIGUOUS',
          (payload->'supporting_metrics'->>'source_period_count')::bigint,
          'Multiple source_period values detected'
   from d where code='TINDAK_PIDANA' and (payload->'supporting_metrics'->>'source_period_count')::bigint>1
 ) x
),
matrix as (
 select coalesce(jsonb_agg(
   jsonb_build_object(
     'pomdam_id',p.id,'code',p.code,'short_name',p.short_name,
     'states',jsonb_build_object(
       'GAKKUM',(select case when count(*)=0 then 'NO_DATA' when count(*) filter(where r.data_status='INVALID_SOURCE')>0 then 'ERROR' when count(*) filter(where r.data_status='NOT_REPORTED')>0 then 'GAP' when count(*) filter(where r.data_status='ESTIMATED')>0 then 'ESTIMATED' else 'COMPLETE' end from gakkum_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='GAKKUM') and r.pomdam_id=p.id),
       'PELANGGARAN',(select case when count(*)=0 then 'NO_DATA' when count(*) filter(where r.data_status='INVALID_SOURCE')>0 then 'ERROR' when count(*) filter(where r.data_status='NOT_REPORTED')>0 then 'GAP' when count(*) filter(where r.data_status='ESTIMATED')>0 then 'ESTIMATED' else 'COMPLETE' end from violation_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='PELANGGARAN') and r.pomdam_id=p.id),
       'SIM_TNI',(select case when count(*)=0 then 'NO_DATA' when count(*) filter(where r.data_status='INVALID_SOURCE')>0 then 'ERROR' when count(*) filter(where r.data_status='NOT_REPORTED')>0 then 'GAP' when count(*) filter(where r.data_status='ESTIMATED')>0 then 'ESTIMATED' else 'COMPLETE' end from sim_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='SIM_TNI') and r.pomdam_id=p.id),
       'PROVOS',(select case when count(*)=0 then 'NO_DATA' when count(*) filter(where r.data_status='INVALID_SOURCE')>0 then 'ERROR' when count(*) filter(where r.data_status='NOT_REPORTED')>0 then 'GAP' when count(*) filter(where r.data_status='ESTIMATED')>0 then 'ESTIMATED' else 'COMPLETE' end from (
         select r.data_status from provos_strength_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='PROVOS') and r.pomdam_id=p.id
         union all
         select r.data_status from provos_personnel_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='PROVOS') and r.pomdam_id=p.id
         union all
         select r.data_status from provos_education_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='PROVOS') and r.pomdam_id=p.id
       ) r),
       'LAKA_LALIN',(select case when count(*)=0 then 'NO_DATA' when count(*) filter(where r.data_status='INVALID_SOURCE')>0 then 'ERROR' when count(*) filter(where r.data_status='NOT_REPORTED')>0 then 'GAP' when count(*) filter(where r.data_status='ESTIMATED')>0 then 'ESTIMATED' else 'COMPLETE' end from laka_accident_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='LAKA_LALIN') and r.pomdam_id=p.id),
       'TINDAK_PIDANA',(select case when count(*)=0 then 'NO_DATA' when count(*) filter(where r.data_status='INVALID_SOURCE')>0 then 'ERROR' when count(*) filter(where r.data_status='NOT_REPORTED')>0 then 'GAP' when count(*) filter(where r.data_status='ESTIMATED')>0 then 'ESTIMATED' else 'COMPLETE' end from criminal_offense_records r where r.period_id=(select (payload->'as_of'->>'id')::uuid from d where code='TINDAK_PIDANA') and r.pomdam_id=p.id)
     )
   ) order by p.report_order
 ),'[]'::jsonb) items
 from pomdams p
 where p.active=true and (p_pomdam_id is null or p.id=p_pomdam_id)
)
select jsonb_build_object(
 'schema_version','1.0',
 'generated_at',now(),
 'scope',jsonb_build_object(
   'type',case when p_pomdam_id is null then 'ALL_POMDAM' else 'POMDAM' end,
   'pomdam_id',p_pomdam_id,
   'pomdam',(select jsonb_build_object('id',p.id,'code',p.code,'short_name',p.short_name,'full_name',p.pomdam_full_name) from pomdams p where p.id=p_pomdam_id)
 ),
 'domains',(select domains from domain_array),
 'attention',(select items from att),
 'pomdam_matrix',(select items from matrix),
 'rules',jsonb_build_object(
   'not_reported_is_zero',false,
   'invalid_source_is_valid',false,
   'fact_rows_are_operational_counts',false,
   'operational_risk_thresholds_defined',false
 )
);
$function$;

CREATE OR REPLACE FUNCTION public.get_criminal_offense_dashboard(p_period_id uuid, p_source_period text, p_pomdam_id uuid DEFAULT NULL::uuid, p_personnel_category_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(offense_version_id uuid, offense_id uuid, canonical_key text, canonical_name text, source_number integer, source_label text, source_period text, display_order integer, record_count bigint, valid_total bigint, valid_count bigint, not_reported_count bigint, invalid_source_count bigint, estimated_total bigint, estimated_count bigint, missing_value_count bigint)
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'public'
AS $function$
  SELECT
    v.id AS offense_version_id,
    o.id AS offense_id,
    o.canonical_key,
    o.canonical_name,
    v.source_number,
    v.source_label,
    v.source_period,
    v.display_order,
    count(*) AS record_count,
    COALESCE(sum(r.value) FILTER (
      WHERE r.data_status = 'VALID'
    ), 0)::bigint AS valid_total,
    count(*) FILTER (
      WHERE r.data_status = 'VALID'
    ) AS valid_count,
    count(*) FILTER (
      WHERE r.data_status = 'NOT_REPORTED'
    ) AS not_reported_count,
    count(*) FILTER (
      WHERE r.data_status = 'INVALID_SOURCE'
    ) AS invalid_source_count,
    COALESCE(sum(r.value) FILTER (
      WHERE r.data_status = 'ESTIMATED'
    ), 0)::bigint AS estimated_total,
    count(*) FILTER (
      WHERE r.data_status = 'ESTIMATED'
    ) AS estimated_count,
    count(*) FILTER (
      WHERE r.data_status IN ('VALID', 'ESTIMATED')
        AND r.value IS NULL
    ) AS missing_value_count
  FROM public.criminal_offense_records r
  JOIN public.criminal_offense_versions v
    ON v.id = r.criminal_offense_version_id
  JOIN public.criminal_offenses o
    ON o.id = v.offense_id
  WHERE r.period_id = p_period_id
    AND v.source_period = p_source_period
    AND (p_pomdam_id IS NULL OR r.pomdam_id = p_pomdam_id)
    AND (
      p_personnel_category_id IS NULL
      OR r.personnel_category_id = p_personnel_category_id
    )
  GROUP BY
    v.id,
    o.id,
    o.canonical_key,
    o.canonical_name,
    v.source_number,
    v.source_label,
    v.source_period,
    v.display_order
  ORDER BY v.display_order, v.source_number, o.canonical_key;
$function$;

CREATE OR REPLACE FUNCTION public.get_my_access_context()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
  select private.get_my_access_context_impl()
$function$;

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
$function$;

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
$function$;

create or replace view "public"."report_audit_summary" as
WITH facts AS (
         SELECT 'GAKKUM'::text AS report_type_code,
            gakkum_records.id,
            gakkum_records.period_id,
            gakkum_records.pomdam_id,
            gakkum_records.data_status,
            gakkum_records.value,
            gakkum_records.source_cell_id
           FROM gakkum_records
        UNION ALL
         SELECT 'PELANGGARAN'::text,
            violation_records.id,
            violation_records.period_id,
            violation_records.pomdam_id,
            violation_records.data_status,
            violation_records.value,
            violation_records.source_cell_id
           FROM violation_records
        UNION ALL
         SELECT 'SIM_TNI'::text,
            sim_records.id,
            sim_records.period_id,
            sim_records.pomdam_id,
            sim_records.data_status,
            sim_records.value,
            sim_records.source_cell_id
           FROM sim_records
        UNION ALL
         SELECT 'PROVOS'::text,
            provos_strength_records.id,
            provos_strength_records.period_id,
            provos_strength_records.pomdam_id,
            provos_strength_records.data_status,
            provos_strength_records.value,
            provos_strength_records.source_cell_id
           FROM provos_strength_records
        UNION ALL
         SELECT 'PROVOS'::text,
            provos_personnel_records.id,
            provos_personnel_records.period_id,
            provos_personnel_records.pomdam_id,
            provos_personnel_records.data_status,
            provos_personnel_records.value,
            provos_personnel_records.source_cell_id
           FROM provos_personnel_records
        UNION ALL
         SELECT 'PROVOS'::text,
            provos_education_records.id,
            provos_education_records.period_id,
            provos_education_records.pomdam_id,
            provos_education_records.data_status,
            provos_education_records.value,
            provos_education_records.source_cell_id
           FROM provos_education_records
        UNION ALL
         SELECT 'LAKA_LALIN'::text,
            laka_accident_records.id,
            laka_accident_records.period_id,
            laka_accident_records.pomdam_id,
            laka_accident_records.data_status,
            laka_accident_records.value,
            laka_accident_records.source_cell_id
           FROM laka_accident_records
        UNION ALL
         SELECT 'LAKA_LALIN'::text,
            laka_personnel_records.id,
            laka_personnel_records.period_id,
            laka_personnel_records.pomdam_id,
            laka_personnel_records.data_status,
            laka_personnel_records.value,
            laka_personnel_records.source_cell_id
           FROM laka_personnel_records
        UNION ALL
         SELECT 'LAKA_LALIN'::text,
            laka_victim_rank_records.id,
            laka_victim_rank_records.period_id,
            laka_victim_rank_records.pomdam_id,
            laka_victim_rank_records.data_status,
            laka_victim_rank_records.value,
            laka_victim_rank_records.source_cell_id
           FROM laka_victim_rank_records
        UNION ALL
         SELECT 'LAKA_LALIN'::text,
            laka_victim_outcome_records.id,
            laka_victim_outcome_records.period_id,
            laka_victim_outcome_records.pomdam_id,
            laka_victim_outcome_records.data_status,
            laka_victim_outcome_records.value,
            laka_victim_outcome_records.source_cell_id
           FROM laka_victim_outcome_records
        UNION ALL
         SELECT 'LAKA_LALIN'::text,
            laka_material_records.id,
            laka_material_records.period_id,
            laka_material_records.pomdam_id,
            laka_material_records.data_status,
            laka_material_records.value,
            laka_material_records.source_cell_id
           FROM laka_material_records
        UNION ALL
         SELECT 'TINDAK_PIDANA'::text,
            criminal_offense_records.id,
            criminal_offense_records.period_id,
            criminal_offense_records.pomdam_id,
            criminal_offense_records.data_status,
            criminal_offense_records.value,
            criminal_offense_records.source_cell_id
           FROM criminal_offense_records
        ), fact_summary AS (
         SELECT f.report_type_code,
            f.period_id,
            count(*) AS fact_rows,
            count(DISTINCT f.pomdam_id) AS pomdam_count,
            count(*) FILTER (WHERE (f.data_status = 'VALID'::text)) AS valid_rows,
            count(*) FILTER (WHERE (f.data_status = 'NOT_REPORTED'::text)) AS not_reported_rows,
            count(*) FILTER (WHERE (f.data_status = 'INVALID_SOURCE'::text)) AS invalid_source_rows,
            count(*) FILTER (WHERE (f.data_status = 'ESTIMATED'::text)) AS estimated_rows,
            count(*) FILTER (WHERE ((f.data_status = 'VALID'::text) AND (f.value IS NULL))) AS valid_null_value,
            count(*) FILTER (WHERE ((f.data_status <> 'VALID'::text) AND (f.value IS NOT NULL))) AS nonvalid_with_value,
            count(*) FILTER (WHERE (f.source_cell_id IS NULL)) AS null_source_cell,
            count(*) FILTER (WHERE (rpv.source_cell_id IS NULL)) AS dangling_source_cell
           FROM ((facts f
             JOIN report_periods rp_1 ON (((rp_1.id = f.period_id) AND (rp_1.report_year = 2026))))
             LEFT JOIN report_provenance rpv ON ((rpv.source_cell_id = f.source_cell_id)))
          GROUP BY f.report_type_code, f.period_id
        ), source_summary AS (
         SELECT sr.report_type_id,
            sr.period_id,
            count(*) AS source_reports,
            count(*) FILTER (WHERE (sr.import_status = 'IMPORTED'::text)) AS imported_source_reports,
            count(*) FILTER (WHERE (sr.import_status <> 'IMPORTED'::text)) AS non_imported_source_reports
           FROM (source_reports sr
             JOIN report_periods rp_1 ON (((rp_1.id = sr.period_id) AND (rp_1.report_year = 2026))))
          GROUP BY sr.report_type_id, sr.period_id
        ), source_cells_summary AS (
         SELECT sr.report_type_id,
            sr.period_id,
            count(rpv.source_cell_id) AS source_cell_count
           FROM ((source_reports sr
             JOIN report_periods rp_1 ON (((rp_1.id = sr.period_id) AND (rp_1.report_year = 2026))))
             LEFT JOIN report_provenance rpv ON ((rpv.source_report_id = sr.id)))
          GROUP BY sr.report_type_id, sr.period_id
        )
 SELECT rt.code AS report_type_code,
    rt.name AS report_type_name,
    fs.period_id,
    rp.period_label,
    rp.report_year,
    COALESCE(ss.source_reports, (0)::bigint) AS source_reports,
    COALESCE(ss.imported_source_reports, (0)::bigint) AS imported_source_reports,
    COALESCE(ss.non_imported_source_reports, (0)::bigint) AS non_imported_source_reports,
    COALESCE(scs.source_cell_count, (0)::bigint) AS source_cell_count,
    COALESCE(fs.fact_rows, (0)::bigint) AS fact_rows,
    COALESCE(fs.pomdam_count, (0)::bigint) AS pomdam_count,
    COALESCE(fs.valid_rows, (0)::bigint) AS valid_rows,
    COALESCE(fs.not_reported_rows, (0)::bigint) AS not_reported_rows,
    COALESCE(fs.invalid_source_rows, (0)::bigint) AS invalid_source_rows,
    COALESCE(fs.estimated_rows, (0)::bigint) AS estimated_rows,
    COALESCE(fs.valid_null_value, (0)::bigint) AS valid_null_value,
    COALESCE(fs.nonvalid_with_value, (0)::bigint) AS nonvalid_with_value,
    COALESCE(fs.null_source_cell, (0)::bigint) AS null_source_cell,
    COALESCE(fs.dangling_source_cell, (0)::bigint) AS dangling_source_cell
   FROM ((((fact_summary fs
     JOIN report_periods rp ON ((rp.id = fs.period_id)))
     JOIN report_types rt ON ((rt.code = fs.report_type_code)))
     LEFT JOIN source_summary ss ON (((ss.report_type_id = rt.id) AND (ss.period_id = fs.period_id))))
     LEFT JOIN source_cells_summary scs ON (((scs.report_type_id = rt.id) AND (scs.period_id = fs.period_id))))
  WHERE ((auth.uid() IS NOT NULL) AND (COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));;

drop trigger if exists "sync_report_provenance_trigger" on "private"."source_cells";
CREATE TRIGGER sync_report_provenance_trigger AFTER INSERT OR DELETE OR UPDATE ON private.source_cells FOR EACH ROW EXECUTE FUNCTION private.sync_report_provenance();
alter table "private"."app_capabilities" enable row level security;
alter table "private"."app_role_capabilities" enable row level security;
alter table "private"."app_roles" enable row level security;
alter table "private"."app_user_pomdam_scopes" enable row level security;
alter table "private"."app_user_roles" enable row level security;
alter table "private"."source_cells" enable row level security;
alter table "private"."source_terms" enable row level security;
alter table "private"."step7_fact_stage" enable row level security;
alter table "private"."step7_rejections" enable row level security;
alter table "public"."accident_types" enable row level security;
alter table "public"."criminal_offense_records" enable row level security;
alter table "public"."criminal_offense_versions" enable row level security;
alter table "public"."criminal_offenses" enable row level security;
alter table "public"."education_statuses" enable row level security;
alter table "public"."gakkum_activities" enable row level security;
alter table "public"."gakkum_activity_versions" enable row level security;
alter table "public"."gakkum_records" enable row level security;
alter table "public"."laka_accident_records" enable row level security;
alter table "public"."laka_material_records" enable row level security;
alter table "public"."laka_personnel_records" enable row level security;
alter table "public"."laka_victim_outcome_records" enable row level security;
alter table "public"."laka_victim_rank_records" enable row level security;
alter table "public"."material_damage_types" enable row level security;
alter table "public"."personnel_categories" enable row level security;
alter table "public"."pomdam_aliases" enable row level security;
alter table "public"."pomdams" enable row level security;
alter table "public"."provos_education_records" enable row level security;
alter table "public"."provos_personnel_records" enable row level security;
alter table "public"."provos_strength_measures" enable row level security;
alter table "public"."provos_strength_records" enable row level security;
alter table "public"."report_periods" enable row level security;
alter table "public"."report_provenance" enable row level security;
alter table "public"."report_submissions" enable row level security;
alter table "public"."report_types" enable row level security;
alter table "public"."sim_records" enable row level security;
alter table "public"."sim_types" enable row level security;
alter table "public"."source_pomdam_occurrences" enable row level security;
alter table "public"."source_report_files" enable row level security;
alter table "public"."source_report_pomdams" enable row level security;
alter table "public"."source_reports" enable row level security;
alter table "public"."vehicle_categories" enable row level security;
alter table "public"."victim_outcomes" enable row level security;
alter table "public"."violation_records" enable row level security;
alter table "public"."violation_versions" enable row level security;
alter table "public"."violations" enable row level security;
drop policy if exists "authenticated_reporting_read" on "public"."accident_types";
create policy "authenticated_reporting_read" on "public"."accident_types" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."criminal_offense_records";
create policy "authorized_reporting_read" on "public"."criminal_offense_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "criminal_offense_records_managed_delete" on "public"."criminal_offense_records";
create policy "criminal_offense_records_managed_delete" on "public"."criminal_offense_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "criminal_offense_records_managed_insert" on "public"."criminal_offense_records";
create policy "criminal_offense_records_managed_insert" on "public"."criminal_offense_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "criminal_offense_records_managed_update" on "public"."criminal_offense_records";
create policy "criminal_offense_records_managed_update" on "public"."criminal_offense_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authenticated_reporting_read" on "public"."criminal_offense_versions";
create policy "authenticated_reporting_read" on "public"."criminal_offense_versions" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."criminal_offenses";
create policy "authenticated_reporting_read" on "public"."criminal_offenses" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."education_statuses";
create policy "authenticated_reporting_read" on "public"."education_statuses" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."gakkum_activities";
create policy "authenticated_reporting_read" on "public"."gakkum_activities" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."gakkum_activity_versions";
create policy "authenticated_reporting_read" on "public"."gakkum_activity_versions" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."gakkum_records";
create policy "authorized_reporting_read" on "public"."gakkum_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "gakkum_records_managed_delete" on "public"."gakkum_records";
create policy "gakkum_records_managed_delete" on "public"."gakkum_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "gakkum_records_managed_insert" on "public"."gakkum_records";
create policy "gakkum_records_managed_insert" on "public"."gakkum_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "gakkum_records_managed_update" on "public"."gakkum_records";
create policy "gakkum_records_managed_update" on "public"."gakkum_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authorized_reporting_read" on "public"."laka_accident_records";
create policy "authorized_reporting_read" on "public"."laka_accident_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "laka_accident_records_managed_delete" on "public"."laka_accident_records";
create policy "laka_accident_records_managed_delete" on "public"."laka_accident_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "laka_accident_records_managed_insert" on "public"."laka_accident_records";
create policy "laka_accident_records_managed_insert" on "public"."laka_accident_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "laka_accident_records_managed_update" on "public"."laka_accident_records";
create policy "laka_accident_records_managed_update" on "public"."laka_accident_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authorized_reporting_read" on "public"."laka_material_records";
create policy "authorized_reporting_read" on "public"."laka_material_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "laka_material_records_managed_delete" on "public"."laka_material_records";
create policy "laka_material_records_managed_delete" on "public"."laka_material_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "laka_material_records_managed_insert" on "public"."laka_material_records";
create policy "laka_material_records_managed_insert" on "public"."laka_material_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "laka_material_records_managed_update" on "public"."laka_material_records";
create policy "laka_material_records_managed_update" on "public"."laka_material_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authorized_reporting_read" on "public"."laka_personnel_records";
create policy "authorized_reporting_read" on "public"."laka_personnel_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "laka_personnel_records_managed_delete" on "public"."laka_personnel_records";
create policy "laka_personnel_records_managed_delete" on "public"."laka_personnel_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "laka_personnel_records_managed_insert" on "public"."laka_personnel_records";
create policy "laka_personnel_records_managed_insert" on "public"."laka_personnel_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "laka_personnel_records_managed_update" on "public"."laka_personnel_records";
create policy "laka_personnel_records_managed_update" on "public"."laka_personnel_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authorized_reporting_read" on "public"."laka_victim_outcome_records";
create policy "authorized_reporting_read" on "public"."laka_victim_outcome_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "laka_victim_outcome_records_managed_delete" on "public"."laka_victim_outcome_records";
create policy "laka_victim_outcome_records_managed_delete" on "public"."laka_victim_outcome_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "laka_victim_outcome_records_managed_insert" on "public"."laka_victim_outcome_records";
create policy "laka_victim_outcome_records_managed_insert" on "public"."laka_victim_outcome_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "laka_victim_outcome_records_managed_update" on "public"."laka_victim_outcome_records";
create policy "laka_victim_outcome_records_managed_update" on "public"."laka_victim_outcome_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authorized_reporting_read" on "public"."laka_victim_rank_records";
create policy "authorized_reporting_read" on "public"."laka_victim_rank_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "laka_victim_rank_records_managed_delete" on "public"."laka_victim_rank_records";
create policy "laka_victim_rank_records_managed_delete" on "public"."laka_victim_rank_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "laka_victim_rank_records_managed_insert" on "public"."laka_victim_rank_records";
create policy "laka_victim_rank_records_managed_insert" on "public"."laka_victim_rank_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "laka_victim_rank_records_managed_update" on "public"."laka_victim_rank_records";
create policy "laka_victim_rank_records_managed_update" on "public"."laka_victim_rank_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authenticated_reporting_read" on "public"."material_damage_types";
create policy "authenticated_reporting_read" on "public"."material_damage_types" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."personnel_categories";
create policy "authenticated_reporting_read" on "public"."personnel_categories" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."pomdam_aliases";
create policy "authorized_reporting_read" on "public"."pomdam_aliases" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "authorized_reporting_read" on "public"."pomdams";
create policy "authorized_reporting_read" on "public"."pomdams" for SELECT to "authenticated" using (private.can_read_pomdam(id));
drop policy if exists "authorized_reporting_read" on "public"."provos_education_records";
create policy "authorized_reporting_read" on "public"."provos_education_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "provos_education_records_managed_delete" on "public"."provos_education_records";
create policy "provos_education_records_managed_delete" on "public"."provos_education_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "provos_education_records_managed_insert" on "public"."provos_education_records";
create policy "provos_education_records_managed_insert" on "public"."provos_education_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "provos_education_records_managed_update" on "public"."provos_education_records";
create policy "provos_education_records_managed_update" on "public"."provos_education_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authorized_reporting_read" on "public"."provos_personnel_records";
create policy "authorized_reporting_read" on "public"."provos_personnel_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "provos_personnel_records_managed_delete" on "public"."provos_personnel_records";
create policy "provos_personnel_records_managed_delete" on "public"."provos_personnel_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "provos_personnel_records_managed_insert" on "public"."provos_personnel_records";
create policy "provos_personnel_records_managed_insert" on "public"."provos_personnel_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "provos_personnel_records_managed_update" on "public"."provos_personnel_records";
create policy "provos_personnel_records_managed_update" on "public"."provos_personnel_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authenticated_reporting_read" on "public"."provos_strength_measures";
create policy "authenticated_reporting_read" on "public"."provos_strength_measures" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."provos_strength_records";
create policy "authorized_reporting_read" on "public"."provos_strength_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "provos_strength_records_managed_delete" on "public"."provos_strength_records";
create policy "provos_strength_records_managed_delete" on "public"."provos_strength_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "provos_strength_records_managed_insert" on "public"."provos_strength_records";
create policy "provos_strength_records_managed_insert" on "public"."provos_strength_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "provos_strength_records_managed_update" on "public"."provos_strength_records";
create policy "provos_strength_records_managed_update" on "public"."provos_strength_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authenticated_reporting_read" on "public"."report_periods";
create policy "authenticated_reporting_read" on "public"."report_periods" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "report_periods_insert_managed" on "public"."report_periods";
create policy "report_periods_insert_managed" on "public"."report_periods" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND (period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end >= period_start) AND (period_type = ANY (ARRAY['MONTH'::text, 'QUARTER'::text, 'SEMESTER'::text, 'YEAR'::text, 'OTHER'::text])) AND (NULLIF(TRIM(BOTH FROM period_label), ''::text) IS NOT NULL)));
drop policy if exists "authorized_reporting_read" on "public"."report_provenance";
create policy "authorized_reporting_read" on "public"."report_provenance" for SELECT to "authenticated" using (private.can_read_source_report(source_report_id));
drop policy if exists "report_submissions_insert_managed" on "public"."report_submissions";
create policy "report_submissions_insert_managed" on "public"."report_submissions" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (submitted_by = ( SELECT auth.uid() AS uid))));
drop policy if exists "report_submissions_select_authorized" on "public"."report_submissions";
create policy "report_submissions_select_authorized" on "public"."report_submissions" for SELECT to "authenticated" using ((private.can_read_pomdam(pomdam_id) AND (private.has_current_capability('VIEW_REPORTS'::text) OR private.has_current_capability('MANAGE_REPORT_DATA'::text))));
drop policy if exists "report_submissions_update_managed" on "public"."report_submissions";
create policy "report_submissions_update_managed" on "public"."report_submissions" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (submitted_by = ( SELECT auth.uid() AS uid))));
drop policy if exists "authenticated_reporting_read" on "public"."report_types";
create policy "authenticated_reporting_read" on "public"."report_types" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."sim_records";
create policy "authorized_reporting_read" on "public"."sim_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "sim_records_managed_delete" on "public"."sim_records";
create policy "sim_records_managed_delete" on "public"."sim_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "sim_records_managed_insert" on "public"."sim_records";
create policy "sim_records_managed_insert" on "public"."sim_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "sim_records_managed_update" on "public"."sim_records";
create policy "sim_records_managed_update" on "public"."sim_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authenticated_reporting_read" on "public"."sim_types";
create policy "authenticated_reporting_read" on "public"."sim_types" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."source_pomdam_occurrences";
create policy "authorized_reporting_read" on "public"."source_pomdam_occurrences" for SELECT to "authenticated" using (private.can_read_source_report(source_report_id));
drop policy if exists "authorized_reporting_read" on "public"."source_report_pomdams";
create policy "authorized_reporting_read" on "public"."source_report_pomdams" for SELECT to "authenticated" using (private.can_read_source_report(source_report_id));
drop policy if exists "authorized_reporting_read" on "public"."source_reports";
create policy "authorized_reporting_read" on "public"."source_reports" for SELECT to "authenticated" using (private.can_read_source_report(id));
drop policy if exists "authenticated_reporting_read" on "public"."vehicle_categories";
create policy "authenticated_reporting_read" on "public"."vehicle_categories" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."victim_outcomes";
create policy "authenticated_reporting_read" on "public"."victim_outcomes" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authorized_reporting_read" on "public"."violation_records";
create policy "authorized_reporting_read" on "public"."violation_records" for SELECT to "authenticated" using (private.can_read_pomdam(pomdam_id));
drop policy if exists "violation_records_managed_delete" on "public"."violation_records";
create policy "violation_records_managed_delete" on "public"."violation_records" for DELETE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL)));
drop policy if exists "violation_records_managed_insert" on "public"."violation_records";
create policy "violation_records_managed_insert" on "public"."violation_records" for INSERT to "authenticated" with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "violation_records_managed_update" on "public"."violation_records";
create policy "violation_records_managed_update" on "public"."violation_records" for UPDATE to "authenticated" using ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id))) with check ((private.has_current_capability('MANAGE_REPORT_DATA'::text) AND private.can_read_pomdam(pomdam_id) AND (source_cell_id IS NULL) AND (data_status = ANY (ARRAY['VALID'::text, 'NOT_REPORTED'::text])) AND (((data_status = 'NOT_REPORTED'::text) AND (value IS NULL)) OR ((data_status = 'VALID'::text) AND (value IS NOT NULL) AND (value >= 0)))));
drop policy if exists "authenticated_reporting_read" on "public"."violation_versions";
create policy "authenticated_reporting_read" on "public"."violation_versions" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
drop policy if exists "authenticated_reporting_read" on "public"."violations";
create policy "authenticated_reporting_read" on "public"."violations" for SELECT to "authenticated" using ((COALESCE(((( SELECT auth.jwt() AS jwt) ->> 'is_anonymous'::text))::boolean, false) IS FALSE));
grant SELECT on table "public"."accident_types" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."criminal_offense_records" to "authenticated";
grant SELECT on table "public"."criminal_offense_versions" to "authenticated";
grant SELECT on table "public"."criminal_offenses" to "authenticated";
grant SELECT on table "public"."education_statuses" to "authenticated";
grant SELECT on table "public"."gakkum_activities" to "authenticated";
grant SELECT on table "public"."gakkum_activity_versions" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."gakkum_records" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."laka_accident_records" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."laka_material_records" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."laka_personnel_records" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."laka_victim_outcome_records" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."laka_victim_rank_records" to "authenticated";
grant SELECT on table "public"."material_damage_types" to "authenticated";
grant SELECT on table "public"."personnel_categories" to "authenticated";
grant SELECT on table "public"."pomdam_aliases" to "authenticated";
grant SELECT on table "public"."pomdams" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."provos_education_records" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."provos_personnel_records" to "authenticated";
grant SELECT on table "public"."provos_strength_measures" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."provos_strength_records" to "authenticated";
grant SELECT on table "public"."report_audit_summary" to "authenticated";
grant INSERT, SELECT on table "public"."report_periods" to "authenticated";
grant SELECT on table "public"."report_provenance" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."report_submissions" to "authenticated";
grant SELECT on table "public"."report_types" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."sim_records" to "authenticated";
grant SELECT on table "public"."sim_types" to "authenticated";
grant SELECT on table "public"."source_pomdam_occurrences" to "authenticated";
grant SELECT on table "public"."source_report_pomdams" to "authenticated";
grant SELECT on table "public"."source_reports" to "authenticated";
grant SELECT on table "public"."vehicle_categories" to "authenticated";
grant SELECT on table "public"."victim_outcomes" to "authenticated";
grant INSERT, SELECT, UPDATE on table "public"."violation_records" to "authenticated";
grant SELECT on table "public"."violation_versions" to "authenticated";
grant SELECT on table "public"."violations" to "authenticated";
grant execute on function "private"."assert_can_read_pomdam"(p_pomdam_id uuid) to "authenticated";
grant execute on function "private"."assert_commander_access"(p_pomdam_id uuid) to "authenticated";
grant execute on function "private"."assert_current_role"() to "authenticated";
grant execute on function "private"."assert_report_input_values"(p_entries jsonb) to "authenticated";
grant execute on function "private"."can_read_pomdam"(p_pomdam_id uuid) to "authenticated";
grant execute on function "private"."can_read_source_report"(p_source_report_id uuid) to "authenticated";
grant execute on function "private"."current_user_role"() to "authenticated";
grant execute on function "private"."get_commander_fact_provenance_impl"(p_domain_code text, p_record_id uuid) to "authenticated";
grant execute on function "private"."get_my_access_context_impl"() to "authenticated";
grant execute on function "private"."has_current_capability"(p_capability_code text) to "authenticated";
grant execute on function "public"."create_report_period"(p_period_start date, p_period_end date, p_period_label text, p_period_type text) to "authenticated";
grant execute on function "public"."get_commander_cop_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_commander_domain_drilldown"(p_domain_code text, p_pomdam_id uuid, p_dimension_code text, p_limit integer) to "authenticated";
grant execute on function "public"."get_commander_fact_provenance"(p_domain_code text, p_record_id uuid) to "authenticated";
grant execute on function "public"."get_commander_gakkum_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_commander_laka_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_commander_pelanggaran_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_commander_provos_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_commander_sim_tni_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_commander_source_file_context"(p_domain_code text, p_record_id uuid) to "authenticated";
grant execute on function "public"."get_commander_source_sheet_context"(p_domain_code text, p_record_id uuid, p_row_radius integer) to "authenticated";
grant execute on function "public"."get_commander_tindak_pidana_snapshot"(p_pomdam_id uuid) to "authenticated";
grant execute on function "public"."get_criminal_offense_dashboard"(p_period_id uuid, p_source_period text, p_pomdam_id uuid, p_personnel_category_id uuid) to "authenticated";
grant execute on function "public"."get_my_access_context"() to "authenticated";
grant execute on function "public"."get_or_create_monthly_report_period"(p_year integer, p_month integer) to "authenticated";
grant execute on function "public"."submit_report"(p_report_type text, p_period_id uuid, p_pomdam_id uuid, p_payload jsonb) to "authenticated";
insert into "public"."report_types" ("id", "code", "name", "active", "created_at", "description") values
('09a0a0dd-f3d5-42a9-bcfb-b2a88879bbb2', 'TINDAK_PIDANA', 'Rekap Tindak Pidana', true, '2026-10-01T11:22:17.520019+00:00', 'Rekap tindak pidana'),
('0a116538-5459-47fa-865a-7f8082b4a70a', 'PROVOS', 'Rekapitulasi Provos TNI AD', true, '2026-10-01T11:22:17.520019+00:00', 'Rekapitulasi personel dan pendidikan Provos'),
('48695751-545b-41cf-b7c3-2e366a0689dc', 'GAKKUM', 'Statistik Giat Gakkum', true, '2026-10-01T11:22:17.520019+00:00', 'Statistik kegiatan penegakan hukum'),
('55278d29-d4ee-43bd-b1d1-b3d54fdd368a', 'LAKA_LALIN', 'Statistik Laka Lalin', true, '2026-10-01T11:22:17.520019+00:00', 'Statistik kecelakaan lalu lintas'),
('ea0eef69-303c-4777-8706-ec16240696e2', 'PELANGGARAN', 'Statistik Pelanggaran', true, '2026-10-01T11:22:17.520019+00:00', 'Rekap pelanggaran'),
('f01be871-69b5-4ee3-b98a-1b70d3bc190f', 'SIM_TNI', 'Rekapitulasi SIM TNI', true, '2026-10-01T11:22:17.520019+00:00', 'Rekapitulasi SIM TNI AD')
on conflict do nothing;
insert into "public"."pomdams" ("id", "code", "active", "valid_to", "created_at", "kodam_name", "short_name", "valid_from", "roman_value", "report_order", "roman_numeral", "kodam_full_name", "pomdam_full_name") values
('6fd6b0df-e78b-4e07-a7c8-686d6f5929e2', 'IM', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Iskandar Muda', 'Iskandar Muda', NULL, NULL, 1, NULL, 'Kodam Iskandar Muda', 'Polisi Militer Kodam Iskandar Muda'),
('60be04aa-e493-40d0-941b-1d6904017def', 'I/BB', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Bukit Barisan', 'Bukit Barisan', NULL, 1, 2, 'I', 'Kodam I/Bukit Barisan', 'Polisi Militer Kodam I/Bukit Barisan'),
('8f1f390f-324d-4dc6-83c2-147d9925b114', 'II/SWJ', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Sriwijaya', 'Sriwijaya', NULL, 2, 3, 'II', 'Kodam II/Sriwijaya', 'Polisi Militer Kodam II/Sriwijaya'),
('cb6b3294-aa58-4fda-850c-9231f1e915c9', 'III/SLW', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Siliwangi', 'Siliwangi', NULL, 3, 4, 'III', 'Kodam III/Siliwangi', 'Polisi Militer Kodam III/Siliwangi'),
('c483ba92-486d-47a0-9e7d-87353f201f1a', 'IV/DIP', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Diponegoro', 'Diponegoro', NULL, 4, 5, 'IV', 'Kodam IV/Diponegoro', 'Polisi Militer Kodam IV/Diponegoro'),
('87ea5ac6-7ab6-4f4d-90ba-70d7eb41d16d', 'V/BRW', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Brawijaya', 'Brawijaya', NULL, 5, 6, 'V', 'Kodam V/Brawijaya', 'Polisi Militer Kodam V/Brawijaya'),
('6026c20a-3dc7-463f-802c-ff005ee130aa', 'VI/MLW', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Mulawarman', 'Mulawarman', NULL, 6, 7, 'VI', 'Kodam VI/Mulawarman', 'Polisi Militer Kodam VI/Mulawarman'),
('be5730c9-ecf4-4784-8f49-030d21e424be', 'IX/UDY', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Udayana', 'Udayana', NULL, 9, 8, 'IX', 'Kodam IX/Udayana', 'Polisi Militer Kodam IX/Udayana'),
('9764e9b4-2ed9-44f3-aa7f-bb85210c7406', 'XII/TPR', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Tanjungpura', 'Tanjungpura', NULL, 12, 9, 'XII', 'Kodam XII/Tanjungpura', 'Polisi Militer Kodam XII/Tanjungpura'),
('c718f466-4579-44e4-9954-182c5d66a136', 'XIII/MDK', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Merdeka', 'Merdeka', NULL, 13, 10, 'XIII', 'Kodam XIII/Merdeka', 'Polisi Militer Kodam XIII/Merdeka'),
('5b655dc8-c2f1-4016-bae0-1f15ff12f5b6', 'XIV/HSN', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Hasanuddin', 'Hasanuddin', NULL, 14, 11, 'XIV', 'Kodam XIV/Hasanuddin', 'Polisi Militer Kodam XIV/Hasanuddin'),
('3d93452c-d6e7-4fab-b9f2-d707e0c6c953', 'XV/PTM', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Pattimura', 'Pattimura', NULL, 15, 12, 'XV', 'Kodam XV/Pattimura', 'Polisi Militer Kodam XV/Pattimura'),
('d5c5015b-ec01-4075-800d-fc8decbb3745', 'XVII/CEN', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Cenderawasih', 'Cenderawasih', NULL, 17, 13, 'XVII', 'Kodam XVII/Cenderawasih', 'Polisi Militer Kodam XVII/Cenderawasih'),
('fe7e70ee-a07b-42a7-926e-330919160ba3', 'XVIII/KSR', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Kasuari', 'Kasuari', NULL, 18, 14, 'XVIII', 'Kodam XVIII/Kasuari', 'Polisi Militer Kodam XVIII/Kasuari'),
('7b8f3a8a-e873-47c7-8775-bdb7de828954', 'XIX/TT', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Tuanku Tambusai', 'Tuanku Tambusai', NULL, 19, 15, 'XIX', 'Kodam XIX/Tuanku Tambusai', 'Polisi Militer Kodam XIX/Tuanku Tambusai'),
('6f6383e6-26ad-4dee-9afd-1c6a6694e621', 'XX/TIB', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Tuanku Imam Bonjol', 'Tuanku Imam Bonjol', NULL, 20, 16, 'XX', 'Kodam XX/Tuanku Imam Bonjol', 'Polisi Militer Kodam XX/Tuanku Imam Bonjol'),
('2cd128f4-d9d1-4510-9dcd-71db59ea242c', 'XXI/RI', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Radin Inten', 'Radin Inten', NULL, 21, 17, 'XXI', 'Kodam XXI/Radin Inten', 'Polisi Militer Kodam XXI/Radin Inten'),
('e068154d-fedb-4743-8a2e-ebc3832575a4', 'XXII/TB', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Tambun Bungai', 'Tambun Bungai', NULL, 22, 18, 'XXII', 'Kodam XXII/Tambun Bungai', 'Polisi Militer Kodam XXII/Tambun Bungai'),
('23210a0e-df53-478b-955a-725efec1a25a', 'XXIII/PW', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Palaka Wira', 'Palaka Wira', NULL, 23, 19, 'XXIII', 'Kodam XXIII/Palaka Wira', 'Polisi Militer Kodam XXIII/Palaka Wira'),
('e83830fb-a2b7-412c-93df-bc96977239ad', 'XXIV/MT', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Mandala Trikora', 'Mandala Trikora', NULL, 24, 20, 'XXIV', 'Kodam XXIV/Mandala Trikora', 'Polisi Militer Kodam XXIV/Mandala Trikora'),
('77852b48-cc3d-48b7-afc8-824269a6081e', 'JAYA', true, NULL, '2026-10-01T11:22:17.520019+00:00', 'Jaya/Jayakarta', 'Jaya/Jayakarta', NULL, NULL, 21, NULL, 'Kodam Jaya/Jayakarta', 'Polisi Militer Kodam Jaya/Jayakarta')
on conflict do nothing;
insert into "public"."pomdam_aliases" ("id", "notes", "pomdam_id", "alias_type", "created_at", "source_value", "source_period") values
('3eb13b1b-02b3-48d8-951c-eb25a1fcfb20', 'Source-era variant; canonical current reporting code is XV/PTM.', '3d93452c-d6e7-4fab-b9f2-d707e0c6c953', 'CONFLICTING_SOURCE', '2026-10-01T11:22:17.520019+00:00', 'XVI/PTM', NULL),
('447b351e-a433-4874-bf0e-7c8ea8cccc85', 'Source variant observed for XX/Tuanku Imam Bonjol.', '6f6383e6-26ad-4dee-9afd-1c6a6694e621', 'SOURCE_VARIANT', '2026-10-01T11:22:17.520019+00:00', 'XX/TB', NULL),
('76cc4e50-603c-4fc4-b42c-a7ae00c7ade0', 'Source variant observed for XIV/Hasanuddin.', '5b655dc8-c2f1-4016-bae0-1f15ff12f5b6', 'SOURCE_VARIANT', '2026-10-01T11:22:17.520019+00:00', 'XIV/HSD', NULL),
('b3708cb4-4466-4290-8bf5-0fa8a466ca3a', 'Source variant observed for XXII/Tambun Bungai.', 'e068154d-fedb-4743-8a2e-ebc3832575a4', 'SOURCE_VARIANT', '2026-10-01T11:22:17.520019+00:00', 'XXII/TIB', NULL),
('d97041ce-d83d-4bf4-99b9-d3c9ac5865d3', 'Observed source typo; canonical current code is XXIV/MT.', 'e83830fb-a2b7-412c-93df-bc96977239ad', 'SOURCE_TYPO', '2026-10-01T11:22:17.520019+00:00', 'XIV/MT', NULL)
on conflict do nothing;
insert into "public"."personnel_categories" ("id", "code", "name", "active", "created_at", "display_order") values
('0a1a3001-c7d6-41ae-a18f-74dde0d85f9b', 'BA', 'Bintara', true, '2026-10-01T11:22:17.520019+00:00', 2),
('7af35523-98aa-4110-9ffc-195b87680539', 'PA', 'Perwira', true, '2026-10-01T11:22:17.520019+00:00', 1),
('8be6d571-164c-4eed-b8e5-085c58013126', 'TA', 'Tamtama', true, '2026-10-01T11:22:17.520019+00:00', 3),
('eae5dfde-47e6-4902-89fb-37185bed43c0', 'PNS', 'Pegawai Negeri Sipil', true, '2026-10-01T11:22:17.520019+00:00', 4)
on conflict do nothing;
insert into "public"."sim_types" ("id", "code", "active", "created_at", "display_name", "source_label", "display_order") values
('00da010f-2319-48d6-8a40-7fb774e08e95', 'BII_KHUSUS', true, '2026-10-01T11:22:17.520019+00:00', 'BII Khusus', 'BII SUS', 4),
('117e8591-750d-470e-b2f0-59fa2099e7d1', 'A', true, '2026-10-01T11:22:17.520019+00:00', 'A', 'A', 1),
('19ab72b5-0ebb-4f5f-9891-56bdfbfc8b23', 'C', true, '2026-10-01T11:22:17.520019+00:00', 'C', 'C', 5),
('7ebea0b8-c670-483f-b87c-fac487eeb33d', 'BII', true, '2026-10-01T11:22:17.520019+00:00', 'BII', 'BII', 3),
('d08669e8-a134-44db-b6aa-e9f5e52fc052', 'BI', true, '2026-10-01T11:22:17.520019+00:00', 'BI', 'BI', 2)
on conflict do nothing;
insert into "public"."gakkum_activities" ("id", "code", "active", "created_at", "canonical_name") values
('06368980-5302-49a3-83ba-b5ba00a2cc69', 'RAZIA_DITEMPAT_LAIN', true, '2026-10-01T11:46:30.907115+00:00', 'Razia di Tempat Lain yang Dianggap Perlu'),
('2056ed43-7471-456e-bcde-512f15fbe2e5', 'PENGGELEDAHAN', true, '2026-10-01T11:46:30.907115+00:00', 'Penggeledahan'),
('2770fdc4-c2a7-42f0-b49c-d69a43409a8b', 'MENDATANGI_TKP', true, '2026-10-01T11:46:30.907115+00:00', 'Mendatangi TKP'),
('3ddbecbb-379f-4825-b482-5870d3d759c9', 'UPAYA_PAKSA', true, '2026-10-01T11:46:30.907115+00:00', 'Upaya Paksa'),
('5165560c-e4a8-4a9e-b768-05a2438e6cb7', 'PENANGKAPAN', true, '2026-10-01T11:46:30.907115+00:00', 'Penangkapan'),
('5176f1ed-e1c9-4f8c-aac8-0d6b69dab546', 'PENYELENGGARAAN_SIM_TNI_AD', true, '2026-10-01T11:46:30.907115+00:00', 'Penyelenggaraan SIM TNI AD'),
('58478d16-757d-47ab-9cb7-94b211de331e', 'RAZIA_DIDALAM_KERETA_API', true, '2026-10-01T11:46:30.907115+00:00', 'Razia di Dalam Kereta Api'),
('5ed792ba-e93a-4dc6-b268-1de08ef90316', 'TINDAKAN_POLISIONIL', false, '2026-10-01T11:46:30.907115+00:00', 'Tindakan Polisionil'),
('6a15b0ab-b49d-43ab-92a2-56f0c44ed0bb', 'PENYEGELAN', true, '2026-10-01T11:46:30.907115+00:00', 'Penyegelan'),
('bac6a95a-c621-47e0-9bfa-24c0040aac7c', 'RAZIA_KENDARAAN_BERMOTOR', true, '2026-10-01T11:46:30.907115+00:00', 'Razia Kendaraan Bermotor'),
('bbe30eec-b63d-456c-be51-e5dd6ac5a9f8', 'RAZIA', true, '2026-10-01T11:46:30.907115+00:00', 'Razia'),
('c20ac601-9524-4762-beac-a4c159cfee37', 'LAIN_LAIN', true, '2026-10-01T11:46:30.907115+00:00', 'Lain-lain'),
('d60837c6-0b8f-4244-85da-15c745d8cafd', 'PATROLI', true, '2026-10-01T11:46:30.907115+00:00', 'Patroli'),
('dc675610-a53b-4224-8baf-74171df5c700', 'PATROLI_KOMBINASI', true, '2026-10-01T11:46:30.907115+00:00', 'Patroli Kombinasi'),
('dd0ed3fd-8935-494a-9a3b-98647b3f5a8e', 'WAS_PERBATASAN', true, '2026-10-01T11:46:30.907115+00:00', 'WAS Perbatasan'),
('df3da909-7f97-4451-8dbc-bece8ede3214', 'PEMBINAAN_PROVOS_ANGKATAN_DARAT', true, '2026-10-01T11:46:30.907115+00:00', 'Pembinaan Provos Angkatan Darat'),
('f994dbb3-14ec-4e94-9d08-9140a517e89c', 'PATROLI_BERKENDARAAN', true, '2026-10-01T11:46:30.907115+00:00', 'Patroli Berkendaraan'),
('fe8941fa-0c00-471e-bf6e-0a8338c3d313', 'RAZIA_DITEMPAT_TERLARANG_ANGGOTA_TNI', true, '2026-10-01T11:46:30.907115+00:00', 'Razia di Tempat Terlarang bagi Anggota TNI'),
('ff875776-5c5f-48e9-8b43-366cf85cd9a4', 'BAN_POM_UTK_KAM_UMUM', true, '2026-10-01T11:46:30.907115+00:00', 'BAN POM UTK KAM UMUM')
on conflict do nothing;
insert into "public"."gakkum_activity_versions" ("id", "level", "valid_to", "created_at", "valid_from", "activity_id", "source_code", "source_label", "display_order", "taxonomy_version", "parent_version_id") values
('00bcafa4-9e74-4de9-8995-064a763fea46', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'dc675610-a53b-4224-8baf-74171df5c700', NULL, 'Patroli Kombinasi', 3, 'CURRENT_2026', '8e921b15-a387-4244-b933-a92ea2595256'),
('01381f1a-1e53-4293-8278-60f3038e6632', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'bac6a95a-c621-47e0-9bfa-24c0040aac7c', NULL, 'Razia Kendaraan Bermotor', 5, 'CURRENT_2026', '50071290-eada-4f54-ae48-e25666641165'),
('046c1076-1544-4dd3-a9b1-58046e86524d', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'fe8941fa-0c00-471e-bf6e-0a8338c3d313', NULL, 'Razia di Tempat Terlarang bagi Anggota TNI', 6, 'CURRENT_2026', '50071290-eada-4f54-ae48-e25666641165'),
('1682534a-6770-43fc-9e15-0c3a8acc5bcd', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'f994dbb3-14ec-4e94-9d08-9140a517e89c', NULL, 'Patroli Berkendaraan', 2, 'CURRENT_2026', '8e921b15-a387-4244-b933-a92ea2595256'),
('1ecf80cc-504c-412e-9822-e73fb9815425', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '06368980-5302-49a3-83ba-b5ba00a2cc69', NULL, 'Razia di Tempat Lain yang Dianggap Perlu', 8, 'CURRENT_2026', '50071290-eada-4f54-ae48-e25666641165'),
('3164b624-4cc6-485e-b03d-c3fa53398516', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '3ddbecbb-379f-4825-b482-5870d3d759c9', NULL, 'Upaya Paksa', 15, 'CURRENT_2026', 'ee3d4cb9-a434-45b8-8722-6be484b66a01'),
('3519887c-793d-406d-896e-d747a492f1bd', 2, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '5176f1ed-e1c9-4f8c-aac8-0d6b69dab546', NULL, 'Penyelenggaraan SIM TNI AD', 9, 'CURRENT_2026', NULL),
('357075c5-640b-4688-b058-c302bbb52fa0', 2, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'df3da909-7f97-4451-8dbc-bece8ede3214', NULL, 'Pembinaan Provos Angkatan Darat', 10, 'CURRENT_2026', NULL),
('437f8786-d607-443e-b333-975c77be4d1b', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '58478d16-757d-47ab-9cb7-94b211de331e', NULL, 'Razia di Dalam Kereta Api', 7, 'CURRENT_2026', '50071290-eada-4f54-ae48-e25666641165'),
('50071290-eada-4f54-ae48-e25666641165', 0, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'bbe30eec-b63d-456c-be51-e5dd6ac5a9f8', NULL, 'Razia', 4, 'CURRENT_2026', NULL),
('63997398-ee31-4798-b8ad-2473a25ea205', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '2770fdc4-c2a7-42f0-b49c-d69a43409a8b', NULL, 'Mendatangi TKP', 12, 'CURRENT_2026', 'ee3d4cb9-a434-45b8-8722-6be484b66a01'),
('80d94aa2-79e0-4dcb-93b7-e3f0109bc3ff', 2, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '5165560c-e4a8-4a9e-b768-05a2438e6cb7', NULL, 'Penangkapan', 16, 'CURRENT_2026', '3164b624-4cc6-485e-b03d-c3fa53398516'),
('8e921b15-a387-4244-b933-a92ea2595256', 0, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'd60837c6-0b8f-4244-85da-15c745d8cafd', NULL, 'Patroli', 1, 'CURRENT_2026', NULL),
('a7e6c1d2-d236-4bd5-bd95-98469f94ff9f', 2, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '6a15b0ab-b49d-43ab-92a2-56f0c44ed0bb', NULL, 'Penyegelan', 18, 'CURRENT_2026', '3164b624-4cc6-485e-b03d-c3fa53398516'),
('d32eef37-50e3-4a57-aafa-48c08b735609', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'dd0ed3fd-8935-494a-9a3b-98647b3f5a8e', NULL, 'WAS Perbatasan', 14, 'CURRENT_2026', 'ee3d4cb9-a434-45b8-8722-6be484b66a01'),
('da2bffa7-e749-44e7-8149-35f2388773fb', 2, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, '2056ed43-7471-456e-bcde-512f15fbe2e5', NULL, 'Penggeledahan', 17, 'CURRENT_2026', '3164b624-4cc6-485e-b03d-c3fa53398516'),
('ee3d4cb9-a434-45b8-8722-6be484b66a01', 0, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'c20ac601-9524-4762-beac-a4c159cfee37', NULL, 'Lain-lain', 11, 'CURRENT_2026', NULL),
('fdeb6e8b-4366-4f63-9268-8ea9b54cb0bb', 1, NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'ff875776-5c5f-48e9-8b43-366cf85cd9a4', NULL, 'BAN POM UTK KAM UMUM', 13, 'CURRENT_2026', 'ee3d4cb9-a434-45b8-8722-6be484b66a01')
on conflict do nothing;
insert into "public"."violations" ("id", "active", "category", "created_at", "canonical_code", "canonical_name") values
('08724695-faf8-4d82-8241-aec5083f5867', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B10', 'B10 Menjadi Backing'),
('359cb23e-b8af-420b-b2d8-0e6ce890d85c', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B8', 'B8 Surat Senjata Api'),
('3f0205dc-5cf2-45af-aa88-12e714ae12c7', true, 'C', '2026-10-01T11:46:30.907115+00:00', 'C4', 'C4 TDK Menggunakan Sabuk PAM'),
('42332307-3797-4329-ae35-e598d588cbad', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B2', 'B2 GAM TNI'),
('4fed9702-455b-4244-85ce-d15debbc29d6', true, 'C', '2026-10-01T11:46:30.907115+00:00', 'C6', 'C6 Pel. Sopan Santun Lalin'),
('64a2149b-5df6-4766-b1bf-e47a399060fa', true, 'C', '2026-10-01T11:46:30.907115+00:00', 'C3', 'C3 Pelanggaran Rambu, Marka JL, DLL'),
('67211de5-15c2-4ea8-bd50-6c25d60e4df6', true, 'C', '2026-10-01T11:46:30.907115+00:00', 'C1', 'C1 Kelengkapan MIN RAN'),
('76eb57b1-3fb9-4422-bf64-2bad9ec24942', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B4', 'B4 Memasuki Daerah Terlarang'),
('80915529-a308-407a-a809-de3e8f81a0a5', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B1', 'B1 P P M'),
('90243763-b266-45ce-acc9-e53116fda8be', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B6', 'B6 Terlambat Apel'),
('919d9fb4-383e-454d-b469-d593fb948759', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B9', 'B9 Pungutan Liar'),
('a4063543-b70d-4f8b-ad6e-673d9458a8ed', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B3', 'B3 P D G'),
('a547b1fb-1b85-4bd6-b820-7e3b4d6c0ea9', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B11', 'B11 Tingkah Laku Tercela Lainnya Bertentangan dengan Perintah/Peraturan Kedinasan/Tidak Sesuai dengan Tata Tertib Militer'),
('af0cd5cf-99fb-4164-9d8b-433ebd9dcad6', true, 'C', '2026-10-01T11:46:30.907115+00:00', 'C2', 'C2 Kelengkapan ALPAL RAN yg Wajib'),
('e22be5de-c468-4b03-8b5a-6a20029e5d9b', true, 'C', '2026-10-01T11:46:30.907115+00:00', 'C5', 'C5 Tidak Menggunakan Helm'),
('e664100d-f80f-4e98-9d14-b3ea894ca077', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B5', 'B5 Keluar Markas SLM Jam Dinas'),
('febaee3a-befc-4edb-8b6f-6a5939ae0066', true, 'B', '2026-10-01T11:46:30.907115+00:00', 'B7', 'B7 Surat Nyata Diri')
on conflict do nothing;
insert into "public"."violation_versions" ("id", "valid_to", "created_at", "valid_from", "source_code", "source_label", "violation_id", "display_order", "source_period") values
('26ed21ec-90bc-452d-9e75-c6bef3a020d9', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B11', 'B11 Tingkah Laku Tercela Lainnya Bertentangan dengan Perintah/Peraturan Kedinasan/Tidak Sesuai dengan Tata Tertib Militer', 'a547b1fb-1b85-4bd6-b820-7e3b4d6c0ea9', 3, 'CURRENT_2026'),
('32541a98-acd2-48f6-a07c-d905bb2ea2e6', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B10', 'B10 Menjadi Backing', '08724695-faf8-4d82-8241-aec5083f5867', 2, 'CURRENT_2026'),
('3d1fd4e8-376d-47f4-933d-d58277908a38', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B9', 'B9 Pungutan Liar', '919d9fb4-383e-454d-b469-d593fb948759', 11, 'CURRENT_2026'),
('3e76311b-efeb-4bb7-8d70-f43c334c200d', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'C2', 'C2 Kelengkapan ALPAL RAN yg Wajib', 'af0cd5cf-99fb-4164-9d8b-433ebd9dcad6', 2, 'CURRENT_2026'),
('42cc43cb-f4ff-49c9-bff2-82bc46289770', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B3', 'B3 P D G', 'a4063543-b70d-4f8b-ad6e-673d9458a8ed', 5, 'CURRENT_2026'),
('67862439-e9d0-4894-a1fc-cc30d7f8252a', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B2', 'B2 GAM TNI', '42332307-3797-4329-ae35-e598d588cbad', 4, 'CURRENT_2026'),
('6cb3b65a-2812-4376-88c1-3efd5398d61d', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B8', 'B8 Surat Senjata Api', '359cb23e-b8af-420b-b2d8-0e6ce890d85c', 10, 'CURRENT_2026'),
('72be1b37-2f7d-4c4d-ad0d-bdd45f7ae3b3', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B5', 'B5 Keluar Markas SLM Jam Dinas', 'e664100d-f80f-4e98-9d14-b3ea894ca077', 7, 'CURRENT_2026'),
('73388de4-8dc8-4160-bc32-a156e5a5b1ff', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'C1', 'C1 Kelengkapan MIN RAN', '67211de5-15c2-4ea8-bd50-6c25d60e4df6', 1, 'CURRENT_2026'),
('a7989805-b84e-4743-8508-56e94c873095', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B1', 'B1 P P M', '80915529-a308-407a-a809-de3e8f81a0a5', 1, 'CURRENT_2026'),
('bd519c1b-5a1a-45fa-ad72-f8485efac2cb', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'C6', 'C6 Pel. Sopan Santun Lalin', '4fed9702-455b-4244-85ce-d15debbc29d6', 6, 'CURRENT_2026'),
('c4423832-6b4f-43f0-bbf9-1ce761dd2d47', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'C5', 'C5 Tidak Menggunakan Helm', 'e22be5de-c468-4b03-8b5a-6a20029e5d9b', 5, 'CURRENT_2026'),
('cb835c57-9f62-4fce-9ba1-edaae8a177a8', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'C4', 'C4 TDK Menggunakan Sabuk PAM', '3f0205dc-5cf2-45af-aa88-12e714ae12c7', 4, 'CURRENT_2026'),
('cd2d50cd-ae7c-4c4c-8c14-5d84e3e2707f', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B6', 'B6 Terlambat Apel', '90243763-b266-45ce-acc9-e53116fda8be', 8, 'CURRENT_2026'),
('d52efdb4-a779-4412-9ecf-18c5c38b91e4', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B7', 'B7 Surat Nyata Diri', 'febaee3a-befc-4edb-8b6f-6a5939ae0066', 9, 'CURRENT_2026'),
('de528143-acdd-4d71-b7fb-4c923ca6bffd', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'B4', 'B4 Memasuki Daerah Terlarang', '76eb57b1-3fb9-4422-bf64-2bad9ec24942', 6, 'CURRENT_2026'),
('eedf68ec-830c-4e2f-9aa5-796e1d885113', NULL, '2026-10-01T11:46:30.907115+00:00', NULL, 'C3', 'C3 Pelanggaran Rambu, Marka JL, DLL', '64a2149b-5df6-4766-b1bf-e47a399060fa', 3, 'CURRENT_2026')
on conflict do nothing;
insert into "public"."education_statuses" ("id", "code", "name", "active", "created_at", "display_order") values
('6759a374-2df1-48fd-b045-5c84478f44ac', 'SUDAH', 'Sudah', true, '2026-10-01T11:22:17.520019+00:00', 1),
('eff09611-f1f0-4224-bdb7-021bd2bba723', 'BELUM', 'Belum', true, '2026-10-01T11:22:17.520019+00:00', 2)
on conflict do nothing;
insert into "public"."provos_strength_measures" ("id", "code", "name", "active", "created_at", "display_order") values
('0793ea06-d579-4e22-9fe2-7698493c4f5d', 'NYATA', 'Nyata', true, '2026-10-01T11:22:17.520019+00:00', 2),
('512982f4-6620-4329-8dc3-f40b56097649', 'DSPP', 'DSPP', true, '2026-10-01T11:22:17.520019+00:00', 1)
on conflict do nothing;
insert into "public"."accident_types" ("id", "code", "name", "active", "created_at", "display_order") values
('4350789b-31f8-47b5-82d1-0ed63353fa28', 'GANDA', 'Ganda', true, '2026-10-01T11:22:17.520019+00:00', 1),
('5672ee77-0c4f-47e8-93c9-2347cb085b65', 'TABRAK_LARI', 'Tabrak Lari', true, '2026-10-01T11:22:17.520019+00:00', 3),
('999e5287-1c08-4ed1-8a14-6a556443dc50', 'TUNGGAL', 'Tunggal', true, '2026-10-01T11:22:17.520019+00:00', 2)
on conflict do nothing;
insert into "public"."victim_outcomes" ("id", "code", "name", "active", "created_at", "display_order") values
('82879a9d-f4e6-4bd5-b8c5-2236947639af', 'LB', 'Luka Berat', true, '2026-10-01T11:22:17.520019+00:00', 2),
('c0e00b25-e5f3-43a9-a24e-eb7187d1237b', 'MD', 'Meninggal Dunia', true, '2026-10-01T11:22:17.520019+00:00', 1),
('e8f1a4a2-58a3-4b34-86d3-cf69f632e849', 'LR', 'Luka Ringan', true, '2026-10-01T11:22:17.520019+00:00', 3)
on conflict do nothing;
insert into "public"."vehicle_categories" ("id", "code", "name", "active", "created_at", "display_order") values
('d36cca10-0618-4f4a-a728-4722676831da', 'RANDIS', 'Kendaraan Dinas', true, '2026-10-01T11:22:17.520019+00:00', 1),
('e26d927d-d108-491c-82e7-2217d290bddc', 'RAN_UMUM', 'Kendaraan Umum', true, '2026-10-01T11:22:17.520019+00:00', 2)
on conflict do nothing;
insert into "public"."material_damage_types" ("id", "code", "name", "active", "created_at", "display_order") values
('57fccd80-5735-4952-b13e-82be34aa77b1', 'RR', 'Rusak Ringan', true, '2026-10-01T11:22:17.520019+00:00', 2),
('78f27b88-8186-4643-a3ab-bbdf1584d868', 'RB', 'Rusak Berat', true, '2026-10-01T11:22:17.520019+00:00', 1)
on conflict do nothing;
insert into "public"."criminal_offenses" ("id", "active", "created_at", "canonical_key", "canonical_name") values
('036dea33-969a-4bf3-9330-74a3c10cb12c', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_047', 'Perkosaan'),
('0473e594-8291-4b34-95b4-e7d829382977', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_046', 'Perkelahian'),
('04d0a627-4afa-43d0-99e9-d87551b9a0a2', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_025', 'Pencemaran Lingkungan'),
('053e2327-dc0e-4143-bbdd-ab13fe4d550c', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_075', 'Penyerobotan tanah'),
('06016517-d219-4e38-87ff-17a86c7210bd', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_090', 'Pencucian uang'),
('085e3fe3-1293-461d-8a58-a58b7c3a1b71', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_089', 'Pembiaran terjadinya suatu kejahatan'),
('089cdce0-d876-489d-86a8-faeaf0c289b9', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_021', 'Pemalsuan'),
('0badb5ee-49b4-4e96-a157-9f20704f24f2', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_051', 'Werfing'),
('103e9cc6-60db-4d05-9b78-9ba23172a2f4', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_105', 'Tindak pidana cukai'),
('17099292-1c67-4278-9d38-2e59bc9ab21f', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_017', 'Meninggalkan Pos'),
('1739de5c-b3b1-4347-a5b5-f5d52f4b0f61', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_040', 'Penyelundupan'),
('17a1bef6-8781-42aa-aadc-3d6a11fee0f7', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_048', 'Perzinahan'),
('19976107-ac73-4f2f-a1b6-9f4b97d4c0cb', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_020', 'Pel./Kej. Thdp ketertiban umum'),
('19fb52f4-4c32-4bb9-a0e0-50026d5ec76a', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_080', 'Nikah siri'),
('20b3ae2a-fec7-4881-a18a-5700eac29436', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_035', 'Penipuan'),
('22f6251c-d879-47ad-8626-285eb7fc3b94', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_078', 'Melakukan kekerasan'),
('23bee93b-2749-4d77-8a8f-6a73f509cf8f', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_009', 'Kelalaian/Pel Thd Kew Dinas'),
('244c091b-3779-4ef1-be4f-469ae7ce5512', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_064', 'Penarikan barbuk'),
('253504f5-9a57-4165-8ea3-5284c1e797d6', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_022', 'Pembunuhan'),
('26aff2c9-d1a7-4daf-bcca-4ac94ed8b952', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_032', 'Penghinaan'),
('282729eb-aaad-4474-bae9-9437a17b4a17', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_010', 'Korupsi'),
('2c6ce093-753d-4415-a265-a4a0bb748c5b', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_087', 'Sembunyikan Jenazah hasil kejahatan'),
('32cece47-0086-4ab6-836e-46400a8761ab', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_018', 'Menolak perintah'),
('35ae82d3-89a2-4315-8803-3647c9ec4ad1', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_019', 'Narkotika/Psykotropika'),
('36809ba8-3c68-4bd5-8305-6c981b620ab2', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_073', 'Pelanggaran IT'),
('37080b8a-f238-4f6a-b182-2e541e8f01e0', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_071', 'Menghalangi penyidikan'),
('38cd4f54-3cfb-4e5a-a818-7f8746e26256', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_098', 'Pungutan liar'),
('3e168a0f-be6c-4322-9d76-ccb98d61ae12', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_045', 'Perjudian'),
('3f0aa7fc-0eb1-4c7c-96ce-a1870fb794ed', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_049', 'Poligami'),
('417948eb-d965-4227-bcd0-cacc1edef00c', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_006', 'Karena lalai org lain luka/meninggal'),
('43bbcce5-1617-4adc-a576-fd919392d232', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_084', 'Kejahatan thdp penguasa umum'),
('45162712-6ec2-4274-8ac8-3e92b8449bed', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_003', 'Desersi'),
('4624a147-ff45-4f58-8c88-b18ac79314ff', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_053', 'Asal usul pernikahan'),
('4d01f6f2-45ce-4a4d-a078-56db1529d9c3', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_070', 'Penodaan Agama'),
('4f2ad895-0062-4539-8502-6b0b8616c0c3', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_097', 'Menyembunyikan/melindungi pelaku'),
('4fc1ef34-597f-4a4c-93b2-aed5bdc183f6', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_059', 'Turut serta melakukan kejahatan'),
('54f5c667-0ce4-4cce-bb8b-dd6ccec81418', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_076', 'Pertolongan jahat'),
('58012094-c272-486a-a09d-9aaf16d0bb83', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_024', 'Penadahan'),
('58b5b5dc-917d-41fb-a6bd-5d6a87710dc7', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_066', 'Membiarkan org yg minta tolong'),
('598929d9-22f8-4db1-873a-c17fbeee8082', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_044', 'Perbuatan tidak menyenangkan'),
('599c3bde-1e88-426b-b9ab-313a817f8de6', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_036', 'Penyalahgunaan alat perang'),
('59bad7b6-67d5-4e88-aea4-5ae1abee5f60', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_103', 'Memasuki pekarangan tanpa izin'),
('5a00c448-975e-45e4-b8c0-a9e1438c647e', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_101', 'Kepemilikan Senpi dan pengancaman dengan kekerasan'),
('5c4b8db0-8524-4e18-8007-9ebb4fd93987', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_011', 'Merampas kemerdekaan org'),
('5f8d0c93-dc60-415c-8558-ee82af4aee23', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_074', 'Percobaan pembunuhan'),
('6054cbcb-b2e0-4a5d-be6a-41f601b488dd', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_052', 'Kejahatan thd kesusilaan'),
('6715e8de-7b75-472f-a523-a86adca2b1c6', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_057', 'Penambangan liar'),
('679011c7-3e28-4edc-b4e2-256536e55ae4', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_042', 'Penganiyaan terhadap bawahan'),
('6c6656b1-6c90-4231-89f3-15e30ff7b216', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_065', 'Aborsi'),
('6d0ccdb1-8404-4fae-b712-90e9aafa4880', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_104', 'Menjadi Backing'),
('6e0eedc5-cebd-465c-ad24-c1022750841d', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_056', 'Menjual aset negara'),
('6e76d8f8-9104-4528-99e1-04e55a41c5b6', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_092', 'Pembakaran'),
('6e865f3d-865f-4d0f-ba68-e6902ddd3ad2', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_031', 'Penggelapan'),
('7132b26f-34e5-4f8e-baf0-4b1e4eea63ee', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_001', 'Asusila'),
('7341ba4e-73d2-4c26-8462-9d12fcc2c95b', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_086', 'Illegal Minning'),
('73c4491b-6199-4f00-8c26-56501f5777ea', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_013', 'Melarikan wanita'),
('774d1075-880e-43ad-98e9-05c2263bb06b', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_028', 'Pencabulan'),
('7981064f-7dd3-41d1-9d98-f0c7382cd802', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_068', 'Illegal Fishing'),
('7a7ba028-f7fe-49d6-aba5-46d65c0c6729', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_100', 'Penyimpangan seksual/LGBT'),
('7e0f6f67-7297-447c-a0d7-be9da3938b7f', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_077', 'Tidak melapor atasan'),
('7ebd4c25-c247-44d3-a7ae-21c67fdd2aeb', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_033', 'Penghasutan'),
('804c1522-a046-4ac7-8fba-e3a8c19f1eb9', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_029', 'Pengancaman'),
('863ed85b-a2bd-4d9d-885a-07fdea7c018f', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_027', 'Pencurian'),
('875bc56f-f652-463b-a63d-bd1cab2bfb0e', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_085', 'Keterangan palsu'),
('8876b376-6865-47a8-a6aa-317036f322f1', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_005', 'Illegal Logging'),
('8b46ecdf-cc3c-4dea-b891-c570fd43b64e', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_030', 'Penganiayaan'),
('92db8ab6-8132-49ce-a836-fb7a78711f2e', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_038', 'Penyalahgunaan Senpi /munisi'),
('95045b0a-975c-4baa-813f-051851b02547', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_041', 'Penyuapan'),
('95e1f71c-aac4-4558-8b0e-5433e76e45d3', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_016', 'Mengedarkan uang palsu'),
('96f11d34-c417-4af0-84c1-ab4c1c82b87e', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_094', 'Kekerasan dengan tenaga bersama'),
('981889bd-5ae9-48fc-81b0-8b8c5cdc8f86', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_058', 'Senjata tajam'),
('984077f3-7b4c-414a-b60e-a83c313bf16b', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_067', 'Pencemaran nama baik'),
('99371837-ca2a-49ed-96a9-d3cd100ca7ee', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_061', 'Kekerasan dimuka umum'),
('994dfaff-6985-4526-9aac-9dd5ecd81ed5', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_093', 'Perdagangan ilegal'),
('997536f7-a90a-44d9-be56-c44aac3cbf4d', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_007', 'KDRT/menelantarkan keluarga'),
('a1766163-71aa-4e2c-a0e8-25ef8611fb4c', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_055', 'Satwa yang dilindungi'),
('a97d4088-cab1-4916-9399-b274a5c372ae', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_015', 'Mencampuri urusan perdata'),
('ab34b404-5367-41d3-a942-c8be947e98fd', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_039', 'Penyalahgunaan Wewenang/jabatan'),
('ad355642-1531-48ad-a263-30f05490a60d', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_082', 'Penembakan'),
('b141f523-6860-493f-915d-0ef1312fadd1', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_069', 'Jual beli Ransum TNI'),
('b35a394b-6ec3-4048-9103-2968a611f28a', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_054', 'Pelecehan anak dibawah umur'),
('b74e793a-875d-4b4f-9cbf-0054b344da4f', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_102', 'Kekerasan yang menyebabkan meninggal dunia'),
('bbaa9c4a-2001-4c7e-8b32-a2cb589de59a', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_023', 'Pemerasan'),
('bfb6008c-8432-4f4f-89c9-7c75d331d15a', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_002', 'Bunuh Diri'),
('c0e3beb3-33bd-4e39-87c8-6644b6804a14', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_026', 'Penculikan'),
('c0fcb99b-71cd-49c2-abb7-614a8514c416', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_063', 'Menghilangkan barang bukti/Inventaris'),
('c9600b57-7b5c-419d-a777-12437b933c01', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_095', 'Penyekapan'),
('d213a640-262a-49e1-8c30-c60c4c660cbc', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_012', 'Main hakim sendiri'),
('d2eaf0f6-cc29-4b7e-b76f-099147bb4e7d', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_034', 'Pengrusakan'),
('d62be2d0-83b2-4115-82be-8201d90ce3b6', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_037', 'Penyalahgunaan Migas/BBM'),
('d88a630e-badf-4cec-a10e-9aaa351e9040', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_060', 'Kejahatan ttd kesopanan'),
('db73984a-9ac8-4040-ae7b-b26820dc7add', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_096', 'penyalahgunaan Amunisi'),
('e076f1ef-ae80-4870-87a8-82cb57242c41', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_099', 'Tidak menaati perintah'),
('e0de5585-ff84-4c07-b9d3-aa00ab805110', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_014', 'Melawan Atasan/Insubordinasi'),
('e26af470-b9c8-46c1-800b-22bb07d96b2f', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_083', 'Pemaksaan'),
('e783a59c-7aca-47fa-b417-b14af6f4edcd', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_043', 'Perampokan'),
('e834d3c6-ece7-45a7-9183-6c6fd48e2d2c', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_079', 'Pengeroyokan'),
('ea4d2a68-3617-48a5-b93b-a68955aeedfa', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_050', 'Pornografi'),
('eb302db6-4351-4210-9d4d-81011aeafcb3', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_062', 'Kejahatan terhadap jabatan'),
('ed370a03-958e-46c6-b3d8-2238e16c6a74', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_088', 'Militer yg tidak m''beri tahu pada penguasa'),
('ef8effe4-ce7d-4dee-847b-f280d4e3f2ed', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_072', 'Jual beli Kaporlap'),
('f50139b1-7ba3-4777-8bc5-37622e6555bf', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_091', 'Atasan memukul bawahan'),
('f9bef0d0-91fd-402e-b826-0003c36517a3', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_008', 'Kejahatan Thd ketaatan'),
('f9e952a5-c255-4549-80f1-66a90f873100', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_081', 'Jual Miras'),
('fcba738b-c423-4cef-9f20-52de81b86705', true, '2026-10-01T11:46:46.321526+00:00', 'OFFENSE_004', 'THTI')
on conflict do nothing;
insert into "public"."criminal_offense_versions" ("id", "valid_to", "created_at", "offense_id", "valid_from", "source_label", "display_order", "source_number", "source_period") values
('03e69e87-3866-4006-a603-81daa8bf26f2', NULL, '2026-10-01T11:46:46.321526+00:00', '5c4b8db0-8524-4e18-8007-9ebb4fd93987', NULL, 'Merampas kemerdekaan org', 11, 11, 'AUG_2026'),
('04390f00-ea62-403b-9497-acf96bff2f02', NULL, '2026-10-01T11:46:46.321526+00:00', '04d0a627-4afa-43d0-99e9-d87551b9a0a2', NULL, 'Pencemaran Lingkungan', 25, 25, 'AUG_2026'),
('05b5bc37-d8f7-4194-a3fd-8cb08a421379', NULL, '2026-10-01T11:46:46.321526+00:00', '4d01f6f2-45ce-4a4d-a078-56db1529d9c3', NULL, 'Penodaan Agama', 70, 70, 'AUG_2026'),
('07a69fca-2f51-4623-95cc-c0d325fb7f9a', NULL, '2026-10-01T11:46:46.321526+00:00', 'bfb6008c-8432-4f4f-89c9-7c75d331d15a', NULL, 'Bunuh Diri', 2, 2, 'AUG_2026'),
('08c36c38-3582-463d-8a96-e5cb074c5596', NULL, '2026-10-01T11:46:46.321526+00:00', 'e26af470-b9c8-46c1-800b-22bb07d96b2f', NULL, 'Pemaksaan', 83, 83, 'AUG_2026'),
('0938d608-e9b2-486e-980c-7e8a83a18c44', NULL, '2026-10-01T11:46:46.321526+00:00', '06016517-d219-4e38-87ff-17a86c7210bd', NULL, 'Pencucian uang', 90, 90, 'AUG_2026'),
('0968e4c4-1959-490e-8025-18126297c0ac', NULL, '2026-10-01T11:46:46.321526+00:00', '92db8ab6-8132-49ce-a836-fb7a78711f2e', NULL, 'Penyalahgunaan Senpi /munisi', 38, 38, 'AUG_2026'),
('1090e942-7d80-4690-a298-ceb9bdcad85d', NULL, '2026-10-01T11:46:46.321526+00:00', 'ed370a03-958e-46c6-b3d8-2238e16c6a74', NULL, 'Militer yg tidak m''beri tahu pada penguasa', 88, 88, 'AUG_2026'),
('1a5e3d93-865d-4521-a916-1030cae97ed1', NULL, '2026-10-01T11:46:46.321526+00:00', '96f11d34-c417-4af0-84c1-ab4c1c82b87e', NULL, 'Kekerasan dengan tenaga bersama', 94, 94, 'AUG_2026'),
('1acc9122-7103-4342-ae19-0b825cc1b830', NULL, '2026-10-01T11:46:46.321526+00:00', '54f5c667-0ce4-4cce-bb8b-dd6ccec81418', NULL, 'Pertolongan jahat', 76, 76, 'AUG_2026'),
('1c418b65-ee20-4dbd-9318-ee93d65dfa1b', NULL, '2026-10-01T11:46:46.321526+00:00', '7981064f-7dd3-41d1-9d98-f0c7382cd802', NULL, 'Illegal Fishing', 68, 68, 'AUG_2026'),
('1e9217b7-70cc-4327-8768-9ff0c64947b9', NULL, '2026-10-01T11:46:46.321526+00:00', '5a00c448-975e-45e4-b8c0-a9e1438c647e', NULL, 'Kepemilikan Senpi dan pengancaman dengan kekerasan', 101, 101, 'AUG_2026'),
('1ec4f856-4c22-451c-b05e-0a5cd4d3574a', NULL, '2026-10-01T11:46:46.321526+00:00', '99371837-ca2a-49ed-96a9-d3cd100ca7ee', NULL, 'Kekerasan dimuka umum', 61, 61, 'AUG_2026'),
('2023ffc5-e8fc-494c-bab3-cf51f18ee650', NULL, '2026-10-01T11:46:46.321526+00:00', '244c091b-3779-4ef1-be4f-469ae7ce5512', NULL, 'Penarikan barbuk', 64, 64, 'AUG_2026'),
('244e44ec-4de7-4be1-a9be-ce71e0b56e60', NULL, '2026-10-01T11:46:46.321526+00:00', '282729eb-aaad-4474-bae9-9437a17b4a17', NULL, 'Korupsi', 10, 10, 'AUG_2026'),
('25edaa3e-f48c-4e49-8a39-ce7c3e227f95', NULL, '2026-10-01T11:46:46.321526+00:00', '22f6251c-d879-47ad-8626-285eb7fc3b94', NULL, 'Melakukan kekerasan', 78, 78, 'AUG_2026'),
('27b2f8b6-8b5c-48e7-83db-5effb33652e6', NULL, '2026-10-01T11:46:46.321526+00:00', 'c0e3beb3-33bd-4e39-87c8-6644b6804a14', NULL, 'Penculikan', 26, 26, 'AUG_2026'),
('2ce70f43-72d6-4c5c-8472-035ddc0b7866', NULL, '2026-10-01T11:46:46.321526+00:00', 'c9600b57-7b5c-419d-a777-12437b933c01', NULL, 'Penyekapan', 95, 95, 'AUG_2026'),
('32663fc8-3d9c-4485-b259-350ecc6068c6', NULL, '2026-10-01T11:46:46.321526+00:00', 'a97d4088-cab1-4916-9399-b274a5c372ae', NULL, 'Mencampuri urusan perdata', 15, 15, 'AUG_2026'),
('35772e9c-1587-45af-a1c8-6cfd926fd847', NULL, '2026-10-01T11:46:46.321526+00:00', '598929d9-22f8-4db1-873a-c17fbeee8082', NULL, 'Perbuatan tidak menyenangkan', 44, 44, 'AUG_2026'),
('3800c6d7-6e6d-4555-92c8-3b6fe0dd0c97', NULL, '2026-10-01T11:46:46.321526+00:00', 'd2eaf0f6-cc29-4b7e-b76f-099147bb4e7d', NULL, 'Pengrusakan', 34, 34, 'AUG_2026'),
('39d69783-2d1e-44e1-99cd-ad0b7240c78c', NULL, '2026-10-01T11:46:46.321526+00:00', '95045b0a-975c-4baa-813f-051851b02547', NULL, 'Penyuapan', 41, 41, 'AUG_2026'),
('3e09b9dd-efdd-4504-a1b7-243d5e5cc159', NULL, '2026-10-01T11:46:46.321526+00:00', '804c1522-a046-4ac7-8fba-e3a8c19f1eb9', NULL, 'Pengancaman', 29, 29, 'AUG_2026'),
('3e6c3f36-456b-4b70-a93d-48cecf148e86', NULL, '2026-10-01T11:46:46.321526+00:00', '863ed85b-a2bd-4d9d-885a-07fdea7c018f', NULL, 'Pencurian', 27, 27, 'AUG_2026'),
('41c01cc0-b25d-4851-827f-c081998ed06f', NULL, '2026-10-01T11:46:46.321526+00:00', 'f9e952a5-c255-4549-80f1-66a90f873100', NULL, 'Jual Miras', 81, 81, 'AUG_2026'),
('44252be5-dc6f-4ef0-890b-ceedadca1616', NULL, '2026-10-01T11:46:46.321526+00:00', 'e076f1ef-ae80-4870-87a8-82cb57242c41', NULL, 'Tidak menaati perintah', 99, 99, 'AUG_2026'),
('490253ce-cc8e-4f48-8ebe-cf8ddd18942d', NULL, '2026-10-01T11:46:46.321526+00:00', '23bee93b-2749-4d77-8a8f-6a73f509cf8f', NULL, 'Kelalaian/Pel Thd Kew Dinas', 9, 9, 'AUG_2026'),
('49375128-4e7e-4a0e-9936-2b2a4ce6e3ae', NULL, '2026-10-01T11:46:46.321526+00:00', '089cdce0-d876-489d-86a8-faeaf0c289b9', NULL, 'Pemalsuan', 21, 21, 'AUG_2026'),
('498e8f43-15c3-4cac-8e2f-335f6be89df1', NULL, '2026-10-01T11:46:46.321526+00:00', '73c4491b-6199-4f00-8c26-56501f5777ea', NULL, 'Melarikan wanita', 13, 13, 'AUG_2026'),
('4b9db1fc-e848-4d1c-9e6a-6afe74b169b3', NULL, '2026-10-01T11:46:46.321526+00:00', '6715e8de-7b75-472f-a523-a86adca2b1c6', NULL, 'Penambangan liar', 57, 57, 'AUG_2026'),
('4be9da93-1a3f-4ba0-bb3e-b36f67f1d0b5', NULL, '2026-10-01T11:46:46.321526+00:00', 'f9bef0d0-91fd-402e-b826-0003c36517a3', NULL, 'Kejahatan Thd ketaatan', 8, 8, 'AUG_2026'),
('529d1966-7da7-4ff3-8368-03b048c9363d', NULL, '2026-10-01T11:46:46.321526+00:00', '417948eb-d965-4227-bcd0-cacc1edef00c', NULL, 'Karena lalai org lain luka/meninggal', 6, 6, 'AUG_2026'),
('5846844d-f72b-420e-9d06-ae8e07130534', NULL, '2026-10-01T11:46:46.321526+00:00', '036dea33-969a-4bf3-9330-74a3c10cb12c', NULL, 'Perkosaan', 47, 47, 'AUG_2026'),
('5a123db0-484b-4122-a9c5-71cd8231e69b', NULL, '2026-10-01T11:46:46.321526+00:00', 'e0de5585-ff84-4c07-b9d3-aa00ab805110', NULL, 'Melawan Atasan/Insubordinasi', 14, 14, 'AUG_2026'),
('5d46573d-34ba-4eed-9900-5171ef2d19e3', NULL, '2026-10-01T11:46:46.321526+00:00', 'c0fcb99b-71cd-49c2-abb7-614a8514c416', NULL, 'Menghilangkan barang bukti/Inventaris', 63, 63, 'AUG_2026'),
('5f1b4890-5e20-4bb8-84e4-06ae93255cb9', NULL, '2026-10-01T11:46:46.321526+00:00', '4f2ad895-0062-4539-8502-6b0b8616c0c3', NULL, 'Menyembunyikan/melindungi pelaku', 97, 97, 'AUG_2026'),
('5f8a088c-7722-440d-b950-a78ead660821', NULL, '2026-10-01T11:46:46.321526+00:00', 'b35a394b-6ec3-4048-9103-2968a611f28a', NULL, 'Pelecehan anak dibawah umur', 54, 54, 'AUG_2026'),
('5fd71e58-8545-4cd9-bfde-3b05c377006e', NULL, '2026-10-01T11:46:46.321526+00:00', '58012094-c272-486a-a09d-9aaf16d0bb83', NULL, 'Penadahan', 24, 24, 'AUG_2026'),
('61dc02e0-7855-46a5-a1f9-0ff69e413d59', NULL, '2026-10-01T11:46:46.321526+00:00', '7a7ba028-f7fe-49d6-aba5-46d65c0c6729', NULL, 'Penyimpangan seksual/LGBT', 100, 100, 'AUG_2026'),
('643c3509-1e7a-41dd-883d-759b1951e679', NULL, '2026-10-01T11:46:46.321526+00:00', '7e0f6f67-7297-447c-a0d7-be9da3938b7f', NULL, 'Tidak melapor atasan', 77, 77, 'AUG_2026'),
('6597b6f7-389b-47d2-a55b-1288155162ee', NULL, '2026-10-01T11:46:46.321526+00:00', '45162712-6ec2-4274-8ac8-3e92b8449bed', NULL, 'Desersi', 3, 3, 'AUG_2026'),
('67dda459-db70-45ce-85fc-0c2c323e5d3a', NULL, '2026-10-01T11:46:46.321526+00:00', '7ebd4c25-c247-44d3-a7ae-21c67fdd2aeb', NULL, 'Penghasutan', 33, 33, 'AUG_2026'),
('6d7f7f4f-fe81-47da-8249-a73dd31e9e81', NULL, '2026-10-01T11:46:46.321526+00:00', '38cd4f54-3cfb-4e5a-a818-7f8746e26256', NULL, 'Pungutan liar', 98, 98, 'AUG_2026'),
('750f8cfe-1e22-4316-a023-537d53cf22e2', NULL, '2026-10-01T11:46:46.321526+00:00', '981889bd-5ae9-48fc-81b0-8b8c5cdc8f86', NULL, 'Senjata tajam', 58, 58, 'AUG_2026'),
('78271985-00e5-41cc-952b-192e336f09d4', NULL, '2026-10-01T11:46:46.321526+00:00', '679011c7-3e28-4edc-b4e2-256536e55ae4', NULL, 'Penganiyaan terhadap bawahan', 42, 42, 'AUG_2026'),
('7e4b26f7-54c3-4877-8c3d-513652a03a70', NULL, '2026-10-01T11:46:46.321526+00:00', '7341ba4e-73d2-4c26-8462-9d12fcc2c95b', NULL, 'Illegal Minning', 86, 86, 'AUG_2026'),
('8498f90e-3f18-4a2c-996e-8529d1fb035c', NULL, '2026-10-01T11:46:46.321526+00:00', '17099292-1c67-4278-9d38-2e59bc9ab21f', NULL, 'Meninggalkan Pos', 17, 17, 'AUG_2026'),
('86a2681b-e0cd-475f-b955-a0007597312d', NULL, '2026-10-01T11:46:46.321526+00:00', '2c6ce093-753d-4415-a265-a4a0bb748c5b', NULL, 'Sembunyikan Jenazah hasil kejahatan', 87, 87, 'AUG_2026'),
('87e10f5b-cc51-429a-8fc2-fc9fdc3acf31', NULL, '2026-10-01T11:46:46.321526+00:00', '6e0eedc5-cebd-465c-ad24-c1022750841d', NULL, 'Menjual aset negara', 56, 56, 'AUG_2026'),
('92792856-13a5-4259-896f-847a47ddea7a', NULL, '2026-10-01T11:46:46.321526+00:00', 'bbaa9c4a-2001-4c7e-8b32-a2cb589de59a', NULL, 'Pemerasan', 23, 23, 'AUG_2026'),
('94099aa5-4851-4654-adbe-a99b3c7ccbf0', NULL, '2026-10-01T11:46:46.321526+00:00', 'b141f523-6860-493f-915d-0ef1312fadd1', NULL, 'Jual beli Ransum TNI', 69, 69, 'AUG_2026'),
('94c7e399-e8e2-424d-9737-292ac8efc6d9', NULL, '2026-10-01T11:46:46.321526+00:00', '17a1bef6-8781-42aa-aadc-3d6a11fee0f7', NULL, 'Perzinahan', 48, 48, 'AUG_2026'),
('94f4230a-f101-4aa5-99a6-d58613fc9436', NULL, '2026-10-01T11:46:46.321526+00:00', '085e3fe3-1293-461d-8a58-a58b7c3a1b71', NULL, 'Pembiaran terjadinya suatu kejahatan', 89, 89, 'AUG_2026'),
('95bde875-1b36-43e9-b88f-51d29726f030', NULL, '2026-10-01T11:46:46.321526+00:00', '95e1f71c-aac4-4558-8b0e-5433e76e45d3', NULL, 'Mengedarkan uang palsu', 16, 16, 'AUG_2026'),
('969f21e4-406d-4ee1-a3e4-83fefbfdc06b', NULL, '2026-10-01T11:46:46.321526+00:00', 'ef8effe4-ce7d-4dee-847b-f280d4e3f2ed', NULL, 'Jual beli Kaporlap', 72, 72, 'AUG_2026'),
('9b776297-af9c-4819-a429-3c1ab82f6540', NULL, '2026-10-01T11:46:46.321526+00:00', 'a1766163-71aa-4e2c-a0e8-25ef8611fb4c', NULL, 'Satwa yang dilindungi', 55, 55, 'AUG_2026'),
('9c84e5b3-02a4-48ab-99ad-a788accada6b', NULL, '2026-10-01T11:46:46.321526+00:00', '103e9cc6-60db-4d05-9b78-9ba23172a2f4', NULL, 'Tindak pidana cukai', 105, 105, 'AUG_2026'),
('9d706c13-e7d5-4448-bb84-940fc1df7e6d', NULL, '2026-10-01T11:46:46.321526+00:00', '7132b26f-34e5-4f8e-baf0-4b1e4eea63ee', NULL, 'Asusila', 1, 1, 'AUG_2026'),
('9f703857-26a2-492c-8299-e2ed0f5a93f5', NULL, '2026-10-01T11:46:46.321526+00:00', '4fc1ef34-597f-4a4c-93b2-aed5bdc183f6', NULL, 'Turut serta melakukan kejahatan', 59, 59, 'AUG_2026'),
('9fd3e827-9d0e-4e44-8db6-48eb5d465318', NULL, '2026-10-01T11:46:46.321526+00:00', '6d0ccdb1-8404-4fae-b712-90e9aafa4880', NULL, 'Menjadi Backing', 104, 104, 'AUG_2026'),
('a295d607-c71f-46c0-b7e3-f04770720b59', NULL, '2026-10-01T11:46:46.321526+00:00', '0badb5ee-49b4-4e96-a157-9f20704f24f2', NULL, 'Werfing', 51, 51, 'AUG_2026'),
('a3790c0b-814d-4d94-a2b1-be5b8aba7c30', NULL, '2026-10-01T11:46:46.321526+00:00', 'd88a630e-badf-4cec-a10e-9aaa351e9040', NULL, 'Kejahatan ttd kesopanan', 60, 60, 'AUG_2026'),
('a6ca1bb6-d237-4622-807c-e748d9e46fa7', NULL, '2026-10-01T11:46:46.321526+00:00', 'e783a59c-7aca-47fa-b417-b14af6f4edcd', NULL, 'Perampokan', 43, 43, 'AUG_2026'),
('a99dab6e-d243-46c3-b292-15c1c3c2205c', NULL, '2026-10-01T11:46:46.321526+00:00', '20b3ae2a-fec7-4881-a18a-5700eac29436', NULL, 'Penipuan', 35, 35, 'AUG_2026'),
('abf81101-53fe-444e-a86e-252532eef646', NULL, '2026-10-01T11:46:46.321526+00:00', '37080b8a-f238-4f6a-b182-2e541e8f01e0', NULL, 'Menghalangi penyidikan', 71, 71, 'AUG_2026'),
('ac25599c-a884-4573-bc65-d1df859b462b', NULL, '2026-10-01T11:46:46.321526+00:00', '774d1075-880e-43ad-98e9-05c2263bb06b', NULL, 'Pencabulan', 28, 28, 'AUG_2026'),
('ac75d658-6cf1-4d34-843c-ce5453fedf22', NULL, '2026-10-01T11:46:46.321526+00:00', '1739de5c-b3b1-4347-a5b5-f5d52f4b0f61', NULL, 'Penyelundupan', 40, 40, 'AUG_2026'),
('adb36199-5bc2-4628-a27a-48240d0c4daa', NULL, '2026-10-01T11:46:46.321526+00:00', '0473e594-8291-4b34-95b4-e7d829382977', NULL, 'Perkelahian', 46, 46, 'AUG_2026'),
('af089176-31b7-4430-9f6b-003ca60bcff6', NULL, '2026-10-01T11:46:46.321526+00:00', 'eb302db6-4351-4210-9d4d-81011aeafcb3', NULL, 'Kejahatan terhadap jabatan', 62, 62, 'AUG_2026'),
('b0a24d6d-0e79-42e6-b0eb-7a9d8d79b17c', NULL, '2026-10-01T11:46:46.321526+00:00', 'd213a640-262a-49e1-8c30-c60c4c660cbc', NULL, 'Main hakim sendiri', 12, 12, 'AUG_2026'),
('b30e8880-ef5c-430e-8f7c-00e0bc513b6a', NULL, '2026-10-01T11:46:46.321526+00:00', '599c3bde-1e88-426b-b9ab-313a817f8de6', NULL, 'Penyalahgunaan alat perang', 36, 36, 'AUG_2026'),
('b80b59fa-831c-4c59-a1cf-2af2e2832945', NULL, '2026-10-01T11:46:46.321526+00:00', 'b74e793a-875d-4b4f-9cbf-0054b344da4f', NULL, 'Kekerasan yang menyebabkan meninggal dunia', 102, 102, 'AUG_2026'),
('b82dbeb1-e018-498a-b4f6-10cb676e084e', NULL, '2026-10-01T11:46:46.321526+00:00', 'ab34b404-5367-41d3-a942-c8be947e98fd', NULL, 'Penyalahgunaan Wewenang/jabatan', 39, 39, 'AUG_2026'),
('bec9b5a2-763b-4441-80ab-87ead9fb00ee', NULL, '2026-10-01T11:46:46.321526+00:00', '3e168a0f-be6c-4322-9d76-ccb98d61ae12', NULL, 'Perjudian', 45, 45, 'AUG_2026'),
('c61f574a-0b7b-4fba-ae3a-0c112072fab6', NULL, '2026-10-01T11:46:46.321526+00:00', '253504f5-9a57-4165-8ea3-5284c1e797d6', NULL, 'Pembunuhan', 22, 22, 'AUG_2026'),
('c66c0d4f-f6a6-4eb5-8296-33f09b4ba4b6', NULL, '2026-10-01T11:46:46.321526+00:00', '997536f7-a90a-44d9-be56-c44aac3cbf4d', NULL, 'KDRT/menelantarkan keluarga', 7, 7, 'AUG_2026'),
('c6d274a0-15c9-424c-98c9-5d9a40dfca5a', NULL, '2026-10-01T11:46:46.321526+00:00', '36809ba8-3c68-4bd5-8305-6c981b620ab2', NULL, 'Pelanggaran IT', 73, 73, 'AUG_2026'),
('c87db462-82d4-44ed-a7e9-f99de0a66adf', NULL, '2026-10-01T11:46:46.321526+00:00', 'e834d3c6-ece7-45a7-9183-6c6fd48e2d2c', NULL, 'Pengeroyokan', 79, 79, 'AUG_2026'),
('caba7283-7bbd-45b5-b6dc-a610c4979edf', NULL, '2026-10-01T11:46:46.321526+00:00', '58b5b5dc-917d-41fb-a6bd-5d6a87710dc7', NULL, 'Membiarkan org yg minta tolong', 66, 66, 'AUG_2026'),
('ccc78cff-32eb-45d6-b2c1-febf750d6090', NULL, '2026-10-01T11:46:46.321526+00:00', '6054cbcb-b2e0-4a5d-be6a-41f601b488dd', NULL, 'Kejahatan thd kesusilaan', 52, 52, 'AUG_2026'),
('d231408d-4774-4c92-a138-bfcd8718cdbf', NULL, '2026-10-01T11:46:46.321526+00:00', '8876b376-6865-47a8-a6aa-317036f322f1', NULL, 'Illegal Logging', 5, 5, 'AUG_2026'),
('d2617699-5542-4869-81fe-0e658b8c4025', NULL, '2026-10-01T11:46:46.321526+00:00', '35ae82d3-89a2-4315-8803-3647c9ec4ad1', NULL, 'Narkotika/Psykotropika', 19, 19, 'AUG_2026'),
('d44497a1-b243-468e-ae2a-64622453dee6', NULL, '2026-10-01T11:46:46.321526+00:00', '43bbcce5-1617-4adc-a576-fd919392d232', NULL, 'Kejahatan thdp penguasa umum', 84, 84, 'AUG_2026'),
('d61277e8-db11-427f-9011-487a627a794e', NULL, '2026-10-01T11:46:46.321526+00:00', '19976107-ac73-4f2f-a1b6-9f4b97d4c0cb', NULL, 'Pel./Kej. Thdp ketertiban umum', 20, 20, 'AUG_2026'),
('d68d09f3-07ea-4810-b112-77557eda8794', NULL, '2026-10-01T11:46:46.321526+00:00', '6e76d8f8-9104-4528-99e1-04e55a41c5b6', NULL, 'Pembakaran', 92, 92, 'AUG_2026'),
('d8a1104f-0662-4a74-8228-f34db1512e51', NULL, '2026-10-01T11:46:46.321526+00:00', '5f8d0c93-dc60-415c-8558-ee82af4aee23', NULL, 'Percobaan pembunuhan', 74, 74, 'AUG_2026'),
('d94754c0-82b0-420a-9c35-f3d648b7e863', NULL, '2026-10-01T11:46:46.321526+00:00', 'ea4d2a68-3617-48a5-b93b-a68955aeedfa', NULL, 'Pornografi', 50, 50, 'AUG_2026'),
('db90d14d-3c96-416a-8f42-2e99d7e6e28e', NULL, '2026-10-01T11:46:46.321526+00:00', 'db73984a-9ac8-4040-ae7b-b26820dc7add', NULL, 'penyalahgunaan Amunisi', 96, 96, 'AUG_2026'),
('deabb721-25dd-4364-a6c1-d15d438694d6', NULL, '2026-10-01T11:46:46.321526+00:00', 'f50139b1-7ba3-4777-8bc5-37622e6555bf', NULL, 'Atasan memukul bawahan', 91, 91, 'AUG_2026'),
('dee335dc-92ae-4227-8997-c5bed106822e', NULL, '2026-10-01T11:46:46.321526+00:00', '32cece47-0086-4ab6-836e-46400a8761ab', NULL, 'Menolak perintah', 18, 18, 'AUG_2026'),
('dfa15285-ae88-41ba-966d-b9d5cfd907d7', NULL, '2026-10-01T11:46:46.321526+00:00', '19fb52f4-4c32-4bb9-a0e0-50026d5ec76a', NULL, 'Nikah siri', 80, 80, 'AUG_2026'),
('e3c467f4-46dd-4294-99e2-e337f00a458c', NULL, '2026-10-01T11:46:46.321526+00:00', '59bad7b6-67d5-4e88-aea4-5ae1abee5f60', NULL, 'Memasuki pekarangan tanpa izin', 103, 103, 'AUG_2026'),
('e5ed9c95-d3f0-4506-8c14-21850b67878c', NULL, '2026-10-01T11:46:46.321526+00:00', 'ad355642-1531-48ad-a263-30f05490a60d', NULL, 'Penembakan', 82, 82, 'AUG_2026'),
('e7256e33-4dcc-4b93-a85d-a61c2f917244', NULL, '2026-10-01T11:46:46.321526+00:00', '6e865f3d-865f-4d0f-ba68-e6902ddd3ad2', NULL, 'Penggelapan', 31, 31, 'AUG_2026'),
('ea51f17b-4296-4fcc-993d-d2887bba8a2b', NULL, '2026-10-01T11:46:46.321526+00:00', 'fcba738b-c423-4cef-9f20-52de81b86705', NULL, 'THTI', 4, 4, 'AUG_2026'),
('f08872ff-c5c4-4c87-8037-ee2008de8711', NULL, '2026-10-01T11:46:46.321526+00:00', '4624a147-ff45-4f58-8c88-b18ac79314ff', NULL, 'Asal usul pernikahan', 53, 53, 'AUG_2026'),
('f0edfe3c-68f9-4b5f-9450-929388c556c1', NULL, '2026-10-01T11:46:46.321526+00:00', '053e2327-dc0e-4143-bbdd-ab13fe4d550c', NULL, 'Penyerobotan tanah', 75, 75, 'AUG_2026'),
('f307b9e7-9902-485f-b829-c56f800e8d4f', NULL, '2026-10-01T11:46:46.321526+00:00', '984077f3-7b4c-414a-b60e-a83c313bf16b', NULL, 'Pencemaran nama baik', 67, 67, 'AUG_2026'),
('f62ff107-fea4-4e84-b850-427e154de578', NULL, '2026-10-01T11:46:46.321526+00:00', '875bc56f-f652-463b-a63d-bd1cab2bfb0e', NULL, 'Keterangan palsu', 85, 85, 'AUG_2026'),
('f7f987a9-30e4-4668-8785-b5f1afac2386', NULL, '2026-10-01T11:46:46.321526+00:00', '994dfaff-6985-4526-9aac-9dd5ecd81ed5', NULL, 'Perdagangan ilegal', 93, 93, 'AUG_2026'),
('f97d6155-267a-43b8-bcbf-54c8296705ad', NULL, '2026-10-01T11:46:46.321526+00:00', 'd62be2d0-83b2-4115-82be-8201d90ce3b6', NULL, 'Penyalahgunaan Migas/BBM', 37, 37, 'AUG_2026'),
('f9f60868-51f7-4917-ab27-2e08b4be4af4', NULL, '2026-10-01T11:46:46.321526+00:00', '26aff2c9-d1a7-4daf-bcca-4ac94ed8b952', NULL, 'Penghinaan', 32, 32, 'AUG_2026'),
('fb2e8df9-ce66-446c-8f2a-b38db27cde0d', NULL, '2026-10-01T11:46:46.321526+00:00', '3f0aa7fc-0eb1-4c7c-96ce-a1870fb794ed', NULL, 'Poligami', 49, 49, 'AUG_2026'),
('fb7628c2-9bed-4716-b684-34867cb77e07', NULL, '2026-10-01T11:46:46.321526+00:00', '8b46ecdf-cc3c-4dea-b891-c570fd43b64e', NULL, 'Penganiayaan', 30, 30, 'AUG_2026'),
('ff971144-a977-41b8-969d-553d0da0f763', NULL, '2026-10-01T11:46:46.321526+00:00', '6c6656b1-6c90-4231-89f3-15e30ff7b216', NULL, 'Aborsi', 65, 65, 'AUG_2026')
on conflict do nothing;
insert into "private"."app_roles" ("active", "role_code", "created_at", "scope_type", "display_name") values
(true, 'POMDAM_COMMANDER', '2026-10-03T16:48:20.502331+00:00', 'POMDAM', 'Komandan Pomdam'),
(true, 'POMDAM_OPERATOR', '2026-10-03T16:48:20.502331+00:00', 'POMDAM', 'Operator Pomdam'),
(true, 'PUSPOMAD_COMMANDER', '2026-10-03T16:48:20.502331+00:00', 'ALL_POMDAM', 'Komandan Puspomad'),
(true, 'PUSPOMAD_DEPUTY_COMMANDER', '2026-10-03T16:48:20.502331+00:00', 'ALL_POMDAM', 'Wakil Komandan Puspomad'),
(true, 'PUSPOMAD_DIRBINGAKKUM', '2026-10-03T16:48:20.502331+00:00', 'ALL_POMDAM', 'Dirbingakkum Puspomad'),
(true, 'PUSPOMAD_OPERATOR', '2026-10-03T16:48:20.502331+00:00', 'ALL_POMDAM', 'Operator Puspomad')
on conflict do nothing;
insert into "private"."app_capabilities" ("active", "created_at", "display_name", "capability_code") values
(true, '2026-10-03T17:08:32.279902+00:00', 'Create or edit report data', 'MANAGE_REPORT_DATA'),
(true, '2026-10-03T17:08:32.279902+00:00', 'Verify report data', 'VERIFY_REPORT_DATA'),
(true, '2026-10-03T17:08:32.279902+00:00', 'View Commander Common Operating Picture', 'VIEW_COMMANDER_COP'),
(true, '2026-10-03T17:08:32.279902+00:00', 'View data quality', 'VIEW_DATA_QUALITY'),
(true, '2026-10-03T17:08:32.279902+00:00', 'View domain data', 'VIEW_DOMAIN_DATA'),
(true, '2026-10-03T17:08:32.279902+00:00', 'View POMDAM directory', 'VIEW_POMDAM_DIRECTORY'),
(true, '2026-10-03T17:08:32.279902+00:00', 'View reports and provenance', 'VIEW_REPORTS')
on conflict do nothing;
insert into "private"."app_role_capabilities" ("active", "role_code", "created_at", "capability_code") values
(true, 'POMDAM_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_COMMANDER_COP'),
(true, 'POMDAM_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DATA_QUALITY'),
(true, 'POMDAM_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DOMAIN_DATA'),
(true, 'POMDAM_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_POMDAM_DIRECTORY'),
(true, 'POMDAM_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_REPORTS'),
(true, 'POMDAM_OPERATOR', '2026-10-03T20:59:55.703077+00:00', 'MANAGE_REPORT_DATA'),
(true, 'POMDAM_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DATA_QUALITY'),
(true, 'POMDAM_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DOMAIN_DATA'),
(true, 'POMDAM_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_POMDAM_DIRECTORY'),
(true, 'POMDAM_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_REPORTS'),
(true, 'PUSPOMAD_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_COMMANDER_COP'),
(true, 'PUSPOMAD_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DATA_QUALITY'),
(true, 'PUSPOMAD_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DOMAIN_DATA'),
(true, 'PUSPOMAD_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_POMDAM_DIRECTORY'),
(true, 'PUSPOMAD_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_REPORTS'),
(true, 'PUSPOMAD_DEPUTY_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_COMMANDER_COP'),
(true, 'PUSPOMAD_DEPUTY_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DATA_QUALITY'),
(true, 'PUSPOMAD_DEPUTY_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DOMAIN_DATA'),
(true, 'PUSPOMAD_DEPUTY_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_POMDAM_DIRECTORY'),
(true, 'PUSPOMAD_DEPUTY_COMMANDER', '2026-10-03T17:08:32.279902+00:00', 'VIEW_REPORTS'),
(true, 'PUSPOMAD_DIRBINGAKKUM', '2026-10-03T17:08:32.279902+00:00', 'VIEW_COMMANDER_COP'),
(true, 'PUSPOMAD_DIRBINGAKKUM', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DATA_QUALITY'),
(true, 'PUSPOMAD_DIRBINGAKKUM', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DOMAIN_DATA'),
(true, 'PUSPOMAD_DIRBINGAKKUM', '2026-10-03T17:08:32.279902+00:00', 'VIEW_POMDAM_DIRECTORY'),
(true, 'PUSPOMAD_DIRBINGAKKUM', '2026-10-03T17:08:32.279902+00:00', 'VIEW_REPORTS'),
(true, 'PUSPOMAD_OPERATOR', '2026-10-03T20:59:55.703077+00:00', 'MANAGE_REPORT_DATA'),
(true, 'PUSPOMAD_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DATA_QUALITY'),
(true, 'PUSPOMAD_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_DOMAIN_DATA'),
(true, 'PUSPOMAD_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_POMDAM_DIRECTORY'),
(true, 'PUSPOMAD_OPERATOR', '2026-10-03T17:08:32.279902+00:00', 'VIEW_REPORTS')
on conflict do nothing;

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
$function$;

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
$function$;

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
$function$;

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
$function$;

