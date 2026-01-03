import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/time/clock.dart';

void main() {
  group('SystemClock', () {
    test('now() returns current time', () {
      final before = DateTime.now();
      final clock = const SystemClock();
      final result = clock.now();
      final after = DateTime.now();

      expect(result.isAfter(before) || result.isAtSameMomentAs(before), isTrue);
      expect(result.isBefore(after) || result.isAtSameMomentAs(after), isTrue);
    });

    test('today() strips time component', () {
      final clock = const SystemClock();
      final result = clock.today();

      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });

  group('FixedClock', () {
    test('now() always returns fixed time', () {
      final fixed = DateTime(2025, 12, 15, 10, 30, 45);
      final clock = FixedClock(fixed);

      expect(clock.now(), equals(fixed));
      expect(clock.now(), equals(fixed)); // Idempotent
    });

    test('FixedClock.at() factory works correctly', () {
      final clock = FixedClock.at(2025, 6, 15);

      expect(clock.now().year, 2025);
      expect(clock.now().month, 6);
      expect(clock.now().day, 15);
    });

    test('today() strips time from fixed clock', () {
      final clock = FixedClock(DateTime(2025, 12, 15, 23, 59, 59));

      expect(clock.today(), equals(DateTime(2025, 12, 15)));
    });
  });
}
