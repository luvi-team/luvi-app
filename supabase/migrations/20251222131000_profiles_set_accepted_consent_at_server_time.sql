-- Ensure `profiles.accepted_consent_at` is set server-side when the user
-- accepts consent (accepted_consent_version is written).
--
-- Rationale:
-- - `accepted_consent_at` is used for audit/diagnostics and must not rely on
--   client device time (clock skew / tampering).
-- - The client writes `accepted_consent_version` only after successful
--   `log_consent` and does NOT send `accepted_consent_at`.
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

  -- UPDATE: only set when version is newly set or changed.
  if old.accepted_consent_version is distinct from new.accepted_consent_version then
    new.accepted_consent_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists set_profiles_accepted_consent_at on public.profiles;
create trigger set_profiles_accepted_consent_at
  before insert or update of accepted_consent_version
  on public.profiles
  for each row
  execute function public.set_profiles_accepted_consent_at();
