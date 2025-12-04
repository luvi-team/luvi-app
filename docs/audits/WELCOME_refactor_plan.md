# Plan: Welcome Screens Refactoring (3 → 5 Screens)

**Persistenter Speicherort:** `docs/audits/WELCOME_refactor_plan.md`

---

## Zusammenfassung
Refactoring der Welcome-Screens von 3 auf 5 Screens mit Video-Integration, vereinfachten Titeln und Entfernung von UI-Elementen (Dots, Skip-Button).

---

## Workflow-Übersicht

```
Phase 0: Assets vorbereiten (User)
    ↓
Phase 1: Figma-Audits (Design-Specs extrahieren)
    ↓
Phase 2: Dependencies & Video-Widget
    ↓
Phase 3: WelcomeShell modifizieren
    ↓
Phase 4: Screen-Dateien (refactor + neu)
    ↓
Phase 5: Assets-Referenzen aktualisieren
    ↓
Phase 6: Routes aktualisieren
    ↓
Phase 7: Lokalisierung
    ↓
Phase 8: Aufräumen (alte Dateien löschen)
    ↓
Phase 9: Tests
```

---

## Anforderungen

| Screen | Typ | Titel | Subtitle | Button |
|--------|-----|-------|----------|--------|
| 1 | VIDEO | Dein Körper. Dein Rhythmus. Jeden Tag. | Dein täglicher Begleiter für Training, Ernährung, Schlaf & mehr. | Weiter |
| 2 | FOTO | In Sekunden wissen, was heute zählt. | Kein Suchen, kein Raten. LUVI zeigt dir den nächsten Schritt. | Weiter |
| 3 | FOTO | Passt sich deinem Zyklus an. | Damit du mit deinem Körper arbeitest, nicht gegen ihn. | Weiter |
| 4 | FOTO | Von Expert:innen erstellt. | Kein Algorithmus, sondern echte Menschen. | Weiter |
| 5 | VIDEO | Kleine Schritte heute. Große Wirkung morgen. | Für jetzt – und dein zukünftiges Ich. | Jetzt loslegen |

### Design-Änderungen
- ✅ Keine farbigen Akzent-Wörter mehr (alles schwarz)
- ✅ Dot-Indikatoren entfernen
- ✅ Skip-Button entfernen
- ✅ Videos: Autoplay, Loop, kein Ton, Pause bei Background
- ⏳ Button-Farbe: Später via Figma-Audit

---

## Implementierungsplan

### Phase 0: Assets vorbereiten (User-Aufgabe)

**Alte Assets löschen:**
```
assets/images/welcome/
├── welcome_01.png          ← LÖSCHEN (altes Stretching-Bild)
├── welcome_02.png          ← LÖSCHEN (altes Gymnastikball-Bild)
├── welcome_03.png          ← LÖSCHEN (altes Hände-Bild)
├── 2.0x/welcome_01.png     ← LÖSCHEN
├── 2.0x/welcome_02.png     ← LÖSCHEN
├── 2.0x/welcome_03.png     ← LÖSCHEN
├── 3.0x/welcome_01.png     ← LÖSCHEN
├── 3.0x/welcome_02.png     ← LÖSCHEN
└── 3.0x/welcome_03.png     ← LÖSCHEN
```

**Neue Bilder importieren:**
```
assets/images/welcome/
├── welcome_02.png          ← NEU: Frau mit Handy (Screen 2)
├── welcome_03.png          ← NEU: Frau meditiert (Screen 3)
├── welcome_04.png          ← NEU: Zwei Frauen mit Tablet (Screen 4)
├── 2.0x/
│   ├── welcome_02.png
│   ├── welcome_03.png
│   └── welcome_04.png
├── 3.0x/
│   ├── welcome_02.png
│   ├── welcome_03.png
│   └── welcome_04.png
└── welcome_wave.svg        ← BEHALTEN (wird weiterverwendet)
```

**Neue Videos importieren:**
```
assets/videos/welcome/      ← NEUER ORDNER ERSTELLEN
├── welcome_01.mp4          ← NEU: Goldenes Video (Screen 1)
└── welcome_05.mp4          ← NEU: Frau im Sonnenlicht (Screen 5)
```

