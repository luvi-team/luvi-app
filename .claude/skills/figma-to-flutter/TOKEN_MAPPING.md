# Figma → Flutter Token Mapping

## Primary Colors (DsColors)
| Figma Hex | Flutter Token | Usage |
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

## Cycle Phase Colors
| Figma Hex | Flutter Token | Phase |
|-----------|---------------|-------|
| #FFB9B9 | `DsColors.phaseMenstruation` | Menstruation |
| #4169E1 | `DsColors.phaseFollicularDark` | Follicular |
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
| Figma px | Flutter Token | Usage |
|----------|---------------|------------|
| 44 | `Sizes.touchTargetMin` | Min Touch Target |
| 50 | `Sizes.buttonHeight` | Standard Button |
| 56 | `Sizes.buttonHeightL` | Large Button |
| 12 | `Sizes.radiusM` | Default Radius |
| 16 | `Sizes.radiusCard` | Card Radius |
| 40 | `Sizes.radiusXL` | Pill/Large Radius |

## Creating New Tokens (Pattern)
```dart
/// Figma: #HEXCODE (Name/Context)
static const Color newTokenName = Color(0xFFHEXCODE);
```

## Typography (Variable Fonts)

LUVI uses **Variable Fonts**. For correct rendering, `fontVariations` is REQUIRED!

### Fonts
| Font | Type | FontFamily Token |
|------|------|------------------|
| Figtree | Variable | `FontFamilies.figtree` |
| Playfair Display | Variable | `FontFamilies.playfairDisplay` |

### Font Weights (wght)
| Figma Weight | wght Value | Flutter Code |
|--------------|------------|--------------|
| Regular (400) | 400 | `fontVariations: [FontVariation('wght', 400)]` |
| Medium (500) | 500 | `fontVariations: [FontVariation('wght', 500)]` |
| SemiBold (600) | 600 | `fontVariations: [FontVariation('wght', 600)]` |
| Bold (700) | 700 | `fontVariations: [FontVariation('wght', 700)]` |
| ExtraBold (800) | 800 | `fontVariations: [FontVariation('wght', 800)]` |

### Example (correct)
```dart
Text(
  'Beispiel',
  style: const TextStyle(
    fontFamily: FontFamilies.figtree,
    fontSize: 17,
    fontVariations: [FontVariation('wght', 400)], // Regular
    color: DsColors.grayscaleBlack,
  ),
)
```

### ⚠️ WARNING
```dart
// ❌ WRONG - fontWeight does NOT work with Variable Fonts!
fontWeight: FontWeight.w400,

// ✅ CORRECT - fontVariations for Variable Fonts
fontVariations: [FontVariation('wght', 400)],
```

---

## Full Token Search
For all tokens: `grep -n "Figma:" lib/core/design_tokens/*.dart`
