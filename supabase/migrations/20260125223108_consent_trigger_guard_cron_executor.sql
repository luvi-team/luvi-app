-- Ensure consent trigger guard runs as dedicated cron role.
-- Re-applies role/grant/schedule in an idempotent way for already-applied base migrations.

begin;

do $$
declare
  has_job boolean := false;
begin
  if to_regprocedure('public.check_and_restore_consent_trigger_state()') is not null then
    if not exists (select 1 from pg_roles where rolname = 'cron_executor') then
      execute 'create role cron_executor';
    end if;
    execute 'grant execute on function public.check_and_restore_consent_trigger_state() to cron_executor';
  end if;

  if to_regprocedure('cron.schedule(text,text,text)') is not null
     and to_regclass('cron.job') is not null then
    execute 'select exists (select 1 from cron.job where jobname = ''consent_trigger_guard'')'
      into has_job;

    if not has_job then
      if to_regprocedure('cron.schedule(text,text,text,text)') is not null then
        execute 'select cron.schedule(''consent_trigger_guard'', ''*/5 * * * *'', ''select public.check_and_restore_consent_trigger_state();'', ''cron_executor'')';
      else
        execute 'select cron.schedule(''consent_trigger_guard'', ''*/5 * * * *'', ''select public.check_and_restore_consent_trigger_state();'')';
        execute 'update cron.job set username = ''cron_executor'' where jobname = ''consent_trigger_guard''';
      end if;
    else
      execute 'update cron.job set username = ''cron_executor'' where jobname = ''consent_trigger_guard'' and username is distinct from ''cron_executor''';
    end if;
  end if;
end $$;

commit;