---

### Phase 1: Figma-Audits (BEVOR Implementierung)

**Ziel:** Exakte Design-Specs aus Figma extrahieren für pixel-perfekte Implementierung.

**Pro Screen auditen:**
- [ ] Screen 1 (Video) – Node-ID: `_________` (User liefert später)
- [ ] Screen 2 (Foto) – Node-ID: `_________`
- [ ] Screen 3 (Foto) – Node-ID: `_________`
- [ ] Screen 4 (Foto) – Node-ID: `_________`
- [ ] Screen 5 (Video) – Node-ID: `_________`

**Zu extrahierende Design-Specs:**

| Kategorie | Details |
|-----------|---------|
| **Spacing** | Padding (horizontal/vertikal), Gaps zwischen Elementen |
| **Typography** | Font-Family, Font-Size, Font-Weight, Line-Height, Letter-Spacing |
| **Farben** | Titel-Farbe, Subtitle-Farbe, Button-Farbe (Fill + Text), Hintergrund |
| **Button** | Höhe, Breite, Border-Radius, Padding |
| **Wave** | Höhe, Position, ggf. neue SVG wenn geändert |
| **Hero** | Aspect-Ratio, Position relativ zur Wave |
| **Layout** | Vertikale Abstände zwischen Title ↔ Subtitle ↔ Button |

**Figma MCP Tools:**
- `mcp__figma__get_design_context` – Haupt-Tool für Code-Generierung
- `mcp__figma__get_screenshot` – Visuelle Referenz
- `mcp__figma__get_variable_defs` – Design-Token-Werte

**Output:** Design-Specs-Dokument mit allen Werten, das als Referenz für die Implementierung dient.

**Zusätzliche Checks in Phase 1:**
- [x] FTUE-Flag finden: Wo wird `hasSeenWelcome`/`isFirstLaunch` gesetzt? ✅
- [x] Prüfen ob Flag-Logik durch neue Routen (w4, w5) beeinflusst wird ✅
- [x] Referenz-Suche für DotsIndicator, dotsCount, alte Assets durchführen ✅
- [x] **Wave-SVG prüfen:** Ist `welcome_wave.svg` im neuen Design identisch oder gibt es eine neue Version? ✅

---

### Phase 1 Ergebnisse (Audit vom 2025-12-04)

#### 1.1 Figma Node-IDs (verifiziert)

| Screen | Node-ID | Typ |
|--------|---------|-----|
| 1 | `68911:8427` | VIDEO |
| 2 | `68911:8391` | FOTO |
| 3 | `68911:8402` | FOTO |
| 4 | `68911:8414` | FOTO |
| 5 | `68924:1197` | VIDEO |

#### 1.2 Gemeinsame Design-Specs (alle Screens)

| Kategorie | Wert | Flutter Token |
|-----------|------|---------------|
| Screen-Basis | 393×852px (iPhone 14 Pro) | Device-abhängig |
| Background | `#FFFFFF` | `colorScheme.surface` |
| Text-Farbe | `#030401` | `colorScheme.onSurface` |

**Typography:**

| Element | Font | Size | Weight | Line-Height | Token |
|---------|------|------|--------|-------------|-------|
| Title | Playfair Display | 32px | SemiBold (600) | 38px | `textTheme.headlineMedium` |
| Subtitle | Figtree | 20px | Regular (400) | 26px | `textTheme.bodyLarge` |
| Button | Figtree | 20px | Bold (700) | 24px | `textTheme.labelLarge` |

> ✅ **Font-Weight-Entscheidung:** Figma nutzt `Playfair Display SemiBold` (600), aber `pubspec.yaml` hat nur Regular/Bold. **Lösung:** Bold (700) als Fallback akzeptiert. SemiBold kann später nachgerüstet werden falls nötig.

**Button:**

