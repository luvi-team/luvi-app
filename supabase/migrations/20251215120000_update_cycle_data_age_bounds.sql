-- Update cycle_data.age bounds (privacy policy update)
-- Previous: age >= 10 AND age <= 65 (constraint: cycle_data_age_check)
-- New:      age >= 16 AND age <= 120

do $$
declare
  violating_count integer;
begin
  if not exists (
    select 1
    from pg_class t
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'cycle_data'
  ) then
    raise notice 'Skipping migration: public.cycle_data does not exist';
    return;
  end if;

  select count(*) into violating_count
  from public.cycle_data
  where age < 16 or age > 120;

  if violating_count > 0 then
    raise exception
      'Cannot apply new age bounds [16,120] on public.cycle_data.age: % existing rows violate the new constraint.',
      violating_count;
  end if;

  alter table public.cycle_data
    drop constraint if exists cycle_data_age_check;

  alter table public.cycle_data
    add constraint cycle_data_age_check check (age >= 16 and age <= 120);
end $$;

