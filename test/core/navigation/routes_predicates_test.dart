import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';

void main() {
  group('isOnboardingRoute', () {
    test('matches onboarding root and numbered steps', () {
      expect(isOnboardingRoute('/onboarding'), isTrue);
      expect(isOnboardingRoute('/onboarding/01'), isTrue);
      expect(isOnboardingRoute('/onboarding/08'), isTrue);
      expect(isOnboardingRoute('/onboarding/done'), isTrue);
      expect(isOnboardingRoute('/onboarding/success?from=login'), isTrue);
    });

    test('excludes welcome and unrelated routes', () {
      expect(isOnboardingRoute('/onboarding/w1'), isFalse);
      expect(isOnboardingRoute('/onboarding/welcome'), isFalse);
      expect(isOnboardingRoute('/auth/login'), isFalse);
    });
  });

  group('isWelcomeRoute', () {
    test('matches any onboarding welcome prefix', () {
      expect(isWelcomeRoute('/onboarding/w'), isTrue);
      expect(isWelcomeRoute('/onboarding/w1'), isTrue);
      expect(isWelcomeRoute('/onboarding/w2/extra'), isTrue);
    });

    test('rejects onboarding core routes', () {
      expect(isWelcomeRoute('/onboarding/01'), isFalse);
      expect(isWelcomeRoute('/auth/login'), isFalse);
    });
  });

  group('isConsentRoute', () {
    test('covers consent root and nested screens', () {
      expect(isConsentRoute('/consent'), isTrue);
      expect(isConsentRoute('/consent/intro'), isTrue);  // ConsentIntroScreen
      expect(isConsentRoute('/consent/02'), isTrue);     // Consent02Screen (legacy/test)
      expect(isConsentRoute('/consent/02/confirm'), isTrue);
    });

    test('ignores non-consent paths', () {
      expect(isConsentRoute('/consent-welcome'), isFalse);
      expect(isConsentRoute('/onboarding/consent'), isFalse);
    });
  });

  group('homeGuardRedirect (defense-in-depth for /heute)', () {
    group('when state is known (isStateKnown=true)', () {
      test('redirects to Onboarding01 when hasCompletedOnboarding is false', () {
        final result = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: false,
        );
        expect(
          result,
          equals(Onboarding01Screen.routeName),
          reason: 'Incomplete onboarding should redirect to Onboarding01',
        );
      });

      test('allows access when hasCompletedOnboarding is true', () {
        final result = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: true,
        );
        expect(
          result,
          isNull,
          reason: 'Completed onboarding should allow access (null = no redirect)',
        );
      });

      test('allows access when hasCompletedOnboarding is null but state known', () {
        // Edge case: state loaded but value is null (shouldn't happen in practice)
        final result = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: null,
        );
        expect(
          result,
          isNull,
          reason: 'When state is known, null should allow (defensive)',
        );
      });
    });

    group('when state is unknown (isStateKnown=false) - FAIL-SAFE', () {
      test('redirects to Splash with skipAnimation when state unknown', () {
        final result = homeGuardRedirect(
          isStateKnown: false,
          hasCompletedOnboarding: null,
        );
        expect(
          result,
          equals('${SplashScreen.routeName}?skipAnimation=true'),
          reason: 'Unknown state should fail-safe to Splash for gate re-check',
        );
      });

      test('redirects to Splash even if hasCompletedOnboarding claims false', () {
        // isStateKnown=false takes precedence - value is unreliable
        final result = homeGuardRedirect(
          isStateKnown: false,
          hasCompletedOnboarding: false,
        );
        expect(
          result,
          equals('${SplashScreen.routeName}?skipAnimation=true'),
          reason: 'Unknown state takes precedence over hasCompletedOnboarding',
        );
      });

      test('redirects to Splash even if hasCompletedOnboarding claims true', () {
        // isStateKnown=false takes precedence - value is unreliable
        final result = homeGuardRedirect(
          isStateKnown: false,
          hasCompletedOnboarding: true,
        );
        expect(
          result,
          equals('${SplashScreen.routeName}?skipAnimation=true'),
          reason: 'Unknown state takes precedence over hasCompletedOnboarding',
        );
      });
    });

    group('redirect loop prevention', () {
      test('never returns Home route (prevents redirect loop)', () {
        const homeRoute = '/heute';

        // Known state cases
        final falseResult = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: false,
        );
        final trueResult = homeGuardRedirect(
          isStateKnown: true,
          hasCompletedOnboarding: true,
        );
        // Unknown state case
        final unknownResult = homeGuardRedirect(
          isStateKnown: false,
          hasCompletedOnboarding: null,
        );

        expect(falseResult, isNot(equals(homeRoute)));
        expect(trueResult, isNot(equals(homeRoute)));
        expect(unknownResult, isNot(equals(homeRoute)));
      });
    });
  });

  group('homeGuardRedirectWithConsent (defense-in-depth with consent check)', () {
    final currentVersion = ConsentConfig.currentVersionInt;

    group('when state is unknown (isStateKnown=false) - FAIL-SAFE', () {
      test('redirects to Splash regardless of other values', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: false,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          equals('${SplashScreen.routeName}?skipAnimation=true'),
          reason: 'Unknown state should fail-safe to Splash',
        );
      });
    });

    group('consent gate (checked FIRST when state is known)', () {
      test('redirects to ConsentWelcome01 when acceptedConsentVersion is null', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true, // Even if onboarding complete
          acceptedConsentVersion: null,
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          equals(ConsentIntroScreen.routeName),
          reason: 'Null consent should redirect to consent flow',
        );
      });

      test('redirects to ConsentWelcome01 when consent version is outdated', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true, // Even if onboarding complete
          acceptedConsentVersion: currentVersion - 1, // Outdated
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          equals(ConsentIntroScreen.routeName),
          reason: 'Outdated consent should redirect to consent flow',
        );
      });

      test('proceeds to onboarding check when consent is current', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false, // Should redirect to onboarding
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          equals(Onboarding01Screen.routeName),
          reason: 'Current consent + incomplete onboarding → Onboarding01',
        );
      });
    });

    group('onboarding gate (checked AFTER consent)', () {
      test('redirects to Onboarding01 when hasCompletedOnboarding is false', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          equals(Onboarding01Screen.routeName),
          reason: 'Incomplete onboarding should redirect to Onboarding01',
        );
      });

      test('allows access when both consent and onboarding are complete', () {
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          isNull,
          reason: 'All gates passed should allow access',
        );
      });

      test('allows access when consent version is higher than current', () {
        // Edge case: user has future consent version (shouldn't happen, but be safe)
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: currentVersion + 1,
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          isNull,
          reason: 'Future consent version should allow access',
        );
      });
    });

    group('gate priority order', () {
      test('consent gate takes priority over onboarding gate', () {
        // Both gates would trigger, but consent should win
        final result = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false, // Would redirect to onboarding
          acceptedConsentVersion: null, // Would redirect to consent
          currentConsentVersion: currentVersion,
        );
        expect(
          result,
          equals(ConsentIntroScreen.routeName),
          reason: 'Consent gate should be checked before onboarding gate',
        );
      });
    });

    group('redirect loop prevention', () {
      test('never returns Home route (prevents redirect loop)', () {
        const homeRoute = '/heute';

        // All possible outcomes
        final unknownState = homeGuardRedirectWithConsent(
          isStateKnown: false,
          hasCompletedOnboarding: null,
          acceptedConsentVersion: null,
          currentConsentVersion: currentVersion,
        );
        final needsConsent = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: null,
          currentConsentVersion: currentVersion,
        );
        final needsOnboarding = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: false,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
        );
        final allPassed = homeGuardRedirectWithConsent(
          isStateKnown: true,
          hasCompletedOnboarding: true,
          acceptedConsentVersion: currentVersion,
          currentConsentVersion: currentVersion,
        );

        expect(unknownState, isNot(equals(homeRoute)));
        expect(needsConsent, isNot(equals(homeRoute)));
        expect(needsOnboarding, isNot(equals(homeRoute)));
        expect(allPassed, isNot(equals(homeRoute))); // null != '/heute'
      });
    });
  });
}
