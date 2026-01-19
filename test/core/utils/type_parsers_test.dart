import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/utils/type_parsers.dart';

void main() {
  group('parseNullableBool', () {
    test('returns true when value is true', () {
      expect(parseNullableBool(true), isTrue);
    });

    test('returns false when value is false', () {
      expect(parseNullableBool(false), isFalse);
    });

    test('returns null when value is null', () {
      expect(parseNullableBool(null), isNull);
    });

    test('returns null when value is String', () {
      expect(parseNullableBool('true'), isNull);
      expect(parseNullableBool('false'), isNull);
    });

    test('returns null when value is int', () {
      expect(parseNullableBool(1), isNull);
      expect(parseNullableBool(0), isNull);
    });

    test('returns null when value is Map', () {
      expect(parseNullableBool(<String, dynamic>{}), isNull);
    });

    test('returns null when value is List', () {
      expect(parseNullableBool(<dynamic>[]), isNull);
    });
  });

  group('parseNullableInt', () {
    test('returns int when value is positive int', () {
      expect(parseNullableInt(42), equals(42));
    });

    test('returns int when value is zero', () {
      expect(parseNullableInt(0), equals(0));
    });

    test('returns int when value is negative int', () {
      expect(parseNullableInt(-1), equals(-1));
    });

    test('returns null when value is null', () {
      expect(parseNullableInt(null), isNull);
    });

    test('returns null when value is String', () {
      expect(parseNullableInt('42'), isNull);
    });

    test('returns int when value is whole-number double', () {
      // JSON parsers often decode integers as doubles (e.g., 42.0)
      expect(parseNullableInt(42.0), equals(42));
      expect(parseNullableInt(0.0), equals(0));
      expect(parseNullableInt(-5.0), equals(-5));
    });

    test('returns null when value is non-whole double', () {
      expect(parseNullableInt(42.5), isNull);
      expect(parseNullableInt(0.1), isNull);
    });

    test('returns null when value is bool', () {
      expect(parseNullableInt(true), isNull);
      expect(parseNullableInt(false), isNull);
    });

    test('returns null for NaN', () {
      expect(parseNullableInt(double.nan), isNull);
    });

    test('returns null for infinity', () {
      expect(parseNullableInt(double.infinity), isNull);
    });

    test('returns null for negative infinity', () {
      expect(parseNullableInt(double.negativeInfinity), isNull);
    });
  });
}
