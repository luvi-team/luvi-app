# Figma → Flutter Token Mapping

## Hauptfarben (DsColors)
| Figma Hex | Flutter Token | Verwendung |
|-----------|---------------|------------|
| #E91E63 | `DsColors.welcomeButtonBg` | Primary CTA Pink |
| #9F2B68 | `DsColors.headlineMagenta` | Headlines |
| #F9F1E6 | `DsColors.splashBg` | Warm Backgrounds |
| #030401 | `DsColors.grayscaleBlack` | Text Primary |
| #FFFFFF | `DsColors.grayscaleWhite` | White |
| #F7F7F8 | `DsColors.cardBackgroundNeutral` | Card BG |
| #DCDCDC | `DsColors.gray300` | Borders |
| #525252 | `DsColors.gray500` | Secondary Text |
| #C93838 | `DsColors.authRebrandError` | Error Red |
| #1B9BA4 | `DsColors.authRebrandRainbowTeal` | Teal Accent |
| #D42C82 | `DsColors.authRebrandRainbowPink` | Pink Accent |
| #F57A25 | `DsColors.authRebrandRainbowOrange` | Orange Accent |

## Zyklus-Phasen Farben
| Figma Hex | Flutter Token | Phase |
|-----------|---------------|-------|
| #FFB9B9 | `DsColors.phaseMenstruation` | Menstruation |
| #4169E1 | `DsColors.phaseFollicularDark` | Follikulär |
| #E1B941 | `DsColors.phaseOvulation` | Ovulation |
| #A755C2 | `DsColors.phaseLuteal` | Luteal |

## Spacing
| Figma px | Flutter Token | Alias |
|----------|---------------|-------|
| 2 | `Spacing.micro` | - |
| 4 | `Spacing.xxs` | - |
| 8 | `Spacing.xs` | - |
| 12 | `Spacing.s` | - |
| 16 | `Spacing.m` | - |
| 24 | `Spacing.l` | `Spacing.screenPadding` |
| 32 | `Spacing.xl` | - |

## Sizes
| Figma px | Flutter Token | Verwendung |
|----------|---------------|------------|
| 44 | `Sizes.touchTargetMin` | Min Touch Target |
| 50 | `Sizes.buttonHeight` | Standard Button |
| 56 | `Sizes.buttonHeightL` | Large Button |
| 12 | `Sizes.radiusM` | Default Radius |
| 16 | `Sizes.radiusCard` | Card Radius |
| 40 | `Sizes.radiusXL` | Pill/Large Radius |

## Neues Token erstellen (Pattern)
```dart
/// Figma: #HEXCODE (Name/Context)
static const Color newTokenName = Color(0xFFHEXCODE);
```

## Vollständige Suche
Für alle Tokens: `grep -n "Figma:" lib/core/design_tokens/*.dart`
