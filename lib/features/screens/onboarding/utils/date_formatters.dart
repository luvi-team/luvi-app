import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Collection of lightweight date formatter helpers used across onboarding.
@immutable
class DateFormatters {
  const DateFormatters._();

  /// Formats a `date` using the provided `localeName` (or falls back to Intl's default locale).
  static String localizedDayMonthYear(
    DateTime date, {
    String? localeName,
  }) {
    final trimmedLocale = localeName?.trim();
    final effectiveLocale = (trimmedLocale == null || trimmedLocale.isEmpty) ? null : trimmedLocale;
    final formatter = DateFormat.yMMMMd(effectiveLocale);
    return formatter.format(date);
  }
}
