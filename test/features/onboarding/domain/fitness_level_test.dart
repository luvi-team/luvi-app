import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_services/user_state_service.dart';

void main() {
  group('FitnessLevel.tryParse', () {
    test('returns null for unknown values', () {
      expect(FitnessLevel.tryParse('unknown_value'), isNull);
    });

    test('parses beginner correctly', () {
      expect(FitnessLevel.tryParse('beginner'), FitnessLevel.beginner);
    });

    test('parses occasional correctly', () {
      expect(FitnessLevel.tryParse('occasional'), FitnessLevel.occasional);
    });

    test('parses fit correctly', () {
      expect(FitnessLevel.tryParse('fit'), FitnessLevel.fit);
    });
  });
}
