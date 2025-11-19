import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Collection of lightweight date formatter helpers used across onboarding.
@immutable
class DateFormatters {
  const DateFormatters._();

  /// Formats a `date` using the provided `localeName` (or falls back to Intl's default locale).
  static String localizedDayMonthYear(DateTime date, {String? localeName}) {
    final effectiveLocale = resolveSupportedLocale2(localeName);

    try {
      final formatter = DateFormat.yMMMMd(effectiveLocale);
      return formatter.format(date);
    } catch (e, stackTrace) {
      // On any failure, fall back to a safe, locale-agnostic ISO-like format.
      debugPrint('DateFormatters.localizedDayMonthYear fallback: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace, label: 'DateFormat error');
      }
      try {
        final iso = date.toIso8601String();
        return iso.length >= 10 ? iso.substring(0, 10) : iso;
      } catch (_) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    }
  }
}

/// Resolve an incoming locale tag to a supported locale name or null.
///
/// - Trims input and canonicalizes via Intl.canonicalizedLocale.
/// - Returns a locale name that matches one of `AppLocalizations.supportedLocales`
///   by base language (e.g., `en-US`, `en_US`, `en-Latn` all map to `en`).
/// - Returns null if input is empty, structurally unusable for our allowlist,
///   or the language is not supported; DateFormat will then fall back to default locale.
@visibleForTesting
String? resolveSupportedLocale(String? tag) {
  // Deprecated: keep symbol for backward compatibility; delegate to corrected resolver.
  return resolveSupportedLocale2(tag);
}

/// Corrected resolver (MVP) that replaces the old regex-based approach.
/// Prefer this over `resolveSupportedLocale`.
@visibleForTesting
String? resolveSupportedLocale2(String? tag) {
  final trimmed = tag?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.startsWith('-') ||
      trimmed.startsWith('_') ||
      trimmed.endsWith('-') ||
      trimmed.endsWith('_') ||
      trimmed.contains('--') ||
      trimmed.contains('__')) {
    return null;
  }

  final canonical = Intl.canonicalizedLocale(trimmed);
  if (canonical.isEmpty) return null;

  final sepIndex = canonical.indexOf(RegExp('[-_]'));
  final baseLang = (sepIndex == -1)
      ? canonical.toLowerCase()
      : canonical.substring(0, sepIndex).toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}$').hasMatch(baseLang)) {
    return null;
  }

  final supported = AppLocalizations.supportedLocales
      .map((l) => l.languageCode.toLowerCase())
      .toSet();
  if (supported.contains(baseLang)) {
    return baseLang;
  }
  return null;
}
