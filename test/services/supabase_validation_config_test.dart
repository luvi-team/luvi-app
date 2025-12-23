import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_services/supabase_service.dart';

void main() {
  group('SupabaseValidationConfig', () {
    test('defaults enforce cycle_data age bounds (16–120)', () {
      const config = SupabaseValidationConfig();
      expect(config.minAge, 16);
      expect(config.maxAge, 120);
    });

    test('preserves custom minAge and maxAge values', () {
      const config = SupabaseValidationConfig(minAge: 18, maxAge: 100);
      expect(config.minAge, 18);
      expect(config.maxAge, 100);
    });

    test('throws assertion error when minAge < 16', () {
      expect(
        () => SupabaseValidationConfig(minAge: 15),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error when maxAge > 120', () {
      expect(
        () => SupabaseValidationConfig(maxAge: 121),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error when minAge > maxAge', () {
      // Note: minAge == maxAge is allowed (e.g., a single valid age)
      // Only minAge > maxAge should throw
      expect(
        () => SupabaseValidationConfig(minAge: 60, maxAge: 50),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows minAge equal to maxAge', () {
      // This is valid - represents a single valid age value
      const config = SupabaseValidationConfig(minAge: 50, maxAge: 50);
      expect(config.minAge, 50);
      expect(config.maxAge, 50);
    });

    test('accepts boundary values (minAge=16, maxAge=120)', () {
      const config = SupabaseValidationConfig(minAge: 16, maxAge: 120);
      expect(config.minAge, 16);
      expect(config.maxAge, 120);
    });
  });
}

