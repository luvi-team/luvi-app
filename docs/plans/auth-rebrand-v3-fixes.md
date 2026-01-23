# Konsolidierter Umsetzungsplan: Auth Rebrand v3 Fixes

> **Quellen:** 3 unabh. Reviews (Opus, Codex, Gemini) + Verification via Explore Agents
> **Branch:** `origin/backup/pre-english-unification`
> **Prioritaet:** Security/Privacy > A11y > DRY/Maintainability
> **Erstellt:** 2026-01-16
> **Workflow:** Alle Aenderungen auf aktuellem Branch, separate Commits pro Sub-Phase
> **Hinweis:** “Client-side Backoff/Cooldown” ist UX/Abuse-Mitigation (kein echter Security-Gate); Server ist SSOT fuer Rate-Limits.

---

## Rollback-Anker setzen (VOR Start)

**WICHTIG:** Vor Beginn der Arbeit einen fixen Rollback-Punkt setzen:

```bash
# Einmalig am Anfang ausfuehren und SHA notieren
ROLLBACK_SHA=$(git rev-parse HEAD)
echo "Rollback-Punkt: $ROLLBACK_SHA"
```

Dieser SHA ist stabiler als Remote-Refs (die sich bewegen koennen).

---

## Verifizierte Findings (alle 3 Reviews konsolidiert)

| # | Finding | Severity | Source | Status |
|---|---------|----------|--------|--------|
| 1 | Password in Provider State (Security) | **CRITICAL** | Codex | VERIFIZIERT |
| 2 | Raw Error Logging in router.dart | **HIGH** | Codex | VERIFIZIERT |
| 3 | Client-side Backoff/Cooldown entfernt (Decision Gate; Server ist SSOT) | **MEDIUM** | Opus/Codex | VERIFIZIERT |
| 4 | Touch Targets <44dp + GestureDetector (kein Fokus/Ripple) | **HIGH** | Codex | VERIFIZIERT |
| 5 | AuthLoginSheet/RegisterSheet 99% Duplikat | **HIGH** | Alle 3 | VERIFIZIERT |
| 6 | Auth Screen build() 163-227 LOC, Nesting 10 Ebenen | **HIGH** | Codex | VERIFIZIERT |
| 7 | ref.listen in build() (Build-Side-Effect) | **HIGH** | Codex | VERIFIZIERT |
| 8 | Password Toggle (mehrfach dupliziert) | MEDIUM | Opus/Codex/Gemini | VERIFIZIERT |
| 9 | Keyboard Padding (mehrfach dupliziert) | MEDIUM | Opus/Codex | VERIFIZIERT |
| 10 | routes.dart supabaseRedirectWithSession 90 LOC | MEDIUM | Codex | VERIFIZIERT |
| 11 | Rainbow Ring Arrays SSOT-Verletzung | MEDIUM | Codex/Opus | VERIFIZIERT |
| 12 | AuthRainbowBackground unused params | LOW | Codex | VERIFIZIERT |
| 13 | splash_controller.dart 559 LOC | LOW | Alle 3 | VERIFIZIERT |

---

## Phase 0: Pre-Flight Checks (VOR Implementation)

### 0.1 Abhaengigkeitsanalyse

**Externe Imports pruefen:**
```bash
# Wer importiert die Sheets?
rg -n "AuthLoginSheet" lib test --glob="*.dart"
rg -n "AuthRegisterSheet" lib test --glob="*.dart"

# LoginState Abhaengigkeiten
rg -n "LoginState" test --glob="*.dart" -l

# Password persistence Hotspots (State, Submit-Mapping, Trim)
rg -n "class LoginState|final String password|trimmedPassword|updateState\\(|_mapAuthException" lib/features/auth/state lib/features/auth/screens lib/features/auth/state/login_submit_provider.dart --glob="*.dart"

# Build-Side-Effects (Listener in build)
rg -n "ref\\.listen<AsyncValue<void>>\\(resetSubmitProvider" lib/features/auth/screens --glob="*.dart"

# Unsanitized error logging in router guards
rg -n "consent_guard_state_error|post_auth_guard_state_error|error: error" lib/router.dart

# Backoff/Cooldown: Verify current state (expected: removed in rebrand)
rg -n "backoff|_consecutiveFailures|authErrWaitBeforeRetry" lib/features/auth/screens/create_new_password_screen.dart
```

---

### 0.2 Decision Gate: Client-side Backoff/Cooldown (Password Update)

**Warum:** Das alte “Backoff” war client-seitig und ist kein echter Schutz (bypassbar). Zudem ist `updateUser(password: ...)` kein klassischer “Brute-Force”-Endpoint wie Login; er ist an Recovery-Token/Session gebunden.

**Vor Entscheidung klaeren:**
- Produkt/UX: Soll es bewusst “Cooldown” geben, oder ist die vereinfachte UX (kein Warten) gewollt?
- Backend/SSOT: Gibt es serverseitige Rate-Limits/Abuse-Protections (Supabase/Edge/Proxy)? Wenn ja: clientseitig optional.
- Testbarkeit: Ohne DI (Supabase Singleton) ist Backoff schwer sauber zu testen → ggf. nur als pure Helper-Logik implementieren.

