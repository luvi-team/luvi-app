# Flutter-Struktur & Navigations-Guidelines

Dieses Dokument ist der Single Source of Truth für Flutter-spezifische Struktur‑Konventionen in `luvi_app`. Es ergänzt `docs/engineering/repo-structure.md` und gilt für alle neuen Features, Refactors und Agent-Sessions.

## 1. Core vs. Features
- **lib/core/** enthält ausschließlich plattformweite Tokens & Hilfen:
  - `design_tokens/**`, `theme/**`, optional `config/**` (App-Links, Feature-Flags), `utils/**` für generische Hilfen.
  - Keine Feature-spezifischen Widgets, Strings oder Services im Core.
- **lib/features/** beherbergt jede Domäne (auth, consent, onboarding …) inklusive `data/`, `domain/`, `state/`, `widgets/`, `screens/`.
- Shared Widgets (z. B. `features/widgets/`) müssen plattformweit genutzt werden; sonst Feature-lokal halten.
- Onboarding-weite Bausteine (z. B. `features/widgets/onboarding/onboarding_header.dart`) liegen im globalen Widgets-Pfad; screenspezifische Varianten bleiben weiterhin unter `features/onboarding/`.

## 2. Services
- Produktive Services leben in der lokalen Package-Workspace `services/` (aktuelles Package: `luvi_services`).
  - Neue Services → Datei unter `services/lib/`, optional Generator laufen lassen.
  - Abhängigkeiten im Package-Pubspec pflegen, App konsumiert via `luvi_services` Pfad-Dependency in `pubspec.yaml`.
- Unter `lib/services/` dürfen keine produktiven Dateien mehr existieren.

## 3. Assets & Strings
- Alle Asset-Pfade laufen über `lib/core/design_tokens/assets.dart`. Keine parallel definierten `Assets`-Klassen.
- Feature-spezifische Strings gehören in das Feature (z. B. `lib/features/auth/strings/auth_strings.dart`). Core darf nur truly globale Copy enthalten.

## 4. Navigation & Routen
- Jede Screen-Klasse definiert `static const routeName`.
- Cross-Screen Konstanten (z. B. Consent 01↔02) nutzen Feature-lokale Helper (`lib/features/consent/routes.dart`) statt bidirektionaler Imports.
- Keine harten Pfad-Literale im Code oder Tests. Benutze `context.go(Screen.routeName)` bzw. `context.goNamed`.
- `lib/features/routes.dart` importiert ausschließlich die Screen-Klassen und nutzt deren Konstante für `GoRoute.path`.

## 5. Tests
- Spiegelung: `test/features/<feature>/…` entspricht `lib/features/<feature>/…`.
- Neue Widgets erhalten gezielte Tests (z. B. `test/features/widgets/onboarding/onboarding_header_test.dart`) statt Sammel-Widgettests.
- Dev-/Audit-Tests bleiben unter `test/dev/**` und sind per Analyzer ausgeschlossen.

## 6. Review-Checkliste (jede Änderung)
1. Liegt der Code im richtigen Baum (core vs. features vs. services)?
2. Gibt es neue Assets/Strings? → zentrale Datei/Feature-Strings aktualisieren.
3. Wurden Routen erweitert? → `routeName` + `features/routes.dart` + Tests anpassen.
4. Services geändert? → `luvi_services` Package (Pubspec & Imports) updaten.
5. Tests aktualisiert? → Spiegelpfad & gezielter Widget-Test vorhanden.

> **Hinweis:** Bei Abweichungen (z. B. bewusstes Legacy-Verzeichnis) muss im PR / Agent-Log kurz dokumentiert werden, warum die Regel ausnahmsweise nicht greift.