| Property | Figma | Code-Token | Code-Wert | Entscheidung |
|----------|-------|------------|-----------|--------------|
| Höhe | 48px | `Sizes.buttonHeight` | 50px | ✅ 50px behalten (2px Diff akzeptiert) |
| Breite | 345px | Full-width mit Padding | — | ✅ `Spacing.l` (24px) horizontal |
| Border-Radius | 40px | `Sizes.radiusXL` | 40px | ✅ Existiert bereits! |
| Hintergrund | `#A8406F` | `colorScheme.primary` | — | ✅ Passt |
| Text-Farbe | `#FFFFFF` | `colorScheme.onPrimary` | — | ✅ Passt |

**Wave & Layout:**

| Property | Figma | Code-Token | Code-Wert | Entscheidung |
|----------|-------|------------|-----------|--------------|
| Wave-Höhe | 321px | `kWelcomeWaveHeight` | 427px | ✅ Auf 321px anpassen (responsiv) |
| Wave-Start (Y) | 531px | — | — | Relativ zu Screen-Höhe |
| Content-Top | 560px | — | — | Relativ zu Wave |
| Content-Left | 16px | `Spacing.m` | 16px | ✅ Existiert bereits! |
| Content-Width | 360px | — | — | Screen-Breite minus 2×16px |
| Gap Title↔Subtitle | 16px | `Spacing.m` | 16px | ✅ Existiert bereits! |

> **Responsiv-Strategie:** Figma-Referenz ist 393×852px (iPhone 14 Pro). Wave-Höhe 321px als Basis, proportional zur Screen-Höhe skalieren. Padding/Gaps bleiben konstant (16px).

#### 1.2b Entscheidungen (Stand: 2025-12-04)

| # | Thema | Entscheidung | Begründung |
|---|-------|--------------|------------|
| 1 | Wave-Höhe | **321px** (responsiv skaliert) | Figma ist visuelle Wahrheit |
| 2 | Font-Weight | **Bold (700)** als Fallback | Pragmatisch, SemiBold später nachrüstbar |
| 3 | Padding | **16px** via `Spacing.m` | Token existiert bereits |
| 4 | Button-Höhe | **50px behalten** | 2px Differenz kaum sichtbar, kein Breaking Change |
| 5 | Button-Radius | **`Sizes.radiusXL`** | Token existiert bereits (40px) |

#### 1.3 Screen-spezifische Specs

| Screen | Hero-Größe | Title | Button-Text |
|--------|------------|-------|-------------|
| 1 | 393×569px | "Dein Körper. Dein Rhythmus. Jeden Tag." | "Weiter" |
| 2 | 393×569px | "In Sekunden wissen, was heute zählt." | "Weiter" |
| 3 | 393×568px | "Passt sich deinem Zyklus an." | "Weiter" |
| 4 | 393×581px | "Von Expert:innen erstellt." | "Weiter" |
| 5 | 392×568px | "Kleine Schritte heute. Große Wirkung morgen." | **"Jetzt loslegen"** |

#### 1.4 Repo-Audit Ergebnisse

**DotsIndicator:** ✅ Nur in Welcome-Kontext
- `dots_indicator.dart:6-7` – Widget-Definition
- `welcome_shell.dart:7` – Import
- `welcome_shell.dart:135` – Verwendung
→ **Gefahrlos löschbar**

**dotsCount:** ✅ Nur für Dots
- `sizes.dart:15` – Konstante
- `welcome_shell.dart:135` – Verwendung
→ **Gefahrlos löschbar**

**Alte Asset-Konstanten:**
- `welcomeHero01` → `consent_welcome_01_screen.dart:63` → **LÖSCHEN** (Video ersetzt)
- `welcomeHero02` → `consent_welcome_02_screen.dart:45` → BEHALTEN (neues Bild)
- `welcomeHero03` → `consent_welcome_03_screen.dart:48` → BEHALTEN (neues Bild)

**Wave-SVG:** ✅ Identisch im Figma – kann weiterverwendet werden

#### 1.5 FTUE-Flow (verifiziert)

```
Lesen:  splash_screen.dart:82 → service.hasSeenWelcomeOrNull
Setzen: consent_02_screen.dart:591 → _markWelcomeSeen() → userState.markWelcomeSeen()

Flow:   Welcome w1→w5 → Consent01 → Consent02 [FLAG] → Onboarding01
```