**Ergebnis dokumentieren (A oder B):**
- A) Kein clientseitiger Cooldown (Default/MVP) → nur bessere Fehlermeldung/Robustheit.
- B) Minimaler Cooldown NUR bei expliziten Rate-Limit-Signalen (z.B. 429 / “rate limit”) → testbar via Helper (siehe Phase 1.3).

## Phase 1: Security, Privacy & A11y Fixes

### Git-Workflow Phase 1

**Kein neuer Branch** - Arbeite auf dem aktuellen Branch weiter.
Pro Sub-Phase einen separaten Commit erstellen fuer saubere Historie und einfaches Rollback.

---

### 1.1 Password aus Provider State entfernen [CRITICAL]

**Problem (verifiziert):**
- `LoginState` persistiert `password` (`lib/features/auth/state/login_state.dart`).
- `LoginNotifier.validate()` trimmed das Passwort (`trimmedPassword`) und schreibt es in den State zurueck.
- `LoginSubmitNotifier._mapAuthException(...)` schreibt das Passwort erneut in den State (unnötige Lebensdauer/Exponierung).

**Ziel:**
- Passwort nur im `TextEditingController` halten (UI-SSOT), Provider-State speichert nur Email + Error-States.
- Passwort niemals “trimmen” oder anderweitig mutieren.

**Files (Hotspots):**
- `lib/features/auth/state/login_state.dart`
- `lib/features/auth/state/login_submit_provider.dart`
- `lib/features/auth/screens/login_screen.dart`

#### Option A (empfohlen, sauber): Password komplett aus Provider-State entfernen

1) `lib/features/auth/state/login_state.dart`
- `password` Feld entfernen; `isValid` und `copyWith` entsprechend anpassen.

2) `lib/features/auth/state/login_state.dart` (LoginNotifier)
- `validate()` so umbauen, dass es Email/Password als Parameter bekommt (oder in zwei Methoden aufgeteilt wird) und nur Errors setzt.
- Email darf weiterhin getrimmt werden; Passwort NICHT trimmen.

3) `lib/features/auth/screens/login_screen.dart`
- `initState`: nur Email aus State in Controller prefillen (kein Passwort-Prefill mehr).
- `onChanged` fuer Passwort: keinen Provider-State mehr mit Passwort befuellen; nur Submit liest aus `_passwordController.text`.

4) `lib/features/auth/state/login_submit_provider.dart`
- `_mapAuthException(...)`: kein Passwort in den Provider-State schreiben (nur Errors/GlobalError).

**Commit:** `fix(auth): stop persisting login password in provider state`

#### Option B (inkrementell): Passwort-Feld vorerst behalten, aber nicht mehr befuellen

Wenn ein kompletter State-API-Change zu riskant ist (Test-/Refactor-Churn), dann:
- `LoginScreen` schreibt Passwort nicht mehr via Provider (nur Controller).
- `LoginNotifier.validate()` nutzt Passwort als Parameter statt `LoginState.password`.
- `_mapAuthException(...)` setzt `password:` nicht (vermeidet “re-seeding” des Passworts in State).

**Commit:** `fix(auth): stop writing password into LoginState (deprecate field)`

**Test-Impact (beide Optionen):**
- `test/features/auth/login_notifier_test.dart`
- `test/features/auth/login_submit_guard_test.dart`
- `test/features/auth/login_screen_widget_test.dart`
- `test/features/auth/screens/login_screen_test.dart` (ggf. Keys/UX-Flow)
- ggf. weitere Tests, die `LoginState.password` referenzieren

---

### 1.2 Raw Error Logging in router.dart vereinheitlichen [HIGH]

**Problem:** `router.dart` loggt Errors unsanitized, waehrend `splash_controller.dart` korrekt `sanitizeError()` nutzt.

**File:** `lib/router.dart`

**Betroffene Stellen:**

**Line 97-102 (_onboardingConsentGuard):**
```dart
// VORHER:
log.w(
  'consent_guard_state_error',
  tag: 'router',
  error: error,  // ❌ RAW
  stack: st,
);

// NACHHER:
log.w(
  'consent_guard_state_error',
  tag: 'router',
  error: sanitizeError(error) ?? error.runtimeType,  // ✅ SANITIZED
  stack: st,
);
```

**Line 135-140 (_postAuthGuard):**
```dart
// VORHER:
log.w(
  'post_auth_guard_state_error',
  tag: 'router',
  error: error,  // ❌ RAW
  stack: st,
);

// NACHHER:
log.w(
  'post_auth_guard_state_error',
  tag: 'router',
  error: sanitizeError(error) ?? error.runtimeType,  // ✅ SANITIZED
  stack: st,
);
```

**Import hinzufuegen:**
```dart
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
```

**Test-Impact:** Keine

**Commit:** `fix(privacy): sanitize error logging in router guards`

---

### 1.3 Client-side Backoff/Cooldown (Decision Gate) [MEDIUM]

**Problem (verifiziert):** In `lib/features/auth/screens/create_new_password_screen.dart` wurde der vorher vorhandene clientseitige “Backoff/Ticker” entfernt.

**Wichtig:** Clientseitiger Backoff ist kein echter Security-Schutz (bypassbar). Zudem ist `updateUser(password: ...)` an Recovery-Token/Session gebunden; “Brute-Force” ist hier meist nicht das passende Threat Model. Wenn wir hier etwas tun, dann als **UX/Abuse-Mitigation** oder als Reaktion auf **explizite Rate-Limit-Signale** vom Server.

