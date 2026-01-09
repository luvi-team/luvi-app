# Auth Flow Bug Fixes - Finaler Plan

> **Erstellt:** 2025-12-11
> **Aktualisiert:** 2026-01-07 (Welcome Rebrand Hinweise hinzugefügt)
> **Status:** Teilweise veraltet (siehe Hinweise)
> **Bewertung:** 10/10 (nach Vereinheitlichung E-Mail + OAuth Flow)

> ⚠️ **WELCOME REBRAND (2026-01):** Einige Terminologie in diesem Dokument ist veraltet.
> Der neue Flow ist: `Splash → Welcome (3 Seiten) → Auth → Consent → Onboarding → Home`
> Siehe `docs/plans/onboarding-flow-implementation-plan.md` für aktuelle Referenz.

## Priorisierte Issues

| Prio | Issue | Problem | Root Cause |
|------|-------|---------|------------|
| 🔴 1 | #3 | "Neu bei LUVI?" → Social Login | Route nicht in Whitelist |
| 🔴 2 | #5 | "Passwort vergessen" → Social Login | Route nicht in Whitelist |
| 🔴 3 | #4 | Nach Apple Login → Social Login statt Onboarding/Home | Post-OAuth Redirect fehlt |
| 🟡 4 | #2 | Keyboard öffnet automatisch & lässt sich nicht schließen | `autofocus: true` + nur onDrag |
| 🟢 5 | #1 | Navigation "zu schnell" | Keine Transition (Nice-to-have) |
| 🟢 6 | #6 | Kein haptisches Feedback | Nicht implementiert (Nice-to-have) |

---

## Entscheidungen (vom User bestätigt)

### Post-OAuth Navigation (Issue 4)
- **First-Time User** (Onboarding nicht abgeschlossen) → Onboarding/Welcome → Dashboard
- **Returning User** (Onboarding erledigt) → direkt Dashboard
- Social/OAuth = E-Mail Login (gleicher Flow)

### Keyboard (Issue 2)
- **Kein Autofocus** - Keyboard öffnet NICHT automatisch
- **Tap-to-dismiss** - Keyboard schließt bei Tap außerhalb der Felder
- Scroll/Drag-dismiss bleibt wie bisher

### Animation (Issue 1)
- **Nice-to-have** - nur wenn einfach machbar, nach funktionalen Fixes

### Haptic Feedback (Issue 6)
- **Nur primäre CTAs**: SignIn, Signup, Reset, Success-Buttons
- **Dezent**: `HapticFeedback.lightImpact()` oder `selectionClick()`

---

## Implementierungs-Plan

### Phase 1: Route Fixes (Issues 3, 5, 4)

**Datei:** `lib/core/navigation/routes.dart`

#### 1.1 Whitelist erweitern (Lines ~259-261)
```dart
// NEU hinzufügen nach isAuthSignIn
final isSigningUp = state.matchedLocation.startsWith(AuthSignupScreen.routeName);
final isResettingPassword = state.matchedLocation.startsWith(ResetPasswordScreen.routeName);
```

#### 1.2 Session-Check anpassen (Lines ~297-301)
```dart
if (session == null) {
  // ERWEITERT: Alle Auth-Screens ohne Session erlauben
  if (isLoggingIn || isAuthSignIn || isSigningUp || isResettingPassword) {
    return null;
  }
  return AuthSignInScreen.routeName;
}
```

#### 1.3 Post-Auth Redirect vereinheitlichen (Lines 303-305)

**Problem:**
- `supabaseRedirect` ist synchron, aber `UserStateService` (First-Time/Returning Check) ist async
- **Zusätzlicher Bug gefunden:** E-Mail-Login führt IMMER zu Onboarding (auch für Returning Users!)

**Aktueller Code (Bug):**
```dart
if (isLoggingIn) {
  return Onboarding01Screen.routeName;  // BUG: Immer Onboarding, auch für Returning Users!
}
```

**Lösung:** BEIDE Flows (E-Mail + OAuth) über `/splash` redirecten! Der `SplashScreen` macht bereits die korrekte async-Logik:

> **⚠️ HINWEIS (Welcome Rebrand):** Die Terminologie wurde aktualisiert:
> - `hasSeenWelcomeOrNull` → `DeviceStateService.hasCompletedWelcome` (device-local)
> - `ConsentWelcome01Screen` → `WelcomeScreen` (3 Seiten unter `/welcome`)
> - Welcome wird jetzt VOR Auth gezeigt, nicht nach

