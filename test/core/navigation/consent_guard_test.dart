import 'package:flutter_test/flutter_test.dart';

import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/routes.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';

import '../../support/test_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

/// Unit tests for consent-related redirect guards.
///
/// Tests cover:
/// - homeGuardRedirectWithConsent: Redirects to ConsentIntro when consent missing/outdated
/// - homeGuardRedirectWithConsent: Returns null (allow) when consent is current
/// - homeGuardRedirectWithConsent: Returns Splash fail-safe when state unknown
void main() {
  TestConfig.ensureInitialized();

  group('homeGuardRedirectWithConsent', () {
    group('consent version check', () {
      test('redirects to ConsentIntro when acceptedConsentVersion is null', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.consentIntro),
          reason: 'Should redirect to ConsentIntro when no consent accepted',
        );
      });

      test('redirects to ConsentIntro when consent version is outdated', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: ConsentConfig.currentVersionInt - 1,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.consentIntro),
          reason: 'Should redirect to ConsentIntro when consent is outdated',
        );
      });

      test('allows access when consent version is current', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: ConsentConfig.currentVersionInt,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          isNull,
          reason: 'Should allow access when consent version is current',
        );
      });

      test('allows access when consent version is newer than required', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: ConsentConfig.currentVersionInt + 1,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          isNull,
          reason: 'Should allow access when user has newer consent version',
        );
      });
    });

    group('fail-safe behavior', () {
      test('redirects to Splash with skipAnimation when state is unknown', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: false,
          hasCompletedOnboarding: null,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals('${RoutePaths.splash}?skipAnimation=true'),
          reason: 'Should redirect to Splash fail-safe when state unknown',
        );
      });

      test('fail-safe takes priority over consent check', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: false,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: null,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals('${RoutePaths.splash}?skipAnimation=true'),
          reason: 'State unknown should redirect to Splash, not ConsentIntro',
        );
      });
    });

    group('onboarding check (after consent)', () {
      test('redirects to Onboarding01 when onboarding incomplete', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: ConsentConfig.currentVersionInt,
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.onboarding01),
          reason: 'Should redirect to Onboarding01 when onboarding incomplete',
        );
      });

      test('consent check happens before onboarding check', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: null, // Missing consent
          currentConsentVersion: ConsentConfig.currentVersionInt,
        );

        expect(
          result,
          equals(RoutePaths.consentIntro),
          reason: 'Consent check should happen before onboarding check',
        );
      });
    });

    group('gate priority order', () {
      test('priority: state unknown > consent > onboarding', () {
        // 1. State unknown
        expect(
          homeGuardRedirectWithConsent(
            isStateKnown: false,
            hasCompletedOnboarding: false,
            acceptedConsentVersion: null,
            currentConsentVersion: 1,
          ),
          equals('${RoutePaths.splash}?skipAnimation=true'),
        );

        // 2. Consent missing (state known)
        expect(
          homeGuardRedirectWithConsent(
            isStateKnown: true,
            hasCompletedOnboarding: false,
            acceptedConsentVersion: null,
            currentConsentVersion: 1,
          ),
          equals(RoutePaths.consentIntro),
        );

        // 3. Onboarding incomplete (consent valid)
        expect(
          homeGuardRedirectWithConsent(
            isStateKnown: true,
            hasCompletedOnboarding: false,
            acceptedConsentVersion: 1,
            currentConsentVersion: 1,
          ),
          equals(RoutePaths.onboarding01),
        );

        // 4. All gates passed
        expect(
          homeGuardRedirectWithConsent(
            isStateKnown: true,
            hasCompletedOnboarding: true,
            acceptedConsentVersion: 1,
            currentConsentVersion: 1,
          ),
          isNull,
        );
      });
    });
  });

  group('homeGuardRedirect (legacy)', () {
    test('redirects to Splash fail-safe when state unknown', () {
      final result = homeGuardRedirect(
        isStateKnown: false,
        hasCompletedOnboarding: null,
      );

      expect(result, equals('${RoutePaths.splash}?skipAnimation=true'));
    });

    test('redirects to Onboarding01 when onboarding incomplete', () {
      final result = homeGuardRedirect(
        isStateKnown: true,
        hasCompletedOnboarding: false,
      );

      expect(result, equals(RoutePaths.onboarding01));
    });

    test('allows access when onboarding complete', () {
      final result = homeGuardRedirect(
        isStateKnown: true,
        hasCompletedOnboarding: true,
      );

      expect(result, isNull);
    });
  });

  group('isOnboardingRoute predicate', () {
    test('returns true for onboarding routes', () {
      expect(isOnboardingRoute('/onboarding/01'), isTrue);
      expect(isOnboardingRoute('/onboarding/02'), isTrue);
      expect(isOnboardingRoute('/onboarding/success'), isTrue);
      expect(isOnboardingRoute('/onboarding/done'), isTrue);
    });

    test('returns false for welcome routes (not onboarding)', () {
      expect(isOnboardingRoute('/onboarding/w1'), isFalse);
      expect(isOnboardingRoute('/onboarding/w5'), isFalse);
    });

    test('returns false for non-onboarding routes', () {
      expect(isOnboardingRoute('/welcome'), isFalse);
      expect(isOnboardingRoute('/auth/signin'), isFalse);
      expect(isOnboardingRoute('/heute'), isFalse);
    });

    test('returns false for edge cases (empty, root paths)', () {
      expect(isOnboardingRoute(''), isFalse);
      expect(isOnboardingRoute('/'), isFalse);
      // Note: '/onboarding' correctly returns true (base onboarding path matches)
    });
  });

  group('isWelcomeRoute predicate', () {
    test('returns true for new /welcome route', () {
      expect(isWelcomeRoute('/welcome'), isTrue);
    });

    test('returns true for legacy /onboarding/w* routes', () {
      expect(isWelcomeRoute('/onboarding/w1'), isTrue);
      expect(isWelcomeRoute('/onboarding/w5'), isTrue);
    });

    test('returns true for ALL legacy /onboarding/w* routes (w1-w5)', () {
      // Explicit test for each route to catch router config omissions
      for (final screen in ['w1', 'w2', 'w3', 'w4', 'w5']) {
        expect(
          isWelcomeRoute('/onboarding/$screen'),
          isTrue,
          reason: '/onboarding/$screen should be recognized as welcome route',
        );
      }
    });

    test('returns false for onboarding routes', () {
      expect(isWelcomeRoute('/onboarding/01'), isFalse);
      expect(isWelcomeRoute('/onboarding/success'), isFalse);
    });

    test('returns false for other routes', () {
      expect(isWelcomeRoute('/auth/signin'), isFalse);
      expect(isWelcomeRoute('/heute'), isFalse);
    });
  });

  group('isConsentRoute predicate', () {
    test('returns true for consent routes', () {
      expect(isConsentRoute('/consent'), isTrue);
      expect(isConsentRoute('/consent/intro'), isTrue);
      expect(isConsentRoute('/consent/options'), isTrue);
      expect(isConsentRoute('/consent/blocking'), isTrue);
      expect(isConsentRoute('/consent/02'), isTrue); // legacy
    });

    test('returns false for non-consent routes', () {
      expect(isConsentRoute('/welcome'), isFalse);
      expect(isConsentRoute('/onboarding/01'), isFalse);
      expect(isConsentRoute('/auth/signin'), isFalse);
    });
  });
}
