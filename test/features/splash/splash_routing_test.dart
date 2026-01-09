import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';

/// Unit tests for determineTargetRoute helper function.
///
/// These tests verify the critical routing logic for First-Time vs Returning users.
/// Extracted from SplashScreen for testability (Codex-Audit).
///
/// Gate Logic (Priority Order):
/// 1. Not authenticated → AuthSignInScreen
/// 2. Authenticated + needs consent (null or outdated version) → ConsentIntroScreen
/// 3. Authenticated + consent OK + hasCompletedOnboarding == false → Onboarding01
/// 4. Authenticated + consent OK + hasCompletedOnboarding == true → defaultTarget
void main() {
  group('determineTargetRoute', () {
    const defaultTarget = '/dashboard';
    const currentVersion = 1;

    group('Unauthenticated users', () {
      test('redirects to AuthSignIn when not authenticated (consent null)', () {
        final result = determineTargetRoute(
          isAuth: false,
          acceptedConsentVersion: null,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn',
        );
      });

      test('redirects to AuthSignIn when not authenticated (consent accepted)', () {
        final result = determineTargetRoute(
          isAuth: false,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn regardless of consent/onboarding status',
        );
      });
    });

    group('Consent-Version Gate', () {
      test('needs consent when acceptedVersion is null', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: null,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentIntroScreen.routeName),
          reason: 'First-time users (null consent) should go to Consent flow',
        );
      });

      test('needs consent when acceptedVersion < currentVersion', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: 1,
          currentConsentVersion: 2, // Version erhöht
          hasCompletedOnboarding: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentIntroScreen.routeName),
          reason: 'Outdated consent version should trigger Consent flow',
        );
      });

      test('skips consent when acceptedVersion == currentVersion', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(defaultTarget),
          reason: 'Current consent version should skip Consent flow',
        );
      });

      test('skips consent when acceptedVersion > currentVersion (edge case)', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: 2,
          currentConsentVersion: 1,
          hasCompletedOnboarding: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(defaultTarget),
          reason: 'Higher consent version should skip Consent flow',
        );
      });
    });

    group('Onboarding Gate (authenticated, consent OK, needs Onboarding)', () {
      test('redirects to Onboarding when consent OK but hasCompletedOnboarding=false', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(Onboarding01Screen.routeName),
          reason: 'Users who completed Consent but not Onboarding should go to Onboarding',
        );
      });

      test('Onboarding Gate takes precedence over Dashboard for incomplete onboarding', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: false,
          defaultTarget: '/heute',
        );
        expect(
          result,
          equals(Onboarding01Screen.routeName),
          reason: 'Onboarding Gate must block Dashboard access until Onboarding is complete',
        );
      });
    });

    group('Returning users (authenticated, completed all flows)', () {
      test('redirects to defaultTarget when all gates passed (returning user)', () {
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(defaultTarget),
          reason: 'Returning authenticated users with completed onboarding should go to Dashboard',
        );
      });

      test('uses custom defaultTarget when provided', () {
        const customTarget = '/custom-dashboard';
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: true,
          defaultTarget: customTarget,
        );
        expect(
          result,
          equals(customTarget),
          reason: 'Should respect custom defaultTarget parameter',
        );
      });
    });

    group('Edge Cases', () {
      test('Consent Gate takes priority over Onboarding Gate', () {
        // Even if hasCompletedOnboarding is true, if consent is null/outdated,
        // user should go to Consent
        final result = determineTargetRoute(
          isAuth: true,
          acceptedConsentVersion: null,
          currentConsentVersion: currentVersion,
          hasCompletedOnboarding: true, // Edge case: this shouldn't happen in practice
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentIntroScreen.routeName),
          reason: 'Consent Gate should take priority over Onboarding completion status',
        );
      });
    });
  });

  group('determineFallbackRoute (fail-safe on state load error)', () {
    test('redirects to AuthSignIn when not authenticated', () {
      final result = determineFallbackRoute(isAuth: false);
      expect(
        result,
        equals(AuthSignInScreen.routeName),
        reason: 'Unauthenticated users should go to AuthSignIn on error',
      );
    });

    test('redirects to ConsentIntro when authenticated (NOT Home)', () {
      final result = determineFallbackRoute(isAuth: true);
      expect(
        result,
        equals(ConsentIntroScreen.routeName),
        reason:
            'Authenticated users should go to ConsentIntro on error, never directly to Home',
      );
    });

    test('never returns Home route on error (fail-safe guarantee)', () {
      // Test both auth states to ensure Home is never returned
      const homeRoute = '/heute';

      final unauthResult = determineFallbackRoute(isAuth: false);
      final authResult = determineFallbackRoute(isAuth: true);

      expect(
        unauthResult,
        isNot(equals(homeRoute)),
        reason: 'Fallback should never return Home route (unauthenticated)',
      );
      expect(
        authResult,
        isNot(equals(homeRoute)),
        reason: 'Fallback should never return Home route (authenticated)',
      );
    });
  });
}
