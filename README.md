# luvi_app

A new Flutter project.

## App-Kontext (SSOT)

Der aktuelle, bereinigte App‑Kontext ist hier abgelegt:
- context/refs/app_context_v3.2.md:1

Archiv (älter):
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

## SSOT/Quickstart

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