**File:** `lib/features/auth/screens/create_new_password_screen.dart`

#### Entscheidung (A oder B) – siehe Phase 0.2

**A) Default/MVP: Kein clientseitiger Cooldown**
- Status quo behalten (kein Warten).
- Fokus: robuste Fehlermeldung + sauberes Logging (ohne PII).
- Akzeptanz: Wiederholte Fehler blockieren die CTA nicht.

**B) Optional: Minimaler Cooldown NUR bei explizitem Rate-Limit**
- Kein Cooldown bei `TimeoutException`/Offline/sonstigen transienten Fehlern.
- Cooldown nur, wenn der Server klar signalisiert “rate limited” (z.B. 429 oder Message enthaelt “rate limit”).

#### Option B – Implementation (testbar, ohne Supabase-Mocking)

**1) Pure Helper extrahieren (Unit-testbar):**
- **NEU:** `lib/features/auth/utils/password_update_cooldown.dart`
- Empfehlung: Helper ist “dumm” (kein Supabase), bekommt `DateTime now` injiziert.

Beispiel-Skizze:
```dart
class PasswordUpdateCooldown {
  PasswordUpdateCooldown({this.maxSeconds = 300});
  final int maxSeconds;
  int _failures = 0;
  DateTime? _lastHit;

  int remainingSeconds(DateTime now) { /* ... */ }
  void registerRateLimitHit(DateTime now) { /* ... */ }
  void reset() { /* ... */ }
}
```

**2) Tests:**
- **NEU:** `test/features/auth/password_update_cooldown_test.dart`
- Tests nur fuer Helper-Logik (keine Supabase-Abhaengigkeit).

**3) UI-Integration (CreateNewPasswordScreen):**
- CTA deaktivieren wenn `remainingSeconds(now) > 0`.
- Snackbar: vorhandenes `l10n.authPasswordUpdateError` + `l10n.authErrWaitBeforeRetry(seconds)` nutzen (kein neuer L10n-Key).

**Commit (Option B):** `feat(auth): add optional password-update cooldown on rate-limit`

---

### 1.4 Touch Targets mit TextButton/InkWell [HIGH]

**Problem:** GestureDetector hat keinen Fokus/Ripple. TextButton bietet bessere A11y.

**File 1:** `lib/features/auth/screens/auth_signin_screen.dart` (Lines 150-175)

```dart
// VORHER:
Semantics(
  button: true,
  label: l10n.authEntryExistingAccount,
  child: GestureDetector(
    onTap: _oauthLoading ? null : _showLoginSheet,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,  // ❌ <44dp
      ),
      child: Text(
        l10n.authEntryExistingAccount,
        style: const TextStyle(...),
      ),
    ),
  ),
)

// NACHHER:
TextButton(
  onPressed: _oauthLoading ? null : _showLoginSheet,
  style: TextButton.styleFrom(
    minimumSize: const Size(0, Sizes.touchTargetMin),  // ✅ 44dp
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,   // ✅ Pixel-Parity (verhindert 48dp default)
    padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
    foregroundColor: DsColors.black,
    textStyle: const TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: AuthRebrandMetrics.linkFontSize,
      fontVariations: [FontVariation('wght', 600)],
      height: AuthRebrandMetrics.bodyLineHeight,
      decoration: TextDecoration.underline,
    ),
  ),
  child: Text(l10n.authEntryExistingAccount),
)
```

**File 2:** `lib/features/auth/screens/login_screen.dart` (Lines 257-278)

```dart
// VORHER:
Widget _buildForgotLink(AppLocalizations l10n) {
  return Semantics(
    button: true,
    label: l10n.authLoginForgot,
    child: GestureDetector(
      key: const ValueKey('login_forgot_link'),
      onTap: () => context.push(ResetPasswordScreen.routeName),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),  // ❌ <44dp
        child: Text(l10n.authLoginForgot, style: ...),
      ),
    ),
  );
}

// NACHHER:
Widget _buildForgotLink(AppLocalizations l10n) {
  return TextButton(
    key: const ValueKey('login_forgot_link'),
    onPressed: () => context.push(ResetPasswordScreen.routeName),
    style: TextButton.styleFrom(
      minimumSize: const Size(0, Sizes.touchTargetMin),  // ✅ 44dp
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,   // ✅ Pixel-Parity
      padding: EdgeInsets.zero,
      foregroundColor: DsColors.grayscale500,
      textStyle: TextStyle(
        fontFamily: FontFamilies.figtree,
        fontSize: AuthRebrandMetrics.dividerTextFontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
    child: Text(l10n.authLoginForgot),
  );
}
```

**Vorteile von TextButton:**
- ✅ 44dp Touch Target via `minimumSize`
- ✅ Focus highlight fuer Keyboard-Navigation
- ✅ Material Ripple Feedback
- ✅ Automatische Semantics (kein manueller Wrapper)
- ✅ Pixel-Parity via `tapTargetSize: MaterialTapTargetSize.shrinkWrap`

**WICHTIG - Pixel-Parity Verification:**
TextButton hat default `tapTargetSize: MaterialTapTargetSize.padded` (48dp).
Mit `shrinkWrap` wird nur `minimumSize` verwendet (44dp).
Nach der Migration Screenshot-Vergleich durchfuehren um Layout-Shift auszuschliessen.

