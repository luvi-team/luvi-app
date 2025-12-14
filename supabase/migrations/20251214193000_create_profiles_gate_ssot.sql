-- Create profiles table to persist account-scoped gate state and onboarding answers.
-- SSOT: Replaces device-only SharedPreferences flags in `UserStateService`.
--
-- Notes:
-- - Consent audit trail remains in `public.consents` (event log).
-- - Cycle inputs remain in `public.cycle_data` (existing table, already 1:1 via unique index).
-- - This table is owner-only via RLS + FORCE RLS (least privilege).

-- Ensure update trigger helper exists (daily_plan migration lives in migrations_archive).
create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
set search_path to 'public'
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,

  -- Onboarding answers (minimal, extend as needed)
  display_name text,
  birth_date date,
  fitness_level text,
  goals jsonb not null default '[]'::jsonb,
  interests jsonb not null default '[]'::jsonb,

  -- Gate SSOT (account-scoped)
  has_seen_welcome boolean not null default false,
  has_completed_onboarding boolean not null default false,
  accepted_consent_version integer,
  accepted_consent_at timestamptz,
  onboarding_completed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint profiles_goals_is_array check (jsonb_typeof(goals) = 'array'),
  constraint profiles_interests_is_array check (jsonb_typeof(interests) = 'array'),
  constraint profiles_fitness_level_check check (
    fitness_level is null or fitness_level in ('beginner', 'occasional', 'fit')
  )
);

comment on table public.profiles is
  'Account-scoped gate SSOT and onboarding answers (owner-only via RLS).';

alter table public.profiles enable row level security;
alter table public.profiles force row level security;

-- Policies: owner-only (authenticated users).
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own
  on public.profiles
  for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists profiles_delete_own on public.profiles;
create policy profiles_delete_own
  on public.profiles
  for delete
  to authenticated
  using (user_id = auth.uid());

-- Triggers: auto-set user_id + maintain updated_at.
drop trigger if exists set_profiles_user_id on public.profiles;
create trigger set_profiles_user_id
  before insert on public.profiles
  for each row execute function public.set_user_id_from_auth();

drop trigger if exists update_profiles_updated_at on public.profiles;
create trigger update_profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at_column();

-- Privileges: authenticated only (account-scoped; no anon access needed).
revoke all on table public.profiles from anon;
revoke all on table public.profiles from public;
grant select, insert, update, delete on table public.profiles to authenticated;

