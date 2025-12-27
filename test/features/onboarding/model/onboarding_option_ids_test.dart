import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart';
import 'package:luvi_app/features/onboarding/model/goal.dart';
import 'package:luvi_app/features/onboarding/model/interest.dart';
import 'package:luvi_app/features/onboarding/model/onboarding_option_ids.dart';

void main() {
  group('Onboarding option IDs (profiles SSOT)', () {
    test('FitnessLevel IDs are canonical and stable', () {
      final ids = FitnessLevel.values.map((e) => e.id).toSet();
      expect(ids, FitnessLevelIds.values);
      expect(ids.any((e) => e.contains(RegExp(r'\s'))), isFalse);
    });

    test('Goal IDs are canonical and stable', () {
      final ids = Goal.values.map((e) => e.id).toSet();
      expect(ids, GoalIds.values);
      expect(ids.any((e) => e.contains(RegExp(r'\s'))), isFalse);
    });

    test('Interest IDs are canonical and stable (snake_case)', () {
      final ids = Interest.values.map((e) => e.id).toSet();
      expect(ids, InterestIds.values);
      expect(ids.any((e) => e.contains(RegExp(r'\s'))), isFalse);
      expect(ids.any((e) => e.contains(RegExp(r'[A-Z]'))), isFalse);
    });

    test('Legacy values are canonicalized safely', () {
      expect(GoalExtension.fromDbKey('well_being'), Goal.wellbeing);
      expect(GoalExtension.fromDbKey('SLEEP'), Goal.sleep);

      expect(
        InterestExtension.fromKey('strengthTraining'),
        Interest.strengthTraining,
      );
      expect(
        InterestExtension.fromKey('hormonesCycle'),
        Interest.hormonesCycle,
      );
    });

    test('Unknown stored values map to null', () {
      expect(FitnessLevelExtension.fromStoredId('something_else'), isNull);
      expect(GoalExtension.fromDbKey('something_else'), isNull);
      expect(InterestExtension.fromKey('something_else'), isNull);
    });
  });
}
