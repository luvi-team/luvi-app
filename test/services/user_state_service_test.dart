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

        expect(service.hasSeenWelcome, isFalse);
        expect(service.hasCompletedOnboarding, isFalse);
        expect(service.fitnessLevel, isNull);
      },
    );

    test('markWelcomeSeen sets flag to true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      await service.markWelcomeSeen();

      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isFalse);
    });

    test('markOnboardingComplete sets flag and fitness level', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

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

      await service.setFitnessLevel(FitnessLevel.fit);

      expect(service.fitnessLevel, FitnessLevel.fit);
      expect(prefs.getString('onboarding_fitness_level'), 'fit');
    });

    test(
      'markWelcomeSeen and markOnboardingComplete keep both flags true',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);

        await service.markWelcomeSeen();
        await service.markOnboardingComplete(fitnessLevel: FitnessLevel.fit);

        expect(service.hasSeenWelcome, isTrue);
        expect(service.hasCompletedOnboarding, isTrue);
        expect(service.fitnessLevel, FitnessLevel.fit);
      },
    );

    test('reset clears all flags and fitness level', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_welcome': true,
        'has_completed_onboarding': true,
        'onboarding_fitness_level': 'unknown',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = UserStateService(prefs: prefs);

      expect(service.hasSeenWelcome, isTrue);
      expect(service.hasCompletedOnboarding, isTrue);
      expect(service.fitnessLevel, FitnessLevel.unknown);

      await service.reset();

      expect(service.hasSeenWelcome, isFalse);
      expect(service.hasCompletedOnboarding, isFalse);
      expect(service.fitnessLevel, isNull);
    });

    test('flags persist across service instances', () async {
      final prefs = await SharedPreferences.getInstance();
      final first = UserStateService(prefs: prefs);
      await first.markWelcomeSeen();
      await first.setFitnessLevel(FitnessLevel.beginner);

      final second = UserStateService(prefs: prefs);
      expect(second.hasSeenWelcome, isTrue);
      expect(second.hasCompletedOnboarding, isFalse);
      expect(second.fitnessLevel, FitnessLevel.beginner);
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
      await first.markWelcomeSeen();
      await first.setFitnessLevel(FitnessLevel.beginner);

      final second = await container.read(userStateServiceProvider.future);

      expect(second.hasSeenWelcome, isTrue);
      expect(second.fitnessLevel, FitnessLevel.beginner);
    });
  });
}
