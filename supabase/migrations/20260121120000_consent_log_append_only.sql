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
-- retention/erasure workflows must remain possible. DELETE is still disallowed
-- for authenticated clients via dropped policies + revoked privileges.
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
-- service_role) and will block the operation. To perform admin/support
-- corrections, temporarily disable the trigger:
--   ALTER TABLE public.consents DISABLE TRIGGER consent_no_update;
--   -- perform correction --
--   ALTER TABLE public.consents ENABLE TRIGGER consent_no_update;
REVOKE UPDATE, DELETE ON public.consents FROM authenticated;

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
  RAISE EXCEPTION 'Consent log is append-only (GDPR audit requirement). UPDATE is not allowed.';
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
