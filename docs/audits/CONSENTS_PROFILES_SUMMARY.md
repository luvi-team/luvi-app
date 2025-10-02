# Consents & Profiles Summary

## consents
- Columns unavailable: Supabase CLI requires authentication; `supabase gen types` failed, so `consents` type not generated.

## profiles
- Columns unavailable: Supabase CLI requires authentication; `supabase gen types` failed, so `profiles` type not generated.

## Consent Flags
- `accepted` boolean: not detected (schema unavailable).
- `version` integer: not detected (schema unavailable).
- `has_consented` boolean in profiles: not detected (schema unavailable).

## Edge Functions
- `log_consent`: present in repository (`supabase/functions/log_consent`). CLI listing skipped due to authentication failure.

## Notes
- To refresh schema types, run `supabase login` (or set `SUPABASE_ACCESS_TOKEN`) and rerun `supabase gen types typescript --project-id cwloioweaqvhibuzdwpi --schema public > docs/audits/SUPABASE_SCHEMA_public.ts`.
- The CLI commands were executed with Supabase CLI v2.40.7; authentication is required for hosted projects.
