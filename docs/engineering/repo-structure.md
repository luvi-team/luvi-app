# Repository-Struktur (Referenz)

> Siehe zusätzlich `docs/engineering/flutter-structure.md` für verbindliche Flutter-spezifische Best Practices (Routen, Assets, Services, Tests).

## Verzeichnisbaum (Soll)
- lib/
- core/
  - design_tokens/
  - theme/
- features/
  - consent/
  - screens/
  - widgets/
  - state/
  - routes.dart
  - cycle/
  - data/            (API/repo/data sources)
  - domain/          (entities/models)
  - widgets/         (PhaseBadge)
- services/ (lokales Package `luvi_services`)
  - lib/user_state_service.dart
  - lib/supabase_service.dart
- test/
  - features/
    - consent/       (tests mirror the feature)
- goldens/
- widgets/
- root tests (e.g., cycle tests, widget_test.dart)

## Notizen
- Optional-Legacy-Folder aufräumen, wenn obsolet
- Dev-only Samples z. B. unter lib/dev/samples/ und via kDebugMode schützen
