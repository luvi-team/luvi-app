import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';

void main() {
  group('weekViewFor', () {
    test('returns monday to sunday window with contiguous phase segments', () {
      final today = DateTime(2023, 9, 28); // Thursday
      final cycleInfo = CycleInfo(
        lastPeriod: DateTime(2023, 9, 16), // Aligned with production fixtures
        cycleLength: 28,
        periodDuration: 5,
      );

      final view = weekViewFor(today, cycleInfo);

      expect(view.days, hasLength(7));
      expect(view.days.first.date, DateTime(2023, 9, 25)); // Monday
      expect(view.days.last.date, DateTime(2023, 10, 1)); // Sunday
      expect(view.days[3].isToday, isTrue); // Thursday index
      expect(view.days[3].phase, Phase.ovulation); // Day 13 of cycle

      // Week shows phase transition: follicular (days 10-12) → ovulation (days 13-16)
      expect(view.segments, hasLength(2));

      final firstSegment = view.segments[0];
      expect(firstSegment.phase, Phase.follicular);
      expect(firstSegment.startIndex, 0);
      expect(firstSegment.endIndex, 2); // Mon 25 - Wed 27 Sept (days 10-12)

      final secondSegment = view.segments[1];
      expect(secondSegment.phase, Phase.ovulation);
      expect(secondSegment.startIndex, 3);
      expect(secondSegment.endIndex, 6); // Thu 28 Sept - Sun 1 Oct (days 13-16)
    });
  });
}
