# Dashboard Reuse Inventory

## Tokens

### Farben
| Name | Pfad | Evidence | Kollisionsrisiko |
| --- | --- | --- | --- |
| `_primary` (`#D9B18E`) | `lib/core/theme/app_theme.dart:10` | `lib/core/theme/app_theme.dart:90` setzt ElevatedButton-`backgroundColor` auf `_primary` | niedrig |
| `_accentSubtle` (`#D9B6A3`) | `lib/core/theme/app_theme.dart:13` | `lib/core/theme/app_theme.dart:77` setzt `ColorScheme.secondary` → verwendet u. a. in `lib/features/consent/screens/consent_welcome_01_screen.dart:37` | mittel |
| `_onPrimary` (`#030401`) | `lib/core/theme/app_theme.dart:16` | `lib/core/theme/app_theme.dart:91` definiert Button-`foregroundColor` | niedrig |
| `_onSurface` (`#030401`) | `lib/core/theme/app_theme.dart:17` | `lib/features/screens/onboarding_03.dart:99` nutzt `colorScheme.onSurface` für den Headline-Text | niedrig |
| `_grayscale400` (`#B0B0B0`) | `lib/core/theme/app_theme.dart:18` | `lib/features/consent/widgets/dots_indicator.dart:33` nutzt `colorScheme.outlineVariant` (aus `_grayscale400`) für inaktive Punkte | mittel |
| `DsTokens.cardSurface` (`#F7F7F8`) | `lib/core/theme/app_theme.dart:149` | `lib/features/widgets/goal_card.dart:50` färbt Karten-Hintergrund | niedrig |
| `DsTokens.cardBorderSelected` (`#1C1411`) | `lib/core/theme/app_theme.dart:150` | `lib/features/widgets/goal_card.dart:54` setzt ausgewählten Rahmen | niedrig |
| `DsTokens.inputBorder` (`#DCDCDC`) | `lib/core/theme/app_theme.dart:151` | `lib/features/auth/widgets/login_email_field.dart:47` nutzt Rahmenfarbe | mittel |
| `DsTokens.grayscale500` (`#696969`) | `lib/core/theme/app_theme.dart:152` | `lib/features/auth/widgets/login_forgot_button.dart:30` setzt Textfarbe | mittel |
| `DsTokens.successColor` (`#04B155`) | `lib/core/theme/app_theme.dart:153` | `lib/features/auth/screens/success_screen.dart:89` färbt Erfolgs-Icon | mittel |
| `DsTokens.inputBorderLight` (`#F7F7F8`) | `lib/core/theme/app_theme.dart:154` | Derzeit kein Consumer (`rg --line-number "inputBorderLight" lib` ohne weitere Treffer) | hoch |
| `OpacityTokens.inactive` (`0.2`) | `lib/core/design_tokens/opacity.dart:3` | `lib/features/screens/onboarding_01.dart:168` blendet Divider ab | niedrig |

**Gradients**

Keine vordefinierten Gradient-Tokens; laut `docs/product/measures/dashboard/DASHBOARD_tokens_mapping.md:23` fehlen Overlay-Gradients für Empfehlungskarten. Kollisionsrisiko: hoch (Neuentwicklung nötig).

