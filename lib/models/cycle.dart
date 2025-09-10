/// Represents cycle information for phase calculation.
///
/// This class calculates the menstrual cycle phase based on
/// the last period date, cycle length, and period duration.
class CycleInfo {
  /// The date of the last menstrual period start.
  final DateTime lastPeriod;

  /// The total cycle length in days.
  final int cycleLength;

  /// The period duration in days.
  final int periodDuration;

  /// Creates a new CycleInfo instance.
  ///
  /// Throws [ArgumentError] if:
  /// - cycleLength <= 0
  /// - periodDuration <= 0 or > cycleLength
  CycleInfo({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodDuration,
  }) : assert(
         cycleLength >= 21 && cycleLength <= 60,
         'cycleLength should be between 21 and 60 days',
       ),
       assert(
         periodDuration >= 1 && periodDuration <= 10,
         'periodDuration should be between 1 and 10 days',
       ) {
    if (cycleLength <= 0) {
      throw ArgumentError.value(cycleLength, 'cycleLength', 'must be positive');
    }
    if (periodDuration <= 0 || periodDuration > cycleLength) {
      throw ArgumentError.value(
        periodDuration,
        'periodDuration',
        'must be positive and not exceed cycleLength',
      );
    }
  }

  /// Calculates the cycle phase for a given date.
  ///
  /// Returns one of: "Menstruation", "Follikel", "Ovulationsfenster", "Luteal"
  String phaseOn(DateTime d) {
    final start = DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);
    final q = DateTime(d.year, d.month, d.day);
    final diff = q.difference(start).inDays;
    final day = ((diff % cycleLength) + cycleLength) % cycleLength;

    if (day < periodDuration) {
      return "Menstruation";
    }
    if (day < periodDuration + 6) {
      return "Follikel";
    }
    if (day >= cycleLength - 14 && day < cycleLength - 10) {
      return "Ovulationsfenster";
    }
    return "Luteal";
  }
}
