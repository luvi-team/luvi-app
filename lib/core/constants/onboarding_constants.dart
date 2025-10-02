/// Shared constants for onboarding flows.
const double kOnboardingPickerHeight = 198.0;

/// Oldest supported birth year for onboarding date pickers.
const int kOnboardingMinBirthYear = 1900;

/// Latest supported birth year for onboarding date pickers.
final int kOnboardingMaxBirthYear = DateTime.now().year;

/// Maximum number of years back a period start can be selected.
const int kOnboardingPeriodStartMaxYearsBack = 2;

/// Computes the earliest selectable period start date relative to [reference].
DateTime onboardingPeriodStartMinDate([DateTime? reference]) {
  final now = reference ?? DateTime.now();
  return DateTime(now.year - kOnboardingPeriodStartMaxYearsBack, now.month, now.day);
}

/// Computes the latest selectable period start date relative to [reference].
DateTime onboardingPeriodStartMaxDate([DateTime? reference]) {
  return reference ?? DateTime.now();
}
