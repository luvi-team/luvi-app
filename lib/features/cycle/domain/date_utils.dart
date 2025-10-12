import 'package:flutter/foundation.dart';

/// Utility helpers for cycle-related date rendering.
@immutable
class CycleDateUtils {
  const CycleDateUtils._();

  static const List<String> _germanMonthAbbr = <String>[
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

  /// Formats a given [referenceDate] as `Heute, 28. Sept`.
  static String formatTodayDe(DateTime referenceDate) {
    final month = referenceDate.month;
    if (month < 1 || month > _germanMonthAbbr.length) {
      throw ArgumentError.value(
        month,
        'referenceDate.month',
        'Month must be between 1 and ${_germanMonthAbbr.length}.',
      );
    }
    final monthLabel = _germanMonthAbbr[month - 1];
    return 'Heute, ${referenceDate.day}. $monthLabel';
  }
}
