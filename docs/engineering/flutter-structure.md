# Flutter-Struktur & Navigations-Guidelines

Dieses Dokument ist der Single Source of Truth für Flutter-spezifische Struktur‑Konventionen in `luvi_app`. Es ergänzt `docs/engineering/repo-structure.md` und gilt für alle neuen Features, Refactors und Agent-Sessions.

## 1. Core vs. Features
- **lib/core/** enthält ausschließlich plattformweite Tokens & Hilfen:
  - `design_tokens/**`, `theme/**`, optional `config/**` (App-Links, Feature-Flags), `utils/**` für generische Hilfen, `analytics/**` für globales Tracking & Recorder-Hooks.
  - Keine Feature-spezifischen Widgets, Strings oder Services im Core.
- **lib/features/** beherbergt jede Domäne (auth, consent, onboarding …) inklusive `data/`, `domain/`, `state/`, `widgets/`, `screens/`.
- Shared Widgets:
  - Plattformweit (über mehrere Features hinweg): `core/widgets/` (z. B. `core/widgets/back_button.dart`). Nur dort ablegen, wenn der Baustein wirklich überall genutzt wird – sonst Feature-lokal halten.
  - Feature-Familie-weit (z. B. über alle Onboarding-Screens): `features/<feature>/widgets/` (z. B. `features/onboarding/widgets/onboarding_header.dart`).
  - Screen-spezifisch: Unterordner im jeweiligen Feature (`features/<feature>/widgets/`) organisieren; kein zentrales `features/widgets/` mehr verwenden.

## 2. Services
- Produktive Services leben in der lokalen Package-Workspace `services/` (aktuelles Package: `luvi_services`).
  - Neue Services → Datei unter `services/lib/`, optional Generator laufen lassen.
  - Abhängigkeiten im Package-Pubspec pflegen, App konsumiert via `luvi_services` Pfad-Dependency in `pubspec.yaml`.
- Unter `lib/services/` dürfen keine produktiven Dateien mehr existieren.

## 3. Assets & Strings
- Alle Asset-Pfade laufen über `lib/core/design_tokens/assets.dart`. Keine parallel definierten `Assets`-Klassen.
- Feature-spezifische Strings gehören in das Feature (z. B. `lib/features/auth/strings/auth_strings.dart`). Core darf nur truly globale Copy enthalten.

## 4. Navigation & Routen

### SSOT: Route Paths
- **`lib/core/navigation/route_paths.dart`** ist die Single Source of Truth für alle Route-Pfade.
- Alle Pfade werden als Konstanten definiert: `RoutePaths.splash`, `RoutePaths.authSignIn`, `RoutePaths.login`, etc.
- Screen-Klassen können zusätzlich `static const routeName` für Rückwärtskompatibilität behalten.

### Router-Komposition
- **`lib/router.dart`** (außerhalb von core/) enthält die GoRouter-Komposition.
- Importiert Feature-Screens und verdrahtet sie mit RoutePaths-Konstanten.
- Entry-Points (`main.dart`, `main_auth_entry.dart`) nutzen entweder `createRouter()` (Standard) oder erstellen einen eigenen `GoRouter` mit `routes: buildAppRoutes(ref)`, wenn zusätzliche Router-Wiring-Optionen (z. B. `refreshListenable`, `observers`) benötigt werden.

### Routes-Helpers (Core)
- **`lib/core/navigation/routes.dart`** enthält NUR Redirect-Helpers:
  - `supabaseRedirect`, `homeGuardRedirect`, etc.
- **Keine Feature-Imports** in core/navigation/ - das wäre eine Clean Architecture Violation.

### Best Practices
- Keine harten Pfad-Literale im Code: `context.go(RoutePaths.heute)` statt `context.go('/heute')`.
- Widgets navigieren via RoutePaths, niemals via Screen-Import.
- Parametrisierte Routes: `RoutePaths.workoutDetail.replaceFirst(':id', workoutId)`.

## 5. Tests
- Spiegelung: `test/features/<feature>/…` entspricht `lib/features/<feature>/…`.
- Neue Widgets erhalten gezielte Tests (z. B. `test/features/onboarding/widgets/onboarding_header_test.dart`) statt Sammel-Widgettests.
- Dev-/Audit-Tests bleiben unter `test/dev/**` und sind per Analyzer ausgeschlossen.

## 6. Review-Checkliste (jede Änderung)
1. Liegt der Code im richtigen Baum (core vs. features vs. services)?
2. Gibt es neue Assets/Strings? → zentrale Datei/Feature-Strings aktualisieren.
3. Wurden Routen erweitert? → `RoutePaths` + `lib/router.dart` + Tests anpassen.
4. Services geändert? → `luvi_services` Package (Pubspec & Imports) updaten.
5. Tests aktualisiert? → Spiegelpfad & gezielter Widget-Test vorhanden.

> **Hinweis:** Bei Abweichungen (z. B. bewusstes Legacy-Verzeichnis) muss im PR / Agent-Log kurz dokumentiert werden, warum die Regel ausnahmsweise nicht greift. Beispiel: Legacy-Navigationstests mit hart codierten Routen in `lib/services` werden unter ADR-0002 (RLS-Refactor) schrittweise migriert. Siehe ADR-0002.
