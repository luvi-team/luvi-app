# Dashboard Mapping Plan

| Figma-Baustein | Repo-Baustein | Status | Evidence |
| --- | --- | --- | --- |
| StatusBar | Kein dediziertes Widget (Flutter `SafeArea`) | nicht vorhanden | `lib/features/consent/widgets/welcome_shell.dart:45` nutzt `SafeArea(top: false)` ohne eigene Statusbar-Komponente |
| HeaderSection | Kombination aus `LoginHeaderSection` + `BackButtonCircle` | teilweise (Props fehlen) | `lib/features/auth/widgets/login_header_section.dart:8` rendert Titel & Inputs, `lib/core/widgets/back_button.dart:33` liefert festen Chevron statt Icon-Slots |
| HeroCard | `GoalCard` (Onboarding) | teilweise (Props fehlen) | `lib/features/onboarding/widgets/goal_card.dart:59` zeigt Text+Radio, aber keine Progress- oder CTA-Zone |
| SectionHeader | `LoginHeader` | teilweise (Props fehlen) | `lib/features/auth/widgets/login_header.dart:18` bietet Überschrift, aber keinen Sekundär-Link „Alles" |
| CategoryChip | `PhaseBadge` | teilweise (Props fehlen) | `lib/features/cycle/widgets/phase_badge.dart:18` rendert reinen Text, keine Kapsel/Icons |
| RecommendationCard | `scopeCard` (Consent 02) | teilweise (Props fehlen) | `lib/features/consent/screens/consent_02_screen.dart:74` baut textbasierte Karte ohne Bild/Gradient |
| BottomActionPills | `AuthBottomCta` | teilweise (Props fehlen) | `lib/features/auth/widgets/auth_bottom_cta.dart:24` verwaltet SafeArea-Padding, aber nur Single-CTA statt Mehrfach-Pill |
| HomeIndicator | System-Komponente (keine Umsetzung im Repo) | nicht vorhanden | Keine Dateien unter `lib/**` mit Home-Indikator; `SafeArea(bottom: false)` (`lib/features/consent/widgets/welcome_shell.dart:45`) zeigt Fehlen |

## Gaps (max. 10)
1. `assets/icons/` enthält nur `google_g.svg`; keine Search-/Bell-Assets → Dashboard-Header-Actions fehlen (`docs/product/measures/dashboard/DASHBOARD_tokens_mapping.md:119`).
2. `lib/core/widgets/back_button.dart:25` hardcodiert Chevron-SVG → keine Wiederverwendung als generischer Icon-Button für Header-Actions.
3. `lib/features/onboarding/widgets/goal_card.dart:59` bietet weder CTA-Button noch Fortschrittsanzeige → Hero-Card aus Figma nicht 1:1 abbildbar.
4. Keine Gradient-Tokens im Repo (`docs/product/measures/dashboard/DASHBOARD_tokens_mapping.md:23`) → Empfehlungskarten-Overlay nicht nachrüstbar ohne Neueinführung.
5. `lib/features/auth/widgets/auth_bottom_cta.dart:24` unterstützt nur Einzel-Child → Dashboard-Bottom-Pill mit 5 Items nicht reusebar.
6. `lib/features/cycle/widgets/phase_badge.dart:18` rendert nur Text → Kategorie-Chips benötigen Icon + gefüllte Capsule.
7. Kein horizontaler Scroller (`rg --line-number "Axis.horizontal" lib` ohne Treffer) → Dashboard-Carousels erfordern neue Patterns.
8. Spacing-Konstanten in `lib/features/auth/layout/auth_layout.dart:8` liegen außerhalb `lib/core/design_tokens/` → Wiederverwendung im Dashboard bricht SSOT.
9. Eigene Text-Styles in `lib/features/auth/widgets/verify_text_styles.dart:5` statt Tokens → Dashboard benötigt konsistente Typo (Figtree 16/12px fehlen).
10. `lib/core/theme/app_theme.dart:154` deklariert `DsTokens.inputBorderLight`, aber ohne Consumer → keine bestehende Referenz für helle Rahmen im Dashboard.
