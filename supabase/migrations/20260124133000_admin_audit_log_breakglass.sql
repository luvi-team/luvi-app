-- Minimal admin audit log for break-glass operations (consent append-only).
--
-- Purpose:
-- - Record rare administrative actions that temporarily weaken audit guarantees,
--   e.g. disabling `public.consents` UPDATE-blocking trigger `consent_no_update`.
-- - Provide an internal audit trail without introducing new user PII.
--
-- Notes:
-- - This does NOT make bypass impossible for superusers. It provides a
--   standardized workflow that logs by default.
-- - All privileges are revoked from application roles.

begin;

create table if not exists public.admin_audit_log (
  id bigserial primary key,
  action text not null,
  table_name text not null,
  trigger_name text,
  reason text not null,
  performed_by text not null default current_user,
  performed_at timestamptz not null default now()
);

comment on table public.admin_audit_log is
  'Internal admin audit log for break-glass DB operations (no user PII).';

create index if not exists admin_audit_log_performed_at_idx
  on public.admin_audit_log (performed_at desc);

alter table public.admin_audit_log enable row level security;

-- No policies: only privileged roles (e.g. postgres) can read/write.
revoke all on table public.admin_audit_log from public;
revoke all on table public.admin_audit_log from anon;
revoke all on table public.admin_audit_log from authenticated;
revoke all on table public.admin_audit_log from service_role;

revoke all on sequence public.admin_audit_log_id_seq from public;
revoke all on sequence public.admin_audit_log_id_seq from anon;
revoke all on sequence public.admin_audit_log_id_seq from authenticated;
revoke all on sequence public.admin_audit_log_id_seq from service_role;

create or replace function public.admin_audit_log_insert(
  p_action text,
  p_table_name text,
  p_trigger_name text,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = "public"
as $$
begin
  if p_action is null or btrim(p_action) = '' then
    raise exception 'p_action must be provided';
  end if;
  if p_table_name is null or btrim(p_table_name) = '' then
    raise exception 'p_table_name must be provided';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'p_reason must be provided';
  end if;

  insert into public.admin_audit_log (action, table_name, trigger_name, reason)
  values (
    btrim(p_action),
    btrim(p_table_name),
    nullif(btrim(p_trigger_name), ''),
    btrim(p_reason)
  );
end;
$$;

comment on function public.admin_audit_log_insert(text, text, text, text) is
  'Insert an admin audit log row for break-glass operations.';

-- Lock down EXECUTE: default grants include PUBLIC, so revoke explicitly.
revoke all on function public.admin_audit_log_insert(text, text, text, text) from public;
revoke all on function public.admin_audit_log_insert(text, text, text, text) from anon;
revoke all on function public.admin_audit_log_insert(text, text, text, text) from authenticated;
revoke all on function public.admin_audit_log_insert(text, text, text, text) from service_role;

create or replace function public.admin_breakglass_set_consent_no_update_enabled(
  p_enabled boolean,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = "public"
as $$
declare
  v_action text;
  v_exists boolean;
begin
  if p_enabled is null then
    raise exception 'p_enabled must be provided';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'p_reason must be provided';
  end if;

  select exists (
    select 1
    from pg_trigger
    where tgrelid = 'public.consents'::regclass
      and tgname = 'consent_no_update'
  ) into v_exists;

  if not v_exists then
    raise exception 'Expected trigger public.consents.consent_no_update to exist';
  end if;

  v_action := case when p_enabled then 'ENABLE_TRIGGER' else 'DISABLE_TRIGGER' end;

  -- Ensure audit row is written before toggling.
  perform public.admin_audit_log_insert(
    v_action,
    'consents',
    'consent_no_update',
    p_reason
  );

  execute format(
    'alter table public.consents %s trigger consent_no_update',
    case when p_enabled then 'enable' else 'disable' end
  );
end;
$$;

comment on function public.admin_breakglass_set_consent_no_update_enabled(boolean, text) is
  'Break-glass helper: logs and toggles consent_no_update trigger in one session.';

revoke all on function public.admin_breakglass_set_consent_no_update_enabled(boolean, text) from public;
revoke all on function public.admin_breakglass_set_consent_no_update_enabled(boolean, text) from anon;
revoke all on function public.admin_breakglass_set_consent_no_update_enabled(boolean, text) from authenticated;
revoke all on function public.admin_breakglass_set_consent_no_update_enabled(boolean, text) from service_role;

commit;
