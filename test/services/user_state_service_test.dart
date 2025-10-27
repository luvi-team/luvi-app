import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luvi_services/user_state_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserStateService', () {
    test('initial state returns false for both flags', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      expect(service.hasSeenWelcome, isFalse);
      expect(service.hasCompletedOnboarding, isFalse);
    });

    test('markWelcomeSeen sets flag to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      await service.markWelcomeSeen();

      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isFalse);
    });

    test('markOnboardingComplete sets flag to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      await service.markOnboardingComplete();

      expect(service.hasCompletedOnboarding, isTrue);
      expect(service.hasSeenWelcome, isFalse);
    });

    test('reset clears all flags', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_welcome': true,
        'has_completed_onboarding': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isTrue);

      await service.reset();

      expect(service.hasSeenWelcome, isFalse);
      expect(service.hasCompletedOnboarding, isFalse);
    });

    test('flags persist across service instances', () async {
      final prefs = await SharedPreferences.getInstance();
      final first = UserStateService(prefs: prefs);
      await first.markWelcomeSeen();

      final second = UserStateService(prefs: prefs);
      expect(second.hasSeenWelcome, isTrue);
      expect(second.hasCompletedOnboarding, isFalse);
    });
  });

  group('userStateServiceProvider', () {
    test('returns service instance', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = await container.read(userStateServiceProvider.future);

      expect(service.hasSeenWelcome, isFalse);
    });

    test('caches service instance', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = await container.read(userStateServiceProvider.future);
      final second = await container.read(userStateServiceProvider.future);

      expect(identical(first, second), isTrue);
    });
  });
}
