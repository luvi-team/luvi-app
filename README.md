# luvi_app

A new Flutter project.

## App-Kontext (SSOT)

Primäre Quelle im Repo:
- docs/product/app-context.md:1

Roadmap (SSOT):
- docs/product/roadmap.md:1

Archiv (älter):
- context/refs/app_context_v3.2.md:1
- context/refs/archive/app_context_napkin_v3.1.txt:1

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Note: Dieses Projekt verwendet `flutter_dotenv`; lokale Entwicklung nutzt `.env.development` (siehe `.env.example` als Vorlage).

## Flutter Tooling (Codex CLI)

- Standardisierte Aufrufe über Wrapper: `scripts/flutter_codex.sh`
  - Analyze: `scripts/flutter_codex.sh analyze`
  - Tests: `scripts/flutter_codex.sh test -j 1` (Loopback‑Socket kann in Sandbox Approval erfordern)
  - Version: `scripts/flutter_codex.sh --version`
- Optional für Builds/Signing/Performance:
  - `CODEX_USE_REAL_HOME=1 scripts/flutter_codex.sh <cmd>` nutzt das echte `$HOME`/Standard‑Caches (z. B. `~/.gradle`, `~/.cocoapods`).
- Make‑Shortcuts:
  - `make analyze`
  - `make test`
  - `make flutter-version`
  - `make format` (Check only)
  - `make format-apply`
  - `make fix`

## Vercel Backend (Hybrid)

1. **Hybrid-Architektur:** Supabase übernimmt Auth, CRUD und Realtime (mit RLS), während Vercel die KI-Endpunkte, Webhooks und Cron-Jobs ausführt.
2. **Setup:** Repository mit Vercel verknüpfen, `VERCEL_API_URL` in der Umgebung setzen; AI-Schlüssel folgen später über die Vercel-Konfiguration.
3. **Development:** `cd api && npm install && npm test && vercel dev` – der Health-Check steht unter `/api/health` bereit.
4. **Weiterführend:** Siehe `api/README.md` für Details zu Logging, CORS und DSGVO-Vorgaben.

## Database Security (RLS)

### Row Level Security (RLS) Implementation

All tables in this project use Supabase Row Level Security (RLS) with owner-based policies:

#### daily_plan Table
- **RLS Status**: ✅ Enabled
- **Policies**: Owner-based (user_id = auth.uid())
  - SELECT: Users can only view their own daily plans
  - INSERT: Users can only create their own daily plans  
  - UPDATE: Users can only update their own daily plans
  - DELETE: Users can only delete their own daily plans
- **Auto-Population**: Trigger `set_user_id_from_auth()` automatically sets user_id from auth context
- **Validation**: Ensures user_id always matches authenticated user

#### Running Migrations
```bash
# Apply new migrations
supabase migration up

# Check migration status
supabase migration list

# Reset database (development only)
supabase db reset
```

#### Testing RLS
Widget tests verify RLS enforcement:
```bash
flutter test test/widgets/daily_plan_rls_test.dart
```

## Init Mode (Tests vs Prod)

- The app uses an InitMode to control initialization behavior (prod/test). The default is `prod` via `initModeProvider`.
- Services access the mode via a small bridge bound in `main.dart`. In widget tests, override with `ProviderScope(overrides: [initModeProvider.overrideWithValue(InitMode.test)])` to run offline without retries/overlays.
- Tests that require a logically initialized client should inject fakes via Provider overrides instead of hitting real network.
