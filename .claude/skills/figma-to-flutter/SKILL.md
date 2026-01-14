---
name: figma-to-flutter
description: Baut Figma-Designs in Flutter nach. Auto-invoke bei: Screenshot, Figma, "bau nach", "implementiere Screen", UI-Design, Mockup.
allowed-tools: Read, Grep, Glob, Edit, Write
---

# Figma → Flutter Skill

## Workflow bei Figma-Screenshot/Design:

### 1. Farben extrahieren
```bash
# Suche existierendes Token
grep -n "Figma: #HEXCODE" lib/core/design_tokens/colors.dart
```
- Gefunden → Token verwenden
- Nicht gefunden → Neues Token erstellen mit `/// Figma: #HEXCODE`

### 2. Spacing extrahieren
```bash
grep -n "Figma: XXpx" lib/core/design_tokens/spacing.dart
```

### 3. Sizes extrahieren
```bash
grep -n "Figma: XXpx" lib/core/design_tokens/sizes.dart
```

### 4. Referenz-Screen finden
- Glob: `lib/features/*/screens/*.dart`
- Besonders: `lib/features/auth/screens/` für Auth-Flows
- Besonders: `lib/features/onboarding/screens/` für Onboarding

### 5. Implementieren mit:
- `DsColors.*` für Farben
- `Spacing.*` für Abstände
- `Sizes.*` für Dimensionen
- `Semantics(label: AppLocalizations.of(context)!.xxx)` für A11y

### 6. Widget-Test erstellen
- Unter `test/features/{feature}/`
- Mit `buildTestApp` aus `test/support/test_app.dart`

### 7. Verifizieren
```bash
scripts/flutter_codex.sh analyze
```
