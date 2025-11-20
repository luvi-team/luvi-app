/// Shared constants for onboarding flows.
const double kOnboardingPickerHeight = 198.0;

/// Total number of onboarding steps (screens 1-8)
const int kOnboardingTotalSteps = 8;

/// Oldest supported birth year for onboarding date pickers.
const int kOnboardingMinBirthYear = 1900;

/// Returns the latest supported birth year for onboarding date pickers.
int get kOnboardingMaxBirthYear => DateTime.now().year;

/// Maximum number of years back a period start can be selected.
const int kOnboardingPeriodStartMaxYearsBack = 2;

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Computes the earliest selectable period start date relative to [reference].
DateTime onboardingPeriodStartMinDate([DateTime? reference]) {
  final now = reference ?? DateTime.now();
  final targetYear = now.year - kOnboardingPeriodStartMaxYearsBack;
  final dim = _daysInMonth(targetYear, now.month);
  final safeDay = now.day.clamp(1, dim);
  return DateTime(targetYear, now.month, safeDay);
}

/// Computes the latest selectable period start date relative to [reference].
DateTime onboardingPeriodStartMaxDate([DateTime? reference]) {
  return reference ?? DateTime.now();
}
