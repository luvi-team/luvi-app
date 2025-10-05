# Dashboard State Contract

| Section | Fields | Notes |
| --- | --- | --- |
| Header | `userName: String`, `dateText: String`, `cyclePhaseText: String` | Top greeting + subline; mirrors Figma copy (`Hey, Anna`, `Heute, 28. Sept`, `Follikelphase`). |
| Hero | `cycleProgressRatio: double (0..1)`, `heroCta: HeroCtaState` | Ratio drives progress ring + percent label; CTA text: `resumeActiveWorkout → "Zurück zum Training"`, `startNewWorkout → "Starte dein Training"`. |
| Categories | `selectedCategory: Category` | Highlights chip in gold; later used to drive recommendation filter. |
| Recommendations | `List<RecommendationProps>` | Cards rendered unter "Empfehlungen"; list wird category-aware sobald Backend angebunden. |
| Bottom-Nav | `selectedIndex: int`, `hasNotifications: bool?` | Index mappt auf Tab-Icons (`0 = Home`); optionaler Glocken-Indikator via `hasNotifications`. |

## Feld → Wirkung (Detail)

| Feld | Typ | Wirkung |
| --- | --- | --- |
| `cycleProgressRatio` | `double (0..1)` | Füllt Ring im Hero-Card, steuert Prozent-Label (`25%`). |
| `heroCta` | `HeroCtaState` | Steuert CTA-Label: `resumeActiveWorkout` → "Zurück zum Training", `startNewWorkout` → "Starte dein Training". |
| `selectedCategory` | `Category` | Goldener Chip-Highlight; später Reco-Filter (Backend-Anbindung). |

## Enums

`HeroCtaState` values: `resumeActiveWorkout`, `startNewWorkout`.
`Category` values: `training`, `nutrition`, `regeneration`, `mindfulness`.

## Asset-Note

Category-Icons künftig als dünnere Strokes (≈1.2–1.5px, no scale-strokes) re-exportieren; aktuell UI-seitig auf 18px skaliert (spec: 24px).

## Verwendung

Der Vertrag dient als Single Source für Dashboard ViewModel (`dashboard_vm.dart`) und Fixtures (`dashboard_fixtures.dart`).