### Spacing
| Name | Pfad | Evidence | Kollisionsrisiko |
| --- | --- | --- | --- |
| `Spacing.l` (`24`) | `lib/core/design_tokens/spacing.dart:2` | `lib/features/screens/onboarding_01.dart:66` nutzt Abstand über dem Header | niedrig |
| `Spacing.m` (`16`) | `lib/core/design_tokens/spacing.dart:3` | `lib/features/widgets/goal_card.dart:46` setzt horizontales Padding | niedrig |
| `Spacing.s` (`12`) | `lib/core/design_tokens/spacing.dart:4` | `lib/features/widgets/goal_card.dart:82` nutzt Abstand vor dem Auswahlindikator | niedrig |
| `Spacing.xs` (`8`) | `lib/core/design_tokens/spacing.dart:5` | `lib/features/consent/widgets/dots_indicator.dart:24` definiert Dot-Abstand | niedrig |
| `Spacing.goalCardVertical` (`20`) | `lib/core/design_tokens/spacing.dart:6` | `lib/features/widgets/goal_card.dart:47` legt vertikales Padding fest | mittel |
| `Spacing.goalCardIconGap` (`20`) | `lib/core/design_tokens/spacing.dart:7` | `lib/features/widgets/goal_card.dart:70` erzeugt Icon-Text-Abstand | mittel |
| `OnboardingSpacing.cardGap` (`24`) | `lib/core/design_tokens/onboarding_spacing.dart:216` | `lib/features/screens/onboarding_03.dart:162` nutzt den Wert für Karten-Stacks | hoch |
| `OnboardingSpacing.headerToFirstCard` (`62`) | `lib/core/design_tokens/onboarding_spacing.dart:170` | `lib/features/screens/onboarding_03.dart:60` positioniert Kopfbereich | hoch |
| `OnboardingSpacing.optionGap05` (`24`) | `lib/core/design_tokens/onboarding_spacing.dart:150` | `lib/features/screens/onboarding_05.dart:131` trennt Optionen | hoch |
| `AuthLayout.horizontalPadding` (`≈20`) | `lib/features/auth/layout/auth_layout.dart:8` | `lib/features/auth/screens/login_screen.dart:137` nutzt identische Padding-Konstante | hoch |
| `AuthLayout.inlineCtaReserveLoginApprox` | `lib/features/auth/layout/auth_layout.dart:36` | `lib/features/auth/screens/login_screen.dart:73` reserviert Scroll-Padding | hoch |
| `AuthEntryLayout.waveToTitleBaseline` (`108`) | `lib/features/auth/layout/auth_entry_layout.dart:5` | `lib/features/auth/screens/auth_entry_screen.dart:46` steuert Hero→Titel-Abstand | hoch |
| `kWelcomeWaveHeight` (`427`) | `lib/features/consent/screens/welcome_metrics.dart:3` | `lib/features/consent/screens/consent_welcome_01_screen.dart:48` übernimmt Wellenhöhe | mittel |
| `kOnboardingPickerHeight` (`198`) | `lib/features/screens/onboarding/utils/onboarding_constants.dart:2` | `lib/features/screens/onboarding_02.dart:255` dimensioniert Picker-Stack | mittel |

### Radii
| Name | Pfad | Evidence | Kollisionsrisiko |
| --- | --- | --- | --- |
| `Sizes.radiusM` (`12`) | `lib/core/design_tokens/sizes.dart:3` | `lib/features/auth/widgets/login_email_field.dart:45` nutzt für Eingabefelder | niedrig |
| `Sizes.radiusL` (`20`) | `lib/core/design_tokens/sizes.dart:4` | `lib/features/widgets/goal_card.dart:43` definiert Karten-Rundung | niedrig |
| `Sizes.radiusXL` (`40`) | `lib/core/design_tokens/sizes.dart:11` | `lib/features/auth/widgets/social_auth_row.dart:86` formt Social-Buttons | mittel |
| `AuthLayout.otpBorderRadius` (`8`) | `lib/features/auth/layout/auth_layout.dart:41` | `lib/features/auth/widgets/verification_code_input.dart:90` nutzt Outline-Radius | hoch |

### Shadows
Keine Shadow-Tokens vorhanden; Dashboard benötigt laut `docs/product/measures/dashboard/DASHBOARD_tokens_mapping.md:102` einen `0px 0px 24px rgba(0,0,0,0.12)`-Shadow für Bottom-Pills. Kollisionsrisiko: hoch.

### Typografie
| Name | Pfad | Evidence | Kollisionsrisiko |
| --- | --- | --- | --- |
| `_textThemeConst.headlineMedium` (Playfair Display 32/40) | `lib/core/theme/app_theme.dart:24` | `lib/features/consent/screens/consent_welcome_01_screen.dart:33` übernimmt Stil | niedrig |
| `_textThemeConst.bodyMedium` (Figtree 20/24) | `lib/core/theme/app_theme.dart:32` | `lib/features/widgets/goal_card.dart:75` verwendet Kopie | niedrig |
| `_textThemeConst.bodySmall` (Inter 14/24) | `lib/core/theme/app_theme.dart:48` | `lib/features/screens/onboarding_03.dart:110` nutzt Step-Typo | mittel (Font-Mismatch zu Dashboard) |
| `TypographyTokens.*` (14,16,20,24,32 + Ratios) | `lib/core/design_tokens/typography.dart:5` | `lib/features/widgets/goal_card.dart:76` nutzt `size16`/`24on16` | niedrig |
| `FontFamilies` (`Figtree`, `Inter`, `Playfair Display`) | `lib/core/design_tokens/typography.dart:22` | `lib/features/consent/screens/consent_02_screen.dart:101` setzt Figtree | niedrig |
| `DsTokens.authEntrySubhead` (Figtree 14/20) | `lib/core/theme/app_theme.dart:155` | `lib/features/auth/screens/auth_entry_screen.dart:88` nutzt Subhead | mittel |
| `verifyTitleStyle`/`verifySubtitleStyle` etc. | `lib/features/auth/widgets/verify_text_styles.dart:5` | `lib/features/auth/screens/verification_screen.dart:50` ruft Helpers für OTP-Header | hoch (Feature-spezifisch, nicht in Tokens) |

