import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';

void main() {
  group('debugSanitizeError', () {
    test('redacts phone numbers with at least ten digits', () {
      final sanitized = debugSanitizeError('Call me at +49 170 123 4567');
      expect(sanitized, contains('[redacted-phone]'));
      expect(sanitized, isNot(contains('170 123 4567')));
    });

    test('ignores date-like strings', () {
      final sanitized = debugSanitizeError('Event on 2023-10-27 at noon');
      expect(sanitized, isNull);
    });

    test('masks UUID values', () {
      final sanitized = debugSanitizeError(
        'Trace id 123e4567-e89b-12d3-a456-426614174000 failed',
      );
      expect(sanitized, contains('[redacted-uuid]'));
      expect(
        sanitized,
        isNot(contains('123e4567-e89b-12d3-a456-426614174000')),
      );
    });

    test('preserves prefixes while redacting hex identifiers', () {
      final sanitized = debugSanitizeError('token=ABCDEF1234567890FEDCBA');
      expect(sanitized, contains('token=[redacted-id]'));
      expect(sanitized, isNot(contains('ABCDEF1234567890FEDCBA')));
    });

    test('does not redact short numeric values', () {
      final sanitized = debugSanitizeError(
        'Received code 123-4567 from device',
      );
      expect(sanitized, isNull);
    });
  });
}
