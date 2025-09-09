# Figma → Flutter Mapping (LUVI · NovaHealth)

## Colors
- Grayscale/White          → Theme.of(context).colorScheme.background
- Grayscale/Black          → Theme.of(context).colorScheme.onBackground
- Grayscale/100            → Theme.of(context).colorScheme.surface
- Grayscale/500            → Theme.of(context).colorScheme.outline
- Primary color/100        → Theme.of(context).colorScheme.primary

## Typography
- Heading/H1 (Playfair 32/40)     → Theme.of(context).textTheme.headlineLarge
- Callout (Inter 16/24, Medium)   → Theme.of(context).textTheme.titleSmall
- Regular klein (Figtree 16/24)   → Theme.of(context).textTheme.bodyMedium
- Caption 1 (Inter 18/27, Semi)   → Theme.of(context).textTheme.titleMedium

## Spacing
- spacing/16                → const SizedBox(height: 16)
- spacing/24                → const SizedBox(height: 24)

Hinweise:
- Keine Hex-Hardcodes im UI-Code. Immer Theme/TextTheme/Abstände verwenden.
- Falls ein Token fehlt, kurz hier ergänzen (eine Zeile).