→ **Keine Code-Änderung am Flag-Handling nötig** ✅

---

### Phase 2: Dependencies & Video-Widget

**2.1 pubspec.yaml**
```yaml
dependencies:
  video_player: ^2.9.1

flutter:
  assets:
    - assets/videos/welcome/
```

**2.2 Neues Widget erstellen**
- **Datei:** `lib/features/consent/widgets/welcome_video_player.dart`
- VideoPlayerController mit Asset-Pfad
- `WidgetsBindingObserver` für App-Lifecycle (Pause/Resume bei Background)
- Autoplay, Loop, Volume 0
- Loading-State mit Placeholder
- **Visibility-Awareness:** ✅ **Option B gewählt** – `isActive` Parameter vom Parent
  - Keine zusätzliche Dependency (kein `visibility_detector` Package)
  - Welcome-Screens nutzen Button-Navigation, kein Swipe → Parent weiß immer welcher Screen aktiv
  - Einfacher zu testen
  ```dart
  class WelcomeVideoPlayer extends StatefulWidget {
    final String assetPath;
    final bool isActive; // Parent setzt true wenn Screen sichtbar
    // ...
  }
  ```
- **A11y:** Video ist rein dekorativ → `excludeFromSemantics: true` (analog zu aktuellem Image.asset Code)
- **Error-State:** Falls Video nicht lädt → Fallback auf neutralen Placeholder:
  ```dart
  errorBuilder: (context, error) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
  ),
  ```
- **Video-Encoding (vom User zu beachten):**
  - Format: H.264 (MP4) für maximale Kompatibilität
  - Keine Tonspur (oder stumm) – spart Dateigröße
  - Empfohlene Größe: < 5 MB pro Video für schnellen App-Start
  - Auflösung: 1080p oder 720p je nach Ziel-Geräten

---

### Phase 3: WelcomeShell modifizieren

**Datei:** [lib/features/consent/widgets/welcome_shell.dart](lib/features/consent/widgets/welcome_shell.dart)

Änderungen:
1. **Zeile 7:** `import 'dots_indicator.dart';` entfernen
2. **Zeile 18:** `activeIndex` Parameter komplett entfernen (nicht nur deprecated)
3. **Zeilen 130-137:** DotsIndicator-Block entfernen
4. **Zeilen 148-155:** Skip-Button (TextButton) entfernen
5. Assert in Zeile 26-32 anpassen (activeIndex nicht mehr in Bedingung)

> **Call-Sites aktualisieren:** Alle `consent_welcome_0X_screen.dart` Dateien müssen den `activeIndex: X` Parameter entfernen, um Linter-Warnungen zu vermeiden.

---

### Phase 4: Screen-Dateien

**Refactoring-Strategie:**

| Alte Datei | Aktion | Neue Verwendung |
|------------|--------|-----------------|
| `consent_welcome_01_screen.dart` | **REFACTOR** | Screen 1 – Video statt Bild, neuer Text |
| `consent_welcome_02_screen.dart` | **REFACTOR** | Screen 2 – neues Bild, neuer Text |
| `consent_welcome_03_screen.dart` | **REFACTOR** | Screen 3 – neues Bild, neuer Text |
| — | **NEU** | `consent_welcome_04_screen.dart` |
| — | **NEU** | `consent_welcome_05_screen.dart` |

**Was wird wiederverwendet:**
- ✅ `WelcomeShell` Widget (Struktur mit Hero, Wave, Text, Button)
- ✅ `welcome_wave.svg` (die weiße Kurve)
- ✅ `LocalizedBuilder` Wrapper
- ✅ `welcome_metrics.dart` (Aspect-Ratio, Wave-Höhe – ggf. nach Figma-Audit anpassen)
- ✅ Navigation-Pattern mit GoRouter

**Was wird geändert:**
- ❌ RichText mit Akzent-Farbe → einfacher schwarzer Text
- ❌ `activeIndex` Parameter → nicht mehr benötigt
- ❌ Image.asset → WelcomeVideoPlayer (nur Screen 1 & 5)

