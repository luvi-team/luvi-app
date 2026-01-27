import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/privacy/telemetry_sanitize.dart';

void main() {
  group('sanitizeTelemetryData', () {
    test('should return empty map for null input', () {
      final result = sanitizeTelemetryData(null);
      expect(result, isEmpty);
    });

    test('should return empty map for empty input', () {
      final result = sanitizeTelemetryData(<String, Object?>{});
      expect(result, isEmpty);
    });

    test('should pass through primitive types', () {
      final input = <String, Object?>{
        'intValue': 42,
        'doubleValue': 3.14,
        'boolValue': true,
      };
      final result = sanitizeTelemetryData(input);

      expect(result['intValue'], equals(42));
      expect(result['doubleValue'], equals(3.14));
      expect(result['boolValue'], equals(true));
    });

    test('should redact known sensitive keys', () {
      final input = <String, Object?>{
        'email': 'user@example.com',
        'password': 'secret123',
        'token': 'abc123',
        'normalKey': 'public',
      };
      final result = sanitizeTelemetryData(input);

      expect(result['email'], equals('[redacted]'));
      expect(result['password'], equals('[redacted]'));
      expect(result['token'], equals('[redacted]'));
      // Normal key should be sanitized but not redacted
      expect(result['normalKey'], isNot(equals('[redacted]')));
    });

    test('should redact sensitive keys case-insensitively', () {
      final input = <String, Object?>{
        'EMAIL': 'user@example.com',
        'Password': 'secret123',
        'TOKEN': 'abc123',
      };
      final result = sanitizeTelemetryData(input);

      expect(result['EMAIL'], equals('[redacted]'));
      expect(result['Password'], equals('[redacted]'));
      expect(result['TOKEN'], equals('[redacted]'));
    });

    test('should handle nested maps recursively', () {
      final input = <String, Object?>{
        'metadata': <String, Object?>{
          'label': 'John',
          'email': 'john@example.com',
        },
      };
      final result = sanitizeTelemetryData(input);

      expect(result['metadata'], isA<Map>());
      final metadataMap = result['metadata'] as Map<String, Object?>;
      expect(metadataMap['email'], equals('[redacted]'));
    });

    test('should handle lists recursively', () {
      final input = <String, Object?>{
        'items': [
          <String, Object?>{'id': 1, 'email': 'a@b.com'},
          <String, Object?>{'id': 2, 'email': 'c@d.com'},
        ],
      };
      final result = sanitizeTelemetryData(input);

      expect(result['items'], isA<List>());
      final items = result['items'] as List;
      expect(items.length, equals(2));

      final first = items[0] as Map<String, Object?>;
      expect(first['email'], equals('[redacted]'));
    });

    test('should sanitize DateTime to day granularity', () {
      final input = <String, Object?>{
        'timestamp': DateTime.utc(2026, 1, 27, 12, 30, 45),
      };
      final result = sanitizeTelemetryData(input);

      // Default is day granularity
      expect(result['timestamp'], equals('2026-01-27'));
    });

    test('should handle unknown types with type marker', () {
      final input = <String, Object?>{
        'custom': _CustomObject(),
      };
      final result = sanitizeTelemetryData(input);

      expect(result['custom'], equals('<_CustomObject>'));
    });

    test('should handle null values', () {
      final input = <String, Object?>{
        'nullable': null,
        'defined': 'value',
      };
      final result = sanitizeTelemetryData(input);

      expect(result['nullable'], isNull);
    });
  });

  group('buildSanitizedExceptionMeta', () {
    test('should return errorType for null error', () {
      final result = buildSanitizedExceptionMeta();

      expect(result['errorType'], equals('UnknownError'));
      expect(result['stackHash'], isA<String>());
    });

    test('should extract error type name', () {
      final result = buildSanitizedExceptionMeta(
        error: ArgumentError('test'),
      );

      expect(result['errorType'], equals('ArgumentError'));
    });

    test('should include stack hash when provided', () {
      final result = buildSanitizedExceptionMeta(
        error: Exception('test'),
        stack: StackTrace.current,
      );

      expect(result['stackHash'], isA<String>());
      expect((result['stackHash'] as String).length, equals(8));
    });

    test('should include props when provided', () {
      final props = <String, Object?>{'key': 'value'};
      final result = buildSanitizedExceptionMeta(
        error: Exception('test'),
        props: props,
      );

      expect(result['props'], isNotNull);
    });

    test('should not include props key when empty', () {
      final result = buildSanitizedExceptionMeta(
        error: Exception('test'),
        props: <String, Object?>{},
      );

      expect(result.containsKey('props'), isFalse);
    });
  });

  group('TelemetryDateSanitization', () {
    test('should have all expected values', () {
      expect(TelemetryDateSanitization.values.length, equals(4));
      expect(TelemetryDateSanitization.values,
          contains(TelemetryDateSanitization.day));
      expect(TelemetryDateSanitization.values,
          contains(TelemetryDateSanitization.hour));
      expect(TelemetryDateSanitization.values,
          contains(TelemetryDateSanitization.redacted));
      expect(TelemetryDateSanitization.values,
          contains(TelemetryDateSanitization.hash));
    });
  });
}

// Helper class for testing unknown type handling
class _CustomObject {}
