# Heute (Dashboard) – Screen Contract

version: "1.1"
last_updated: "2026-01-23"
acceptance_version: "1.1"

**Zweck/Scope**
- Übersicht für den Tag: Begrüßung, Zyklusstatus, LUVI Sync Teaser, Kategorien, Empfehlungen, Trainingsdaten, Info‑Karte.
- Primäre Navigation: Startpunkt für „Zyklus“, „LUVI Sync“, „Puls“, „Profil“.

**Hierarchie (Render‑Reihenfolge)**
- Header: Begrüßung + Phase + Glocke + Week‑Strip (HeuteScreen → header section).
- LUVI Sync Hero Preview (Bild, Yin‑Yang Badge, Teaser, CTA „Mehr“) – Key `dashboard_hero_sync_preview` (HeroSyncPreview widget).
- Kategorien Grid (4 Chips, dynamische Breiten, Wrap) – Key `dashboard_categories_grid` (HeuteScreen → categories section).
- „Deine Top‑Empfehlung“ – prominent (HeuteScreen, TopRecommendationTile widget).
- „Weitere Trainings“ – horizontaler Scroller mit RecommendationCards – Key `dashboard_recommendations_list` (HeuteScreen → recommendations section).
- „Deine Trainingsdaten“ – StatsScroller (Wearable‑abhängig) – Key `dashboard_training_stats_scroller` (HeuteScreen → stats section, StatsScroller widget).
- Info‑Karte zur Zyklusphase (CycleTipCard) (HeuteScreen → tip card section).
- Bottom‑Dock + Floating Sync Button – Keys `dashboard_dock_nav`, `floating_sync_button` (HeuteScreen → bottom dock).

**Navigation/Routes**
- Screen‑Route: `HeuteScreen.routeName = '/heute'` (HeuteScreen.routeName).
- Week‑Strip Tap: navigiert zu `/zyklus` (CycleInlineCalendar).
- LUVI Sync Hero CTA „Mehr“: `go('/luvi-sync')` (HeroSyncPreview).
- Floating Sync Button: `go('/luvi-sync')` + Tab aktiv (HeuteScreen → floating action button).
- Top Recommendation Tap: `go('/workout/<id>')` (TopRecommendationTile).
- Bottom‑Nav Tabs: Heute/Zyklus/Puls/Profil (Index 0..3), visuell über `BottomNavDock` (BottomNavDock).

**State/Contracts**
- ViewModel: `DashboardVM` (DashboardVM) – Felder `cycleProgressRatio`, `heroCta`, `selectedCategory`.
- Fixtures: `HeuteFixtures` → `HeuteFixtureState` mit Header/Hero/TopReco/Kategorien/Empfehlungen/TrainingStats/Wearable/BottomNav (HeuteFixtures).
- Zyklusprojektion: `WeekStripView` + `weekViewFor()` (WeekStripView).
- Phase‑Mapping: `Phase` enum + `phaseFor()` Adapter (Phase enum).

**Datenabhängigkeiten**
- Zyklus: `CycleInfo.phaseFor(date)` für Phase im Header/Calendar (CycleInfo / Phase).
- Wearables: StatsScroller zeigt entweder Live‑Karten oder `WearableConnectCard` Fallback (wenn `connected=false`) (StatsScroller).
- Empfehlungen: aktuell aus Fixtures; Filterung nach Kategorie ist vorbereitet (TODO‑Hook in `_onCategoryTap`) (HeuteScreen).

**Lokalisierung (Auszug)**
- Titel: `dashboardCategoriesTitle`, `dashboardTopRecommendationTitle`, `dashboardMoreTrainingsTitle`, `dashboardTrainingDataTitle` (AppLocalizations).
- Kategorien: `dashboardCategoryTraining/…` (AppLocalizations).
- Hero CTA „Mehr“: `dashboardHeroCtaMore` (AppLocalizations).
- Semantics/Hints: TopReco („Tippe, um …“), Calendar‑Hint, CycleTip Texte (AppLocalizations).

**Accessibility/Keys**
- Screen‑Anker: `dashboard_header`, `dashboard_hero_sync_preview`, `dashboard_categories_grid`, `dashboard_recommendations_list`, `dashboard_training_stats_scroller`, `dashboard_dock_nav`, `floating_sync_button` (HeuteScreen).
- Semantics Labels: TopRecommendation (zusammengesetzt), CycleInlineCalendar (heute/default), CycleTipCard (Headline+Body) (TopRecommendationTile, CycleInlineCalendar, CycleTipCard).
- Tap Areas: Bottom‑Dock min 44×44, Icon 32px (BottomNavTokens).

**Design/Tokens**
- Abstände/Texte/Farben über Theme‑Extensions (TextColorTokens, DsTokens, SurfaceColorTokens, ShadowTokens) (HeroSyncPreview).
- Kategorien‑Chips: min/max Breiten, Icon‑Container 60px, Label 14/24 (CategoryChip).
- Empfehlungen: Card 155×180, Radius 20, Gradient Overlay (RecommendationCard).
- TopReco: Tile 150px Höhe, Badge 32px, Overlay‑Gradient (TopRecommendationTile).
- StatsScroller: Kartenhöhe `kStatsCardHeight`, Labels umbrechen (z. B. „Verbrannte\nEnergie“), HR‑Glyph Layer (StatsScroller).
- Bottom‑Dock: Höhe 96px, Center‑Cutout/Sync‑Button Token‑basiert (BottomNavTokens).

**Consent/Scopes (Nutzung auf dem Screen)**
- `cycle_tracking`: Phase/Week‑Strip/TipCard.
- `wearable_sync`: Stats (Puls/kcal/Schritte) Live/Fallback.
- `ai_reco`: LUVI Sync Journal + Top‑Empfehlung, sobald KI‑Briefing angebunden.

**Bekannte UI‑Zustände (Fixtures)**
- Default: Training‑Chip aktiv, 3 Recos, Wearable connected → 3 Stat‑Karten (HeuteFixtures).
- Mit Glocke: Notification‑Badge aktiv (HeuteFixtures).
- Leere Empfehlungen: Platzhaltertext, Hero‑CTA „Starte dein Training“ (HeuteFixtures).

**Test‑Hinweise**
- Widget‑Smoke: Render von Header→TipCard; Keys prüfen; keine Exceptions.
- Semantics: Calendar/TopReco/TipCard Labels vorhanden.
- Nav: Taps auf Calendar → `/zyklus`, Hero „Mehr“ → `/luvi-sync`, TopReco → `/workout/<id>`.
- Fallback: StatsScroller zeigt `WearableConnectCard`, wenn `connected=false`.

**Fehlerbilder (zu beobachten)**
- Asset‑Laden (SVG/PNG) – siehe `errorBuilder`/Debug‑Logs in CategoryChip/RecommendationCard/TopReco.
- Bild‑Jank – mitigiert durch `precacheImage` (Hero + TopReco) (HeuteScreen).
- Layout‑Enge – Category‑Breitenkompression (HeuteLayoutUtils).

– Ende –
