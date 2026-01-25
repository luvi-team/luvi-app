-- ============================================================================
-- Migration: Fix consent trigger guard + service_role grants
-- Date: 2026-01-25
-- Purpose:
-- - Enforce least-privilege by revoking UPDATE/DELETE on public.consents from
--   service_role (append-only consent audit log).
-- ============================================================================

begin;

-- Align service_role grants with append-only semantics (defense-in-depth).
do $$
begin
  if to_regclass('public.consents') is not null and exists (select 1 from pg_roles where rolname = 'service_role') then
    execute 'revoke update, delete on public.consents from service_role';
  end if;
end $$;

commit;
