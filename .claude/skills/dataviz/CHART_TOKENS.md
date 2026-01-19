# Chart Design Tokens

## Farben für Charts (DsColors)
| Verwendung | Token | Hex |
|------------|-------|-----|
| Primary Line | `DsColors.signature` | #9F2B68 |
| Secondary Line | `DsColors.primaryGold` | #D9B18E |
| Positive | `DsColors.phaseOvulation` | #E1B941 |
| Negative | `DsColors.authRebrandError` | #C93838 |
| Neutral | `DsColors.grayscale500` | #696969 |
| Background | `DsColors.cardBackgroundNeutral` | #F7F7F8 |

## Zyklus-Phasen Farben
| Phase | Token | Hex |
|-------|-------|-----|
| Menstruation | `DsColors.phaseMenstruation` | #FFB9B9 |
| Follikulär | `DsColors.phaseFollicularDark` | #4169E1 |
| Ovulation | `DsColors.phaseOvulation` | #E1B941 |
| Luteal | `DsColors.phaseLuteal` | #A755C2 |

## Chart Spacing
- Padding: `Spacing.m` (16dp)
- Legend Gap: `Spacing.xs` (8dp)
- Axis Label: `Spacing.xxs` (4dp)

## A11y Requirements
- **Contrast Ratio:** Minimum 3:1 for UI components (lines, bars), 4.5:1 for text/labels
- **Semantics:** Every chart requires `Semantics(label: '...')` with descriptive text
  - Use `excludeSemantics: true` on decorative children
  - Use `sortKey` for logical reading order in complex charts
  - Example: `Semantics(label: 'Line chart showing cycle length over 6 months')`
- **Legends:** Must be keyboard-focusable and screen-reader accessible
  - Wrap legend items in `Semantics` with color + value description
  - Example: `Semantics(label: 'Menstruation phase: 5 days')`
