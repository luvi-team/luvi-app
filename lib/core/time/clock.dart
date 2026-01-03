/// Clock abstraction for testable time-dependent code.
///
/// Enables dependency injection of time sources, allowing tests to use
/// deterministic dates instead of `DateTime.now()`.
abstract class Clock {
  /// Returns the current time.
  DateTime now();

  /// Returns today's date without time component.
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

/// Default clock implementation using system time.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

/// Fixed clock for testing with deterministic time.
class FixedClock implements Clock {
  final DateTime _fixed;

  FixedClock(this._fixed);

  /// Factory constructor for convenience.
  factory FixedClock.at(int year, int month, int day) =>
      FixedClock(DateTime(year, month, day));

  @override
  DateTime now() => _fixed;

  @override
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}
