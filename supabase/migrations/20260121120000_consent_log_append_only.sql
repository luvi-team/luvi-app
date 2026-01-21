-- ============================================================================
-- Migration: Consent Log Append-Only
-- Date: 2026-01-21
-- Purpose: GDPR compliance - consent log must be immutable audit trail
-- ============================================================================
--
-- GDPR Art. 7(1) requires demonstrable proof of consent. To satisfy audit
-- requirements, consent records must be:
-- 1. Append-only (no UPDATE/DELETE)
-- 2. Timestamped immutably (created_at)
-- 3. User-scoped (via RLS)
--
-- This migration:
-- 1. Drops UPDATE and DELETE RLS policies (client cannot bypass)
-- 2. Revokes UPDATE/DELETE privileges from authenticated role
-- 3. Adds defense-in-depth triggers (catches service_role bypass attempts)
--
-- Rollback: See bottom of file for manual rollback instructions.
-- ============================================================================

BEGIN;

-- Step 1: Drop UPDATE and DELETE RLS policies
-- These policies were created in 20250903235538_create_consents_table.sql
DROP POLICY IF EXISTS "Users can update their own consents" ON public.consents;
DROP POLICY IF EXISTS "Users can delete their own consents" ON public.consents;

-- Step 2: Revoke UPDATE/DELETE privileges from authenticated role
-- Note: service_role retains privileges for admin/support workflows, but
-- the trigger below will block modifications regardless.
REVOKE UPDATE, DELETE ON public.consents FROM authenticated;

-- Step 3: Defense-in-depth trigger (catches any bypass attempts, including service_role)
-- This is belt-and-suspenders: even if someone escalates to service_role or
-- bypasses RLS, the trigger will prevent modifications.
CREATE OR REPLACE FUNCTION public.prevent_consent_modification()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Consent log is append-only (GDPR audit requirement). Modifications are not allowed.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing triggers if they exist (idempotent)
DROP TRIGGER IF EXISTS consent_no_update ON public.consents;
DROP TRIGGER IF EXISTS consent_no_delete ON public.consents;

-- Create triggers for both UPDATE and DELETE
CREATE TRIGGER consent_no_update
  BEFORE UPDATE ON public.consents
  FOR EACH ROW EXECUTE FUNCTION public.prevent_consent_modification();

CREATE TRIGGER consent_no_delete
  BEFORE DELETE ON public.consents
  FOR EACH ROW EXECUTE FUNCTION public.prevent_consent_modification();

-- Step 4: Add comment documenting the immutability requirement
COMMENT ON TABLE public.consents IS 'Append-only consent audit log (GDPR Art. 7). UPDATE/DELETE blocked by trigger.';

COMMIT;

-- ============================================================================
-- Verification (run in SQL Editor after migration)
-- ============================================================================
--
-- 1. Check policies (should only show SELECT and INSERT):
--    SELECT policyname, cmd FROM pg_policies WHERE tablename = 'consents';
--
-- 2. Check triggers (should show consent_no_update and consent_no_delete):
--    SELECT tgname FROM pg_trigger WHERE tgrelid = 'public.consents'::regclass;
--
-- 3. Test UPDATE blocking:
--    UPDATE public.consents SET version = '999' WHERE user_id = auth.uid();
--    -- Expected: ERROR: Consent log is append-only (GDPR audit requirement)
--
-- ============================================================================
-- Rollback Instructions (NOT RECOMMENDED - breaks GDPR compliance)
-- ============================================================================
--
-- -- Revert triggers
-- DROP TRIGGER IF EXISTS consent_no_update ON public.consents;
-- DROP TRIGGER IF EXISTS consent_no_delete ON public.consents;
-- DROP FUNCTION IF EXISTS public.prevent_consent_modification();
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
