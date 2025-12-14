import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';

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
      expect(isConsentRoute('/consent/02'), isTrue);
      expect(isConsentRoute('/consent/02/confirm'), isTrue);
    });

    test('ignores non-consent paths', () {
      expect(isConsentRoute('/consent-welcome'), isFalse);
      expect(isConsentRoute('/onboarding/consent'), isFalse);
    });
  });

  group('homeGuardRedirect (defense-in-depth for /heute)', () {
    test('redirects to Onboarding01 when hasCompletedOnboarding is false', () {
      final result = homeGuardRedirect(hasCompletedOnboarding: false);
      expect(
        result,
        equals(Onboarding01Screen.routeName),
        reason: 'Incomplete onboarding should redirect to Onboarding01',
      );
    });

    test('allows access when hasCompletedOnboarding is true', () {
      final result = homeGuardRedirect(hasCompletedOnboarding: true);
      expect(
        result,
        isNull,
        reason: 'Completed onboarding should allow access (null = no redirect)',
      );
    });

    test('allows access when hasCompletedOnboarding is null (unknown state)', () {
      final result = homeGuardRedirect(hasCompletedOnboarding: null);
      expect(
        result,
        isNull,
        reason: 'Unknown onboarding state should allow through (rely on normal flow)',
      );
    });

    test('never returns Home route (prevents redirect loop)', () {
      const homeRoute = '/heute';

      final falseResult = homeGuardRedirect(hasCompletedOnboarding: false);
      final trueResult = homeGuardRedirect(hasCompletedOnboarding: true);
      final nullResult = homeGuardRedirect(hasCompletedOnboarding: null);

      expect(falseResult, isNot(equals(homeRoute)));
      expect(trueResult, isNot(equals(homeRoute)));
      expect(nullResult, isNot(equals(homeRoute)));
    });
  });
}
