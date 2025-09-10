# Design Tokens (Figma → Flutter)
Kurzregeln:
- Keine Hex-Farben in Screens; immer über Theme/Extensions zugreifen.
- Nur benötigte Tokens ins Theme einbinden (MIWF).

Beispiele:
- color/action/primary → Theme.of(context).colorScheme.primary
- font/heading/H1 → Theme.of(context).textTheme.headlineLarge
- spacing/24 → const SizedBox(height: 24)  # dokumentierte Spacing-Skala

Ablage:
- Export-Datei: lib/core/design_tokens/figma_tokens.json (Dualite)
- Mapping erfolgt schrittweise in lib/core/theme/app_theme.dart