**4.1 Bestehende Screens modifizieren**

| Datei | Änderungen |
|-------|------------|
| [consent_welcome_01_screen.dart](lib/features/consent/screens/consent_welcome_01_screen.dart) | Hero → Video, Titel vereinfachen (kein RichText), neue L10n-Keys |
| [consent_welcome_02_screen.dart](lib/features/consent/screens/consent_welcome_02_screen.dart) | Titel vereinfachen, neue L10n-Keys, Navigation bleibt → w3 |
| [consent_welcome_03_screen.dart](lib/features/consent/screens/consent_welcome_03_screen.dart) | Titel vereinfachen, neue L10n-Keys, Navigation → w4 (NEU) |

**4.2 Neue Screens erstellen**

| Datei | Details |
|-------|---------|
| `consent_welcome_04_screen.dart` | Route: `/onboarding/w4`, Hero: Foto, Navigation → w5 |
| `consent_welcome_05_screen.dart` | Route: `/onboarding/w5`, Hero: Video, Button: "Jetzt loslegen", Navigation → `/consent/01` |

> ⚠️ **WICHTIG:** Screen 5 navigiert zu `Consent01Screen.routeName` (`/consent/01`), NICHT zu `/onboarding/01`!
> Der DSGVO-Consent-Flow (Consent01 → Consent02) darf nicht übersprungen werden.
> Das `hasSeenWelcome`-Flag wird erst in `Consent02Screen` gesetzt, nicht am Ende der Welcome-Screens.

**4.3 FTUE-Flag – KEINE Änderung nötig** ✅

> ✅ **Verifiziert:** Das `hasSeenWelcome`-Flag wird in `consent_02_screen.dart` (Zeile 591-594) gesetzt,
> NACH dem DSGVO-Consent-Flow – nicht am Ende der Welcome-Screens.

**Aktueller Flow (bleibt unverändert):**
```
Welcome w1→w5 → Consent01 → Consent02 [hasSeenWelcome gesetzt] → Onboarding01
```

**Fundstellen:**
- **Lesen:** `splash_screen.dart` → `service.hasSeenWelcomeOrNull`
- **Schreiben:** `consent_02_screen.dart` → `_markWelcomeSeen()` → `userState.markWelcomeSeen()`

**Keine Code-Änderung erforderlich** – der Flow bleibt semantisch korrekt (Welcome = Consent abgeschlossen).

---

### Phase 5: Assets-Referenzen aktualisieren

**Datei:** [lib/core/design_tokens/assets.dart](lib/core/design_tokens/assets.dart)

> **Klarstellung:** Die *Pfade* für `welcome_02.png` und `welcome_03.png` bleiben gleich – nur die *Bilddateien* wurden ausgetauscht. Die Code-Konstanten `welcomeHero02` und `welcomeHero03` bleiben unverändert. Nur `welcomeHero01` wird entfernt (ersetzt durch Video).

**Entfernen:**
```dart
// NUR diese Zeilen LÖSCHEN (Screen 1 nutzt jetzt Video):
const String _kWelcomeHero01 = 'assets/images/welcome/welcome_01.png';  // ← LÖSCHEN

// In _Images Klasse LÖSCHEN:
final String welcomeHero01 = _kWelcomeHero01;  // ← LÖSCHEN
```

**Behalten (Pfade bleiben, Bilddateien wurden ausgetauscht):**
```dart
// Diese Konstanten BLEIBEN unverändert:
const String _kWelcomeHero02 = 'assets/images/welcome/welcome_02.png';  // BEHALTEN (neues Bild)
const String _kWelcomeHero03 = 'assets/images/welcome/welcome_03.png';  // BEHALTEN (neues Bild)

// In _Images Klasse BEHALTEN:
final String welcomeHero02 = _kWelcomeHero02;  // BEHALTEN
final String welcomeHero03 = _kWelcomeHero03;  // BEHALTEN
```

