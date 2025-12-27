-- Follow-up migration:
-- `20251222131000_profiles_set_accepted_consent_at_server_time` created a trigger
-- that only fires on UPDATEs of `accepted_consent_version`. That makes the
-- `accepted_consent_at` backfill branch unreachable when fixing legacy rows.
--
-- This migration updates the trigger to fire on all UPDATEs so we can backfill
-- `accepted_consent_at` whenever:
-- - `accepted_consent_version` is present (already accepted), and
-- - `accepted_consent_at` is still null.
--
-- Idempotent: uses CREATE OR REPLACE and DROP IF EXISTS.

create or replace function public.set_profiles_accepted_consent_at()
returns trigger
language plpgsql
set search_path to 'public'
as $$
begin
  -- Only act when consent version is present.
  if new.accepted_consent_version is null then
    return new;
  end if;

  if tg_op = 'INSERT' then
    -- New row: ALWAYS set server timestamp (overwrite any client value).
    -- This ensures audit integrity regardless of client clock skew/tampering.
    -- Client should not send accepted_consent_at; if it does, we ignore it.
    new.accepted_consent_at = now();
    return new;
  end if;

  -- UPDATE:
  -- - Set when consent version is newly set or changed.
  -- - Backfill when `accepted_consent_at` is missing for an already accepted
  --   consent version (e.g. legacy rows / previous bug).
  if old.accepted_consent_version is distinct from new.accepted_consent_version then
    new.accepted_consent_at = now();
  elsif old.accepted_consent_at is null and new.accepted_consent_at is null then
    new.accepted_consent_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists set_profiles_accepted_consent_at on public.profiles;
create trigger set_profiles_accepted_consent_at
  before insert or update
  on public.profiles
  for each row
  execute function public.set_profiles_accepted_consent_at();

