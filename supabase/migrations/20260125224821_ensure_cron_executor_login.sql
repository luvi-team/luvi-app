-- Ensure cron_executor has LOGIN for pg_cron connections.
-- Needed because earlier migrations may have created the role without LOGIN.

begin;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'cron_executor') then
    execute 'alter role cron_executor login';
  else
    execute 'create role cron_executor login';
  end if;
end $$;

commit;
