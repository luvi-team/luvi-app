# Environment Variables Setup for Supabase

## Minimal setup

Create a `.env.development` file at the project root with:

```env
SUPABASE_URL=https://YOUR-PROJECT-ref.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_PUBLIC_KEY
```

The app initializes Supabase via `SupabaseService`. In production builds, credentials should be supplied using compile-time defines and NOT via asset files:

- Preferred (prod): pass via `--dart-define` or CI env → `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Fallback (local dev only): values loaded from `.env.*` using `flutter_dotenv`.

Resolution order inside the service: 1) `--dart-define` → 2) `.env` (`SUPABASE_*`) → 3) legacy `.env` (`SUPA_*`).

## Notes
- Do not commit real secrets. `.env.*` is ignored by `.gitignore` (only `.env.example` is tracked). If any real values were ever committed, rotate the credentials immediately and purge history.
- For other environments, create corresponding files (e.g. `.env.staging`, `.env.production`) for local dev only, and pass the file name to `dotenv.load()`.
- Sensitive data MUST NOT be stored in `SharedPreferences` or `.env` assets. Use platform-backed secure storage for secrets.
- Note: `.env.*` files used with `flutter_dotenv` during local development are acceptable as they are not bundled into the production app when using `--dart-define`.
