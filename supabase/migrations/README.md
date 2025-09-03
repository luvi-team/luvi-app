# LUVI Database Migrations

## Migration Files

- `20250903235538_create_consents_table.sql` - User consent management with GDPR compliance
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
VALUES (auth.uid(), '{"data_processing": true, "marketing": false}', 'v1.0');

-- View own consents (should succeed)
SELECT * FROM consents WHERE user_id = auth.uid();

-- Update own consent (should succeed)
UPDATE consents 
SET scopes = '{"data_processing": true, "marketing": true}' 
WHERE user_id = auth.uid() AND version = 'v1.0';

-- Revoke consent (should succeed)
UPDATE consents 
SET revoked_at = NOW() 
WHERE user_id = auth.uid() AND version = 'v1.0';

-- Try to view other user's consents (should return empty)
SELECT * FROM consents WHERE user_id != auth.uid();
```

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
VALUES ('00000000-0000-0000-0000-000000000000', '{}', 'v1.0'); -- Wrong user_id

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

Following LUVI principle: "Engine darf nackt laufen  Daten nie" (Data protection is always active).