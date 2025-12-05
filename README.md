# luvi_app

A new Flutter project.

## App-Kontext (SSOT)

Primäre Quelle im Repo:
Hinweis: ":1" kennzeichnet die Startzeile (Zeile 1) des Dokuments.
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

## Local Development (Supabase Credentials)

Supabase-Credentials werden via `--dart-define` übergeben (Security Best Practice - nicht im Asset-Bundle).

### Setup

1. **Erstelle `.env.development`** (falls nicht vorhanden):
   ```bash
   cp .env.example .env.development
   # Dann SUPABASE_URL und SUPABASE_ANON_KEY eintragen
   ```

2. **App starten** (wähle eine Option):

   **Option A: Helper-Script (empfohlen)**
   ```bash
   ./scripts/run_dev.sh -d "iPhone 16 Pro"   # iOS Simulator
   ./scripts/run_dev.sh -d chrome            # Chrome
   ./scripts/run_dev.sh                      # Default device
   ```

   **Option B: VSCode**
   - F5 drücken → "LUVI (Dev)" oder "LUVI (Dev) - iPhone Simulator" wählen
   - Voraussetzung: Shell-Umgebungsvariablen gesetzt (siehe unten)

   **Option C: Manuell**
   ```bash
   export $(cat .env.development | xargs)
   flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL \
               --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
   ```

### Warum --dart-define statt Asset-Bundling?

- Credentials sind **nicht** im APK/IPA extrahierbar
- Konsistent mit Production-Builds
- Flutter Security Best Practice

### Fallback (Legacy)

Falls `--dart-define` nicht gesetzt ist, versucht die App `.env.development` via `flutter_dotenv` zu laden (funktioniert nur auf Web/Desktop, nicht auf iOS/Android Simulatoren).

## Flutter Tooling (Codex CLI)

- Standardisierte Aufrufe über Wrapper: `scripts/flutter_codex.sh`
  - Analyze: `scripts/flutter_codex.sh analyze`
  - Tests: `scripts/flutter_codex.sh test -j 1` (Loopback-Socket kann eine Sandbox-Genehmigung erfordern)
  - Version: `scripts/flutter_codex.sh --version`
- Optional für Builds/Signing/Performance:
  - WARNUNG: `CODEX_USE_REAL_HOME=1` ist ausschließlich für lokale Entwicklung gedacht und darf NIEMALS in CI verwendet werden.
    - Risiken: Sicherheitsprobleme (Zugriff/Leak auf echte Credentials & Schlüssel in `~/.gradle`, `~/.cocoapods`, `~/.pub-cache`) und fehlende Reproduzierbarkeit.
    - Lokales Beispiel (sicherer): `CODEX_USE_REAL_HOME=1 scripts/flutter_codex.sh build` nur auf deinem Dev‑Rechner; im Zweifel vorher temporäre Test-Accounts/Creds nutzen.
    - Empfehlung (Guard): In `scripts/flutter_codex.sh` einen Runtime‑Check ergänzen, der bei gesetztem `CODEX_USE_REAL_HOME` in CI abbricht oder laut warnt (erkenne gängige CI‑Variablen wie `CI`, `GITHUB_ACTIONS`, `BUILD_NUMBER`, `VERCEL`, `CODESPACES`).
  - `CODEX_USE_REAL_HOME=1 scripts/flutter_codex.sh <cmd>` nutzt das echte `$HOME`/Standard‑Caches (z. B. `~/.gradle`, `~/.cocoapods`).
- Make‑Shortcuts:
  - `make analyze`
  - `make test`
  - `make flutter-version`
  - `make format` (Check only)
  - `make format-apply`
  - `make fix`

## Vercel Backend (Hybrid)

- App‑Kontext: `docs/product/app-context.md:1`
- Tech‑Stack: `docs/engineering/tech-stack.md:1`
- Roadmap: `docs/product/roadmap.md:1`
- Gold‑Standard Workflow (inkl. „Praktische Anleitung · Ultra‑Slim“): `docs/engineering/gold-standard-workflow.md:62`

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
