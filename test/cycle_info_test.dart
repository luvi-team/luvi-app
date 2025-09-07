import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/models/cycle.dart';

void main() {
  test('phase calc basics', () {
    final c = CycleInfo(
        lastPeriod: DateTime(2025, 9, 1),
        cycleLength: 28,
        periodDuration: 4);
    expect(c.phaseOn(DateTime(2025, 9, 1)), 'Menstruation');
  });
}