**Hinzufügen:**
```dart
// Neue Konstanten:
const String _kWelcomeHero04 = 'assets/images/welcome/welcome_04.png';  // NEU
const String _kWelcomeVideo01 = 'assets/videos/welcome/welcome_01.mp4'; // NEU
const String _kWelcomeVideo05 = 'assets/videos/welcome/welcome_05.mp4'; // NEU

// In _Images Klasse hinzufügen:
final String welcomeHero04 = _kWelcomeHero04;

// Neue _Videos Klasse erstellen:
class _Videos {
  const _Videos();
  final String welcomeVideo01 = _kWelcomeVideo01;
  final String welcomeVideo05 = _kWelcomeVideo05;
}

// In Assets Klasse hinzufügen:
static const videos = _Videos();
```

**Asset-Dateien (vom User bereitzustellen):**
- `assets/videos/welcome/welcome_01.mp4`
- `assets/videos/welcome/welcome_05.mp4`
- `assets/images/welcome/welcome_02.png` (+ 2x, 3x) - aktualisiert
- `assets/images/welcome/welcome_03.png` (+ 2x, 3x) - aktualisiert
- `assets/images/welcome/welcome_04.png` (+ 2x, 3x) - neu

---

### Phase 6: Routes aktualisieren

**Datei:** `lib/core/navigation/routes.dart`

Neue Routes hinzufügen:
```dart
GoRoute(
  path: ConsentWelcome04Screen.routeName,  // '/onboarding/w4'
  name: 'welcome4',
  builder: (context, state) => const ConsentWelcome04Screen(),
),
GoRoute(
  path: ConsentWelcome05Screen.routeName,  // '/onboarding/w5'
  name: 'welcome5',
  builder: (context, state) => const ConsentWelcome05Screen(),
),
```

---

### Phase 7: Lokalisierung

**Dateien:** `lib/l10n/app_de.arb` & `lib/l10n/app_en.arb`

**Neue Keys (vereinfacht):**
```json
// DE
"welcome01Title": "Dein Körper. Dein Rhythmus. Jeden Tag.",
"welcome01Subtitle": "Dein täglicher Begleiter für Training, Ernährung, Schlaf & mehr.",
"welcome02Title": "In Sekunden wissen, was heute zählt.",
"welcome02Subtitle": "Kein Suchen, kein Raten. LUVI zeigt dir den nächsten Schritt.",
"welcome03Title": "Passt sich deinem Zyklus an.",
"welcome03Subtitle": "Damit du mit deinem Körper arbeitest, nicht gegen ihn.",
"welcome04Title": "Von Expert:innen erstellt.",
"welcome04Subtitle": "Kein Algorithmus, sondern echte Menschen.",
"welcome05Title": "Kleine Schritte heute. Große Wirkung morgen.",
"welcome05Subtitle": "Für jetzt – und dein zukünftiges Ich.",
"welcome05PrimaryCta": "Jetzt loslegen"

// EN
"welcome01Title": "Your body. Your rhythm. Every day.",
"welcome01Subtitle": "Your daily companion for training, nutrition, sleep & more.",
"welcome02Title": "Know what matters today in seconds.",
"welcome02Subtitle": "No searching, no guessing. LUVI shows you the next step.",
"welcome03Title": "Adapts to your cycle.",
"welcome03Subtitle": "So you work with your body, not against it.",
"welcome04Title": "Created by experts.",
"welcome04Subtitle": "No algorithm, but real people.",
"welcome05Title": "Small steps today. Big impact tomorrow.",
"welcome05Subtitle": "For now – and your future self.",
"welcome05PrimaryCta": "Start now"
```

**Alte Keys entfernen:**
- `welcome01TitlePrefix`, `welcome01TitleAccent`, `welcome01TitleSuffixLine1`, `welcome01TitleSuffixLine2`
- `welcome02TitleLine1`, `welcome02TitleLine2`
- `welcome03TitleLine1`, `welcome03TitleLine2`

---

### Phase 8: Aufräumen

**Dateien löschen:**
- `lib/features/consent/widgets/dots_indicator.dart`

**Dateien aktualisieren:**
- `lib/core/design_tokens/sizes.dart` – `dotsCount` entfernen (falls nicht anderweitig genutzt)

