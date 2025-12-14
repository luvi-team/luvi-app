-- Extend cycle_data to capture onboarding cycle regularity (Onboarding07).
-- Keeps all cycle inputs in one place and stays optional (nullable).

alter table public.cycle_data
  add column if not exists cycle_regularity text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'cycle_data'
      and c.conname = 'cycle_data_cycle_regularity_check'
  ) then
    alter table public.cycle_data
      add constraint cycle_data_cycle_regularity_check
      check (
        cycle_regularity is null
        or cycle_regularity in ('regular', 'unpredictable', 'unknown')
      );
  end if;
end;
$$;

