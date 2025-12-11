import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';

/// Unit tests for determineTargetRoute helper function.
///
/// These tests verify the critical routing logic for First-Time vs Returning users.
/// Extracted from SplashScreen for testability (Codex-Audit).
void main() {
  group('determineTargetRoute', () {
    const defaultTarget = '/dashboard';

    group('Unauthenticated users', () {
      test('redirects to AuthSignIn when not authenticated (hasSeenWelcome = null)', () {
        final result = determineTargetRoute(
          isAuth: false,
          hasSeenWelcomeMaybe: null,
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
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn regardless of welcome status',
        );
      });

      test('redirects to AuthSignIn when not authenticated (hasSeenWelcome = false)', () {
        final result = determineTargetRoute(
          isAuth: false,
          hasSeenWelcomeMaybe: false,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unauthenticated users should always go to AuthSignIn regardless of welcome status',
        );
      });
    });

    group('First-Time users (authenticated)', () {
      test('redirects to Consent when hasSeenWelcome is null (first-time user via OAuth)', () {
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: null,
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
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(ConsentWelcome01Screen.routeName),
          reason: 'First-time authenticated users (false) should go to Consent flow',
        );
      });
    });

    group('Returning users (authenticated)', () {
      test('redirects to defaultTarget when hasSeenWelcome is true (returning user)', () {
        final result = determineTargetRoute(
          isAuth: true,
          hasSeenWelcomeMaybe: true,
          defaultTarget: defaultTarget,
        );
        expect(
          result,
          equals(defaultTarget),
          reason: 'Returning authenticated users should go directly to Dashboard',
        );
      });
    });
  });
}