**Hinweis:** `consent_01_screen.dart` hat keinen Zurück-Button → keine Änderung nötig.

---

### Phase 9: Tests

**Bestehende Tests aktualisieren:**
- `test/features/consent/screens/consent_welcome_01_screen_test.dart`
- `test/features/consent/screens/consent_welcome_02_screen_test.dart`
- `test/features/consent/screens/consent_welcome_03_screen_test.dart`
- `test/features/consent/widgets/welcome_shell_test.dart`

**Neue Tests erstellen:**
- `test/features/consent/screens/consent_welcome_04_screen_test.dart`
- `test/features/consent/screens/consent_welcome_05_screen_test.dart`
- `test/features/consent/widgets/welcome_video_player_test.dart`

**Tests löschen:**
- `test/features/consent/widgets/welcome_shell_active_index_test.dart` (Dots nicht mehr relevant)
- `test/features/consent/widgets/dots_indicator_test.dart` (falls vorhanden)

**9.1 QA-Schritt (manuell)**

> Vor Merge: Manueller Test auf echten Geräten/Emulatoren

- [ ] iOS Simulator: Video-Autoplay, Loop, Pause bei App-Background
- [ ] Android Emulator: Video-Autoplay, Loop, Pause bei App-Background
- [ ] Navigation w1 → w2 → w3 → w4 → w5 → **Consent01** → Consent02 funktioniert
- [ ] App-Neustart nach Consent02: Welcome-Screens werden nicht mehr gezeigt (FTUE-Flag)

**9.2 routes_predicates_test.dart erweitern**

**Datei:** `test/core/navigation/routes_predicates_test.dart`

Neue Test-Cases für w4/w5:
- [ ] `isWelcomeRoute('/onboarding/w4')` returns `true`
- [ ] `isWelcomeRoute('/onboarding/w5')` returns `true`

---

## Kritische Dateien

| Datei | Aktion |
|-------|--------|
| `lib/features/consent/widgets/welcome_shell.dart` | MODIFY |
| `lib/features/consent/widgets/welcome_video_player.dart` | CREATE |
| `lib/features/consent/screens/consent_welcome_01_screen.dart` | MODIFY |
| `lib/features/consent/screens/consent_welcome_02_screen.dart` | MODIFY |
| `lib/features/consent/screens/consent_welcome_03_screen.dart` | MODIFY |
| `lib/features/consent/screens/consent_welcome_04_screen.dart` | CREATE |
| `lib/features/consent/screens/consent_welcome_05_screen.dart` | CREATE |
| `lib/core/design_tokens/assets.dart` | MODIFY |
| `lib/core/navigation/routes.dart` | MODIFY |
| `lib/l10n/app_de.arb` | MODIFY |
| `lib/l10n/app_en.arb` | MODIFY |
| `lib/features/consent/widgets/dots_indicator.dart` | DELETE |
| `pubspec.yaml` | MODIFY |
| `test/core/navigation/routes_predicates_test.dart` | MODIFY (w4/w5 Tests) |

---

## Voraussetzungen (vom User)

**Phase 0 – Assets:**
- [ ] Video-Assets bereitstellen: `welcome_01.mp4`, `welcome_05.mp4`
- [ ] Bild-Assets bereitstellen: `welcome_02.png`, `welcome_03.png`, `welcome_04.png` (jeweils 1x, 2x, 3x)
- [ ] Alte Bilder löschen: `welcome_01.png`, `welcome_02.png`, `welcome_03.png` (+ 2x, 3x)

**Phase 1 – Figma Node-IDs:** ✅ ERLEDIGT
- [x] Screen 1 Node-ID: `68911:8427`
- [x] Screen 2 Node-ID: `68911:8391`
- [x] Screen 3 Node-ID: `68911:8402`
- [x] Screen 4 Node-ID: `68911:8414`
- [x] Screen 5 Node-ID: `68924:1197`

---

## Risiko-Checks & Absicherungen

### 1) Repo-Abhängigkeiten vor Löschen prüfen

