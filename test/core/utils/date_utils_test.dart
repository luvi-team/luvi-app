import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/utils/date_utils.dart';

void main() {
  group('date_utils (app wrapper)', () {
    test('daysInMonth handles leap-year February', () {
      expect(daysInMonth(2024, 2), 29);
      expect(daysInMonth(2025, 2), 28);
    });

    test('calculateAge handles Feb 29 in non-leap years', () {
      final reference = DateTime(2025, 2, 28);
      final birthDate = DateTime(2000, 2, 29);
      expect(calculateAge(birthDate, reference), 25);
    });
  });
}
