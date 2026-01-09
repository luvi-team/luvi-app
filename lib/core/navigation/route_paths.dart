/// Single Source of Truth (SSOT) for all route paths.
///
/// This file contains ONLY path constants - no feature imports allowed.
/// Router composition with Screen widgets happens in [lib/router.dart].
///
/// Guardrail: lib/core/** must never import lib/features/**
abstract final class RoutePaths {
  // ─────────────────────────────────────────────────────────────────────────
  // Splash
  // ─────────────────────────────────────────────────────────────────────────
  static const splash = '/splash';

  // ─────────────────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────────────────
  static const authSignIn = '/auth/signin';
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const resetPassword = '/auth/reset';
  static const authForgot = '/auth/forgot'; // Legacy redirect → resetPassword
  static const createNewPassword = '/auth/password/new';
  static const passwordSaved = '/auth/password/success';

  // ─────────────────────────────────────────────────────────────────────────
  // Welcome (single route with PageView)
  // ─────────────────────────────────────────────────────────────────────────
  static const welcome = '/welcome';

  // ─────────────────────────────────────────────────────────────────────────
  // Consent Flow (C1-C3)
  // ─────────────────────────────────────────────────────────────────────────
  static const consentIntro = '/consent/intro'; // C1 - new canonical path
  static const consentOptions = '/consent/options'; // C2
  static const consentBlocking = '/consent/blocking'; // C3

  /// Legacy alias - redirects to [consentIntro] for backwards compatibility.
  static const consentIntroLegacy = '/consent/02';

  // ─────────────────────────────────────────────────────────────────────────
  // Onboarding (O1-O8)
  // ─────────────────────────────────────────────────────────────────────────
  static const onboarding01 = '/onboarding/01';
  static const onboarding02 = '/onboarding/02';
  static const onboarding03Fitness = '/onboarding/03';
  static const onboarding04Goals = '/onboarding/04';
  static const onboarding05Interests = '/onboarding/05';
  static const onboarding06CycleIntro = '/onboarding/cycle-intro';
  static const onboarding06Period = '/onboarding/period-start';
  static const onboarding07Duration = '/onboarding/period-duration';
  static const onboardingSuccess = '/onboarding/success';
  static const onboardingDone = '/onboarding/done';

  // ─────────────────────────────────────────────────────────────────────────
  // Dashboard
  // ─────────────────────────────────────────────────────────────────────────
  static const heute = '/heute';
  static const workoutDetail = '/workout/:id';
  static const trainingsOverview = '/trainings/overview';
  static const luviSync = '/luvi-sync';

  // ─────────────────────────────────────────────────────────────────────────
  // Cycle
  // ─────────────────────────────────────────────────────────────────────────
  static const cycleOverview = '/zyklus';

  // ─────────────────────────────────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────────────────────────────────
  static const profile = '/profil';

  // ─────────────────────────────────────────────────────────────────────────
  // Legal (In-App Fallback Routes)
  // ─────────────────────────────────────────────────────────────────────────
  static const legalPrivacy = '/legal/privacy';
  static const legalTerms = '/legal/terms';
}
