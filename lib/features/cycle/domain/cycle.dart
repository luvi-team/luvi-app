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
    final phase = _phaseForDate(
      date: d,
      lastPeriod: lastPeriod,
      cycleLength: cycleLength,
      periodDuration: periodDuration,
    );

    switch (phase) {
      case _Phase.menstruation:
        return "Menstruation";
      case _Phase.follicular:
        return "Follikel";
      case _Phase.ovulation:
        return "Ovulationsfenster";
      case _Phase.luteal:
        return "Luteal";
    }
  }
}

/// Internal phase enum for pure function calculation.
enum _Phase { menstruation, follicular, ovulation, luteal }

/// Pure function for evidence-based phase calculation (internal).
///
/// Calculates menstrual cycle phase using backwards ovulation timing:
/// ovulationDay = cycleLength - lutealLength (typically day 15 for 28-day cycle).
///
/// Parameters:
/// - [date]: The date to calculate phase for
/// - [lastPeriod]: Start date of last menstrual period
/// - [cycleLength]: Total cycle length in days
/// - [periodDuration]: Menstruation duration in days
/// - [lutealLength]: Luteal phase length (default 13, evidence-based typical 12-14)
/// - [ovulationWindowDays]: UI highlighting window around ovulation (±days, default 2)
///
/// Returns: Phase enum value (menstruation, follicular, ovulation, luteal)
_Phase _phaseForDate({
  required DateTime date,
  required DateTime lastPeriod,
  required int cycleLength,
  required int periodDuration,
  int lutealLength = 13,
  int ovulationWindowDays = 2,
}) {
  // Dart DateTime supports only local or UTC zones. To perform DST-safe day
  // arithmetic, we: 1) convert UTC inputs to local time, keeping local inputs
  // as-is; 2) extract the calendar date (year/month/day) in local time; and
  // 3) create UTC date-only values for difference calculations.
  DateTime toLocalZone(DateTime dt) => dt.isUtc ? dt.toLocal() : dt;
  DateTime toUtcDateOnly(DateTime local) =>
      DateTime.utc(local.year, local.month, local.day);

  final lastPeriodLocal = toLocalZone(lastPeriod);
  final dateLocal = toLocalZone(date);
  final start = toUtcDateOnly(lastPeriodLocal);
  final q = toUtcDateOnly(dateLocal);
  final diff = q.difference(start).inDays;

  // Calculate 1-based cycle day (wrap negatives cyclically)
  final day = 1 + ((diff % cycleLength) + cycleLength) % cycleLength;

  // Ovulation occurs ~lutealLength days before next period (backwards calculation)
  final ovulationDay = (cycleLength - lutealLength).clamp(1, cycleLength);

  // Check if date falls within ovulation window (±ovulationWindowDays)
  final inOvulationWindow = (day - ovulationDay).abs() <= ovulationWindowDays;

  // Phase logic (medical evidence-based)
  if (day <= periodDuration) {
    return _Phase.menstruation;
  }
  if (inOvulationWindow) {
    return _Phase.ovulation;
  }
  if (day < ovulationDay) {
    return _Phase.follicular;
  }
  return _Phase.luteal;
}
