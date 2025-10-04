# Dashboard Path Compliance

| Pfad | Abweichung von SSOT-Struktur | Betroffene Komponenten/Tokens |
| --- | --- | --- |
| `lib/features/auth/layout/auth_layout.dart:4` | Feature-spezifische Spacing-/Radius-Tokens liegen außerhalb `lib/core/design_tokens/` | `AuthBottomCta` (`lib/features/auth/widgets/auth_bottom_cta.dart:11`), `LoginScreen` (`lib/features/auth/screens/login_screen.dart:73`), `VerificationCodeInput` (`lib/features/auth/widgets/verification_code_input.dart:90`) |
| `lib/features/auth/layout/auth_entry_layout.dart:5` | Layout-Konstanten für Hero-Abstände im Feature statt im Core-Tokens-Pfad | `AuthEntryScreen` (`lib/features/auth/screens/auth_entry_screen.dart:46`), `WelcomeShell`-Consumer |
| `lib/features/consent/screens/welcome_metrics.dart:3` | Hero-Aspekt & Wave-Höhe unter `features/consent` statt `core/design_tokens/` | `ConsentWelcome01/02/03` (`lib/features/consent/screens/**`), `AuthEntryScreen` (`lib/features/auth/screens/auth_entry_screen.dart:30`) |
| `lib/features/screens/onboarding/utils/onboarding_constants.dart:2` | Picker-Höhen & Min/Max-Daten außerhalb `lib/core/design_tokens/` | `Onboarding02Screen` (`lib/features/screens/onboarding_02.dart:255`), `Onboarding04Screen` (`lib/features/screens/onboarding_04.dart:76`) |
| `lib/features/auth/widgets/verify_text_styles.dart:5` | Typografie-Helfer im Feature-Widget statt zentraler Token-Ablage | `VerificationScreen` (`lib/features/auth/screens/verification_screen.dart:50`) |
| `lib/core/theme/app_theme.dart:9` | Farb-Konstanten bleiben private Theme-Werte (`_primary`, `_accentSubtle`) statt ausgelagerter Farb-Tokens | Alle Komponenten via `Theme.of` (`GoalCard` `lib/features/widgets/goal_card.dart:50`, `LoginCtaSection` `lib/features/auth/widgets/login_cta_section.dart:33`) |
