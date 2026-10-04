-- Repair constraints omitted while reconstructing the production baseline.
do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname='app_roles_pkey'
      and conrelid='private.app_roles'::regclass
  ) then
    alter table "private"."app_roles"
      add constraint "app_roles_pkey" primary key (role_code);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname='app_role_capabilities_pkey'
      and conrelid='private.app_role_capabilities'::regclass
  ) then
    alter table "private"."app_role_capabilities"
      add constraint "app_role_capabilities_pkey" primary key (role_code, capability_code);
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname='app_role_capabilities_capability_code_fkey'
      and conrelid='private.app_role_capabilities'::regclass
  ) then
    alter table "private"."app_role_capabilities"
      add constraint "app_role_capabilities_capability_code_fkey"
      foreign key (capability_code)
      references private.app_capabilities(capability_code)
      on delete cascade;
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname='app_role_capabilities_role_code_fkey'
      and conrelid='private.app_role_capabilities'::regclass
  ) then
    alter table "private"."app_role_capabilities"
      add constraint "app_role_capabilities_role_code_fkey"
      foreign key (role_code)
      references private.app_roles(role_code)
      on delete cascade;
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname='app_user_roles_role_code_fkey'
      and conrelid='private.app_user_roles'::regclass
  ) then
    alter table "private"."app_user_roles"
      add constraint "app_user_roles_role_code_fkey"
      foreign key (role_code)
      references private.app_roles(role_code);
  end if;
end $$;