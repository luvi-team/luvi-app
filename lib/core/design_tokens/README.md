# Figma → Flutter Mapping (LUVI · NovaHealth)

## Colors (automatisch gemappt via FigmaVariableMapping)
- Grayscale/White          → Theme.of(context).colorScheme.surface
- Grayscale/Black          → Theme.of(context).colorScheme.onSurface  
- Grayscale/100            → Theme.of(context).colorScheme.surfaceContainerHighest
- Grayscale/200            → Theme.of(context).colorScheme.surfaceContainerHigh
- Grayscale/400            → Theme.of(context).colorScheme.outlineVariant
- Grayscale/500            → Theme.of(context).colorScheme.outline
- Primary color/100        → Theme.of(context).colorScheme.primary

## Typography (automatisch gemappt via FigmaVariableMapping)  
- Heading/H1 (Playfair 32/40)     → Theme.of(context).textTheme.headlineLarge
- Caption 1 (Inter 18/27, Semi)   → Theme.of(context).textTheme.titleMedium
- Regular klein (Figtree 16/24)   → Theme.of(context).textTheme.bodyMedium
- Callout (Inter 16/24, Medium)   → Theme.of(context).textTheme.titleSmall

## Spacing
- spacing/16                → const SizedBox(height: 16)
- spacing/24                → const SizedBox(height: 24)

## Verwendung

### Im UI-Code (empfohlen):
```dart
// Farben
color: Theme.of(context).colorScheme.primary,
backgroundColor: Theme.of(context).colorScheme.surface,

// Typography  
style: Theme.of(context).textTheme.headlineLarge,

// Convenience-Zugriff via LuviDesignTokens
final tokens = LuviDesignTokens.of(context);
color: tokens.primary,
style: tokens.h1,
```

### Automatisches Mapping via @figma get_code:
Die `FigmaVariableMapping` Klasse definiert das automatische Mapping von Figma Variables zu Flutter Theme Properties. Wenn @figma get_code verwendet wird, werden Hex-Werte automatisch durch die entsprechenden Theme-Aufrufe ersetzt.

## Hinweise
- **Keine Hex-Hardcodes** im UI-Code. Immer Theme/TextTheme verwenden.
- **Theme ist zentral definiert** in `LuviTokens.theme` basierend auf Figma Variables
- **Google Fonts** werden automatisch geladen (Playfair Display, Inter, Figtree)
- Falls ein Token fehlt, in `FigmaVariableMapping` ergänzen