**Test-Impact:** Keine - Verhalten identisch, UX verbessert

**Commit:** `fix(a11y): replace GestureDetector with TextButton for proper focus/ripple`

---

### 1.5 ref.listen aus build() verschieben [HIGH]

**File:** `lib/features/auth/screens/reset_password_screen.dart` (Line 78)

**Hinweis:** Riverpod erlaubt `ref.listen(...)` in `build()` (Pattern ist verbreitet). Hier ist es dennoch sinnvoll, den Listener in `initState()` zu verankern, um (a) “no side-effects in build” als Hygiene-Regel einzuhalten und (b) SnackBar-Duplikate bei Rebuilds leichter auszuschliessen.

**Fix:**
```dart
class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final ProviderSubscription<AsyncValue<void>> _submitSubscription;

  @override
  void initState() {
    super.initState();
    _submitSubscription = ref.listenManual<AsyncValue<void>>(
      resetSubmitProvider,
      (prev, next) {
        if (!mounted) return;
        if (next.hasError && !next.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authResetErrorGeneric),
              backgroundColor: DsColors.authRebrandError,
              duration: Timing.snackBarBrief,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _submitSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen ENTFERNT aus build()
    // ...
  }
}
```

**Test-Impact:** Keine

**Commit:** `refactor(auth): move ref.listen to initState in ResetPasswordScreen`

---

### Phase 1 Verification

```bash
# 1. Static Analysis (Repo-Wrapper, sandbox-safe)
scripts/flutter_codex.sh analyze

# 2. Auth Tests (Wrapper; in Sandbox ggf. Approval wegen Loopback)
scripts/flutter_codex.sh test -j 1 test/features/auth/

# 3. Navigation/Splash Guards (optional, aber nah an den Aenderungen)
scripts/flutter_codex.sh test -j 1 test/core/navigation/ test/features/splash/

# 3. Manuelle Verification
# - App starten, Login Screen oeffnen
# - Falsches Password eingeben
# - In DevTools pruefen: Password NICHT in Provider State sichtbar
# - Links antippen: Ripple-Effekt sichtbar?
# - Tab-Navigation: Links fokussierbar?
# - Create New Password: Cooldown nur wenn Option B (Rate-Limit) umgesetzt
```

---

## Phase 2: Duplication Reduction & Build Length

### Git-Workflow Phase 2

**Kein neuer Branch** - Weiterhin auf aktuellem Branch arbeiten.
Pro Sub-Phase einen separaten Commit erstellen.

---

### 2.1 AuthRebrandScaffold extrahieren [HIGH - Haupt-Refactor]

**Problem:** Alle 4 Auth Screens haben identischen 60+ LOC Scaffold-Block mit 10 Nesting-Ebenen.

**Betroffene Screens (build() LOC / Nesting):**
- `login_screen.dart`: 182 LOC, 10 Ebenen (Lines 74-255)
- `auth_signup_screen.dart`: 227 LOC, 10 Ebenen (Lines 175-401)
- `create_new_password_screen.dart`: 166 LOC, 10 Ebenen (Lines 209-374)
- `reset_password_screen.dart`: 163 LOC, 10 Ebenen (Lines 69-231)

**Gemeinsamer Pattern (in jedem Screen identisch):**
```dart
Scaffold(
  backgroundColor: DsColors.authRebrandBackground,
  resizeToAvoidBottomInset: false,
  body: Stack(
    children: [
      Positioned.fill(
        child: AuthRainbowBackground(
          containerTop: MediaQuery.of(context).padding.top +
              AuthRebrandMetrics.rainbowContainerTopOffset,
        ),
      ),
      SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: AuthRebrandMetrics.backButtonLeft,
              top: AuthRebrandMetrics.backButtonTop,
            ),
            child: AuthBackButton(
              onPressed: _handleBack,
              semanticsLabel: l10n.authBackSemantic,
            ),
          ),
        ),
      ),
      SafeArea(
        child: Center(
          child: AuthKeyboardAwarePadding(
            compact: _isCompact,
            child: SingleChildScrollView(
              child: _content,  // <-- Nur das unterscheidet sich
            ),
          ),
        ),
      ),
    ],
  ),
)
```

**Neues Widget erstellen:**

