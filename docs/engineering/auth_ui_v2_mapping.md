# Auth UI v2 – Figma → Flutter Mapping

> **Erstellt:** 2025-12-09
> **Status:** Analyse-Phase (kein Code)
> **Figma-Quelle:** Nova Health UI – Working Copy

---

## Zusammenfassung

### Wiederverwendbare Komponenten (100% Match)
| Komponente | Widget/Token | Pfad |
|------------|--------------|------|
| Pink CTA Button | `WelcomeButton` | `lib/features/consent/widgets/welcome_button.dart` |
| Back Button Circle | `BackButtonCircle` | `lib/core/widgets/back_button.dart` |
| Error Text | `FieldErrorText` | `lib/features/auth/widgets/field_error_text.dart` |
| Button Background (#A8406F) | `DsColors.welcomeButtonBg` | `lib/core/design_tokens/colors.dart` |
| Button Radius (40px) | `Sizes.radiusXL` | `lib/core/design_tokens/sizes.dart` |
| Input Radius (12px) | `Sizes.radiusM` | `lib/core/design_tokens/sizes.dart` |
| Button Height (50→56px) | `Sizes.buttonHeight` | TODO: Figma zeigt 56px, Token ist 50px |
| Grayscale/100 (#F7F7F8) | `DsTokens.cardSurface` | `lib/core/theme/app_theme.dart` |
| Grayscale/300 (#DCDCDC) | `DsTokens.inputBorder` | `lib/core/theme/app_theme.dart` |
| Grayscale/500 (#696969) | `DsTokens.grayscale500` | `lib/core/theme/app_theme.dart` |

### Neue Komponenten erforderlich
| Komponente | Zweck | Basis-Tokens |
|------------|-------|--------------|
| `AuthGradientBackground` | Beige Linear/Conic Gradient | `DsColors.welcomeWaveBg` + neue Stops |
| `AuthGlassCard` | Glassmorphism Content Card | `GlassTokens` anpassen |
| `AuthOutlineButton` | "Anmelden mit E-Mail" Outline | Border + White Fill |
| `GlowCheckmark` | Success Icon mit Beige Glow | Radial Gradient + Icon |

### Anzupassende Komponenten
| Komponente | Änderung |
|------------|----------|
| `AuthTextField` | Background-Farbe prüfen (Figma: #F7F7F8) |
| `WelcomeButton` | Height 50→56px, Font prüfen |

---

## Screen 1: SignIn (Entry)

**Figma Node:** `69020:1379`
**Route:** `/auth/signin` (ersetzt `/auth/entry`)

### Screenshot-Referenz
Conic Gradient Background mit Glassmorphism Card und 3 Auth-Buttons.

### UI-Elemente

| Element | Figma-Werte | Mapping |
|---------|-------------|---------|
| **Background** | Conic Gradient (siehe Details) | **NEW:** `AuthConicGradient` |
| **Glass Card** | `bg: rgba(255,255,255,0.1)`, `radius: 40px`, `h: 204px`, `w: 361px` | **NEW:** `AuthGlassCard` (nutzt `GlassTokens` Basis) |
| **Headline** | Playfair Display Bold, 32px, #9F2B68, center, 3 Zeilen | **NEW:** Token für Magenta-Headline |
| **Apple Button** | Black bg, white text, h: 56px, radius: pill | **REUSE:** `sign_in_with_apple` Package |
| **Google Button** | White bg, gray border, h: 58px, radius: pill | **REUSE:** `sign_in_button` Package |
| **E-Mail Button** | White bg, gray border, h: 58px, radius: pill, Mail-Icon | **NEW:** `AuthOutlineButton` |

### Figma-Details: Background Gradient

```
Typ: Conic Gradient (transformiert)
Matrix: -23.89, -0.69962, 0.32271, -11.02
Center: (197, 395.5)

Stops:
- -11.03%: #D4B896
- 10.15%: #D4B896
- 19.79%: #E5D3BF
- 29.13%: #EADDCD
- 40.04%: #D4B896
- 60.93%: #D6BC9C
- 71.72%: #EDE1D3
- 78.65%: #E2CFB8
- 88.97%: #D4B896
- 110.15%: #D4B896
```

> **TODO:** Exakte Gradient-Transformation in Flutter verifizieren – Conic Gradient mit Matrix ist komplex.

### Figma-Details: Glass Card

| Property | Wert |
|----------|------|
| Background | `rgba(255, 255, 255, 0.1)` |
| Border Radius | 40px |
| Width | 361px |
| Height | 204px |
| Position | `top: 245px`, `left: 16px` |

> Bestehender `GlassTokens.light` hat `background: Color(0x8CFFFFFF)` (55% opacity) – Figma zeigt 10% opacity. **TODO:** Separate Auth-Glass-Tokens?

### Figma-Details: Headline

| Property | Wert |
|----------|------|
| Font | Playfair Display Bold |
| Size | 32px |
| Line Height | 40px |
| Color | #9F2B68 (Magenta/Pink) |
| Text | "Verpasse nicht, das Beste aus Dir zu machen!" |

> **TODO:** Neue Farbe `DsColors.headlineMagenta` = #9F2B68 hinzufügen.

### Figma-Details: Auth Buttons Container

| Property | Wert |
|----------|------|
| Gap | 12px |
| Padding | horizontal 24px |
| Position | `top: 473px` |

### Button-Spezifikationen

| Button | Background | Border | Height | Text |
|--------|------------|--------|--------|------|
| Apple | #000000 | none | 56px | "Anmelden mit Apple" |
| Google | #FFFFFF | 1px #E5E7EB | 58px | "Anmelden mit Google" |
| E-Mail | #FFFFFF | 1px #E5E7EB | 58px | "Anmelden mit E-Mail" |

---

## Screen 2: Login

**Figma Node:** `68919:8853`
**Route:** `/auth/login`

### Screenshot-Referenz
Linear Gradient Background, Back Button, 2 Input Fields, Pink CTA, "Passwort vergessen?" Link.

### UI-Elemente

| Element | Figma-Werte | Mapping |
|---------|-------------|---------|
| **Background** | Linear Gradient (siehe Details) | **NEW:** `AuthLinearGradient` |
| **Back Button** | Circle, size ~61px, Arrow Left | **REUSE:** `BackButtonCircle` |
| **Title** | Playfair Display Bold, 24px, #010100 | **REUSE:** Theme `headlineMedium` anpassen |
| **E-Mail Input** | h: 50px, bg: #F7F7F8, border: #DCDCDC, radius: 12px | **REUSE:** `AuthTextField` |
| **Password Input** | wie E-Mail + Eye Icon | **REUSE:** `AuthTextField` + Suffix Icon |
| **CTA Button** | h: 56px, bg: #A8406F, radius: 40px, w: 345px | **REUSE:** `WelcomeButton` (Height anpassen) |
| **Forgot Link** | Figtree Bold, 20px, #696969, right-aligned | **NEW:** `AuthForgotButton` oder TextButton |

### Figma-Details: Linear Gradient Background

```
Typ: Linear Gradient (top to bottom)
Stops:
- 18.37%: #D4B896
- 50.33%: #EDE1D3
- 74.47%: #D4B896
```

> **Mapping:** Kann als `LinearGradient` in Flutter implementiert werden.

### Figma-Details: Input Fields

| Property | Wert |
|----------|------|
| Height | 50px |
| Background | #F7F7F8 (`DsTokens.cardSurface`) |
| Border | 1px solid #DCDCDC (`DsTokens.inputBorder`) |
| Border Radius | 12px (`Sizes.radiusM`) |
| Padding Left | 16px |
| Placeholder Color | #696969 (`DsTokens.grayscale500`) |
| Placeholder Font | Figtree Regular, 16px, line-height 24px |
| Gap between inputs | 20px |

### Figma-Details: CTA Button

| Property | Wert |
|----------|------|
| Height | 56px |
| Width | 345px |
| Background | #A8406F (`DsColors.welcomeButtonBg`) |
| Border Radius | 40px (`Sizes.radiusXL`) |
| Text | Figtree Bold, 20px, #FFFFFF |
| Position | `top: 370px` |

> **TODO:** `Sizes.buttonHeight` ist 50px, Figma zeigt 56px. Neuer Token `Sizes.buttonHeightL = 56`?

### Figma-Details: Forgot Password Link

| Property | Wert |
|----------|------|
| Font | Figtree Bold, 20px |
| Color | #696969 |
| Position | right-aligned, `top: 486px` |
| Text | "Passwort vergessen?" |

---

## Screen 3: Reset Password

**Figma Node:** `68919:8822`
**Route:** `/auth/reset` (ersetzt `/auth/forgot`)

### Screenshot-Referenz
Wie Login, aber mit Subtitle-Text und nur 1 Input.

### UI-Elemente

| Element | Figma-Werte | Mapping |
|---------|-------------|---------|
| **Background** | Linear Gradient (identisch zu Login) | **REUSE:** `AuthLinearGradient` |
| **Back Button** | wie Login | **REUSE:** `BackButtonCircle` |
| **Title** | "Passwort vergessen?", Playfair Bold 24px | **REUSE:** Theme |
| **Subtitle** | Figtree Regular 16px, #010100, line-height 24px | **NEW:** Subtitle-Style oder bodyMedium |
| **E-Mail Input** | wie Login | **REUSE:** `AuthTextField` |
| **CTA Button** | "Passwort zurücksetzen" | **REUSE:** `WelcomeButton` |

### Figma-Details: Subtitle

| Property | Wert |
|----------|------|
| Font | Figtree Regular |
| Size | 16px |
| Line Height | 24px |
| Color | #010100 |
| Text | "Gib deine E-Mail ein und wir schicken dir einen Link zum Zurücksetzen zu." |
| Gap to Title | 8px |

---

## Screen 4: Create New Password

**Figma Node:** `68919:8814`
**Route:** `/auth/password/new`

### Screenshot-Referenz
Wie Login, aber mit 2 Password-Inputs.

### UI-Elemente

| Element | Figma-Werte | Mapping |
|---------|-------------|---------|
| **Background** | Linear Gradient | **REUSE:** `AuthLinearGradient` |
| **Back Button** | wie Login | **REUSE:** `BackButtonCircle` |
| **Title** | "Neues Passwort erstellen" | **REUSE:** Theme |
| **Password Input 1** | "Neues Passwort" | **REUSE:** `AuthTextField` |
| **Password Input 2** | "Neues Passwort bestätigen" | **REUSE:** `AuthTextField` |
| **CTA Button** | "Passwort zurücksetzen" | **REUSE:** `WelcomeButton` |

### Figma-Details: Input Fields

| Property | Wert |
|----------|------|
| Gap between inputs | 20px |
| Position start | `top: 170px` |

> **Note:** Zweites Input-Placeholder nutzt Inter Medium statt Figtree in Figma – **TODO:** Inkonsistenz prüfen.

---

## Screen 5: Success

**Figma Node:** `68919:8802`
**Route:** `/auth/password/success`
> **Note:** Der Pfad `/auth/password/success` wurde bewusst gewählt, um den Namespace pro Use-Case zu trennen (Password Recovery Flow).

### Screenshot-Referenz
Radial Gradient Background, Glow Checkmark Icon, Centered Text, Pink CTA.

### UI-Elemente

| Element | Figma-Werte | Mapping |
|---------|-------------|---------|
| **Background** | Radial Gradient (Beige Glow) | **NEW:** `AuthRadialGradient` |
| **Glow Icon** | Circle mit Glow + Checkmark | **NEW:** `GlowCheckmark` |
| **Title** | "Geschafft!", Playfair Regular 32px | **REUSE:** Theme |
| **Subtitle** | "Neues Passwort gespeichert.", Playfair Regular 24px | Style anpassen |
| **CTA Button** | "Zurück zur Anmeldung" | **REUSE:** `WelcomeButton` |

### Figma-Details: Radial Gradient Background

```
Typ: Radial Gradient
Center: (197, 230.5)
Radius-Transform: scale(19.55, 15.767)

Stops:
- 0%: #D4B896
- 14.17%: #DBC4A7
- 32.86%: #E4D3BE
- 42.51%: #E9DBCA
- 49.82%: #EDE1D3
- 60.22%: #E8D9C7
- 74.22%: #E1CDB5
- 85.34%: #DBC4A8
- 99.99%: #D4B896
```

> **TODO:** Flutter `RadialGradient` mit Transform verifizieren.

### Figma-Details: Glow Checkmark

| Property | Wert |
|----------|------|
| Outer Circle | 104px × 104px |
| Circle Color | Radial Gradient (Beige Glow) |
| Inner Icon | 48px × 48px, Checkmark |
| Icon Color | #FFFFFF (mit Stroke) |
| Position | `top: 179px`, centered |

> Bestehender `_SuccessIcon` nutzt `tokens.successColor` (#04B155 grün) – **Figma zeigt Beige Glow!**

### Figma-Details: Text Container

| Property | Wert |
|----------|------|
| Title Font | Playfair Display Regular, 32px |
| Title Color | #030401 |
| Title Line Height | 40px |
| Subtitle Font | Playfair Display Regular, 24px |
| Subtitle Color | #1C1411 (`DsColors.secondaryDark`) |
| Subtitle Line Height | 32px |
| Gap | 8px |
| Position | `top: 463px` |

### Figma-Details: CTA Button

| Property | Wert |
|----------|------|
| Text | "Zurück zur Anmeldung" |
| Position | `top: 607px` |

---

## Neue Tokens (Vorschlag)

### Colors (`lib/core/design_tokens/colors.dart`)

```dart
// Auth Flow Specific
static const Color headlineMagenta = Color(0xFF9F2B68);  // SignIn Headline
static const Color authGradientBase = Color(0xFFD4B896); // Gradient-Basis
static const Color authGradientLight = Color(0xFFEDE1D3); // Gradient-Mitte
```

### Sizes (`lib/core/design_tokens/sizes.dart`)

```dart
static const double buttonHeightL = 56.0;  // Auth CTA Buttons
static const double glassCardRadius = 40.0; // Glass Card
```

@immutable
class AuthGradientTokens extends ThemeExtension<AuthGradientTokens> {
  // Linear Gradient (Login, Reset, NewPassword)
  final List<Color> linearColors;
  final List<double> linearStops;

  // Radial Gradient (Success)
  final List<Color> radialColors;
  final List<double> radialStops;

  // Conic Gradient (SignIn) – komplexer, ggf. CustomPainter
  // TODO: Define conic gradient fields or document CustomPainter approach
}

---

## Offene TODOs

| # | Bereich | Frage/Aktion |
|---|---------|--------------|
| 1 | **Button Height** | Figma: 56px vs Token: 50px – neuen Token `buttonHeightL` erstellen? |
| 2 | **Glass Opacity** | Figma: 10% vs `GlassTokens`: 55% – separater Auth-Token? |
| 3 | **Conic Gradient** | Flutter-Implementierung für transformierten Conic Gradient prüfen |
| 4 | **Success Glow** | Beige Glow-Effekt für Checkmark – CustomPainter oder Image? |
| 5 | **Font Inkonsistenz** | NewPassword Input 2 nutzt Inter statt Figtree – Figma-Bug? |
| 6 | **Headline Magenta** | Neue Farbe #9F2B68 in DsColors aufnehmen |
| 7 | **Radial Gradient Transform** | Figma-Matrix in Flutter RadialGradient umrechnen |

---

## Widget-Hierarchie (Vorschlag)

```
AuthSignInScreen
├── AuthConicGradientBackground
├── SafeArea
├── AuthGlassCard
│   └── MagentaHeadline
└── AuthButtonColumn
    ├── AppleSignInButton (Package)
    ├── GoogleSignInButton (Package)
    └── AuthOutlineButton (E-Mail)

AuthLoginScreen / AuthResetScreen / AuthNewPasswordScreen
├── AuthLinearGradientBackground
├── SafeArea
├── BackButtonCircle
├── AuthScreenShell
│   ├── Title (H2 Bold)
│   ├── Subtitle? (nur Reset)
│   └── AuthTextField(s)
└── AuthBottomCta
    └── WelcomeButton

AuthSuccessScreen
├── AuthRadialGradientBackground
├── SafeArea
├── GlowCheckmark
├── SuccessText
└── AuthBottomCta
    └── WelcomeButton
```

---

## Nächste Schritte

1. **Phase 1 – Foundation:** Neue Tokens + Gradient-Widgets erstellen
2. **Phase 2 – SignIn:** Komplexester Screen zuerst (Conic Gradient + Glass)
3. **Phase 3 – Form Screens:** Login, Reset, NewPassword (ähnliche Struktur)
4. **Phase 4 – Success:** Radial Gradient + Glow Checkmark
5. **Phase 5 – Cleanup:** Alte Screens entfernen, Routes anpassen
