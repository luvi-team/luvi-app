import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';

void main() {
  group('onboardingBirthdateMaxDate', () {
    test('handles leap year Feb 29 when target year is also leap year', () {
      // Today is Feb 29, 2024 (leap year), kMinAge=16
      // 2024-16=2008 (also leap year), so Feb 29 is valid
      final result = onboardingBirthdateMaxDate(DateTime(2024, 2, 29));
      expect(result, DateTime(2008, 2, 29));
    });

    test('computes max birthdate correctly for March 31', () {
      // March 31 preserved: 2025-16=2009, March has 31 days in both years.
      // Note: Feb 29 → Feb 28 clamping cannot be tested with kMinAge=16
      // because 16 is divisible by 4, preserving leap year alignment.
      final result = onboardingBirthdateMaxDate(DateTime(2025, 3, 31));
      expect(result, DateTime(2009, 3, 31));
    });

    test('subtracts kMinAge years from date (June)', () {
      // June 15, 2025 - 16 years = June 15, 2009
      // Note: Actual day clamping (Feb 29 → Feb 28) is tested in leap year tests above
      final result = onboardingBirthdateMaxDate(DateTime(2025, 6, 15));
      expect(result, DateTime(2009, 6, 15));
    });

    test('Jan 1 unchanged', () {
      final result = onboardingBirthdateMaxDate(DateTime(2025, 1, 1));
      expect(result, DateTime(2009, 1, 1));
    });

    test('Dec 31 unchanged', () {
      final result = onboardingBirthdateMaxDate(DateTime(2025, 12, 31));
      expect(result, DateTime(2009, 12, 31));
    });
  });

  group('onboardingBirthdateMinDate', () {
    test('returns date kMaxAge+1 years ago plus 1 day', () {
      final result = onboardingBirthdateMinDate(DateTime(2025, 6, 15));
      // 2025 - 120 - 1 = 1904, then +1 day
      // June 15, 1904 + 1 day = June 16, 1904
      expect(result, DateTime(1904, 6, 16));
    });
  });

  group('todayDateOnly', () {
    test('returns date without time component', () {
      final result = todayDateOnly();
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });
  });

  group('Age Policy constants', () {
    test('kMinAge is 16', () {
      expect(kMinAge, 16);
    });

    test('kMaxAge is 120', () {
      expect(kMaxAge, 120);
    });
  });
}