**Hinweis (Dependency):** Wenn `AuthKeyboardAwarePadding` noch nicht extrahiert ist, hier vorerst das bestehende `AnimatedPadding` inline lassen **oder** Phase 2.4 vorziehen.
```dart
// lib/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_back_button.dart';
import 'auth_keyboard_aware_padding.dart';
import 'auth_rainbow_background.dart';
import 'auth_rebrand_metrics.dart';

/// Scaffold wrapper for Auth Rebrand v3 screens.
///
/// Provides consistent layout:
/// - Beige background
/// - Rainbow arcs
/// - Back button (top-left)
/// - Keyboard-aware content area
///
/// Reduces 60+ LOC and 10-level nesting to single widget.
class AuthRebrandScaffold extends StatelessWidget {
  const AuthRebrandScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.compactKeyboard = false,
    this.scaffoldKey,
  });

  /// The content to display (typically AuthContentCard)
  final Widget child;

  /// Callback when back button is pressed
  final VoidCallback onBack;

  /// Use compact keyboard padding (for screens with fewer fields)
  final bool compactKeyboard;

  /// Optional key for the Scaffold widget (for testing)
  final Key? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: DsColors.authRebrandBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Rainbow background
          Positioned.fill(
            child: AuthRainbowBackground(
              containerTop: topPadding + AuthRebrandMetrics.rainbowContainerTopOffset,
            ),
          ),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AuthRebrandMetrics.backButtonLeft,
                  top: AuthRebrandMetrics.backButtonTop,
                ),
                child: AuthBackButton(
                  onPressed: onBack,
                  semanticsLabel: l10n.authBackSemantic,
                ),
              ),
            ),
          ),

          // Content area
          SafeArea(
            child: Center(
              child: AuthKeyboardAwarePadding(
                compact: compactKeyboard,
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Migration Beispiel (login_screen.dart):**
```dart
// VORHER: 182 LOC, 10 Nesting-Ebenen
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: DsColors.authRebrandBackground,
    resizeToAvoidBottomInset: false,
    body: Stack(
      children: [
        Positioned.fill(child: AuthRainbowBackground(...)),
        SafeArea(child: Align(child: Padding(child: AuthBackButton(...)))),
        SafeArea(
          child: Center(
            child: AnimatedPadding(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AuthContentCard(child: ...),
                    // ... 150+ LOC content
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// NACHHER: ~50 LOC, 5 Nesting-Ebenen
@override
Widget build(BuildContext context) {
  return AuthRebrandScaffold(
    scaffoldKey: const ValueKey('auth_login_screen'),
    onBack: () => context.go(AuthSignInScreen.routeName),
    child: Column(
      children: [
        AuthContentCard(child: _buildForm(context)),
        // ... nur Content-spezifischer Code
      ],
    ),
  );
}
```

**Erwartete Verbesserungen:**
| Screen | Vorher LOC | Nachher LOC | Vorher Nesting | Nachher Nesting |
|--------|-----------|-------------|----------------|-----------------|
| login_screen | 182 | ~60 | 10 | 5 |
| auth_signup_screen | 227 | ~80 | 10 | 5 |
| create_new_password_screen | 166 | ~50 | 10 | 5 |
| reset_password_screen | 163 | ~50 | 10 | 5 |

**EMPFOHLEN - Layout-Verification (vor Merge):**

Weil AuthRebrandScaffold das Layout aller 4 Auth Screens kapselt, wird visueller Vergleich empfohlen:

**Option A: Manueller Vergleich (empfohlen)**
- App im Simulator/Emulator starten
- Alle 4 Auth Screens vor und nach Migration vergleichen
- Fokus auf: Rainbow-Position, Back-Button, Card-Zentrierung

**Option B: Screenshot-Vergleich (falls Tooling vorhanden)**
```bash
# Hinweis: flutter screenshot ist nicht ueberall verfuegbar
# 1. VOR Migration: Screenshots erstellen
# 2. NACH Migration: Screenshots erstellen
# 3. Visueller oder Pixel-Diff Vergleich
```

**Acceptance-Kriterium:** Kein sichtbarer Layout-Shift fuer kritische Elemente (Rainbow, Back-Button, Card).

---

**Barrel Export aktualisieren (`auth_rebrand.dart`):**
```dart
export 'auth_rebrand_scaffold.dart';
```

**Test-Impact:**
- Alle Auth Screen Tests anpassen (ValueKey Lookup aendert sich ggf.)
- Golden Tests (falls vorhanden) muessen nach Refactor aktualisiert werden

**Commit:** `refactor(auth): extract AuthRebrandScaffold to reduce nesting`

---

### 2.2 OAuth Bottom Sheet Duplikat entfernen (non-breaking) [HIGH]

**Problem:** `AuthLoginSheet` und `AuthRegisterSheet` sind fast identisch (Apple/Google/Divider/Email + Layout).

**Ziel:** Duplikate reduzieren **ohne** Breaking Change (bestehende Imports/Calls bleiben gueltig).

**Files zu erstellen:**
- `lib/features/auth/widgets/rebrand/auth_oauth_sheet_content.dart` (NEU)

**Files zu aktualisieren:**
- `lib/features/auth/widgets/rebrand/auth_login_sheet.dart` (delegiert an shared content)
- `lib/features/auth/widgets/rebrand/auth_register_sheet.dart` (delegiert an shared content)

**Shared Widget (Skizze):**
```dart
// lib/features/auth/widgets/rebrand/auth_oauth_sheet_content.dart
class AuthOAuthSheetContent extends StatelessWidget {
  const AuthOAuthSheetContent({
    super.key,
    required this.headline,
    required this.onApplePressed,
    required this.onGooglePressed,
    required this.onEmailPressed,
  });

  final String headline;
  final VoidCallback onApplePressed;
  final VoidCallback onGooglePressed;
  final VoidCallback onEmailPressed;

  @override
  Widget build(BuildContext context) {
    // identischer Code wie vorher; nur headline ist parametrisierbar
  }
}
```

**Wrapper-Update (Beispiel):**
- `AuthLoginSheet` nutzt `headline: l10n.authLoginSheetHeadline`
- `AuthRegisterSheet` nutzt `headline: l10n.authRegisterHeadline`

**Commit:** `refactor(auth): dedupe auth oauth bottom sheets via shared content widget`

---

### 2.3 PasswordToggleButton extrahieren [MEDIUM]

**Problem:** Password-Visibility Toggle ist mehrfach dupliziert (Semantics + IconButton).

**Files zu aktualisieren (6 Stellen):**
- `login_screen.dart` (Lines 218-219)
- `auth_signup_screen.dart` (Lines 322-323, 366-367)
- `create_new_password_screen.dart` (Lines 306-307, 341-342)
- `login_password_field.dart` (Lines 94-95)

**Neues Widget:**
```dart
// lib/features/auth/widgets/password_visibility_toggle_button.dart
class PasswordVisibilityToggleButton extends StatelessWidget {
  const PasswordVisibilityToggleButton({
    super.key,
    required this.obscured,
    required this.onPressed,
    this.color,
    this.size,
  });

  final bool obscured;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: obscured ? l10n.authShowPassword : l10n.authHidePassword,
      child: IconButton(
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: color,
          size: size,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
```

**Hinweis:** Widget ist bewusst style-agnostisch (Farbe/Size optional), damit es sowohl in Rebrand-Screens (`DsColors`/`AuthRebrandMetrics`) als auch in Legacy-Widgets (`tokens`/`Spacing`) genutzt werden kann.

**Commit:** `refactor(auth): extract PasswordVisibilityToggleButton widget`

---

### 2.4 AuthKeyboardAwarePadding extrahieren [MEDIUM]

**Problem:** 5x identisches Pattern.

**Files zu erstellen:**
- `lib/features/auth/widgets/rebrand/auth_keyboard_aware_padding.dart` (NEU)

**Neues Widget (Skizze):**
```dart
// lib/features/auth/widgets/rebrand/auth_keyboard_aware_padding.dart
class AuthKeyboardAwarePadding extends StatelessWidget {
  const AuthKeyboardAwarePadding({
    super.key,
    required this.child,
    this.compact = false,
  });

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final factor = compact
        ? AuthRebrandMetrics.keyboardPaddingFactorCompact
        : AuthRebrandMetrics.keyboardPaddingFactor;
    final max = compact
        ? AuthRebrandMetrics.keyboardPaddingMaxCompact
        : AuthRebrandMetrics.keyboardPaddingMax;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: (inset * factor).clamp(0, max)),
      child: child,
    );
  }
}
```

**Commit:** `refactor(auth): extract AuthKeyboardAwarePadding widget`

---

### 2.5 Barrel Export aktualisieren [MEDIUM - NICHT VERGESSEN]

**Problem:** Neue Widgets muessen in `auth_rebrand.dart` exportiert werden, sonst sind sie nicht importierbar.

**File:** `lib/features/auth/widgets/rebrand/auth_rebrand.dart`

**Hinzuzufuegende Exports (pro neuem Widget):**

```dart
// Bestehende Exports bleiben erhalten...

// NEUE Exports fuer Phase 2:
export 'auth_rebrand_scaffold.dart';           // 2.1
export 'auth_oauth_sheet_content.dart';        // 2.2 (shared content; optional export)
export 'auth_keyboard_aware_padding.dart';     // 2.4
```

**Hinweis:** `PasswordVisibilityToggleButton` liegt bewusst ausserhalb des Rebrand-Barrels:
- Import direkt aus `lib/features/auth/widgets/password_visibility_toggle_button.dart`

**Checkliste (nach jedem Widget-Commit):**
- [ ] Export in `auth_rebrand.dart` hinzugefuegt
- [ ] `scripts/flutter_codex.sh analyze` ohne Fehler
- [ ] Alle Imports in Screens aktualisiert

**Commit:** `chore(auth): update barrel exports for new rebrand widgets`

---

### Phase 2 Verification

```bash
# 1. Static Analysis (Wrapper)
scripts/flutter_codex.sh analyze

# 2. Alle Auth Tests (Wrapper)
scripts/flutter_codex.sh test -j 1 test/features/auth/

# 3. LOC/Nesting Check
# Manuell pruefen: build() Methoden sollten <80 LOC sein

# 4. Non-breaking: Sheets bleiben, aber sollen shared content nutzen
rg -n "AuthOAuthSheetContent" lib/features/auth/widgets/rebrand/auth_login_sheet.dart
rg -n "AuthOAuthSheetContent" lib/features/auth/widgets/rebrand/auth_register_sheet.dart
```

---

## Phase 3: SSOT & Cleanup

### Git-Workflow Phase 3

**Kein neuer Branch** - Weiterhin auf aktuellem Branch arbeiten.
Pro Sub-Phase einen separaten Commit erstellen.

---

### 3.1 Rainbow Ring Arrays SSOT-Haertung [MEDIUM]

**Problem:** `_ringWidths` ist in `auth_rainbow_background.dart` hardcoded, obwohl `AuthRebrandMetrics.rainbowRingWidths` existiert.

**File:** `lib/features/auth/widgets/rebrand/auth_rainbow_background.dart`

**Line 75 (VORHER):**
```dart
class _RainbowPillPainter extends CustomPainter {
  // ...

  // Ring widths from SSOT: teal=329, pink=249, orange=167, beige=87
  static const List<double> _ringWidths = [329.0, 249.0, 167.0, 87.0];  // ❌ HARDCODED
```

**NACHHER:**
```dart
class _RainbowPillPainter extends CustomPainter {
  // ...

  // Ring widths from SSOT
  static const List<double> _ringWidths = AuthRebrandMetrics.rainbowRingWidths;  // ✅ SSOT
```

**Hinweis:** Die X/Y Offsets referenzieren bereits korrekt `AuthRebrandMetrics.ringTealX` etc.

**Commit:** `refactor(auth): use SSOT for rainbow ring widths`

---

### 3.2 AuthRainbowBackground unused params entfernen (optional) [LOW]

**File:** `lib/features/auth/widgets/rebrand/auth_rainbow_background.dart`

**Pre-Check:**
```bash
rg -n "containerHeight" lib test --glob="*.dart"
rg -n "isOverlay" lib/features/auth test/features/auth --glob="*.dart"
```

**Guardrail:** Nur entfernen, wenn der Pre-Check **keine** produktiven Call-Sites zeigt. Sonst als Low-Priority stehen lassen (API-Stabilitaet > Clean-up).

**Zu entfernen:**
- `containerHeight` (Lines 21, 30)
- `isOverlay` (Lines 23, 39, 47, 63, 136)

**Commit:** `refactor(auth): remove unused params from AuthRainbowBackground`

---

### 3.3 routes.dart supabaseRedirectWithSession aufteilen [MEDIUM]

**Problem:** Funktion ist 90 LOC (Lines 162-251).

**File:** `lib/core/navigation/routes.dart`

**Aktuelle Struktur:**
- Lines 168-176: Dev-only bypass flags
- Lines 178-209: State initialization + route type detection
- Lines 211-234: Route-specific short-circuits
- Lines 236-250: Session validation

**Refactoring-Vorschlag:**
```dart
// Neue Helper-Funktionen:

/// Determines the type of route being accessed.
_RouteType _classifyRoute(String location) {
  if (location.startsWith('/auth/')) return _RouteType.auth;
  if (location == RoutePaths.splash) return _RouteType.splash;
  // etc.
}

/// Safely extracts session from Supabase, returns null on error.
Session? _getSessionSafely() {
  try {
    return SupabaseService.client.auth.currentSession;
  } catch (e) {
    return null;
  }
}

/// Handles bypass routes that don't need session validation.
String? _handleBypassRoutes({
  required _RouteType routeType,
  required bool isDevBypassDashboard,
  required bool isDevBypassOnboarding,
}) {
  // Password recovery, dev bypasses, splash, welcome logic
}
```

**Ergebnis:**
- `supabaseRedirectWithSession`: ~30 LOC (orchestration only)
- `_classifyRoute`: ~15 LOC
- `_getSessionSafely`: ~10 LOC
- `_handleBypassRoutes`: ~25 LOC

**Commit:** `refactor(navigation): split supabaseRedirectWithSession into helpers`

---

### 3.4 splash_controller.dart Methoden extrahieren [LOW]

**File:** `lib/features/splash/state/splash_controller.dart`

**Ziel:** `_runGateSequence` von ~80 LOC auf <30 LOC

**Refactored:**
```dart
Future<void> _runGateSequence(int token) async {
  if (await _checkWelcomeGate(token)) return;
  if (_checkAuthGate(token)) return;

  final consentResult = await _checkConsentGate(token);
  if (consentResult == null) return;

  await _checkOnboardingGate(token, consentResult);
}
```

**Commit:** `refactor(splash): extract gate check methods`

---

### Phase 3 Verification

```bash
# 1. Static Analysis (Wrapper)
scripts/flutter_codex.sh analyze

# 2. Full Test Suite (Wrapper; in Sandbox ggf. Approval wegen Loopback)
scripts/flutter_codex.sh test -j 1

# 3. LOC Checks
wc -l lib/features/splash/state/splash_controller.dart  # Ziel: <530
wc -l lib/core/navigation/routes.dart  # Funktion sollte <40 LOC sein
```

---

## Zusammenfassung der zu aendernden Files

| Phase | File | Aktion |
|-------|------|--------|
| 0 | - | Abhaengigkeitsanalyse |
| 1.1 | `lib/features/auth/state/login_state.dart` | Passwort nicht im Provider-State persistieren (Option A/B) + Passwort nicht trimmen |
| 1.1 | `lib/features/auth/state/login_submit_provider.dart` | Kein Passwort in `_mapAuthException` in State schreiben |
| 1.1 | `lib/features/auth/screens/login_screen.dart` | Passwort nur aus Controller verwenden |
| 1.2 | `lib/router.dart` | sanitizeError() fuer Guard-Logs |
| 1.3 | `lib/features/auth/screens/create_new_password_screen.dart` | Decision Gate: kein Cooldown ODER rate-limit-only Cooldown via Helper |
| 1.3 | **NEU (Option B)** `lib/features/auth/utils/password_update_cooldown.dart` | Rate-limit-only Cooldown Helper (pure logic, unit-testbar) |
| 1.3 | **NEU (Option B)** `test/features/auth/password_update_cooldown_test.dart` | Unit Tests fuer Cooldown Helper |
| 1.4 | `lib/features/auth/screens/auth_signin_screen.dart` | TextButton statt GestureDetector |
| 1.4 | `lib/features/auth/screens/login_screen.dart` | TextButton statt GestureDetector |
| 1.5 | `lib/features/auth/screens/reset_password_screen.dart` | ref.listen nach initState |
| 2.1 | **NEU** `lib/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart` | Erstellen (Haupt-Refactor) |
| 2.1 | `lib/features/auth/screens/*` | Migration zu AuthRebrandScaffold (nur betroffene Screens) |
| 2.2 | **NEU** `lib/features/auth/widgets/rebrand/auth_oauth_sheet_content.dart` | Shared Content erstellen (non-breaking) |
| 2.2 | `lib/features/auth/widgets/rebrand/auth_login_sheet.dart` | Auf shared content umstellen |
| 2.2 | `lib/features/auth/widgets/rebrand/auth_register_sheet.dart` | Auf shared content umstellen |
| 2.3 | **NEU** `lib/features/auth/widgets/password_visibility_toggle_button.dart` | Gemeinsames Toggle-Widget erstellen |
| 2.4 | **NEU** `lib/features/auth/widgets/rebrand/auth_keyboard_aware_padding.dart` | Erstellen |
| 2.5 | `lib/features/auth/widgets/rebrand/auth_rebrand.dart` | Barrel Exports aktualisieren (neue Exports; keine removals) |
| 3.1 | `lib/features/auth/widgets/rebrand/auth_rainbow_background.dart` | SSOT fuer Ring Widths |
| 3.2 | `lib/features/auth/widgets/rebrand/auth_rainbow_background.dart` | Optional: Unused params entfernen (nur wenn wirklich ungenutzt) |
| 3.3 | `lib/core/navigation/routes.dart` | Helper-Funktionen extrahieren |
| 3.4 | `lib/features/splash/state/splash_controller.dart` | Gate-Methoden extrahieren |

---

## Vollstaendige Verification Checkliste

### Automatisiert
```bash
scripts/flutter_codex.sh analyze
scripts/flutter_codex.sh test -j 1
scripts/flutter_codex.sh test -j 1 test/features/auth/
scripts/flutter_codex.sh test -j 1 test/features/splash/
scripts/flutter_codex.sh test -j 1 test/core/navigation/
```

### Manuell

**Security:**
- [ ] DevTools: Password nicht in Provider State nach Submit
- [ ] Create New Password: Cooldown nur wenn Option B umgesetzt (Rate-Limit-Signale)
- [ ] Router-Logs: Keine sensiblen Daten in Crash Reports

**A11y:**
- [ ] iOS VoiceOver: Alle Auth Screens durchnavigieren
- [ ] Android TalkBack: Alle Auth Screens durchnavigieren
- [ ] Links fokussierbar mit Tastatur
- [ ] Ripple-Effekt bei Link-Taps

**Funktional:**
- [ ] Login Flow komplett
- [ ] Signup Flow komplett
- [ ] Password Reset Flow komplett
- [ ] Create New Password Flow komplett
- [ ] Keyboard Animation smooth

---

## Rollback-Strategie

### Empfohlene Methode: Commit-basiertes Rollback

Da alle Aenderungen als separate Commits erfolgen, ist `git revert` die praeziseste Methode:

```bash
# Einzelnen Commit rueckgaengig machen (praezise, keine Side-Effects)
git revert <commit-sha>

# Mehrere Commits rueckgaengig machen
git revert <oldest-sha>..<newest-sha>
```

### Alternative: SHA-basiertes Checkout

Falls ein vollstaendiger Rollback noetig ist, nutze den am Anfang gesetzten ROLLBACK_SHA:

```bash
# Voraussetzung: ROLLBACK_SHA wurde am Anfang gesetzt
# ROLLBACK_SHA=$(git rev-parse HEAD)

# Phase 1 Rollback
git checkout $ROLLBACK_SHA -- lib/features/auth/state/
git checkout $ROLLBACK_SHA -- lib/router.dart
git checkout $ROLLBACK_SHA -- lib/features/auth/screens/

# Phase 2 Rollback
git checkout $ROLLBACK_SHA -- lib/features/auth/widgets/rebrand/

# Phase 3 Rollback
git checkout $ROLLBACK_SHA -- lib/core/navigation/routes.dart
git checkout $ROLLBACK_SHA -- lib/features/splash/state/splash_controller.dart
```

### Wichtige Hinweise zum Rollback

1. **Neue Dateien:** Bei checkout-basiertem Rollback werden NEU erstellte Dateien
   (z.B. `auth_rebrand_scaffold.dart`) NICHT geloescht - manuell entfernen:
   ```bash
   rm lib/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart
   rm lib/features/auth/widgets/rebrand/auth_oauth_sheet_content.dart
   rm lib/features/auth/widgets/rebrand/auth_keyboard_aware_padding.dart
   rm lib/features/auth/widgets/password_visibility_toggle_button.dart
   rm lib/features/auth/utils/password_update_cooldown.dart
   rm test/features/auth/password_update_cooldown_test.dart
   ```

2. **Geloeschte Dateien:** (Falls in spaeteren Refactors doch Dateien geloescht werden)
   werden sie bei checkout wiederhergestellt - das ist gewuenscht.

3. **Praezision:** `git revert` ist praeziser als `git checkout` fuer Rollbacks,
   da es nur die spezifischen Aenderungen eines Commits rueckgaengig macht.
