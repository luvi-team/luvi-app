import 'package:flutter/foundation.dart';

/// Collection of lightweight date formatter helpers used across onboarding.
@immutable
class DateFormatters {
  const DateFormatters._();

  static const List<String> _germanMonths = <String>[
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  /// Formats a [DateTime] as `5 Mai 2002` (German locale, no leading zero).
  static String germanDayMonthYear(DateTime date) {
    final month = date.month;
    return '${date.day} ${_germanMonths[month - 1]} ${date.year}';
  }
}
