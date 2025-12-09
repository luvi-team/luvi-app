# Auth Flow Refactoring Plan

> **Status:** Approved
> **Datum:** 2025-12-09
> **Agent:** Claude Code

## Ziel
Refactoring des Auth Flows von 8 auf 6 Screens mit neuem Figma-Design.

**Strategie:** "Design First, Logic Preserve" - Bestehende Supabase-Logik behalten, nur UI neu.

---

## Audit-Ergebnisse (Verifiziert)

### Komponenten die 100% Figma matchen (wiederverwenden!)
| Komponente | Datei |
|------------|-------|
| Pink CTA Button | `lib/features/consent/widgets/welcome_button.dart` |
| Back Button | `lib/core/widgets/back_button.dart` |
| Error Text | `lib/features/auth/widgets/field_error_text.dart` |
| Apple Button | `lib/features/auth/widgets/social_auth_row.dart` |
| Google Button | `lib/features/auth/widgets/social_auth_row.dart` |
| Beige Farbe | `DsColors.welcomeWaveBg` (#FAEEE0) |
| Glassmorphism Token | `GlassTokens` in `app_theme.dart` |

### Komponenten die angepasst werden müssen
| Komponente | Problem | Lösung |
|------------|---------|--------|
| Input Fields | Grauer Hintergrund | Beige/weiß anpassen |

### Komponenten die NEU erstellt werden müssen
| Komponente | Zweck |
|------------|-------|
| E-Mail Login Button | Outline-Style Button für "Anmelden mit E-Mail" |
| Glow Checkmark | Beige Glow statt grünem Circle |
| Auth Gradient Background | Vollflächiger beige Gradient |

### Supabase-Integration (NICHT anfassen - funktioniert!)
- ✅ signUp, signIn, signOut
- ✅ Session Management (Stream-basiert)
- ✅ Password Reset (Magic Link)
- ✅ Error Handling

---

## Screen-Mapping: Alt → Neu

| # | Neuer Screen | Ersetzt | Route | Figma |
|---|--------------|---------|-------|-------|
| 1 | **AuthSignInScreen** | AuthEntryScreen | `/auth/signin` | Node 69020-1379 |
| 2 | **AuthLoginScreen** | LoginScreen | `/auth/login` | Node 68919-8853 |
| 3 | **AuthSignupScreen** | AuthSignupScreen | `/auth/signup` | **Kein Figma** → Login-Layout |
| 4 | **AuthResetPasswordScreen** | ResetPasswordScreen | `/auth/reset` | Node 68919-8822 |
| 5 | **AuthCreatePasswordScreen** | CreateNewPasswordScreen | `/auth/password/new` | Node 68919-8814 |
| 6 | **AuthSuccessScreen** | SuccessScreen | `/auth/success` | Node 68919-8802 |

**Signup Screen (ohne Figma - basiert auf Login):**
- Layout: Identisch zu AuthLoginScreen
- Titel: "Konto erstellen" (L10n Key)
- Felder: E-Mail + Passwort (nur 2, nicht 5 wie bisher)
- CTA: "Registrieren"
- Link unten: "Schon dabei? Anmelden" → `/auth/login`

**Entfernt:**
- VerificationScreen (6-digit OTP) - komplett entfernt
- SuccessScreen Variante "forgotEmailSent" - nicht mehr nötig

---

## Taktische Vorgehensweise (5 Phasen)

### Phase 1: Foundation (4 neue Widgets)
**Ziel:** Fehlende Komponenten erstellen

| Widget | Datei | Beschreibung |
|--------|-------|--------------|
| AuthGradientBackground | `lib/features/auth/widgets/auth_gradient_background.dart` | Beige Gradient (#FAEEE0 basiert) |
| GlassmorphismCard | `lib/features/auth/widgets/glassmorphism_card.dart` | Nutzt existierende `GlassTokens` |
| GlowCheckmark | `lib/features/auth/widgets/glow_checkmark.dart` | Beige Glow statt grün |
| AuthOutlineButton | `lib/features/auth/widgets/auth_outline_button.dart` | Für "Anmelden mit E-Mail" |

**Wiederverwendet (nicht neu erstellen!):**
- `WelcomeButton` → Pink CTA
- `BackButtonCircle` → Navigation zurück
- `AuthTextField` → Input Felder
- `FieldErrorText` → Error States

---

### Phase 2: Auth Shell
**Ziel:** Gemeinsame Layout-Struktur

Datei: `lib/features/auth/widgets/auth_shell.dart` (anpassen oder neu)

```
AuthShell
├── AuthGradientBackground (neu)
├── SafeArea
├── Optional: BackButtonCircle (existiert)
├── Content (scrollable)
└── AuthBottomCta (existiert) mit WelcomeButton (existiert)
```

---

### Phase 3: Screens (einer nach dem anderen)

| # | Screen | Provider (wiederverwenden) | Neue UI |
|---|--------|---------------------------|---------|
| 1 | AuthSignInScreen | - | Glassmorphism Card + 3 Buttons |
| 2 | AuthLoginScreen | `loginProvider`, `loginSubmitProvider` | Neues Layout |
| 3 | AuthSignupScreen | `signupProvider` (vereinfachen) | Nur E-Mail + PW |
| 4 | AuthResetPasswordScreen | `resetPasswordProvider`, `resetSubmitProvider` | Neues Layout |
| 5 | AuthCreatePasswordScreen | bestehende Logik | Neues Layout |
| 6 | AuthSuccessScreen | - | GlowCheckmark |

---

### Phase 4: Navigation
**Datei:** `lib/core/navigation/routes.dart`

| Aktion | Route |
|--------|-------|
| Behalten | `/auth/login`, `/auth/signup`, `/auth/password/new` |
| Umbenennen | `/auth/entry` → `/auth/signin` |
| Umbenennen | `/auth/forgot` → `/auth/reset` |
| Entfernen | `/auth/verify`, `/auth/forgot/sent` |
| Hinzufügen | `/auth/success` (vereinfacht) |

---

### Phase 5: Cleanup & Tests

1. **Dateien entfernen:**
   - `verification_screen.dart`
   - Nicht mehr benötigte Widgets

2. **L10n aktualisieren:**
   - `app_de.arb` + `app_en.arb`

3. **Tests:**
   - 1 Widget-Test pro Screen (minimum)

4. **Qualität:**
   - `flutter analyze` ohne Errors

---

## Kritische Dateien

### Zu modifizieren
| Datei | Änderung |
|-------|----------|
| `lib/core/navigation/routes.dart` | Routes anpassen |
| `lib/l10n/app_de.arb` | Neue L10n Keys |
| `lib/l10n/app_en.arb` | Neue L10n Keys |

### Zu erstellen (NEU)
| Datei | Zweck |
|-------|-------|
| `lib/features/auth/widgets/auth_gradient_background.dart` | Beige Hintergrund |
| `lib/features/auth/widgets/glassmorphism_card.dart` | Glass Card |
| `lib/features/auth/widgets/glow_checkmark.dart` | Success Icon |
| `lib/features/auth/widgets/auth_outline_button.dart` | E-Mail Button |
| `lib/features/auth/screens/auth_signin_screen.dart` | Entry Screen |

### Zu refaktorieren (bestehend → neues Design)
| Datei | Änderung |
|-------|----------|
| `lib/features/auth/screens/login_screen.dart` | Neues UI, Provider behalten |
| `lib/features/auth/screens/auth_signup_screen.dart` | Vereinfachen auf 2 Felder |
| `lib/features/auth/screens/reset_password_screen.dart` | Neues UI |
| `lib/features/auth/screens/create_new_password_screen.dart` | Neues UI |
| `lib/features/auth/screens/success_screen.dart` | GlowCheckmark |

### Zu entfernen
| Datei | Grund |
|-------|-------|
| `lib/features/auth/screens/auth_entry_screen.dart` | Ersetzt durch AuthSignInScreen |
| `lib/features/auth/screens/verification_screen.dart` | OTP Flow entfällt |

---

## Figma-Mapping (SSOT)

**Referenz:** [auth_ui_v2_mapping.md](./auth_ui_v2_mapping.md)

Das Mapping-Dokument enthält:
- Alle Figma-Werte (Gradients, Farben, Spacing, Typography)
- REUSE vs NEW Entscheidungen pro UI-Element
- Offene TODOs (Button Height 50→56px, Glass Opacity, etc.)

### Offene TODOs aus Mapping

| # | Thema | Entscheidung |
|---|-------|--------------|
| 1 | Button Height | Neuer Token `Sizes.buttonHeightL = 56.0` |
| 2 | Glass Opacity | Auth-spezifischer Token (10% statt 55%) |
| 3 | Headline Magenta | Neuer Token `DsColors.headlineMagenta = #9F2B68` |
| 4 | Conic Gradient | CustomPainter oder vereinfachter LinearGradient |

---

## Zusammenfassung

**Was wir tun:**
- 4 neue Widgets erstellen
- 5 bestehende Screens refaktorieren (UI neu, Logik behalten)
- 1 neuen Screen erstellen (AuthSignInScreen)
- 2 Screens/Routes entfernen

**Was wir NICHT tun:**
- Supabase-Integration ändern
- Provider-Architektur ändern
- Backend-Logik umschreiben
