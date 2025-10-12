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

    test('ovulation window (28/13): day 15 ±1', () {
      // cycleLength=28, lutealLength=13 (default) → ovulationDay = 28-13 = 15
      // Window: days 14-16 (±1)
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      expect(c.phaseOn(DateTime(2025, 9, 14)), 'Ovulationsfenster'); // day 14
      expect(c.phaseOn(DateTime(2025, 9, 15)), 'Ovulationsfenster'); // day 15
      expect(c.phaseOn(DateTime(2025, 9, 16)), 'Ovulationsfenster'); // day 16
      // Day 17 should be luteal (outside ±1 window)
      expect(c.phaseOn(DateTime(2025, 9, 17)), 'Luteal'); // day 17
      // Day 13 should be follicular (before window)
      expect(c.phaseOn(DateTime(2025, 9, 13)), 'Follikel'); // day 13
    });

    // NOTE: ovulation window (28/14) test would require exposing lutealLength
    // in CycleInfo constructor. For now, the 28/13 default is tested above.
    // Future enhancement: Make lutealLength configurable.

    test('ovulation window (30/13): day 17 ±1', () {
      // cycleLength=30, lutealLength=13 (default) → ovulationDay = 30-13 = 17
      // Window: days 16-18 (±1)
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 30,
        periodDuration: 5,
      );
      expect(c.phaseOn(DateTime(2025, 9, 16)), 'Ovulationsfenster'); // day 16
      expect(c.phaseOn(DateTime(2025, 9, 17)), 'Ovulationsfenster'); // day 17
      expect(c.phaseOn(DateTime(2025, 9, 18)), 'Ovulationsfenster'); // day 18
      // Day 19 should be luteal (outside ±1 window)
      expect(c.phaseOn(DateTime(2025, 9, 19)), 'Luteal'); // day 19
      // Day 15 should be follicular (before window)
      expect(c.phaseOn(DateTime(2025, 9, 15)), 'Follikel'); // day 15
    });

    test('follicular phase (after menstruation, before ovulation)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      // Days 6-13 should be follicular (before ovulation window 14-16)
      expect(c.phaseOn(DateTime(2025, 9, 6)), 'Follikel'); // day 6
      expect(c.phaseOn(DateTime(2025, 9, 10)), 'Follikel'); // day 10
      expect(c.phaseOn(DateTime(2025, 9, 13)), 'Follikel'); // day 13
    });

    test('luteal phase (after ovulation)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 5,
      );
      // Days 17-28 should be luteal (after ovulation window 14-16)
      expect(c.phaseOn(DateTime(2025, 9, 17)), 'Luteal'); // day 17
      expect(c.phaseOn(DateTime(2025, 9, 20)), 'Luteal'); // day 20
      expect(c.phaseOn(DateTime(2025, 9, 28)), 'Luteal'); // day 28
    });

    test('edge case: very short cycle (21 days)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 21,
        periodDuration: 3,
      );
      // ovulationDay = 21-13 = 8, window: 7-9
      expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation'); // day 1
      expect(c.phaseOn(DateTime(2025, 9, 4)), 'Follikel'); // day 4
      expect(c.phaseOn(DateTime(2025, 9, 8)), 'Ovulationsfenster'); // day 8
      expect(c.phaseOn(DateTime(2025, 9, 10)), 'Luteal'); // day 10
    });

    test('edge case: longer cycle (35 days)', () {
      final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 35,
        periodDuration: 5,
      );
      // ovulationDay = 35-13 = 22, window: 21-23
      expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation'); // day 1
      expect(c.phaseOn(DateTime(2025, 9, 10)), 'Follikel'); // day 10
      expect(c.phaseOn(DateTime(2025, 9, 22)), 'Ovulationsfenster'); // day 22
      expect(c.phaseOn(DateTime(2025, 9, 24)), 'Luteal'); // day 24
    });
  });
}