## Widgets & Komponenten

### Cards
| Name | Pfad | Props/States | Eignung | Evidence |
| --- | --- | --- | --- | --- |
| `GoalCard` | `lib/features/widgets/goal_card.dart:17` | `icon?`, `title`, `selected`, `onTap` | Empfehlungskarte (teilweise – kein Bild/CTA/Progress) | `lib/features/screens/onboarding_03.dart:164`, `lib/features/screens/onboarding_05.dart:133` |
| `scopeCard` (lokale Factory) | `lib/features/consent/screens/consent_02_screen.dart:52` | `body`, `scope`, `trailingLinks?`, `cardKey?`; nutzt lokale `selected`-State | Empfehlungskarte (teilweise – text-only, kein Bild) | `lib/features/consent/screens/consent_02_screen.dart:230` |

### Chips & Badges
| Name | Pfad | Props/States | Eignung | Evidence |
| --- | --- | --- | --- | --- |
| `PhaseBadge` | `lib/features/cycle/widgets/phase_badge.dart:4` | `info`, `date`, `consentGiven`; rendert Text oder `SizedBox.shrink()` | Kategorie-Chip (teilweise – reiner Text, keine Capsule) | `test/features/cycle/widgets/phase_badge_test.dart:7` |
| `CustomRadioCheck` | `lib/features/widgets/custom_radio_check.dart:9` | `selected` (bool) | Kategorie-Chip (teilweise – kann als Status-Indikator dienen) | `lib/features/widgets/goal_card.dart:83` |

### Buttons & CTA
| Name | Pfad | Props/States | Eignung | Evidence |
| --- | --- | --- | --- | --- |
| `BackButtonCircle` | `lib/features/widgets/back_button.dart:5` | `onPressed`, `size`, `innerSize?`, `backgroundColor?`, `iconColor?`, `isCircular`, `iconSize`; fester Chevron | SectionHeader (teilweise – Icon fix, keine Slot-Icons) | `lib/features/screens/onboarding_02.dart:111` |
| `LoginCtaSection` | `lib/features/auth/widgets/login_cta_section.dart:8` | `onSubmit`, `onSignup`, `hasValidationError`, `isLoading` | Bottom-Pill (teilweise – vertikale CTA + Link, keine Tabs) | `lib/features/auth/screens/login_screen.dart:110` |
| `AuthBottomCta` | `lib/features/auth/widgets/auth_bottom_cta.dart:7` | `child`, `topPadding`, `horizontalPadding`, `bottomPadding`, `animationDuration` | Bottom-Pill (teilweise – SafeArea-Padding, aber nur Single-Child) | `lib/features/auth/screens/verification_screen.dart:91` |
| `ConsentButton` | `lib/features/consent/widgets/consent_button.dart:4` | interner Loading-State, `ConsentService`-Call | Bottom-Pill (teilweise – Einzel-CTA mit Spinner) | `lib/features/consent/screens/consent_02_screen.dart:48` |

### Section Header
| Name | Pfad | Props/States | Eignung | Evidence |
| --- | --- | --- | --- | --- |
| `LoginHeader` | `lib/features/auth/widgets/login_header.dart:5` | keine Props; lokalisiert Text über `AuthStrings` | SectionHeader (teilweise – Zweizeilig, kein „Alles“-Link) | `lib/features/auth/widgets/login_header_section.dart:42` |
| `LoginHeaderSection` | `lib/features/auth/widgets/login_header_section.dart:8` | `emailController`, `passwordController`, Fehlerstrings, `obscurePassword`, Callbacks | SectionHeader (teilweise – kapselt Header + Felder, aber nicht isoliert wiederverwendbar) | `lib/features/auth/screens/login_screen.dart:143` |

### Hero / großflächige Layouts
| Name | Pfad | Props/States | Eignung | Evidence |
| --- | --- | --- | --- | --- |
| `WelcomeShell` | `lib/features/consent/widgets/welcome_shell.dart:8` | `hero`, `heroAspect`, `waveHeightPx`, `title?`, `subtitle?`, `onNext?`, `activeIndex?`, `waveAsset`, `bottomContent?` | Hero (teilweise – kein Progress/CTA-Overlay, Wave mandatory) | `lib/features/consent/screens/consent_welcome_01_screen.dart:27`, `lib/features/auth/screens/auth_entry_screen.dart:22` |

