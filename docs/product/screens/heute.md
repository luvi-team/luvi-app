# Heute (Dashboard) – Screen Contract

version: "1.0"
last_updated: "2025-10-13"
acceptance_version: "1.1"

**Zweck/Scope**
- Übersicht für den Tag: Begrüßung, Zyklusstatus, LUVI Sync Teaser, Kategorien, Empfehlungen, Trainingsdaten, Info‑Karte.
- Primäre Navigation: Startpunkt für „Zyklus“, „LUVI Sync“, „Puls“, „Profil“.

**Hierarchie (Render‑Reihenfolge)**
- Header: Begrüßung + Phase + Glocke + Week‑Strip (`lib/features/screens/heute_screen.dart:214`).
- LUVI Sync Hero Preview (Bild, Yin‑Yang Badge, Teaser, CTA „Mehr“) – Key `dashboard_hero_sync_preview` (`lib/features/screens/heute_screen.dart:134`).
- Kategorien Grid (4 Chips, dynamische Breiten, Wrap) – Key `dashboard_categories_grid` (`lib/features/screens/heute_screen.dart:370`).
- „Deine Top‑Empfehlung“ – prominent (`lib/features/screens/heute_screen.dart:160`, `lib/features/dashboard/widgets/top_recommendation_tile.dart:1`).
- „Weitere Trainings“ – horizontaler Scroller mit RecommendationCards – Key `dashboard_recommendations_list` (`lib/features/screens/heute_screen.dart:426`).
- „Deine Trainingsdaten“ – StatsScroller (Wearable‑abhängig) – Key `dashboard_training_stats_scroller` (`lib/features/screens/heute_screen.dart:182`, `lib/features/dashboard/widgets/stats_scroller.dart:1`).
- Info‑Karte zur Zyklusphase (CycleTipCard) (`lib/features/screens/heute_screen.dart:356`).
- Bottom‑Dock + Floating Sync Button – Keys `dashboard_dock_nav`, `floating_sync_button` (`lib/features/screens/heute_screen.dart:478`).

**Navigation/Routes**
- Screen‑Route: `HeuteScreen.routeName = '/heute'` (`lib/features/screens/heute_screen.dart:22`).
- Week‑Strip Tap: navigiert zu `/zyklus` (`lib/features/cycle/widgets/cycle_inline_calendar.dart:74`).
- LUVI Sync Hero CTA „Mehr“: `go('/luvi-sync')` (`lib/features/widgets/hero_sync_preview.dart:81`).
- Floating Sync Button: `go('/luvi-sync')` + Tab aktiv (`lib/features/screens/heute_screen.dart:498`).
- Top Recommendation Tap: `go('/workout/<id>')` (`lib/features/dashboard/widgets/top_recommendation_tile.dart:132`).
- Bottom‑Nav Tabs: Heute/Zyklus/Puls/Profil (Index 0..3), visuell über `BottomNavDock` (`lib/features/widgets/bottom_nav_dock.dart:1`).

**State/Contracts**
- ViewModel: `DashboardVM` (`lib/features/dashboard/state/heute_vm.dart:5`) – Felder `cycleProgressRatio`, `heroCta`, `selectedCategory`.
- Fixtures: `HeuteFixtures` → `HeuteFixtureState` mit Header/Hero/TopReco/Kategorien/Empfehlungen/TrainingStats/Wearable/BottomNav (`lib/features/dashboard/data/fixtures/heute_fixtures.dart:113`).
- Zyklusprojektion: `WeekStripView` + `weekViewFor()` (`lib/features/cycle/domain/week_strip.dart:7`).
- Phase‑Mapping: `Phase` enum + `phaseFor()` Adapter (`lib/features/cycle/domain/phase.dart:6`).

**Datenabhängigkeiten**
- Zyklus: `CycleInfo.phaseFor(date)` für Phase im Header/Calendar (`lib/features/cycle/domain/cycle.dart:1`, `lib/features/cycle/domain/phase.dart:40`).
- Wearables: StatsScroller zeigt entweder Live‑Karten oder `WearableConnectCard` Fallback (wenn `connected=false`) (`lib/features/dashboard/widgets/stats_scroller.dart:33`).
- Empfehlungen: aktuell aus Fixtures; Filterung nach Kategorie ist vorbereitet (TODO‑Hook in `_onCategoryTap`) (`lib/features/screens/heute_screen.dart:368`).

