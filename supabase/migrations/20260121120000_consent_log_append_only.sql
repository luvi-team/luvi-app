-- ============================================================================
-- Migration: Consent Log Append-Only
-- Date: 2026-01-21
-- Purpose: GDPR compliance - consent log must be immutable audit trail
-- ============================================================================
--
-- GDPR Art. 7(1) requires demonstrable proof of consent. To satisfy audit
-- requirements, consent records must be:
-- 1. Append-only (no UPDATE; DELETE reserved for erasure)
-- 2. Timestamped immutably (created_at)
-- 3. User-scoped (via RLS)
--
-- This migration:
-- 1. Drops UPDATE and DELETE RLS policies (client cannot bypass)
-- 2. Revokes UPDATE/DELETE privileges from authenticated role
-- 3. Adds defense-in-depth trigger for UPDATEs (catches bypass attempts)
--
-- IMPORTANT: We intentionally do NOT block DELETE via trigger.
-- Reason: Account deletion (ON DELETE CASCADE from auth.users) and potential
-- retention/erasure workflows must remain possible.
-- DELETE is still disallowed for end-user clients because:
-- - RLS has no DELETE policy (only SELECT/INSERT owner-scoped to auth.uid()).
-- - Table grants revoke UPDATE/DELETE for the authenticated role (defense-in-depth).
--
-- Rollback: See bottom of file for manual rollback instructions.
-- ============================================================================

BEGIN;

-- Step 1: Drop UPDATE and DELETE RLS policies
-- These policies were created in 20250903235538_create_consents_table.sql
DROP POLICY IF EXISTS "Users can update their own consents" ON public.consents;
DROP POLICY IF EXISTS consents_update_own ON public.consents;
DROP POLICY IF EXISTS "Users can delete their own consents" ON public.consents;
DROP POLICY IF EXISTS consents_delete_own ON public.consents;

-- Step 2: Revoke UPDATE/DELETE privileges from authenticated role
-- Note: service_role retains GRANTed UPDATE/DELETE privileges, however the
-- FOR EACH ROW UPDATE trigger defined below fires for ALL roles (including
-- service_role) and will block the operation.
--
-- Operational note:
-- - Admin/support MUST NOT UPDATE existing consent rows (GDPR audit integrity).
-- - Corrections must be append-only (INSERT a new consent row, e.g. with a newer
--   version/scopes and/or revoked_at), never mutate historical rows.
-- - If a break-glass trigger disable is ever required, follow the runbook and
--   obtain explicit approval: docs/runbooks/consents-append-only-breakglass.md
-- - If using break-glass, log trigger toggles via `public.admin_audit_log`
--   (helper: `public.admin_breakglass_set_consent_no_update_enabled(...)`).
--
-- Example (break-glass, approved only; same session):
--   select public.admin_breakglass_set_consent_no_update_enabled(false, '<reason>');
--   -- perform correction (prefer INSERT a new consent row; never UPDATE historical rows)
--   select public.admin_breakglass_set_consent_no_update_enabled(true, '<reason>');
REVOKE UPDATE, DELETE ON public.consents FROM authenticated;

-- ============================================================================
-- Admin Correction Workflow (SECURITY NOTE)
-- ============================================================================
--
-- SCENARIO: Support needs to correct a consent record (rare, requires audit trail)
--
-- PREREQUISITES:
--   - Superuser or postgres role access
--   - Audit log entry BEFORE modification (external system)
--   - Documented reason for correction
--
-- PROCEDURE:
--   -- 1. Document the correction reason in your audit system
--   -- 2. Set a short session timeout and open a transaction guardrail
--   SET statement_timeout = '30s';
--   BEGIN;
--   SAVEPOINT consent_no_update_guard;
--
--   -- 3. Disable trigger temporarily
--   ALTER TABLE public.consents DISABLE TRIGGER consent_no_update;
--
--   -- 4. Perform the specific correction
--   UPDATE public.consents SET version = 'v1.1' WHERE id = '<consent_id>';
--
--   -- 5. Re-enable trigger IMMEDIATELY (do not leave disabled!)
--   ALTER TABLE public.consents ENABLE TRIGGER consent_no_update;
--
--   -- 6. Reset timeout and commit the session
--   RESET statement_timeout;
--   COMMIT;
--
--   -- On error after SAVEPOINT:
--   --   ROLLBACK TO SAVEPOINT consent_no_update_guard;
--   --   ALTER TABLE public.consents ENABLE TRIGGER consent_no_update;
--   --   RESET statement_timeout;
--   --   COMMIT;
--
--   -- 7. Verify trigger is re-enabled
--   SELECT tgname, tgenabled FROM pg_trigger
--     WHERE tgrelid = 'public.consents'::regclass
--       AND tgname = 'consent_no_update';
--   -- Expected: tgenabled = 'O' (Origin/enabled)
--
-- WARNING: Never leave the trigger disabled. If your session crashes,
-- reconnect and verify trigger state before any other operations.
-- ============================================================================

-- Step 3: Defense-in-depth trigger to prevent UPDATEs (append-only semantics)
-- We do NOT create a DELETE trigger; see IMPORTANT note above.
DROP TRIGGER IF EXISTS consent_no_update ON public.consents;
DROP TRIGGER IF EXISTS consent_no_delete ON public.consents;
DROP FUNCTION IF EXISTS public.prevent_consent_modification();

CREATE OR REPLACE FUNCTION public.prevent_consent_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = "public"
AS $$
BEGIN
  RAISE EXCEPTION 'Consent log is append-only (GDPR audit requirement). UPDATE is not allowed.'
    USING ERRCODE = 'P0001';
END;
$$;

-- Create trigger for UPDATE only
CREATE TRIGGER consent_no_update
  BEFORE UPDATE ON public.consents
  FOR EACH ROW EXECUTE FUNCTION public.prevent_consent_update();

-- Step 4: Add comment documenting the immutability requirement
COMMENT ON TABLE public.consents IS
  'Append-only consent audit log (GDPR Art. 7). Client UPDATE/DELETE disallowed; UPDATE blocked by trigger; DELETE reserved for erasure/retention.';

COMMIT;

-- ============================================================================
-- Verification (run in SQL Editor after migration)
-- ============================================================================
--
-- 1. Check policies (should only show SELECT and INSERT):
--    SELECT policyname, cmd FROM pg_policies WHERE tablename = 'consents';
--
-- 2. Check triggers (should show consent_no_update):
--    SELECT tgname FROM pg_trigger WHERE tgrelid = 'public.consents'::regclass;
--
-- 3. Test UPDATE blocking:
--    UPDATE public.consents SET version = '999' WHERE user_id = auth.uid();
--    -- Expected: ERROR: Consent log is append-only (GDPR audit requirement)
--
-- 4. Verify client DELETE is disallowed (should fail for authenticated):
--    DELETE FROM public.consents WHERE user_id = auth.uid();
--
-- ============================================================================
-- Rollback Instructions (NOT RECOMMENDED - breaks GDPR compliance)
-- ============================================================================
--
-- -- Revert triggers
-- DROP TRIGGER IF EXISTS consent_no_update ON public.consents;
-- DROP FUNCTION IF EXISTS public.prevent_consent_update();
--
-- -- Restore privileges (NOT RECOMMENDED)
-- GRANT UPDATE, DELETE ON public.consents TO authenticated;
--
-- -- Restore policies (NOT RECOMMENDED)
-- CREATE POLICY "Users can update their own consents" ON public.consents
--     FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- CREATE POLICY "Users can delete their own consents" ON public.consents
--     FOR DELETE USING (user_id = auth.uid());
--
-- ============================================================================
