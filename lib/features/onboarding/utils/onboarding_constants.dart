// Shared constants for onboarding flows.

// Re-export calculateAge from core for backward compatibility
export 'package:luvi_app/core/utils/date_utils.dart' show calculateAge;
const double kOnboardingPickerHeight = 198.0;

/// Total number of onboarding questions (screens O1-O5 + cycle intro)
/// Note: O6/O7 are cycle calendar screens without progress indicator
const int kOnboardingTotalSteps = 6;

/// Oldest supported birth year for onboarding date pickers.
const int kOnboardingMinBirthYear = 1900;

/// Returns the latest supported birth year for onboarding date pickers.
int kOnboardingMaxBirthYear([DateTime? reference]) =>
    (reference ?? DateTime.now()).year;

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

// ─── Period Duration Bounds (O7) ───

/// Minimum period duration in days
const int kMinPeriodDuration = 1;

/// Maximum period duration in days
const int kMaxPeriodDuration = 14;

// ─── Interest Selection (O5) ───

/// Minimum number of interests required for O5
const int kMinInterestSelections = 3;

/// Maximum number of interests allowed for O5
const int kMaxInterestSelections = 5;

/// Returns today as date-only (no time component).
///
/// NOTE: For critical date comparisons across multiple calls within the same
/// operation, consider passing an explicit reference date to avoid edge cases
/// around midnight boundaries.
DateTime todayDateOnly([DateTime? reference]) {
  final now = reference ?? DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Maximum birthdate (user must be at least [kMinAge] years old)
/// = today - kMinAge years, with explicit day clamping for leap year edge cases.
/// Uses _daysInMonth + clamp pattern to prevent DateTime constructor overflow
/// when today is Feb 29 but target year is not a leap year.
DateTime onboardingBirthdateMaxDate([DateTime? reference]) {
  final today = todayDateOnly(reference);
  final targetYear = today.year - kMinAge;
  // Clamp day to valid range for target month (handles Feb 29 → Feb 28)
  final maxDay = _daysInMonth(targetYear, today.month);
  final safeDay = today.day.clamp(1, maxDay);
  return DateTime(targetYear, today.month, safeDay);
}

/// Minimum birthdate (user cannot be older than [kMaxAge]).
/// The +1 day offset prevents excluding users born exactly (kMaxAge+1) years ago
/// due to leap-year or month-boundary rounding (e.g., Feb 29 birth on non-leap year).
/// Uses _daysInMonth + clamp pattern to prevent DateTime constructor overflow
/// when today is Feb 29 but target year is not a leap year.
DateTime onboardingBirthdateMinDate([DateTime? reference]) {
  final today = todayDateOnly(reference);
  final targetYear = today.year - kMaxAge - 1;
  // Clamp day to valid range for target month (handles Feb 29 -> Feb 28)
  final maxDay = _daysInMonth(targetYear, today.month);
  final safeDay = today.day.clamp(1, maxDay);
  final baseDate = DateTime(targetYear, today.month, safeDay);
  return baseDate.add(const Duration(days: 1));
}

/// Maximum number of years back a period start can be selected.
const int kOnboardingPeriodStartMaxYearsBack = 2;

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Computes the earliest selectable period start date relative to [reference].
DateTime onboardingPeriodStartMinDate([DateTime? reference]) {
  final now = todayDateOnly(reference);
  final targetYear = now.year - kOnboardingPeriodStartMaxYearsBack;
  final dim = _daysInMonth(targetYear, now.month);
  final safeDay = now.day.clamp(1, dim);
  return DateTime(targetYear, now.month, safeDay);
}

/// Computes the latest selectable period start date relative to [reference].
DateTime onboardingPeriodStartMaxDate([DateTime? reference]) {
  return todayDateOnly(reference);
}

// ─── Fallback Period Start ───

/// Default days back for synthetic period start fallback.
/// Used when O7 is accessed without O6 providing periodStart.
const int kFallbackPeriodStartDaysBack = 7;

// ─── O9 Success Screen Timing ───

/// Navigation delay after success animation completes.
/// UX: Allows user to see the success state before transitioning to home.
const Duration kOnboardingNavigationDelay = Duration(milliseconds: 500);
