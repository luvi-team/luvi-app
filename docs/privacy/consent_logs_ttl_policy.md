# TTL Policy: consent_logs

Version: v1.0 · Retention: 12 months (365 days)

Policy
- Purpose: auditability and abuse prevention; records older than 12 months are purged.
- Scope: `consent_logs` table in Supabase Postgres.
- Frequency: daily cleanup at 03:15 UTC (example).

SQL (pg_cron)
```sql
-- enable extension once (managed by Supabase where available)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- housekeeping function
CREATE OR REPLACE FUNCTION purge_consent_logs_ttl()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  DELETE FROM consent_logs
  WHERE created_at < (now() - INTERVAL '365 days');
END$$;

-- schedule daily run
SELECT cron.schedule(
  'purge_consent_logs_ttl',
  '15 3 * * *',
  $$SELECT purge_consent_logs_ttl();$$
);
```

Notes
- If pg_cron is unavailable, schedule via Edge Function or external job runner with the same SQL.
- Keep an audit of purge runs (e.g., log affected row count).
- Review retention annually with legal/compliance; parameterize interval if policy changes.

