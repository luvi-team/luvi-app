# Figma Screen implementieren

Implementiere einen Screen basierend auf Figma-Design.

## Input: $ARGUMENTS
- Screenshot-Pfad ODER
- Beschreibung des Designs

## Workflow:
1. **Analysiere** das Design (Farben, Spacing, Layout)
2. **Suche Tokens** in:
   - `lib/core/design_tokens/colors.dart`
   - `lib/core/design_tokens/spacing.dart`
   - `lib/core/design_tokens/sizes.dart`
3. **Erstelle fehlende Tokens** mit `/// Figma: xxx` Kommentar
4. **Implementiere** den Screen
5. **Erstelle Widget-Test**
6. **Führe aus**: `scripts/flutter_codex.sh analyze`
