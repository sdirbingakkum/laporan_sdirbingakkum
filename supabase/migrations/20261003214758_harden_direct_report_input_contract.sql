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
alter table "private"."app_capabilities" add constraint "app_capabilities_pkey" primary key (capability_code);
alter table "private"."app_roles" add constraint "app_roles_pkey" primary key (role_code);
create table if not exists "private"."app_user_roles" (
  "user_id" uuid not null,
  "role_code" text not null,
  "active" boolean not null default true,
  "created_at" timestamp with time zone not null default now(),
  "updated_at" timestamp with time zone not null default now()
);