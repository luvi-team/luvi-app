import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Collection of lightweight date formatter helpers used across onboarding.
@immutable
class DateFormatters {
  const DateFormatters._();

  /// Formats a `date` using the provided `localeName` (or falls back to Intl's default locale).
  static String localizedDayMonthYear(DateTime date, {String? localeName}) {
    final trimmed = localeName?.trim();

    // Accept patterns like 'de', 'en', 'en_US', 'pt_BR', 'zh_Hans', 'zh-Hans'
    final localePattern =
        RegExp(r'^[A-Za-z]{2,3}([_-][A-Za-z0-9]{2,8}){0,2}$');
    final effectiveLocale =
        (trimmed == null || trimmed.isEmpty || !localePattern.hasMatch(trimmed))
            ? null
            : trimmed;

    try {
      final formatter = DateFormat.yMMMMd(effectiveLocale);
      return formatter.format(date);
    } catch (e) {
      // Fall back to default locale on any failure and avoid throwing
      try {
        final fallback = DateFormat.yMMMMd();
        return fallback.format(date);
      } catch (_) {
        // As an absolute last resort, return ISO-like date
        return DateFormat('y-MM-dd').format(date);
      }
    }
  }
}
