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

  static String germanDayMonthYear(DateTime date) {
    return '${date.day} ${_germanMonths[date.month - 1]} ${date.year}';
  }
}
