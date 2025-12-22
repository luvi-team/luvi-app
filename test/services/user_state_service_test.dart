import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luvi_services/user_state_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FitnessLevel', () {
    test('fromSelectionIndex maps UI order', () {
      expect(FitnessLevel.fromSelectionIndex(0), FitnessLevel.beginner);
      expect(FitnessLevel.fromSelectionIndex(1), FitnessLevel.occasional);
      expect(FitnessLevel.fromSelectionIndex(2), FitnessLevel.fit);

      expect(() => FitnessLevel.fromSelectionIndex(3), throwsRangeError);
    });

    test('selectionIndexFor returns expected indices', () {
      expect(FitnessLevel.selectionIndexFor(FitnessLevel.beginner), 0);
      expect(FitnessLevel.selectionIndexFor(FitnessLevel.occasional), 1);
      expect(FitnessLevel.selectionIndexFor(FitnessLevel.fit), 2);

      expect(FitnessLevel.selectionIndexFor(FitnessLevel.unknown), isNull);
      expect(FitnessLevel.selectionIndexFor(null), isNull);
    });

    test('tryParse returns null for unknown values', () {
      expect(FitnessLevel.tryParse(''), isNull);
      expect(FitnessLevel.tryParse('invalid'), isNull);
      expect(FitnessLevel.tryParse('fit'), FitnessLevel.fit);
    });
  });

  group('UserStateService', () {
    test(
      'initial state returns false for both flags and null fitness level',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        expect(service.hasSeenWelcome, isFalse);
        expect(service.hasCompletedOnboarding, isFalse);
        expect(service.hasCompletedOnboardingOrNull, isNull);
        expect(service.fitnessLevel, isNull);
      },
    );

    test(
      'hasCompletedOnboardingOrNull distinguishes unknown from false',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        expect(service.hasCompletedOnboardingOrNull, isNull);

        await service.setHasCompletedOnboarding(false);
        expect(service.hasCompletedOnboardingOrNull, isFalse);
        expect(service.hasCompletedOnboarding, isFalse);
      },
    );

    test(
      'setHasCompletedOnboarding(false) clears fitness level key',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        await service.setFitnessLevel(FitnessLevel.fit);
        expect(service.fitnessLevel, FitnessLevel.fit);

        await service.setHasCompletedOnboarding(false);
        expect(service.hasCompletedOnboarding, isFalse);
        expect(service.fitnessLevel, isNull);
        expect(prefs.containsKey('u:test-user:onboarding_fitness_level'), isFalse);
      },
    );

    test(
      'setHasCompletedOnboarding(true) persists explicit true',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        await service.setHasCompletedOnboarding(true);

        expect(service.hasCompletedOnboarding, isTrue);
        expect(service.hasCompletedOnboardingOrNull, isTrue);
      },
    );

    test('markWelcomeSeen sets flag to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);
      await service.bindUser('test-user');

      await service.markWelcomeSeen();

      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isFalse);
    });

    test('markOnboardingComplete sets flag and fitness level', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);
      await service.bindUser('test-user');

      await service.markOnboardingComplete(
        fitnessLevel: FitnessLevel.occasional,
      );

      expect(service.hasCompletedOnboarding, isTrue);
      expect(service.hasSeenWelcome, isFalse);
      expect(service.fitnessLevel, FitnessLevel.occasional);
    });

    test('setFitnessLevel persists selection', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);
      await service.bindUser('test-user');

      await service.setFitnessLevel(FitnessLevel.fit);

      expect(service.fitnessLevel, FitnessLevel.fit);
      expect(prefs.getString('u:test-user:onboarding_fitness_level'), 'fit');
    });

    test(
      'markWelcomeSeen and markOnboardingComplete keep both flags true',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        await service.markWelcomeSeen();
        await service.markOnboardingComplete(fitnessLevel: FitnessLevel.fit);

        expect(service.hasSeenWelcome, isTrue);
        expect(service.hasCompletedOnboarding, isTrue);
        expect(service.fitnessLevel, FitnessLevel.fit);
      },
    );

    test('reset clears all flags and fitness level', () async {
      SharedPreferences.setMockInitialValues({
        'u:test-user:has_seen_welcome': true,
        'u:test-user:has_completed_onboarding': true,
        'u:test-user:onboarding_fitness_level': 'unknown',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);
      await service.bindUser('test-user');

      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isTrue);
      expect(service.fitnessLevel, FitnessLevel.unknown);

      await service.reset();

      expect(service.hasSeenWelcome, isFalse);
      expect(service.hasCompletedOnboarding, isFalse);
      expect(service.hasCompletedOnboardingOrNull, isNull);
      expect(service.fitnessLevel, isNull);
    });

    test('flags persist across service instances', () async {
      final prefs = await SharedPreferences.getInstance();
      final first = UserStateService(prefs: prefs);
      await first.bindUser('test-user');
      await first.markWelcomeSeen();

      await first.setFitnessLevel(FitnessLevel.beginner);

      final second = UserStateService(prefs: prefs);
      await second.bindUser('test-user');
      expect(second.hasSeenWelcome, isTrue);
      expect(second.hasCompletedOnboarding, isFalse);

      expect(second.fitnessLevel, FitnessLevel.beginner);
    });

    test('bindUser clears previous user scoped gate keys (no cross-account leak)',
        () async {
      SharedPreferences.setMockInitialValues({
        'u:user-a:accepted_consent_version': 1,
        'u:user-a:has_seen_welcome': true,
        'u:user-a:has_completed_onboarding': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      await service.bindUser('user-a');
      expect(service.acceptedConsentVersionOrNull, 1);
      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isTrue);

      await service.bindUser('user-b');
      // New user sees a clean slate (must not inherit A's cache).
      expect(service.acceptedConsentVersionOrNull, isNull);
      expect(service.hasSeenWelcomeOrNull, isNull);
      expect(service.hasCompletedOnboardingOrNull, isNull);
      // Previous user's keys were cleared for privacy.
      expect(prefs.containsKey('u:user-a:accepted_consent_version'), isFalse);
      expect(prefs.containsKey('u:user-a:has_seen_welcome'), isFalse);
      expect(prefs.containsKey('u:user-a:has_completed_onboarding'), isFalse);
    });
  });

  group('userStateServiceProvider', () {
    test('returns service instance', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = await container.read(userStateServiceProvider.future);

      expect(service.hasSeenWelcome, isFalse);
      expect(service.fitnessLevel, isNull);
    });

    test('reuses shared preferences across reads', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = await container.read(userStateServiceProvider.future);
      await first.bindUser('test-user');
      await first.markWelcomeSeen();
      await first.setFitnessLevel(FitnessLevel.beginner);

      final second = await container.read(userStateServiceProvider.future);
      await second.bindUser('test-user');

      expect(second.hasSeenWelcome, isTrue);
      expect(second.fitnessLevel, FitnessLevel.beginner);
    });
  });
}
