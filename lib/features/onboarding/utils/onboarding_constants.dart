/// Shared constants for onboarding flows.
const double kOnboardingPickerHeight = 198.0;

/// Total number of onboarding questions (screens O1-O5 + cycle intro)
/// Note: O6/O7 are cycle calendar screens without progress indicator
const int kOnboardingTotalSteps = 6;

/// Oldest supported birth year for onboarding date pickers.
const int kOnboardingMinBirthYear = 1900;

/// Returns the latest supported birth year for onboarding date pickers.
int get kOnboardingMaxBirthYear => DateTime.now().year;

// ─── Age Policy 16-120 (Codex-Review Runde 5) ───

/// Minimum age for onboarding (Legal/DSGVO/Product decision)
const int kMinAge = 16;

/// Maximum age for onboarding (biologically plausible)
const int kMaxAge = 120;

/// Default cycle length in days (MVP assumption)
/// This is the full cycle duration, not period duration!
const int kDefaultCycleLength = 28;

/// Default period duration in days
const int kDefaultPeriodDuration = 7;

/// Returns today as date-only (no time component)
DateTime get todayDateOnly {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Maximum birthdate (user must be at least [kMinAge] years old)
/// = today - kMinAge years
DateTime onboardingBirthdateMaxDate([DateTime? reference]) {
  final today = reference ?? todayDateOnly;
  return DateTime(today.year - kMinAge, today.month, today.day);
}

/// Minimum birthdate (user cannot be older than [kMaxAge])
/// = (today - kMaxAge - 1 years) + 1 day (prevents edge-case)
/// Uses Duration.add() to avoid day overflow at month boundaries.
DateTime onboardingBirthdateMinDate([DateTime? reference]) {
  final today = reference ?? todayDateOnly;
  final baseDate = DateTime(today.year - kMaxAge - 1, today.month, today.day);
  return baseDate.add(const Duration(days: 1));
}

/// Calculates age from birthdate
int calculateAge(DateTime birthDate, [DateTime? reference]) {
  final now = reference ?? DateTime.now();
  int age = now.year - birthDate.year;
  // Correction if birthday hasn't occurred yet this year
  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}

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
