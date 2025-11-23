# Repository-Struktur (Referenz)

> Siehe zusätzlich `docs/engineering/flutter-structure.md` für verbindliche Flutter-spezifische Best Practices (Routen, Assets, Services, Tests).

## Verzeichnisbaum (Soll / Ist)
- lib/
  - core/
    - design_tokens/
    - theme/
    - config/
    - navigation/
    - analytics/
    - privacy/
    - utils/
    - widgets/
  - features/
    - auth/
    - consent/
    - cycle/
    - dashboard/
    - legal/
    - onboarding/
    - splash/
    - (jedes Feature inkl. `data/`, `domain/`, `state/`, `screens/`, `widgets/`, `utils/` nach Bedarf)
  - l10n/
- services/ — lokales Dart-Package (`luvi_services`)
  - geteilte App-Services unter `services/lib/**`
  - Konsumiert als Pfad-Dependency aus `pubspec.yaml`
- test/
  - core/            (spiegelt `lib/core/**`)
  - features/        (spiegelt `lib/features/**`)
  - services/        (Tests für `luvi_services`)
  - l10n/
  - support/         (Test-Helper, Mocks, Fixtures)
  - dev/             (Audit-/Dev-Only-Tests)
  - root tests (z. B. übergreifende Widget-/Integrationstests)

## Notizen
- Optional-Legacy-Folder aufräumen, wenn obsolet
- Dev-only Samples z. B. unter lib/dev/samples/ und via kDebugMode schützen
