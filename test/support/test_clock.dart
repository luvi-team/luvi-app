import 'package:luvi_app/core/time/clock.dart';

/// Common test dates for deterministic testing.
class TestDates {
  /// Mid-month date (avoids month boundary issues)
  static final midMonth = DateTime(2025, 12, 15);

  /// First day of month
  static final monthStart = DateTime(2025, 12, 1);

  /// Last day of month
  static final monthEnd = DateTime(2025, 12, 31);
}

/// Extension for convenient FixedClock creation from DateTime.
extension ClockTestExtensions on DateTime {
  /// Creates a FixedClock from this DateTime.
  FixedClock get asClock => FixedClock(this);
}
