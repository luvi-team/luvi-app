import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/routes.dart';

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
      expect(isConsentRoute('/consent/01'), isTrue);
      expect(isConsentRoute('/consent/02/confirm'), isTrue);
    });

    test('ignores non-consent paths', () {
      expect(isConsentRoute('/consent-welcome'), isFalse);
      expect(isConsentRoute('/onboarding/consent'), isFalse);
    });
  });
}