**Lokalisierung (Auszug)**
- Titel: `dashboardCategoriesTitle`, `dashboardTopRecommendationTitle`, `dashboardMoreTrainingsTitle`, `dashboardTrainingDataTitle` (`lib/l10n/app_localizations_de.dart:35`).
- Kategorien: `dashboardCategoryTraining/…` (`lib/l10n/app_localizations_de.dart:59`).
- Hero CTA „Mehr“: `dashboardHeroCtaMore` (`lib/l10n/app_localizations_de.dart:79`).
- Semantics/Hints: TopReco („Tippe, um …“), Calendar‑Hint, CycleTip Texte (`lib/l10n/app_localizations_de.dart:87`).

**Accessibility/Keys**
- Screen‑Anker: `dashboard_header`, `dashboard_hero_sync_preview`, `dashboard_categories_grid`, `dashboard_recommendations_list`, `dashboard_training_stats_scroller`, `dashboard_dock_nav`, `floating_sync_button` (`lib/features/screens/heute_screen.dart:121`).
- Semantics Labels: TopRecommendation (zusammengesetzt), CycleInlineCalendar (heute/default), CycleTipCard (Headline+Body) (`lib/features/dashboard/widgets/top_recommendation_tile.dart:167`, `lib/features/cycle/widgets/cycle_inline_calendar.dart:61`, `lib/features/dashboard/widgets/cycle_tip_card.dart:52`).
- Tap Areas: Bottom‑Dock min 44×44, Icon 32px (`lib/features/widgets/bottom_nav_tokens.dart:61`).

**Design/Tokens**
- Abstände/Texte/Farben über Theme‑Extensions (TextColorTokens, DsTokens, SurfaceColorTokens, ShadowTokens) (`lib/features/widgets/hero_sync_preview.dart:18`).
- Kategorien‑Chips: min/max Breiten, Icon‑Container 60px, Label 14/24 (`lib/features/widgets/category_chip.dart:14`).
- Empfehlungen: Card 155×180, Radius 20, Gradient Overlay (`lib/features/widgets/recommendation_card.dart:7`).
- TopReco: Tile 150px Höhe, Badge 32px, Overlay‑Gradient (`lib/features/dashboard/widgets/top_recommendation_tile.dart:9`).
- StatsScroller: Kartenhöhe `kStatsCardHeight`, Labels umbrechen (z. B. „Verbrannte\nEnergie“), HR‑Glyph Layer (`lib/features/dashboard/widgets/stats_scroller.dart:1`).
- Bottom‑Dock: Höhe 96px, Center‑Cutout/Sync‑Button Token‑basiert (`lib/features/widgets/bottom_nav_tokens.dart:1`).

**Consent/Scopes (Nutzung auf dem Screen)**
- `cycle_tracking`: Phase/Week‑Strip/TipCard.
- `wearable_sync`: Stats (Puls/kcal/Schritte) Live/Fallback.
- `ai_reco`: LUVI Sync Journal + Top‑Empfehlung, sobald KI‑Briefing angebunden.

**Bekannte UI‑Zustände (Fixtures)**
- Default: Training‑Chip aktiv, 3 Recos, Wearable connected → 3 Stat‑Karten (`lib/features/dashboard/data/fixtures/heute_fixtures.dart:312`).
- Mit Glocke: Notification‑Badge aktiv (`lib/features/dashboard/data/fixtures/heute_fixtures.dart:337`).
- Leere Empfehlungen: Platzhaltertext, Hero‑CTA „Starte dein Training“ (`lib/features/dashboard/data/fixtures/heute_fixtures.dart:345`).

**Test‑Hinweise**
- Widget‑Smoke: Render von Header→TipCard; Keys prüfen; keine Exceptions.
- Semantics: Calendar/TopReco/TipCard Labels vorhanden.
- Nav: Taps auf Calendar → `/zyklus`, Hero „Mehr“ → `/luvi-sync`, TopReco → `/workout/<id>`.
- Fallback: StatsScroller zeigt `WearableConnectCard`, wenn `connected=false`.

**Fehlerbilder (zu beobachten)**
- Asset‑Laden (SVG/PNG) – siehe `errorBuilder`/Debug‑Logs in CategoryChip/RecommendationCard/TopReco.
- Bild‑Jank – mitigiert durch `precacheImage` (Hero + TopReco) (`lib/features/screens/heute_screen.dart:41`).
- Layout‑Enge – Category‑Breitenkompression (`lib/features/screens/heute_layout_utils.dart:1`).

– Ende –