- Prüft `hasCompletedWelcome` via `DeviceStateService` (device-local)
- First-Time (welcome not completed) → `/welcome` → `/auth/signin`
- Returning (welcome completed) → `/auth/signin` oder direkt `HeuteScreen`

```dart
// ERSETZEN: Lines 303-305 komplett durch:
// Nach Login (E-Mail ODER OAuth) mit Session → zu Splash
if ((isLoggingIn || isAuthSignIn) && session != null) {
  return SplashScreen.routeName;  // Splash macht die First-Time/Returning Logik
}
```

**Warum das funktioniert:**
1. User loggt sich ein (E-Mail auf `/auth/login` ODER OAuth auf `/auth/signin`)
2. `supabaseRedirect` erkennt Session → redirect zu `/splash`
3. `SplashScreen._navigateAfterAnimation()` prüft async `hasSeenWelcomeOrNull`
4. Navigiert zu Welcome/Onboarding (First-Time) oder Dashboard (Returning)

**Vorteile der Vereinheitlichung:**
- Konsistentes Verhalten für E-Mail UND OAuth
- Fixt zusätzlichen Bug: E-Mail-Login für Returning Users ging fälschlich zu Onboarding
- Nutzt bestehende SplashScreen-Logik (kein neuer Code)

---

### Phase 2: Keyboard Fix (Issue 2)

**Datei:** `lib/features/auth/screens/login_screen.dart`

#### 2.1 Autofocus entfernen (Line 151)
```dart
LoginEmailField(
  autofocus: false,  // GEÄNDERT von true
  // ...
)
```

#### 2.2 Tap-to-dismiss hinzufügen

**Empfehlung: In `auth_shell.dart`** (gilt für ALLE Auth-Screens automatisch)

**Datei:** `lib/features/auth/widgets/auth_shell.dart` (Line 60)

```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    behavior: HitTestBehavior.translucent,  // WICHTIG: siehe Erklärung unten
    child: Stack(
      children: [
        // ... existing code (background, SafeArea, etc.)
      ],
    ),
  );
}
```

**Warum `HitTestBehavior.translucent`?**
- `opaque`: Blockiert ALLE Taps → Buttons/Links würden nicht mehr funktionieren ❌
- `deferToChild`: Nur Taps auf Kinder → Tap auf leere Fläche wird ignoriert ❌
- `translucent`: Empfängt Taps UND leitet sie an Kinder weiter → Keyboard schließt + Buttons funktionieren ✅

**Vorteile:**
- Einmal ändern → wirkt auf LoginScreen, SignupScreen, ResetScreen, etc.
- Konsistentes Verhalten überall
- Kein Copy-Paste in jeden Screen
- Buttons/Links bleiben voll funktionsfähig

---

### Phase 3: Nice-to-have (Issues 1 & 6)

#### 3.1 Haptic Feedback

**Nur eine Datei ändern:** `lib/features/consent/widgets/welcome_button.dart`

`WelcomeButton` wird bereits in allen Auth-Screens als primärer CTA verwendet:
- LoginScreen, SignupScreen, ResetPasswordScreen, CreateNewPasswordScreen, SuccessScreen

```dart
import 'package:flutter/services.dart';

class WelcomeButton extends StatelessWidget {
  // ... existing fields

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : () {
        HapticFeedback.lightImpact();  // NEU: Dezentes Feedback
        onPressed?.call();
      },
      // ... rest unchanged
    );
  }
}
```

**Vorteile:**
- Eine Stelle ändern → alle primären CTAs haben Haptic
- Konsistent dezent (`lightImpact`)
- Kein Overhead in anderen Dateien

#### 3.2 Navigation Animation (Optional)

**Datei:** `lib/core/navigation/routes.dart`

Für sanfte Slide-Transition kann `pageBuilder` statt `builder` verwendet werden:
```dart
GoRoute(
  path: LoginScreen.routeName,
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const LoginScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  ),
),
```

---

## Dateien zu ändern

| Datei | Phase | Änderungen | LOC |
|-------|-------|------------|-----|
| `lib/core/navigation/routes.dart` | 1 | Whitelist + Post-OAuth Redirect | ~10 |
| `lib/features/auth/screens/login_screen.dart` | 2 | `autofocus: false` | 1 |
| `lib/features/auth/widgets/auth_shell.dart` | 2 | Tap-to-dismiss Keyboard | ~5 |
| `lib/features/consent/widgets/welcome_button.dart` | 3 | Haptic Feedback | ~3 |

