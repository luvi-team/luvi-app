import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';

void main() {
  group('debugSanitizeError', () {
    test('redacts phone numbers with at least ten digits', () {
      final sanitized = debugSanitizeError('Call me at +49 170 123 4567');
      expect(sanitized, contains('[redacted-phone]'));
      expect(sanitized, isNot(contains('170 123 4567')));
      expect(sanitized, isNot(contains('+49 170 123 4567')));
    });

    test('redacts email addresses', () {
      const email = 'user+alerts@example.com';
      final sanitized = debugSanitizeError(
        'Reach out to $email if anything breaks.',
      );
      expect(sanitized, contains('[redacted-email]'));
      expect(sanitized, isNot(contains(email)));
      expect(sanitized, isNot(contains('example.com')));
    });

    // A null result signals that no sanitization was necessary because the input
    // was deemed safe (no redactions performed).
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

    test('redacts multiple PII types in a single string', () {
      const email = 'user@example.com';
      const phone = '1234567890'; // 10 digits boundary
      const uuid = '123e4567-e89b-12d3-a456-426614174000';
      final sanitized = debugSanitizeError(
        'Contact $email or call $phone (trace $uuid) for help',
      );

      // All tokens should be present
      expect(sanitized, contains('[redacted-email]'));
      expect(sanitized, contains('[redacted-phone]'));
      expect(sanitized, contains('[redacted-uuid]'));

      // Original sensitive substrings should be absent
      expect(sanitized, isNot(contains(email)));
      expect(sanitized, isNot(contains(phone)));
      expect(sanitized, isNot(contains(uuid)));
    });

    test('returns null for empty input (no redaction)', () {
      final sanitized = debugSanitizeError('');
      expect(sanitized, isNull);
    });

    test('redacts exactly 10-digit phone numbers (boundary)', () {
      final sanitized = debugSanitizeError('Call 1234567890');
      expect(sanitized, contains('[redacted-phone]'));
      expect(sanitized, isNot(contains('1234567890')));
    });

    test('handles very long mixed-content strings efficiently', () {
      const email = 'long.user+service@example.org';
      const phone = '+1 (404) 555-1234 ext. 9';
      const uuid = '123e4567-e89b-12d3-a456-426614174000';
      final buffer = StringBuffer();
      for (int i = 0; i < 200; i++) {
        buffer.writeln('Log line $i: ok value=42, status=ok');
        if (i % 25 == 0) buffer.writeln('contact $email');
        if (i % 40 == 0) buffer.writeln('phone $phone');
        if (i % 33 == 0) buffer.writeln('trace=$uuid');
      }
      final veryLong = buffer.toString();
      final sanitized = debugSanitizeError(veryLong);

      // Ensure all relevant redactions occurred at least once
      expect(sanitized, contains('[redacted-email]'));
      expect(sanitized, contains('[redacted-phone]'));
      expect(sanitized, contains('[redacted-uuid]'));

      // Check that originals are not present
      expect(sanitized, isNot(contains(email)));
      expect(sanitized, isNot(contains('+1 (404) 555-1234')));
      expect(sanitized, isNot(contains(uuid)));
    });
  });
}