**Bevor gelöscht wird, Referenzen suchen:**
```bash
# DotsIndicator Referenzen
grep -r "DotsIndicator" lib/
grep -r "dots_indicator" lib/

# dotsCount Referenzen
grep -r "dotsCount" lib/

# Alte Welcome-Bilder Referenzen
grep -r "welcome_01.png" lib/
grep -r "welcome_02.png" lib/
grep -r "welcome_03.png" lib/
```

**Nur löschen wenn:** Keine Referenzen außerhalb der Welcome-Screens gefunden werden.

---

### 2) Back-Navigation Reality-Check ✅ GEKLÄRT

**Status:** Kein Zurück-Button auf Consent-Screen → **Keine Änderung nötig.**

Der Consent-Screen hat (und wird haben) keinen Zurück-Button. Die Navigation ist nur vorwärts.

---

### 2b) AuthEntryScreen – Kein Risiko ✅

`AuthEntryScreen` nutzt `WelcomeShell` mit `bottomContent` (custom content statt default).
Die Entfernung von Dots/Skip hat dort **keinen Impact** – diese Elemente werden nur im Default-Content verwendet.

---

### 3) FTUE-Flag (First-Time User Experience)

**Prüfen:**
- Wo wird `hasSeenWelcome` / `hasCompletedOnboarding` gesetzt?
- Wird dieses Flag durch die neuen Routen (w4, w5) beeinflusst?
- Muss das Flag nach w5 statt w3 gesetzt werden?

**Suchen:**
```bash
grep -r "hasSeenWelcome\|hasCompletedOnboarding\|firstTime\|isFirstLaunch" lib/
```

➡️ **In Phase 1 (Figma-Audit) zusätzlich prüfen!**

---

### 4) Video-Lifecycle erweitert ✅ ENTSCHIEDEN

**Bereits spezifiziert:**
- Pause bei App-Background
- Resume bei App-Foreground

**ZUSÄTZLICH erforderlich (Performance/Battery):**
- Nur das Video der **aktiven Page** soll spielen
- ✅ **Lösung:** `isActive` Parameter (Option B) – kein extra Package nötig
- Welcome-Screens nutzen Button-Navigation → Parent weiß immer welcher Screen aktiv

➡️ **Bereits in Phase 2.2 spezifiziert!**

---

### 5) Design-Tokens-Mapping

**Regel:** Keine hardcodierten Hex-Werte!

**Bei Figma-Audit:**
- Farben auf existierende Theme-Tokens mappen (`DsColors`, `TextColorTokens`)
- Falls neue Farbe benötigt → neuen Token in Design-System anlegen
- Niemals: `Color(0xFFAB1234)` direkt im Widget

**Beispiel:**
```dart
// ❌ FALSCH
color: Color(0xFFB8336A),

// ✅ RICHTIG
color: Theme.of(context).colorScheme.primary,
// oder
color: DsColors.buttonPrimary,
```

---

### 6) Asset-Referenzen vor Löschen prüfen

**Bevor alte Bilder gelöscht werden:**
```bash
grep -r "welcomeHero01\|welcomeHero02\|welcomeHero03" lib/
grep -r "welcome_01.png\|welcome_02.png\|welcome_03.png" lib/
```

**Nur löschen wenn:** Keine Referenzen außerhalb der zu refactorenden Screens.

---

## Checkliste vor Merge

- [ ] `flutter analyze` ✅
- [ ] Alle Widget-Tests bestanden ✅
- [ ] Kein PII in Logs ✅
- [ ] Semantics-Labels auf allen interaktiven Elementen ✅
- [ ] Touch-Targets ≥ 44dp ✅
- [ ] L10n-Keys in DE und EN ARB ✅
- [ ] Design-Tokens verwendet (keine Hex-Werte) ✅
- [ ] GoRouter-Navigation ✅
- [ ] Referenz-Checks durchgeführt (Dots, Assets) ✅
- [ ] FTUE-Flag geprüft ✅
- [ ] Video nur auf aktiver Page aktiv ✅
- [ ] QA-Schritt 9.1 durchgeführt (iOS + Android manuell getestet) ✅
