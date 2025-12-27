# LUVI Database Migrations

## Migration Files

- `20250903235538_create_consents_table.sql` - User consent management with GDPR compliance
- `20251215123000_harden_consents_scopes_array.sql` - Anti-drift (legacy): enforce `consents.scopes` as JSONB array
- `20251222173000_consents_scopes_object_bool.sql` - Canonicalize: enforce `consents.scopes` as JSONB object<boolean> (SSOT)
- `20250903235539_create_cycle_data_table.sql` - Menstrual cycle tracking data
- `20250903235540_create_email_preferences_table.sql` - User email notification preferences

## RLS Policies

All tables implement owner-based RLS policies using `user_id = auth.uid()` following ADR-0002 (least-privilege principle).

## Manual Test Queries

### Prerequisites
```sql
-- Ensure you're authenticated as a user
SELECT auth.uid(); -- Should return your user UUID
```

### Consents Table Tests

```sql
-- Insert consent (should succeed for own user_id)
INSERT INTO consents (user_id, scopes, version) 
VALUES (auth.uid(), '{"terms": true, "health_processing": true, "analytics": true}'::jsonb, 'v1.0');

-- View own consents (should succeed)
SELECT * FROM consents WHERE user_id = auth.uid();

-- Update own consent (should succeed)
UPDATE consents 
SET scopes = '{"terms": true, "health_processing": true, "marketing": true}'::jsonb
WHERE user_id = auth.uid() AND version = 'v1.0';

-- Revoke consent (should succeed)
UPDATE consents 
SET revoked_at = NOW() 
WHERE user_id = auth.uid() AND version = 'v1.0';

-- Try to view other user's consents (should return empty)
SELECT * FROM consents WHERE user_id != auth.uid();
```

### Performance

- Composite index for sliding-window queries: `idx_consents_user_id_created_at` on `(user_id, created_at DESC)`.
  - Added via migration `20251103113000_consents_user_id_created_at_idx.sql`.
  - Optimizes `WHERE user_id = $1 AND created_at > $2` for rate limit checks and timelines.
  - Verify in production: `\d+ consents` and `EXPLAIN ANALYZE` on the rate-limit count.

### Cycle Data Table Tests

```sql
-- Insert cycle data (should succeed for own user_id)
INSERT INTO cycle_data (user_id, cycle_length, period_duration, last_period, age) 
VALUES (auth.uid(), 28, 5, '2025-09-01', 25);

-- View own cycle data (should succeed)
SELECT * FROM cycle_data WHERE user_id = auth.uid();

-- Update cycle data (should succeed)
UPDATE cycle_data 
SET cycle_length = 30 
WHERE user_id = auth.uid();

-- Try invalid data (should fail due to CHECK constraints)
INSERT INTO cycle_data (user_id, cycle_length, period_duration, last_period, age) 
VALUES (auth.uid(), 100, 5, '2025-09-01', 25); -- cycle_length too high

-- Try to access other user's data (should return empty)
SELECT * FROM cycle_data WHERE user_id != auth.uid();
```

### Email Preferences Table Tests

```sql
-- Insert email preferences (should succeed for own user_id)
INSERT INTO email_preferences (user_id, newsletter) 
VALUES (auth.uid(), true);

-- View own preferences (should succeed)
SELECT * FROM email_preferences WHERE user_id = auth.uid();

-- Update preferences (should succeed)
UPDATE email_preferences 
SET newsletter = false 
WHERE user_id = auth.uid();

-- Try duplicate insert (should fail due to unique constraint)
INSERT INTO email_preferences (user_id, newsletter) 
VALUES (auth.uid(), false);

-- Try to access other user's preferences (should return empty)
SELECT * FROM email_preferences WHERE user_id != auth.uid();
```

### RLS Policy Tests

```sql
-- Test policy violations (should all fail or return empty)
INSERT INTO consents (user_id, scopes, version) 
VALUES ('00000000-0000-0000-0000-000000000000', '{}'::jsonb, 'v1.0'); -- Wrong user_id

INSERT INTO cycle_data (user_id, cycle_length, period_duration, last_period, age) 
VALUES ('00000000-0000-0000-0000-000000000000', 28, 5, '2025-09-01', 25); -- Wrong user_id

INSERT INTO email_preferences (user_id, newsletter) 
VALUES ('00000000-0000-0000-0000-000000000000', true); -- Wrong user_id
```

## Running Migrations

```bash
# Apply migrations
supabase db push

# Reset database (caution: destroys data)
supabase db reset

# Check migration status
supabase migration list
```

## Security Notes

- All tables have RLS enabled by default
- Only authenticated users can access their own data
- Foreign key constraints ensure data integrity
- CHECK constraints validate business rules
- Indexes optimize common query patterns

Following LUVI principle: "Engine darf nackt laufen – Daten nie" (Data protection is always active).

## Consent Change-Set Rule

**CRITICAL**: Consent-related changes form an atomic change-set.

### What counts as a "Consent Change"?

Changes to **any** of the following components require coordinated deployment:

| Component | Examples |
|-----------|----------|
| **DB Table** | `public.consents` (schema, constraints, RLS) |
| **DB Function** | `public.log_consent_if_allowed` |
| **Edge Function** | `supabase/functions/log_consent/` |
| **Scopes Config** | `config/consent_scopes.json` |
| **Migrations** | `*consent*.sql`, `*consents*.sql`, or RPC changes |

**Why?** Format drift between App, Edge Function, and DB constraint causes silent failures.

### Deployment Checklist for Consent Changes

> **Note:** These steps are performed **after merge** during deployment, not during PR review.

- [ ] Migration applied: `supabase db push`
- [ ] Edge Function deployed: `supabase functions deploy log_consent`
- [ ] Contract test passes: `deno test supabase/tests/log_consent.test.ts`
- [ ] SSOT test passes: `deno test supabase/functions/log_consent/consent_scopes_ssot.test.ts`
