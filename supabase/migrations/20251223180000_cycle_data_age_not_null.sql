-- Enforce NOT NULL on cycle_data.age
-- Prerequisite: CHECK constraint (age >= 16 AND age <= 120) already exists
-- from migration 20251215120000_update_cycle_data_age_bounds.sql
--
-- This is a separate migration to follow the immutability principle of
-- database migrations. We do not modify already-applied migrations.

do $$
declare
  null_count integer;
begin
  -- Verify table exists
  if not exists (
    select 1 from pg_class t
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public' and t.relname = 'cycle_data'
  ) then
    raise notice 'Skipping: public.cycle_data does not exist';
    return;
  end if;

  -- Check for NULL values before adding constraint
  select count(*) into null_count
  from public.cycle_data
  where age is null;

  if null_count > 0 then
    raise exception 'Cannot add NOT NULL: % rows have NULL age values. Clean up data first.', null_count;
  end if;

  -- Add NOT NULL constraint (idempotent check via pg_attribute)
  if exists (
    select 1
    from pg_attribute a
    join pg_class c on c.oid = a.attrelid
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'cycle_data'
      and a.attname = 'age'
      and a.attnotnull = false
  ) then
    alter table public.cycle_data
      alter column age set not null;
    raise notice 'Successfully added NOT NULL constraint to cycle_data.age';
  else
    raise notice 'cycle_data.age is already NOT NULL or does not exist';
  end if;
end $$;