### Bottom / Pill Actions
| Name | Pfad | Props/States | Eignung | Evidence |
| --- | --- | --- | --- | --- |
| `AuthBottomCta` | `lib/features/auth/widgets/auth_bottom_cta.dart:7` | s. o. | Bottom-Pill (teilweise – animiert Keyboard-Inset, aber nur Single-CTA) | `lib/features/auth/screens/create_new_password_screen.dart:76` |
| `LoginCtaSection` | `lib/features/auth/widgets/login_cta_section.dart:8` | s. o. | Bottom-Pill (teilweise – CTA + Link statt Mehrfach-Navigation) | `lib/features/auth/screens/login_screen.dart:110` |

## Listen & Layout-Patterns
| Pattern | Pfad | Spacing/Gaps/Insets | Clip/Radius/Shadow | Hinweise |
| --- | --- | --- | --- | --- |
| Scrollbarer Consent-Karten-Stack (`ListView`) | `lib/features/consent/screens/consent_02_screen.dart:230` | `EdgeInsets.fromLTRB(20,24,20,24)` + `SizedBox(height:20)` zwischen Cards | `BorderRadius.circular(Sizes.radiusL)`; kein Shadow | Vertikale Liste, keine horizontale Alternative vorhanden |
| Onboarding-Zielliste (`Column` + `List.generate`) | `lib/features/screens/onboarding_03.dart:157` | `spacing.cardGap` (24) + `spacing.lastCardToCta` | `GoalCard` nutzt Radius 20, keine Schatten | Eignet sich für gridartige Stapel, aber ohne Bildinhalt |
| Hero-Layer mit Wave (`Stack` + `Align`) | `lib/features/consent/widgets/welcome_shell.dart:45` | Padding `Spacing.l` am Boden, Wave-Höhe via `kWelcomeWaveHeight` | kein Clip, Hero über `AspectRatio`; Wave füllt Breite | Bietet Full-bleed Hero, jedoch starres Wave-Asset |
| Scroll + Bottom-Picker (`Stack` mit `Positioned`) | `lib/features/screens/onboarding_02.dart:73` & `:248` | Scroll-Padding `spacing.ctaToPicker`, Picker-Höhe `kOnboardingPickerHeight` | kein Shadow; Divider nutzt `OpacityTokens.inactive` | Muster für sticky Bottom-Elemente, nur vertikale Variante |
| Form-Shell mit Keyboard-Reserve (`SingleChildScrollView` + `ConstrainedBox`) | `lib/features/auth/screens/login_screen.dart:135` | Padding `EdgeInsets.fromLTRB(Spacing.l,0,Spacing.l,safeBottom)` + Reserven aus `AuthLayout` | kein Clip/Shadow | Ermöglicht full-height Layouts, ScrollController erforderlich |

> **Gap:** `rg --line-number "Axis.horizontal" lib` liefert keine Treffer ⇒ Keine vorhandenen horizontalen Scroller/Carousels.

## Tests & Utilities
| Name | Pfad | Kurzbeschreibung Einsatz |
| --- | --- | --- |
| `pumpSignupScreen` helper | `test/features/auth/signup_submit_test.dart:22` | Baut Router + Theme + ProviderScope für Signup-Interaktions-Tests |
| `textFieldByHint` finder | `test/features/auth/signup_submit_test.dart:39` | Wiederverwendbare TextField-Suche per Hint-Text |
| `windowMeasure` harness | `test/dev/audit/window_verify_test.dart:37` | Simuliert SafeArea/Keyboard, misst Abstände für Layout-Regressionen |
| `FakeViewPadding` | `test/dev/audit/window_verify_test.dart:8` | Stellt ViewInsets/SafeArea im Testfenster nach |
| `ensureSemantics` usage | `test/features/consent/widgets/welcome_shell_test.dart:71` | Erzwingt Semantics-Auswertung für Header-Checks |
| `DotsIndicator` key assertions | `test/features/consent/widgets/dots_indicator_test.dart:19` | Verifiziert deterministische Keys statt Dekorationsabgleiche |
| `LoginScreen` CTA state test | `test/features/auth/screens/login_screen_test.dart:72` | Prüft, dass CTA nach Validierungsfehlern deaktiviert wird |
| Golden-Failure Artefakte | `test/_artifacts/goldens/failures/onboarding_01_testImage.png` | Bestehende Golden-Baseline (Fehlerausgabe) für Onboarding 01 |

