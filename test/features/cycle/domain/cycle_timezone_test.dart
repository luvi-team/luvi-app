import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';

void main() {
  group('CycleInfo timezone/day-only behavior', () {
    test('uses local calendar day boundaries regardless of time-of-day', () {
      final info = CycleInfo(
        lastPeriod: DateTime(2025, 1, 1, 23, 59), // late night
        cycleLength: 28,
        periodDuration: 5,
      );

      // Same calendar day with early time should still be day 1
      expect(info.phaseOn(DateTime(2025, 1, 1, 0, 1)), 'Menstruation');

      // Next calendar day should be day 2, still menstruation for periodDuration=5
      expect(info.phaseOn(DateTime(2025, 1, 2, 0, 1)), 'Menstruation');
    });

    test('UTC vs local representations yield identical phase for same dates', () {
      final lastPeriodLocal = DateTime(2025, 2, 10, 8, 30);
      final info = CycleInfo(
        lastPeriod: lastPeriodLocal,
        cycleLength: 28,
        periodDuration: 5,
      );

      final sameCalendarDayLocal = DateTime(2025, 2, 12, 18, 00);
      // Convert by components to a UTC instant representing the same date-only when normalized
      final sameCalendarDayUtc = DateTime.utc(2025, 2, 12, 12, 0);

      expect(info.phaseOn(sameCalendarDayLocal), isNotEmpty);
      expect(info.phaseOn(sameCalendarDayUtc), info.phaseOn(sameCalendarDayLocal));
    });

    test('DST-safe arithmetic by date-only normalization', () {
      // The implementation uses local Y-M-D components then UTC date-only to
      // compute day differences, which is robust across DST changes.
      final info = CycleInfo(
        lastPeriod: DateTime(2025, 3, 29, 12, 0),
        cycleLength: 28,
        periodDuration: 5,
      );

      // Next calendar day (potential DST change in some locales) should be day 2
      final phaseNextDayLate = DateTime(2025, 3, 30, 23, 0);
      final phase = info.phaseOn(phaseNextDayLate);
      expect(phase, isNotEmpty);
      // Day 2 is still within menstruation window
      expect(phase, 'Menstruation');
    });
  });
}
