import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/domain/fitness_level.dart';
import 'package:luvi_app/features/onboarding/domain/goal.dart';
import 'package:luvi_app/features/onboarding/domain/interest.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';

void main() {
  group('OnboardingData.isComplete', () {
    // Base valid data that passes all checks
    OnboardingData validData() => OnboardingData(
          name: 'Test User',
          birthDate: DateTime(2000, 1, 15),
          fitnessLevel: FitnessLevel.beginner,
          selectedGoals: const [Goal.fitter],
          selectedInterests: const [
            Interest.strengthTraining,
            Interest.cardio,
            Interest.nutrition,
          ],
          periodStart: DateTime.now().subtract(const Duration(days: 7)),
        );

    test('returns false when name is null', () {
      // copyWith doesn't allow setting to null, so we create new instance
      final incompleteData = OnboardingData(
        name: null,
        birthDate: validData().birthDate,
        fitnessLevel: validData().fitnessLevel,
        selectedGoals: validData().selectedGoals,
        selectedInterests: validData().selectedInterests,
        periodStart: validData().periodStart,
      );
      expect(incompleteData.isComplete, isFalse);
    });

    test('returns false when name is empty string', () {
      final data = validData().copyWith(name: '');
      expect(data.isComplete, isFalse);
    });

    test('returns false when name is whitespace only', () {
      final data = validData().copyWith(name: '   ');
      // Defense-in-depth: isComplete now checks name!.trim().isNotEmpty
      // This ensures whitespace-only names are rejected even if
      // notifier.setName() trimming was somehow bypassed
      expect(data.name, '   ');
      expect(data.isComplete, isFalse);
    });

    test('returns false when birthDate is null', () {
      final incompleteData = OnboardingData(
        name: 'Test User',
        birthDate: null,
        fitnessLevel: validData().fitnessLevel,
        selectedGoals: validData().selectedGoals,
        selectedInterests: validData().selectedInterests,
        periodStart: validData().periodStart,
      );
      expect(incompleteData.isComplete, isFalse);
    });

    test('returns false when fitnessLevel is null', () {
      final incompleteData = OnboardingData(
        name: 'Test User',
        birthDate: validData().birthDate,
        fitnessLevel: null,
        selectedGoals: validData().selectedGoals,
        selectedInterests: validData().selectedInterests,
        periodStart: validData().periodStart,
      );
      expect(incompleteData.isComplete, isFalse);
    });

    test('returns false when selectedGoals is empty', () {
      final incompleteData = OnboardingData(
        name: 'Test User',
        birthDate: validData().birthDate,
        fitnessLevel: validData().fitnessLevel,
        selectedGoals: const [],
        selectedInterests: validData().selectedInterests,
        periodStart: validData().periodStart,
      );
      expect(incompleteData.isComplete, isFalse);
    });

    test('returns false when selectedInterests has fewer than 3 items', () {
      final incompleteData = OnboardingData(
        name: 'Test User',
        birthDate: validData().birthDate,
        fitnessLevel: validData().fitnessLevel,
        selectedGoals: validData().selectedGoals,
        selectedInterests: const [Interest.strengthTraining, Interest.cardio],
        periodStart: validData().periodStart,
      );
      expect(incompleteData.isComplete, isFalse);
    });

    test('returns true when periodStart is null (I don\'t remember case)', () {
      // periodStart is OPTIONAL to support "I don't remember" flow in O6
      final dataWithoutPeriod = OnboardingData(
        name: 'Test User',
        birthDate: validData().birthDate,
        fitnessLevel: validData().fitnessLevel,
        selectedGoals: validData().selectedGoals,
        selectedInterests: validData().selectedInterests,
        periodStart: null,
      );
      expect(dataWithoutPeriod.isComplete, isTrue);
    });

    test('returns true when all required fields are valid', () {
      final completeData = validData();
      expect(completeData.isComplete, isTrue);
    });

    test('returns true with exactly 3 interests (minimum)', () {
      final data = OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        periodStart: DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(data.selectedInterests.length, 3);
      expect(data.isComplete, isTrue);
    });

    test('returns true with exactly 5 interests (maximum)', () {
      final data = OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
          Interest.mobility,
          Interest.mindfulness,
        ],
        periodStart: DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(data.selectedInterests.length, 5);
      expect(data.isComplete, isTrue);
    });

    test('returns true with 6 interests (UI enforces max, not isComplete)', () {
      // Boundary test: >5 interests. isComplete only checks >= 3.
      // Max limit (5) is enforced by UI/notifier, not by OnboardingData.isComplete
      final data = OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
          Interest.mobility,
          Interest.mindfulness,
          Interest.hormonesCycle, // 6th - exceeds UI max
        ],
        periodStart: DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(data.selectedInterests.length, 6);
      // isComplete only checks >= 3, max is enforced by UI/notifier
      expect(data.isComplete, isTrue);
    });
  });

  group('OnboardingData.copyWith clearPeriodStart', () {
    test('copyWith can clear periodStart with clearPeriodStart flag', () {
      final data = OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        periodStart: DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(data.periodStart, isNotNull);

      final cleared = data.copyWith(clearPeriodStart: true);
      expect(cleared.periodStart, isNull);
      // Other fields should be preserved
      expect(cleared.name, equals('Test User'));
      expect(cleared.birthDate, isNotNull);
      expect(cleared.fitnessLevel, equals(FitnessLevel.beginner));
    });

    test('copyWith preserves periodStart when clearPeriodStart is false', () {
      final originalDate = DateTime.now().subtract(const Duration(days: 7));
      final data = OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        periodStart: originalDate,
      );

      final updated = data.copyWith(name: 'New Name');
      expect(updated.periodStart, equals(originalDate));
      expect(updated.name, equals('New Name'));
    });

    test('copyWith can set new periodStart value', () {
      final originalDate = DateTime.now().subtract(const Duration(days: 7));
      final newDate = DateTime.now().subtract(const Duration(days: 3));
      final data = OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        periodStart: originalDate,
      );

      final updated = data.copyWith(periodStart: newDate);
      expect(updated.periodStart, equals(newDate));
    });
  });
}
