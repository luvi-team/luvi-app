import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';

/// Unit tests for the onboarding gate sync logic.
///
/// Tests the `determineOnboardingGateRoute` helper function which decides
/// navigation based on remote (server SSOT) and local state.
void main() {
  group('determineOnboardingGateRoute', () {
    const homeRoute = HeuteScreen.routeName;
    const onboardingRoute = Onboarding01Screen.routeName;

    group('Remote SSOT available (remote != null)', () {
      test('remote true → navigates to Home', () {
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(result, equals(homeRoute));
      });

      test('remote true takes priority over local false', () {
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(result, equals(homeRoute));
      });

      test('remote true takes priority over local true (consistent)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, equals(homeRoute));
      });

      test('remote false + local null → navigates to Onboarding01 (first-time user)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(result, equals(onboardingRoute));
      });

      test('remote false + local true → returns null (race-retry needed)', () {
        // This triggers race-retry logic in the caller
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });

      test('remote false + local false → navigates to Onboarding01 (consistent)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(result, equals(onboardingRoute));
      });
    });

    group('Remote unavailable (remote == null) - local fallback', () {
      test('remote null + local false → navigates to Onboarding01', () {
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(result, equals(onboardingRoute));
      });

      test('remote null + local true → returns null (fail-safe, never Home)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });

      test('remote null + local null → returns null (show Unknown UI)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });
    });

    group('Edge cases', () {
      test('uses provided homeRoute parameter', () {
        const customHome = '/custom-home';
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: null,
          homeRoute: customHome,
        );
        expect(result, equals(customHome));
      });

      test('returns Onboarding01 for first-time user scenarios', () {
        // Remote false + local null (first-time user)
        final firstTimeResult = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(firstTimeResult, equals(Onboarding01Screen.routeName));

        // Remote false + local false (consistent state)
        final consistentResult = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(consistentResult, equals(Onboarding01Screen.routeName));

        // Local false fallback (offline)
        final localResult = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(localResult, equals(Onboarding01Screen.routeName));
      });
    });

    group('Race-retry scenarios', () {
      test('local true + remote false → returns null (triggers race-retry)', () {
        // This scenario indicates potential race condition:
        // User completed onboarding locally but server hasn't synced yet
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });

      test('after race-retry: remote becomes true → would route to Home', () {
        // Simulates the case where server synced during the 500ms delay
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, equals(homeRoute));
      });

      test('after race-retry: remote still false → caller routes to Onboarding', () {
        // After race-retry, determineOnboardingGateRoute still returns null
        // But the caller (_navigateAfterAnimation) handles this case explicitly
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
        // Note: The actual routing to Onboarding happens in the caller
        // when it detects (targetRoute == null && remoteGate == false)
      });

      test('race-retry not triggered for first-time users', () {
        // First-time user: local null + remote false → direct Onboarding
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(result, equals(onboardingRoute));
      });

      test('race-retry not triggered when local is false', () {
        // Both agree user hasn't completed → direct Onboarding
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(result, equals(onboardingRoute));
      });
    });
  });

  group('determineTargetRoute - existing tests', () {
    // Ensure existing routing logic still works
    const defaultTarget = '/dashboard';
    const currentVersion = 1;

    test('unauth user always goes to AuthSignIn', () {
      final result = determineTargetRoute(
        isAuth: false,
        acceptedConsentVersion: currentVersion,
        currentConsentVersion: currentVersion,
        hasCompletedOnboarding: true,
        defaultTarget: defaultTarget,
      );
      expect(result, equals(AuthSignInScreen.routeName));
    });

    test('auth user with outdated consent goes to ConsentWelcome01', () {
      final result = determineTargetRoute(
        isAuth: true,
        acceptedConsentVersion: null,
        currentConsentVersion: currentVersion,
        hasCompletedOnboarding: true,
        defaultTarget: defaultTarget,
      );
      expect(result, equals(ConsentWelcome01Screen.routeName));
    });

    test('auth user with valid consent but no onboarding goes to Onboarding', () {
      final result = determineTargetRoute(
        isAuth: true,
        acceptedConsentVersion: currentVersion,
        currentConsentVersion: currentVersion,
        hasCompletedOnboarding: false,
        defaultTarget: defaultTarget,
      );
      expect(result, equals(Onboarding01Screen.routeName));
    });

    test('auth user with all gates passed goes to defaultTarget', () {
      final result = determineTargetRoute(
        isAuth: true,
        acceptedConsentVersion: currentVersion,
        currentConsentVersion: currentVersion,
        hasCompletedOnboarding: true,
        defaultTarget: defaultTarget,
      );
      expect(result, equals(defaultTarget));
    });
  });

  group('determineFallbackRoute - existing tests', () {
    test('unauth user goes to AuthSignIn', () {
      final result = determineFallbackRoute(isAuth: false);
      expect(result, equals(AuthSignInScreen.routeName));
    });

    test('auth user goes to ConsentWelcome01 (safe fallback)', () {
      final result = determineFallbackRoute(isAuth: true);
      expect(result, equals(ConsentWelcome01Screen.routeName));
    });
  });
}
