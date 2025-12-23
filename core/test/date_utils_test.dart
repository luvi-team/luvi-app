import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_core/luvi_core.dart';

void main() {
  group('daysInMonth', () {
    test('returns 31 for January', () {
      expect(daysInMonth(2025, 1), 31);
    });

    test('returns 28 for February in non-leap year', () {
      expect(daysInMonth(2025, 2), 28);
    });

    test('returns 29 for February in leap year', () {
      expect(daysInMonth(2024, 2), 29);
    });

    test('returns 30 for April', () {
      expect(daysInMonth(2025, 4), 30);
    });

    test('returns 31 for December', () {
      expect(daysInMonth(2025, 12), 31);
    });
  });

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

    group('Feb 29 leap year birthday handling', () {
      // Legal interpretation: In non-leap years, Feb 29 birthdays are
      // celebrated on Feb 28 (the last day of February).

      test('Feb 29 birth on Feb 28 non-leap year = birthday has occurred', () {
        // Reference: Feb 28, 2025 (non-leap). Birth: Feb 29, 2000 (leap).
        // Feb 29 is treated as Feb 28 in 2025, so birthday HAS occurred.
        final reference = DateTime(2025, 2, 28);
        final birthDate = DateTime(2000, 2, 29);
        expect(calculateAge(birthDate, reference), 25);
      });

      test('Feb 29 birth on Feb 27 non-leap year = birthday not yet', () {
        // Reference: Feb 27, 2025. Birth: Feb 29, 2000.
        // Birthday (treated as Feb 28) hasn't occurred yet.
        final reference = DateTime(2025, 2, 27);
        final birthDate = DateTime(2000, 2, 29);
        expect(calculateAge(birthDate, reference), 24);
      });

      test('Feb 29 birth on Mar 1 non-leap year = birthday passed', () {
        // Reference: Mar 1, 2025. Birth: Feb 29, 2000.
        // Birthday (Feb 28) has passed.
        final reference = DateTime(2025, 3, 1);
        final birthDate = DateTime(2000, 2, 29);
        expect(calculateAge(birthDate, reference), 25);
      });

      test('Feb 29 birth on Feb 29 leap year = exact birthday', () {
        // Reference: Feb 29, 2024 (leap). Birth: Feb 29, 2000 (leap).
        // Exact birthday in a leap year.
        final reference = DateTime(2024, 2, 29);
        final birthDate = DateTime(2000, 2, 29);
        expect(calculateAge(birthDate, reference), 24);
      });

      test('Feb 29 birth on Feb 28 leap year = day before birthday', () {
        // Reference: Feb 28, 2024 (leap). Birth: Feb 29, 2000 (leap).
        // In a leap year, Feb 28 is before Feb 29, so birthday hasn't occurred.
        final reference = DateTime(2024, 2, 28);
        final birthDate = DateTime(2000, 2, 29);
        expect(calculateAge(birthDate, reference), 23);
      });
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
