import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Collection of lightweight date formatter helpers used across onboarding.
@immutable
class DateFormatters {
  const DateFormatters._();

  /// Formats a `date` using the provided `localeName` (or falls back to Intl's default locale).
  static String localizedDayMonthYear(DateTime date, {String? localeName}) {
    final trimmed = localeName?.trim();

    // Pragmatic BCP 47 language tag validation (RFC 5646-inspired, not exhaustive).
    // Accepts common forms like:
    // - 'de', 'en'
    // - 'en-US', 'pt-BR'
    // - 'zh-Hans', 'zh-Hant-TW'
    // - with variants/extensions/private-use (e.g., 'sl-rozaj-biske', 'en-US-u-ca-buddhist', 'x-private')
    // Note: Full BCP 47 ABNF (incl. grandfathered tags) is intentionally not implemented for MVP.
    final localePattern = RegExp(
      r'^(?:'
      r'x(?:-[A-Za-z0-9]{1,8})+' // private-use only
      r'|'
      r'(?:[A-Za-z]{2,8}(?:-[A-Za-z]{3}){0,3})' // language + optional extlang
      r'(?:-[A-Za-z]{4})?' // optional script
      r'(?:-(?:[A-Za-z]{2}|\d{3}))?' // optional region
      r'(?:-(?:\d[A-Za-z0-9]{3}|[A-Za-z0-9]{5,8}))*' // variants
      r'(?:-[0-9A-WY-Za-wy-z](?:-[A-Za-z0-9]{2,8})+)*' // extensions
      r'(?:-x(?:-[A-Za-z0-9]{1,8})+)?' // optional private-use tail
      r')$'
    );
    final effectiveLocale =
        (trimmed == null || trimmed.isEmpty || !localePattern.hasMatch(trimmed))
            ? null
            : trimmed;

    try {
      final formatter = DateFormat.yMMMMd(effectiveLocale);
      return formatter.format(date);
    } catch (e, stackTrace) {
      // On any failure, fall back to a safe, locale-agnostic ISO-like format.
      debugPrint('DateFormatters.localizedDayMonthYear fallback: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace, label: 'DateFormat error');
      }
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
