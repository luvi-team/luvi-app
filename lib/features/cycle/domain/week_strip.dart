import 'package:flutter/foundation.dart';

import 'cycle.dart';
import 'phase.dart';

/// Lightweight view model for a 7-day inline calendar strip.
@immutable
class WeekStripView {
  const WeekStripView({required this.days, required this.segments})
    : assert(days.length == 7, 'Week strip requires exactly 7 days.');

  /// Ordered list of days visible in the strip (Monday → Sunday).
  final List<WeekStripDay> days;

  /// Contiguous phase segments backing the painter layer.
  final List<WeekStripSegment> segments;
}

/// Individual day in the inline calendar.
@immutable
class WeekStripDay {
  const WeekStripDay({
    required this.date,
    required this.phase,
    required this.isToday,
  });

  final DateTime date;
  final Phase phase;
  final bool isToday;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeekStripDay &&
        other.date == date &&
        other.phase == phase &&
        other.isToday == isToday;
  }

  @override
  int get hashCode => Object.hash(date, phase, isToday);
}

/// Contiguous block of identical phases (for painter path).
@immutable
class WeekStripSegment {
  const WeekStripSegment({
    required this.phase,
    required this.startIndex,
    required this.endIndex,
  }) : assert(startIndex >= 0 && startIndex <= endIndex),
       assert(endIndex >= 0);

  final Phase phase;
  final int startIndex;
  final int endIndex;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeekStripSegment &&
        other.phase == phase &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode => Object.hash(phase, startIndex, endIndex);
}

/// Builds the week strip projection for the given [today] reference.
WeekStripView weekViewFor(DateTime today, CycleInfo cycleInfo) {
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final days = List<WeekStripDay>.generate(7, (index) {
    final date = startOfWeek.add(Duration(days: index));
    final phase = cycleInfo.phaseFor(date);
    final isToday = _isSameDate(date, today);
    return WeekStripDay(date: date, phase: phase, isToday: isToday);
  }, growable: false);

  final segments = <WeekStripSegment>[];
  var segmentStart = 0;

  for (var i = 0; i < days.length; i++) {
    final isLast = i == days.length - 1;
    final hasPhaseChangeAhead = !isLast && days[i].phase != days[i + 1].phase;

    if (isLast || hasPhaseChangeAhead) {
      segments.add(
        WeekStripSegment(
          phase: days[i].phase,
          startIndex: segmentStart,
          endIndex: i,
        ),
      );
      segmentStart = i + 1;
    }
  }

  return WeekStripView(days: days, segments: segments);
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
