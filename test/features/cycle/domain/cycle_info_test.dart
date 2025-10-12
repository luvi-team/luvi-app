import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';

void main() {
  group('CycleInfo phase calculation', () {
    test('menstruation phase (day 1-periodDuration)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      // Days 1-5 should be menstruation
      expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation'); // day 1
      expect(c.phaseOn(DateTime(2025, 9, 5)), 'Menstruation'); // day 5
      // Day 6 should NOT be menstruation
      expect(c.phaseOn(DateTime(2025, 9, 6)), isNot('Menstruation'));
    });

    test('wrap/negative date case (cyclic behavior)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      // Date before lastPeriod should wrap cyclically
      final dateBeforePeriod = DateTime(2025, 8, 31);
      final phase = c.phaseOn(dateBeforePeriod);
      expect(phase, isNotEmpty);
      // Should wrap to day 28 of previous cycle (luteal phase with lutealLength=13)
      expect(phase, 'Luteal');
    });

    test('ovulation window (28/13): day 15 ±2', () {
      // cycleLength=28, lutealLength=13 (default) → ovulationDay = 28-13 = 15
      // Window: days 13-17 (±2)
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      expect(c.phaseOn(DateTime(2025, 9, 13)), 'Ovulationsfenster'); // day 13
      expect(c.phaseOn(DateTime(2025, 9, 14)), 'Ovulationsfenster'); // day 14
      expect(c.phaseOn(DateTime(2025, 9, 15)), 'Ovulationsfenster'); // day 15
      expect(c.phaseOn(DateTime(2025, 9, 16)), 'Ovulationsfenster'); // day 16
      expect(c.phaseOn(DateTime(2025, 9, 17)), 'Ovulationsfenster'); // day 17
      // Day 18 should be luteal (outside ±2 window)
      expect(c.phaseOn(DateTime(2025, 9, 18)), 'Luteal'); // day 18
      // Day 12 should be follicular (before window)
      expect(c.phaseOn(DateTime(2025, 9, 12)), 'Follikel'); // day 12
    });

    test('ovulation window (30/13): day 17 ±2', () {
      // cycleLength=30, lutealLength=13 (default) → ovulationDay = 30-13 = 17
      // Window: days 15-19 (±2)
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 30,
        periodDuration: 5,
      );
      expect(c.phaseOn(DateTime(2025, 9, 15)), 'Ovulationsfenster'); // day 15
      expect(c.phaseOn(DateTime(2025, 9, 16)), 'Ovulationsfenster'); // day 16
      expect(c.phaseOn(DateTime(2025, 9, 17)), 'Ovulationsfenster'); // day 17
      expect(c.phaseOn(DateTime(2025, 9, 18)), 'Ovulationsfenster'); // day 18
      expect(c.phaseOn(DateTime(2025, 9, 19)), 'Ovulationsfenster'); // day 19
      // Day 20 should be luteal (outside ±2 window)
      expect(c.phaseOn(DateTime(2025, 9, 20)), 'Luteal'); // day 20
      // Day 14 should be follicular (before window)
      expect(c.phaseOn(DateTime(2025, 9, 14)), 'Follikel'); // day 14
    });

    test('follicular phase (after menstruation, before ovulation)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      // Days 6-12 should be follicular (before ovulation window 13-17)
      expect(c.phaseOn(DateTime(2025, 9, 6)), 'Follikel'); // day 6
      expect(c.phaseOn(DateTime(2025, 9, 10)), 'Follikel'); // day 10
      expect(c.phaseOn(DateTime(2025, 9, 12)), 'Follikel'); // day 12
    });

    test('luteal phase (after ovulation)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      // Days 18-28 should be luteal (after ovulation window 13-17)
      expect(c.phaseOn(DateTime(2025, 9, 18)), 'Luteal'); // day 18
      expect(c.phaseOn(DateTime(2025, 9, 20)), 'Luteal'); // day 20
      expect(c.phaseOn(DateTime(2025, 9, 28)), 'Luteal'); // day 28
    });

    test('edge case: very short cycle (21 days)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 21,
        periodDuration: 3,
      );
      // ovulationDay = 21-13 = 8, window: 6-10
      expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation'); // day 1
      expect(c.phaseOn(DateTime(2025, 9, 4)), 'Follikel'); // day 4
      expect(c.phaseOn(DateTime(2025, 9, 6)), 'Ovulationsfenster'); // day 6
      expect(c.phaseOn(DateTime(2025, 9, 8)), 'Ovulationsfenster'); // day 8
      expect(c.phaseOn(DateTime(2025, 9, 10)), 'Ovulationsfenster'); // day 10
      expect(c.phaseOn(DateTime(2025, 9, 11)), 'Luteal'); // day 11
    });

    test('edge case: longer cycle (35 days)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 35,
        periodDuration: 5,
      );
      // ovulationDay = 35-13 = 22, window: 20-24
      expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation'); // day 1
      expect(c.phaseOn(DateTime(2025, 9, 10)), 'Follikel'); // day 10
      expect(c.phaseOn(DateTime(2025, 9, 22)), 'Ovulationsfenster'); // day 22
      expect(c.phaseOn(DateTime(2025, 9, 24)), 'Ovulationsfenster'); // day 24
      expect(c.phaseOn(DateTime(2025, 9, 25)), 'Luteal'); // day 25
    });
  });
}
