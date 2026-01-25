-- ============================================================================
-- Migration: Fix consent trigger guard + service_role grants
-- Date: 2026-01-25
-- Purpose:
-- - Ensure check_and_restore_consent_trigger_state() only self-heals when the
--   consent_no_update trigger is actually disabled (tgenabled = 'D'), not when
--   it is in ALWAYS mode (tgenabled = 'A').
-- - Enforce least-privilege by revoking UPDATE/DELETE on public.consents from
--   service_role (append-only consent audit log).
-- ============================================================================

begin;

create or replace function public.check_and_restore_consent_trigger_state()
returns void
language plpgsql
security definer
set search_path = "public"
as $$
declare
  v_tgenabled "char";
  v_reason text;
begin
  if to_regclass('public.consents') is null then
    raise warning 'public.consents table does not exist; skipping trigger state check';
    return;
  end if;

  select tgenabled
    into v_tgenabled
    from pg_trigger
   where tgrelid = 'public.consents'::regclass
     and tgname = 'consent_no_update'
     and not tgisinternal;

  if v_tgenabled is null then
    v_reason := 'consent_no_update trigger missing on public.consents; manual intervention required';
    perform pg_notify('consent_trigger_alert', v_reason);
    if to_regprocedure('public.admin_audit_log_insert(text,text,text,text)') is not null then
      execute format(
        'select public.admin_audit_log_insert(%L,%L,%L,%L)',
        'TRIGGER_MISSING',
        'consents',
        'consent_no_update',
        v_reason
      );
    end if;
    return;
  end if;

  -- Only self-heal when the trigger is actually disabled.
  -- Do not override 'A' (always) or other non-disabled modes.
  if v_tgenabled = 'D' then
    execute 'alter table public.consents enable trigger consent_no_update';
    v_reason := format('consent_no_update trigger was %s; re-enabled automatically', v_tgenabled);
    perform pg_notify('consent_trigger_alert', v_reason);
    if to_regprocedure('public.admin_audit_log_insert(text,text,text,text)') is not null then
      execute format(
        'select public.admin_audit_log_insert(%L,%L,%L,%L)',
        'TRIGGER_REENABLED',
        'consents',
        'consent_no_update',
        v_reason
      );
    end if;
  end if;
end;
$$;

comment on function public.check_and_restore_consent_trigger_state() is
  'Checks consent_no_update trigger state; re-enables if disabled; emits pg_notify + audit log entry.';

revoke all on function public.check_and_restore_consent_trigger_state() from public;
revoke all on function public.check_and_restore_consent_trigger_state() from anon;
revoke all on function public.check_and_restore_consent_trigger_state() from authenticated;
revoke all on function public.check_and_restore_consent_trigger_state() from service_role;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'supabase_admin') then
    execute 'grant execute on function public.check_and_restore_consent_trigger_state() to supabase_admin';
  else
    raise warning 'Role supabase_admin not found; check_and_restore_consent_trigger_state() not granted';
  end if;
end $$;

-- Align service_role grants with append-only semantics (defense-in-depth).
do $$
begin
  if to_regclass('public.consents') is not null and exists (select 1 from pg_roles where rolname = 'service_role') then
    execute 'revoke update, delete on public.consents from service_role';
  end if;
end $$;

commit;
