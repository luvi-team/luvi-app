# Environment Variables Setup for Supabase

## Minimal setup

Create a `.env.development` file at the project root with:

```env
SUPABASE_URL=https://YOUR-PROJECT-ref.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_PUBLIC_KEY
```

The app loads this file in `lib/main.dart` using `flutter_dotenv` and initializes Supabase in `SupabaseService.initializeFromEnv()`.

The service prefers `SUPABASE_*` keys and gracefully falls back to legacy `SUPA_*` keys if present.

## Notes
- Do not commit real secrets. `.env.*` is already ignored by `.gitignore` (except `.env.example`).
- For other environments, create corresponding files (e.g. `.env.staging`, `.env.production`) and pass the appropriate file name to `dotenv.load()`.
