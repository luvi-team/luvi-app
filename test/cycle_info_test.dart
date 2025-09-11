import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';

void main() {
  test('phase calc basics', () {
    final c = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 4,
    );
    expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation');
  });

  test('wrap/negative date case', () {
    final c = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 4,
    );
    // Date before lastPeriod should not crash and return a phase
    final dateBeforePeriod = DateTime(2025, 8, 31);
    final phase = c.phaseOn(dateBeforePeriod);
    expect(phase, isNotEmpty);
    // Should wrap to day 27 of previous cycle (luteal phase)
    expect(phase, 'Luteal');
  });

  test('ovulation bounds', () {
    final c = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 4,
    );
    // Day 14 (cycleLength - 14) should be start of ovulation window
    expect(c.phaseOn(DateTime(2025, 9, 15)), 'Ovulationsfenster');
    // Day 18 (cycleLength - 10) should NOT be ovulation window (exclusive end)
    expect(c.phaseOn(DateTime(2025, 9, 19)), 'Luteal');
  });

  test('period boundary', () {
    final c = CycleInfo(
      lastPeriod: DateTime(2025, 9, 1),
      cycleLength: 28,
      periodDuration: 4,
    );
    // Day 4 (periodDuration) should be Follikel, not Menstruation
    expect(c.phaseOn(DateTime(2025, 9, 5)), 'Follikel');
  });
}
