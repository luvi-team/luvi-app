# Dashboard State Contract

| Section | Fields | Notes |
| --- | --- | --- |
| Header | `userName: String`, `dateText: String`, `cyclePhaseText: String` | Top greeting + subline; mirrors Figma copy (`Hey, Anna`, `Heute, 28. Sept`, `Follikelphase`). |
| Hero | `cycleProgressRatio: double (0..1)`, `heroCta: HeroCtaState` | Ratio drives progress ring + percent label; CTA text: `resumeActiveWorkout → "Zurück zum Training"`, `startNewWorkout → "Starte dein Training"`. |
| Categories | `selectedCategory: Category` | Highlights chip in gold; later used to drive recommendation filter. |
| Recommendations | `List<RecommendationProps>` | Cards rendered unter "Empfehlungen"; list wird category-aware sobald Backend angebunden. |
| Bottom-Nav | `selectedIndex: int`, `hasNotifications: bool?` | Index mappt auf Tab-Icons (`0 = Start`); optionaler Glocken-Indikator via `hasNotifications`. |

`HeroCtaState` values: `resumeActiveWorkout`, `startNewWorkout`.
`Category` values: `training`, `nutrition`, `regeneration`, `mindfulness`.

Der Vertrag dient als Single Source für Dashboard ViewModel und Fixtures.
