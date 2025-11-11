-- FORCE RLS for sensitive tables (idempotent)
alter table if exists public.consents          force row level security;
alter table if exists public.cycle_data        force row level security;
alter table if exists public.email_preferences force row level security;
/* Vorlage für neue Tabellen:
alter table if exists public.playlist          force row level security;
*/

