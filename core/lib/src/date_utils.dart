// Date utilities for LUVI app.
//
// Provides date calculation functions used across features and services.
// This file is the single source of truth for age calculation logic.

/// Returns the number of days in a given month and year.
///
/// Handles leap years correctly for February.
int daysInMonth(int year, int month) {
  // DateTime(year, month + 1, 0) gives the last day of the previous month,
  // which is the last day of `month` in `year`.
  return DateTime(year, month + 1, 0).day;
}

/// Calculates age from birthdate using date-only semantics.
///
/// Uses date-only comparison (time components are stripped) for consistency
/// with LUVI's age policy validation (16-120 years).
///
/// Handles Feb 29 births correctly in non-leap years by treating the birthday
/// as Feb 28 (the last day of February). This follows most legal jurisdictions'
/// interpretation where Feb 29 birthdays are celebrated on Feb 28 in non-leap years.
///
/// [birthDate] The person's birth date.
/// [reference] Optional reference date for testing. Defaults to today.
///
/// Returns the calculated age in years.
int calculateAge(DateTime birthDate, [DateTime? reference]) {
  final now = reference ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Handle Feb 29 births in non-leap years: treat as Feb 28
  final maxDayInMonth = daysInMonth(today.year, birthDate.month);
  final birthDay =
      birthDate.day > maxDayInMonth ? maxDayInMonth : birthDate.day;
  final birthdayThisYear = DateTime(today.year, birthDate.month, birthDay);

  return today.year - birthDate.year - (today.isBefore(birthdayThisYear) ? 1 : 0);
}
