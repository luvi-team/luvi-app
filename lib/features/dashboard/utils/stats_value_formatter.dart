import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Value and unit presentation used by [StatsScroller] to render statistics.
@immutable
class StatValueFormatResult {
  const StatValueFormatResult({
    required this.valueText,
    this.unitText,
    required this.stackUnit,
  });

  final String valueText;
  final String? unitText;
  final bool stackUnit;

  /// Convenience accessor that joins value and unit for assertions/logging.
  String get displayText {
    final trimmedUnit = unitText?.trim();
    if (trimmedUnit == null || trimmedUnit.isEmpty) {
      return valueText;
    }
    return stackUnit ? '$valueText\n$trimmedUnit' : '$valueText $trimmedUnit';
  }
}

/// Formats numeric stat values according to the current locale and unit layout.
StatValueFormatResult formatStatValue({
  required Locale locale,
  num? value,
  String? unit,
  bool stackUnit = false,
}) {
  final trimmedUnit = unit?.trim();
  final hasUnit = trimmedUnit != null && trimmedUnit.isNotEmpty;
  final hasNumericValue = value != null;
  final numberText = hasNumericValue
      ? NumberFormat.decimalPattern(locale.toString()).format(value)
      : '--';

  return StatValueFormatResult(
    valueText: numberText,
    unitText: hasUnit && hasNumericValue ? trimmedUnit : null,
    stackUnit: hasUnit && hasNumericValue ? stackUnit : false,
  );
}
