import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Collection of lightweight date formatter helpers used across onboarding.
@immutable
class DateFormatters {
  const DateFormatters._();

  /// Formats a `date` using the provided `localeName` (or falls back to Intl's default locale).
  static String localizedDayMonthYear(DateTime date, {String? localeName}) {
    final trimmed = localeName?.trim();
    final effectiveLocale = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    final formatter = DateFormat.yMMMMd(effectiveLocale);
    return formatter.format(date);
  }
}
