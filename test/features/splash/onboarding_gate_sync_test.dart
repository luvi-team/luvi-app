import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';

// Point 11: Module-level test constants for route assertions
const _testHomeRoute = HeuteScreen.routeName;
const _testOnboardingRoute = Onboarding01Screen.routeName;
const _testDefaultTarget = '/dashboard';
const _testCurrentVersion = 1;

/// Unit tests for the onboarding gate sync logic.
///
/// Tests the `determineOnboardingGateRoute` helper function which decides
/// navigation based on remote (server SSOT) and local state.
void main() {
  group('determineOnboardingGateRoute', () {

    group('Remote SSOT available (remote != null)', () {
      test('remote true → navigates to Home', () {
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: null,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testHomeRoute));
      });

      test('remote true takes priority over local false', () {
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: false,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testHomeRoute));
      });

      test('remote true takes priority over local true (consistent)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: true,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testHomeRoute));
      });

      test('remote false + local null → navigates to Onboarding01 (first-time user)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: null,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testOnboardingRoute));
      });

      test('remote false + local true → returns null (race-retry needed)', () {
        // This triggers race-retry logic in the caller
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: true,
          homeRoute: _testHomeRoute,
        );
        expect(result, isNull);
      });

      test('remote false + local false → navigates to Onboarding01 (consistent)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: false,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testOnboardingRoute));
      });
    });

    group('Remote unavailable (remote == null) - local fallback', () {
      test('remote null + local false → navigates to Onboarding01', () {
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: false,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testOnboardingRoute));
      });

      test('remote null + local true → returns null (fail-safe, never Home)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: true,
          homeRoute: _testHomeRoute,
        );
        expect(result, isNull);
      });

      test('remote null + local null → returns null (triggers _showUnknownUI with retry prompt)', () {
        // When both remote and local are null, the function returns null.
        // The caller (SplashScreen) then shows the Unknown UI with:
        // - Retry button to attempt navigation again
        // - Sign out button to clear state and restart
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: null,
          homeRoute: _testHomeRoute,
        );
        expect(result, isNull, reason: 'null signals caller to show Unknown UI');
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

      // Point 9: Split combined test into three separate tests for better failure isolation
      test('returns Onboarding01 when remote false and local null (first-time user)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: null,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(Onboarding01Screen.routeName));
      });

      test('returns Onboarding01 when remote false and local false (consistent state)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: false,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(Onboarding01Screen.routeName));
      });

      test('returns Onboarding01 when remote null and local false (offline fallback)', () {
        final result = determineOnboardingGateRoute(
          remoteGate: null,
          localGate: false,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(Onboarding01Screen.routeName));
      });
    });

    group('Race-retry scenarios', () {
      test('local true + remote false → returns null (triggers race-retry)', () {
        // This scenario indicates potential race condition:
        // User completed onboarding locally but server hasn't synced yet
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: true,
          homeRoute: _testHomeRoute,
        );
        expect(result, isNull);
      });

      test('after race-retry: remote becomes true → would route to Home', () {
        // Simulates the case where server synced during the 500ms delay
        final result = determineOnboardingGateRoute(
          remoteGate: true,
          localGate: true,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testHomeRoute));
      });

      test('after race-retry: remote still false → caller routes to Onboarding', () {
        // After race-retry, determineOnboardingGateRoute still returns null
        // But the caller (_navigateAfterAnimation) handles this case explicitly
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: true,
          homeRoute: _testHomeRoute,
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
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testOnboardingRoute));
      });

      test('race-retry not triggered when local is false', () {
        // Both agree user hasn't completed → direct Onboarding
        final result = determineOnboardingGateRoute(
          remoteGate: false,
          localGate: false,
          homeRoute: _testHomeRoute,
        );
        expect(result, equals(_testOnboardingRoute));
      });
    });
  });

  group('determineTargetRoute - existing tests', () {
    // Ensure existing routing logic still works
    test('unauth user always goes to AuthSignIn', () {
      final result = determineTargetRoute(
        isAuth: false,
        acceptedConsentVersion: _testCurrentVersion,
        currentConsentVersion: _testCurrentVersion,
        hasCompletedOnboarding: true,
        defaultTarget: _testDefaultTarget,
      );
      expect(result, equals(AuthSignInScreen.routeName));
    });

    test('auth user with outdated consent goes to ConsentWelcome01', () {
      final result = determineTargetRoute(
        isAuth: true,
        acceptedConsentVersion: null,
        currentConsentVersion: _testCurrentVersion,
        hasCompletedOnboarding: true,
        defaultTarget: _testDefaultTarget,
      );
      expect(result, equals(ConsentWelcome01Screen.routeName));
    });

    test('auth user with valid consent but no onboarding goes to Onboarding', () {
      final result = determineTargetRoute(
        isAuth: true,
        acceptedConsentVersion: _testCurrentVersion,
        currentConsentVersion: _testCurrentVersion,
        hasCompletedOnboarding: false,
        defaultTarget: _testDefaultTarget,
      );
      expect(result, equals(Onboarding01Screen.routeName));
    });

    test('auth user with all gates passed goes to defaultTarget', () {
      final result = determineTargetRoute(
        isAuth: true,
        acceptedConsentVersion: _testCurrentVersion,
        currentConsentVersion: _testCurrentVersion,
        hasCompletedOnboarding: true,
        defaultTarget: _testDefaultTarget,
      );
      expect(result, equals(_testDefaultTarget));
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
