import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:luvi_app/features/dashboard/utils/stats_value_formatter.dart';

void main() {
  setUpAll(() {
    Intl.defaultLocale = 'de';
  });

  const germanLocale = Locale('de');

  group('formatStatValue', () {
    test('formats thousands with German separators', () {
      final result = formatStatValue(locale: germanLocale, value: 2500);

      expect(result.valueText, '2.500');
      expect(result.displayText, '2.500');
      expect(result.stackUnit, isFalse);
    });

    test('formats fractional numbers with a German comma', () {
      final result = formatStatValue(
        locale: germanLocale,
        value: 1234.56,
        unit: 'km',
      );

      expect(result.valueText, '1.234,56');
      expect(result.displayText, '1.234,56 km');
      expect(result.stackUnit, isFalse);
    });

    test('stacks unit on newline when requested', () {
      final result = formatStatValue(
        locale: germanLocale,
        value: 94,
        unit: 'bpm',
        stackUnit: true,
      );

      expect(result.stackUnit, isTrue);
      expect(result.unitText, 'bpm');
      expect(result.displayText, '94\nbpm');
    });

    test('ignores stacking when no unit is provided', () {
      final result = formatStatValue(
        locale: germanLocale,
        value: 42,
        stackUnit: true,
      );

      expect(result.stackUnit, isFalse);
      expect(result.unitText, isNull);
      expect(result.displayText, '42');
    });

    test('handles null and zero values gracefully', () {
      final nullResult = formatStatValue(
        locale: germanLocale,
        value: null,
        unit: 'kcal',
      );
      final zeroResult = formatStatValue(
        locale: germanLocale,
        value: 0,
        unit: 'kcal',
      );

      expect(nullResult.valueText, '--');
      expect(nullResult.displayText, '--');
      expect(zeroResult.valueText, '0');
      expect(zeroResult.displayText, '0 kcal');
    });

    test('formats large numbers with grouping separators', () {
      final result = formatStatValue(locale: germanLocale, value: 9876543);

      expect(result.valueText, '9.876.543');
      expect(result.displayText, '9.876.543');
    });
  });
}
