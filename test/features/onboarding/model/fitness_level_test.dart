import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart' as app;
import 'package:luvi_services/user_state_service.dart' as services;

void main() {
  group('FitnessLevel cross-enum mapping', () {
    test('all app FitnessLevel values map to service FitnessLevel via tryParse', () {
      // Verify that every app.FitnessLevel can be mapped to services.FitnessLevel
      // This ensures the enums stay in sync between app and service layers
      for (final level in app.FitnessLevel.values) {
        final serviceLevel = services.FitnessLevel.tryParse(level.name);
        expect(
          serviceLevel,
          isNotNull,
          reason: 'app.FitnessLevel.${level.name} should map to services.FitnessLevel',
        );
        expect(
          serviceLevel!.name,
          level.name,
          reason: 'Mapped enum should have matching name',
        );
      }
    });

    test('tryParse returns null for unknown values (fallback safety)', () {
      // Verify that unknown values don't crash but return null
      expect(services.FitnessLevel.tryParse('unknown_value'), isNull);
      expect(services.FitnessLevel.tryParse(''), isNull);
      expect(services.FitnessLevel.tryParse(null), isNull);
    });

    test('service FitnessLevel has expected values', () {
      // Explicit check that service enum has the expected values
      expect(services.FitnessLevel.values, contains(services.FitnessLevel.beginner));
      expect(services.FitnessLevel.values, contains(services.FitnessLevel.occasional));
      expect(services.FitnessLevel.values, contains(services.FitnessLevel.fit));
    });

    test('app FitnessLevel has expected values', () {
      // Explicit check that app enum has the expected values
      expect(app.FitnessLevel.values, contains(app.FitnessLevel.beginner));
      expect(app.FitnessLevel.values, contains(app.FitnessLevel.occasional));
      expect(app.FitnessLevel.values, contains(app.FitnessLevel.fit));
    });

    test('app FitnessLevel.dbKey matches name for all values', () {
      // Verify dbKey extension returns the enum name (used for DB storage)
      for (final level in app.FitnessLevel.values) {
        expect(level.dbKey, level.name);
      }
    });
  });
}
