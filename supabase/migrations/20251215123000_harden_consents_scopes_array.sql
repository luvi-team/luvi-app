-- Harden `public.consents.scopes` to be a JSONB array (anti-drift).
--
-- Background:
-- - Table default was `'{}'::jsonb` (object), which allowed drift.
-- - `public.log_consent_if_allowed(...)` validates `p_scopes` as a JSONB array
--   and inserts into `public.consents.scopes`.
-- - This migration aligns the table schema with the RPC contract by:
--   1) Backfilling legacy object rows into arrays of enabled keys
--   2) Setting the column default to `'[]'::jsonb`
--   3) Enforcing `jsonb_typeof(scopes) = 'array'` via CHECK constraint

do $$
declare
  backfilled_rows integer := 0;
begin
  if not exists (
    select 1
    from pg_class t
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'consents'
  ) then
    raise notice 'Skipping migration: public.consents does not exist';
    return;
  end if;

  -- Backfill legacy object-map format: {"scope": true/false} → ["scope", ...].
  update public.consents c
  set scopes = (
    select coalesce(jsonb_agg(e.key order by e.key), '[]'::jsonb)
    from jsonb_each(c.scopes) as e(key, value)
    where e.value = 'true'::jsonb
  )
  where jsonb_typeof(c.scopes) = 'object';

  get diagnostics backfilled_rows = row_count;
  if backfilled_rows > 0 then
    raise notice 'Backfilled % public.consents rows from object→array scopes', backfilled_rows;
  end if;

  -- Defense-in-depth: normalize unexpected JSON types to an empty array.
  update public.consents
  set scopes = '[]'::jsonb
  where jsonb_typeof(scopes) is null
     or jsonb_typeof(scopes) <> 'array';

  -- Align default with the canonical array format.
  alter table public.consents
    alter column scopes set default '[]'::jsonb;

  -- Enforce array type at the schema layer to prevent drift.
  alter table public.consents
    drop constraint if exists consents_scopes_is_array;
  alter table public.consents
    add constraint consents_scopes_is_array
      check (jsonb_typeof(scopes) = 'array');
end $$;

