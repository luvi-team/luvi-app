import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';

void main() {
  group('weekViewFor', () {
    test('returns monday to sunday window with contiguous phase segments', () {
      final today = DateTime(2023, 9, 28); // Thursday
      final cycleInfo = CycleInfo(
        lastPeriod: DateTime(2023, 9, 19),
        cycleLength: 28,
        periodDuration: 5,
      );

      final view = weekViewFor(today, cycleInfo);

      expect(view.days, hasLength(7));
      expect(view.days.first.date, DateTime(2023, 9, 25)); // Monday
      expect(view.days.last.date, DateTime(2023, 10, 1)); // Sunday
      expect(view.days[3].isToday, isTrue); // Thursday index
      expect(view.days[3].phase, Phase.follicular);
      expect(view.segments, hasLength(2));

      final firstSegment = view.segments[0];
      final secondSegment = view.segments[1];

      expect(firstSegment.phase, Phase.follicular);
      expect(firstSegment.startIndex, 0);
      expect(firstSegment.endIndex, 4);

      expect(secondSegment.phase, Phase.luteal);
      expect(secondSegment.startIndex, 5);
      expect(secondSegment.endIndex, 6);
    });
  });
}
