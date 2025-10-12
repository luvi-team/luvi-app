import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luvi_app/l10n/app_localizations.dart';

/// Utility helpers for cycle-related date rendering.
@immutable
class CycleDateUtils {
  const CycleDateUtils._();

  /// Formats a given [referenceDate] as `Heute, 28. Sept`.
  ///
  /// When [localizations] is provided, month abbreviations are resolved via
  /// `AppLocalizations` for consistency with the active locale. Falls back to
  /// internal abbreviations if localization data is unavailable.
  static String formatTodayDe(
    DateTime referenceDate, {
    AppLocalizations? localizations,
  }) {
    final month = referenceDate.month;
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'referenceDate.month',
        'Month must be between 1 and 12.',
      );
    }
    final monthLabel = _resolveMonthAbbreviation(month, localizations);
    return 'Heute, ${referenceDate.day}. $monthLabel';
  }

  static String _resolveMonthAbbreviation(
    int month,
    AppLocalizations? localizations,
  ) {
    final localized = localizations?.monthAbbreviation(month);
    if (localized != null && localized.isNotEmpty) {
      return localized;
    }

    const fallbackMonthAbbr = <String>[
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Okt',
      'Nov',
      'Dez',
    ];
    return fallbackMonthAbbr[month - 1];
  }
}

extension MonthAbbreviationLookup on AppLocalizations {
  /// Returns a locale-aware month abbreviation (e.g., `Sept.` in German).
  String? monthAbbreviation(int month) {
    if (month < 1 || month > 12) {
      return null;
    }
    try {
      final formatter = intl.DateFormat('MMM', localeName);
      return formatter.format(DateTime(2020, month));
    } catch (_) {
      return null;
    }
  }
}
