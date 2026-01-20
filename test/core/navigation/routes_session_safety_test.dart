import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/route_query_params.dart';
import 'package:luvi_app/core/navigation/routes.dart';
import 'package:luvi_app/core/privacy/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';

import '../../support/test_config.dart';

/// Tests for session safety and defensive redirect behavior.
///
/// Note: supabaseRedirectWithSession requires BuildContext and GoRouterState,
/// making it complex to unit test. The session access try-catch added in Fix 6
/// ensures resilience when SupabaseService throws unexpectedly.
///
/// These tests verify the related homeGuardRedirect function which uses
/// similar defensive patterns and is more easily unit-testable.
void main() {
  TestConfig.ensureInitialized();

  group('homeGuardRedirect session safety', () {
    test(
      'redirects to splash when state is unknown (fail-safe)',
      () {
        // When state is unknown, redirect to splash for re-evaluation
        // This is the fail-safe behavior when session state is uncertain
        final redirect = homeGuardRedirect(
          isStateKnown: false,
          hasCompletedOnboarding: null,
        );

        expect(redirect, '${SplashScreen.routeName}?${RouteQueryParams.skipAnimationTrueQuery}');
      },
    );

    test(
      'allows access when state is known and onboarding complete',
      () {
        // When state is known and onboarding is complete, allow access
        final redirect = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: true,
        );

        // null = no redirect, access allowed
        expect(redirect, isNull);
      },
    );

    test(
      'redirects to onboarding when state known but not completed',
      () {
        // When state is known but onboarding not complete, redirect to onboarding
        final redirect = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: false,
        );

        expect(redirect, Onboarding01Screen.routeName);
      },
    );

    test(
      'handles null hasCompletedOnboarding defensively when state known',
      () {
        // Edge case: state is known but value is null
        // Should allow access defensively (fail-open for known state)
        final redirect = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: null,
        );

        // null = no redirect, defensive allow
        expect(redirect, isNull);
      },
    );
  });

  group('homeGuardRedirectWithConsent session safety', () {
    test(
      'redirects to splash when state unknown regardless of consent',
      () {
        // State unknown = fail-safe to splash
        final redirect = homeGuardRedirectWithConsent(
          isStateKnown: false,
          hasCompletedOnboarding: null,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(redirect, '${SplashScreen.routeName}?${RouteQueryParams.skipAnimationTrueQuery}');
      },
    );

    test(
      'redirects to consent when version outdated',
      () {
        // State known, onboarding complete, but consent outdated
        final redirect = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: 0, // Outdated
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        // Should redirect to consent welcome screen
        expect(redirect, ConsentIntroScreen.routeName);
      },
    );

    test(
      'allows access when state known, onboarding complete, consent current',
      () {
        // All requirements met
        final redirect = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: ConsentConfig.currentVersionInt,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        // null = no redirect, access allowed
        expect(redirect, isNull);
      },
    );
  });
}
