import 'package:flutter_test/flutter_test.dart';

import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/routes.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';

import '../../support/test_config.dart';

/// Unit tests for post-auth route guard bypass prevention.
///
/// These tests verify that deep-links to post-auth routes (workout, trainings,
/// cycle, profile) are properly guarded against bypass attacks.
///
/// The guard logic is tested via [homeGuardRedirectWithConsent] which is
/// the same function used by [_postAuthGuard] in router.dart.
void main() {
  TestConfig.ensureInitialized();

  group('Post-Auth Guard Bypass Prevention', () {
    group('consent gate', () {
      test('deep link without consent redirects to consent intro', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: null, // No consent
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.consentIntro),
          reason: 'Missing consent should redirect to consent intro',
        );
      });

      test('deep link with outdated consent redirects to consent intro', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: ConsentConfig.currentVersionInt - 1,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.consentIntro),
          reason: 'Outdated consent should redirect to consent intro',
        );
      });
    });

    group('onboarding gate', () {
      test('deep link without onboarding redirects to onboarding', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: ConsentConfig.currentVersionInt,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.onboarding01),
          reason: 'Incomplete onboarding should redirect to onboarding',
        );
      });
    });

    group('fail-safe gate', () {
      test('deep link with loading state redirects to splash', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: false,
          hasCompletedOnboarding: null,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals('${RoutePaths.splash}?skipAnimation=true'),
          reason: 'Unknown state should fail-safe to splash',
        );
      });
    });

    group('access granted', () {
      test('deep link with all gates passed allows access', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: ConsentConfig.currentVersionInt,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          isNull,
          reason: 'All gates passed should allow access (null = no redirect)',
        );
      });
    });

    group('gate priority order', () {
      test('consent check happens before onboarding check', () {
        // User has neither consent nor onboarding
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: null, // Missing consent
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.consentIntro),
          reason: 'Consent should be checked before onboarding',
        );
      });

      test('fail-safe takes priority over consent and onboarding', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: false, // Unknown state
          hasCompletedOnboarding: false,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals('${RoutePaths.splash}?skipAnimation=true'),
          reason: 'Fail-safe should take priority over other gates',
        );
      });
    });

    group('error state handling', () {
      test('error state redirects to splash (same as unknown state)', () {
        // When userStateServiceProvider is in AsyncValue.error state,
        // _postAuthGuard handles it by:
        // 1. Logging with log.w('post_auth_guard_state_error', ...)
        // 2. Returning splash?skipAnimation=true (fail-safe)
        //
        // This is consistent with _onboardingConsentGuard behavior.
        // The guard logic treats error as isStateKnown=false.
        final result = homeGuardRedirectWithConsent(
          isStateKnown: false, // Error state → isStateKnown=false
          hasCompletedOnboarding: null,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals('${RoutePaths.splash}?skipAnimation=true'),
          reason: 'Error state should fail-safe to splash (same as loading)',
        );
      });
    });
  });
}
