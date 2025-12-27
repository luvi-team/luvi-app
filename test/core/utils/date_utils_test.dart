import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/utils/date_utils.dart';

void main() {
  group('calculateAge', () {
    test('returns correct age when birthday has passed this year', () {
      // Reference: Dec 23, 2025. Birth: Jan 15, 2000. Age = 25
      final reference = DateTime(2025, 12, 23);
      final birthDate = DateTime(2000, 1, 15);
      expect(calculateAge(birthDate, reference), 25);
    });

    test('returns correct age when birthday has not passed this year', () {
      // Reference: Jan 10, 2025. Birth: Mar 15, 2000. Age = 24 (not 25 yet)
      final reference = DateTime(2025, 1, 10);
      final birthDate = DateTime(2000, 3, 15);
      expect(calculateAge(birthDate, reference), 24);
    });

    test('returns correct age on exact birthday', () {
      // Reference: Mar 15, 2025. Birth: Mar 15, 2000. Age = 25
      final reference = DateTime(2025, 3, 15);
      final birthDate = DateTime(2000, 3, 15);
      expect(calculateAge(birthDate, reference), 25);
    });

    test('returns correct age day before birthday', () {
      // Reference: Mar 14, 2025. Birth: Mar 15, 2000. Age = 24
      final reference = DateTime(2025, 3, 14);
      final birthDate = DateTime(2000, 3, 15);
      expect(calculateAge(birthDate, reference), 24);
    });

    test('handles leap year birthday correctly', () {
      // Reference: Feb 28, 2025 (non-leap). Birth: Feb 29, 2000 (leap).
      // Legal interpretation: Feb 29 birthdays are celebrated on Feb 28 in
      // non-leap years. So on Feb 28, 2025, the birthday HAS occurred.
      final reference = DateTime(2025, 2, 28);
      final birthDate = DateTime(2000, 2, 29);
      expect(calculateAge(birthDate, reference), 25);
    });

    test('handles same month different day', () {
      // Reference: Mar 10, 2025. Birth: Mar 15, 2000. Age = 24
      final reference = DateTime(2025, 3, 10);
      final birthDate = DateTime(2000, 3, 15);
      expect(calculateAge(birthDate, reference), 24);
    });

    test('handles minimum age boundary (16 years)', () {
      // Reference: Dec 23, 2025. Birth: Dec 23, 2009. Age = 16 (exactly)
      final reference = DateTime(2025, 12, 23);
      final birthDate = DateTime(2009, 12, 23);
      expect(calculateAge(birthDate, reference), 16);
    });

    test('handles maximum age boundary (120 years)', () {
      // Reference: Dec 23, 2025. Birth: Dec 23, 1905. Age = 120
      final reference = DateTime(2025, 12, 23);
      final birthDate = DateTime(1905, 12, 23);
      expect(calculateAge(birthDate, reference), 120);
    });
  });
}
