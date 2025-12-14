import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';

/// Unit tests for determineTargetRoute helper function.
///
/// These tests verify the critical routing logic for First-Time vs Returning users.
/// Extracted from SplashScreen for testability (Codex-Audit).
///
/// Gate Logic (Priority Order):
/// 1. Not authenticated → AuthSignInScreen
/// 2. Authenticated + hasSeenWelcome != true → ConsentWelcome01Screen (Welcome/Consent)
/// 3. Authenticated + hasSeenWelcome == true + hasCompletedOnboarding == false → Onboarding01
/// 4. Authenticated + hasSeenWelcome == true + hasCompletedOnboarding == true → defaultTarget
void main() {
  group('determineTargetRoute', () {
    const defaultTarget = '/dashboard';

    group('Unauthenticated users', () {
      test('redirects to AuthSignIn when not authenticated (hasSeenWelcome = null)', () {
        final result = determineTargetRoute(
          isAuth: false,
          hasSeenWelcomeMaybe: null,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn',
        );
      });

      test('redirects to AuthSignIn when not authenticated (hasSeenWelcome = true)', () {
        final result = determineTargetRoute(
          isAuth: false,
          hasSeenWelcomeMaybe: true,
          hasCompletedOnboarding: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn regardless of welcome/onboarding status',
        );
      });

      test('redirects to AuthSignIn when not authenticated (hasSeenWelcome = false)', () {
        final result = determineTargetRoute(
          isAuth: false,
          hasSeenWelcomeMaybe: false,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn regardless of welcome status',
        );
      });
    });

    group('First-Time users (authenticated, needs Welcome/Consent)', () {
      test('redirects to Consent when hasSeenWelcome is null (first-time user via OAuth)', () {
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: null,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentWelcome01Screen.routeName),
          reason: 'First-time authenticated users (null) should go to Consent flow',
        );
      });

      test('redirects to Consent when hasSeenWelcome is false (first-time user via Email)', () {
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: false,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentWelcome01Screen.routeName),
          reason: 'First-time authenticated users (false) should go to Consent flow',
        );
      });
    });

    group('Onboarding Gate (authenticated, completed Welcome, needs Onboarding)', () {
      test('redirects to Onboarding when hasSeenWelcome=true but hasCompletedOnboarding=false', () {
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: true,
          hasCompletedOnboarding: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(Onboarding01Screen.routeName),
          reason: 'Users who completed Welcome/Consent but not Onboarding should go to Onboarding',
        );
      });

      test('Onboarding Gate takes precedence over Dashboard for incomplete onboarding', () {
        // This test ensures that even if hasSeenWelcome is true,
        // the user cannot bypass Onboarding by going directly to Dashboard
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: true,
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
          hasSeenWelcomeMaybe: true,
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
          hasSeenWelcomeMaybe: true,
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
      test('Welcome Gate takes priority over Onboarding Gate', () {
        // Even if hasCompletedOnboarding is true, if hasSeenWelcome is null/false,
        // user should go to Welcome (this is an edge case that shouldn't occur in practice)
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: null,
          hasCompletedOnboarding: true, // Edge case: this shouldn't happen in practice
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentWelcome01Screen.routeName),
          reason: 'Welcome Gate should take priority over Onboarding completion status',
        );
      });
    });
  });
}