**Total: ~19 Lines of Code** (ohne Tests)

---

## Automatisierte Tests

### Unit Test für Routes (NEU)

**Datei:** `test/core/navigation/routes_auth_whitelist_test.dart`

```dart
void main() {
  group('supabaseRedirect whitelist', () {
    test('allows /auth/signup without session', () {
      // Mock GoRouterState mit matchedLocation = '/auth/signup'
      // Expect: return null (nicht redirecten)
    });

    test('allows /auth/reset without session', () {
      // Mock GoRouterState mit matchedLocation = '/auth/reset'
      // Expect: return null
    });

    test('redirects /auth/signin (OAuth) with session to /splash', () {
      // Mock GoRouterState mit matchedLocation = '/auth/signin'
      // Mock session != null
      // Expect: return SplashScreen.routeName
    });

    test('redirects /auth/login (E-Mail) with session to /splash', () {
      // Mock GoRouterState mit matchedLocation = '/auth/login'
      // Mock session != null
      // Expect: return SplashScreen.routeName (nicht Onboarding01Screen!)
    });
  });
}
```

### Widget Test für Keyboard (ERWEITERN)

**Datei:** `test/features/auth/login_screen_keyboard_test.dart`

```dart
testWidgets('email field does not autofocus', (tester) async {
  await tester.pumpWidget(buildTestApp(initialLocation: '/auth/login'));
  await tester.pumpAndSettle();

  // LoginEmailField ist ein Wrapper-Widget (Column > Container > TextField)
  // → find.descendant nötig, um das innere TextField zu finden
  final emailFieldWrapper = find.byKey(const ValueKey('login_email_field'));
  final textField = tester.widget<TextField>(
    find.descendant(of: emailFieldWrapper, matching: find.byType(TextField)),
  );
  expect(textField.autofocus, isFalse);
});
```

---

## Manuelle Test-Checkliste

### Phase 1: Route Fixes (Critical)
- [ ] LoginScreen → "Neu bei LUVI? Hier starten" → SignupScreen
- [ ] LoginScreen → "Passwort vergessen?" → ResetPasswordScreen
- [ ] **E-Mail Login (First-Time User)** → Splash → Welcome/Onboarding
- [ ] **E-Mail Login (Returning User)** → Splash → Dashboard (vorher Bug: ging zu Onboarding!)
- [ ] Apple OAuth Login (First-Time User) → Splash → Welcome/Onboarding
- [ ] Apple OAuth Login (Returning User) → Splash → Dashboard
- [ ] Google OAuth Login (falls aktiviert) → gleicher Flow wie Apple/E-Mail

### Phase 2: Keyboard (Medium)
- [ ] LoginScreen: Email-Feld hat KEINEN Autofocus
- [ ] LoginScreen: Keyboard öffnet erst bei Tap ins Feld
- [ ] LoginScreen: Keyboard schließt bei Tap außerhalb
- [ ] SignupScreen: Gleiches Verhalten (via AuthShell)
- [ ] ResetScreen: Gleiches Verhalten (via AuthShell)

### Phase 3: Nice-to-have
- [ ] Haptic bei "Anmelden" Button spürbar
- [ ] Haptic bei "Registrieren" Button spürbar
- [ ] Haptic dezent (nicht nervig)

---

## Risiken & Mitigations

| Risiko | Wahrscheinlichkeit | Mitigation |
|--------|-------------------|------------|
| SplashScreen Animation verzögert Post-OAuth-Flow | Niedrig | Animation ist ~1-2s, akzeptabel |
| Keyboard-Tap-to-dismiss blockiert andere Taps | Niedrig | `HitTestBehavior.translucent` erlaubt Durchreichen |
| Haptic funktioniert nicht auf allen Geräten | Niedrig | `lightImpact` ist plattform-übergreifend unterstützt |

---

## Referenzen

- **Root Cause Analyse:** `lib/core/navigation/routes.dart` Lines 246-307
- **SplashScreen Logik:** `lib/features/splash/screens/splash_screen.dart` Lines 72-103
- **AuthShell Widget:** `lib/features/auth/widgets/auth_shell.dart`
- **WelcomeButton:** `lib/features/consent/widgets/welcome_button.dart`
