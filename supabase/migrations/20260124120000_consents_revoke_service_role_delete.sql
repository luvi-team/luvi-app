-- ============================================================================
-- Migration: Consents - Revoke DELETE for service_role
-- Date: 2026-01-24
-- Purpose: Enforce append-only consent audit trail (GDPR Art. 7) by preventing
--          direct DELETEs on public.consents via service_role.
--
-- Rationale:
-- - public.consents is intended as an immutable audit log (append-only).
-- - Account deletion should remove consent records via ON DELETE CASCADE from
--   auth.users, not via direct table DELETEs.
-- - service_role is commonly used in operational scripts; removing DELETE here
--   reduces accidental/unaudited deletions.
-- ============================================================================

BEGIN;

REVOKE DELETE ON public.consents FROM service_role;

COMMIT;
