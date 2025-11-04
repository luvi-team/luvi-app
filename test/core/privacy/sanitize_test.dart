import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/privacy/sanitize.dart';

void main() {
  group('sanitizeForLog', () {
    test('redacts emails', () {
      final s = 'Contact me at john.doe@example.com';
      expect(sanitizeForLog(s), isNot(contains('john.doe@example.com')));
      expect(sanitizeForLog(s), contains('[redacted-email]'));
    });

    test('redacts Bearer tokens', () {
      final s = 'Authorization: Bearer abc.DEF-123_~+/' 'xyz=';
      final out = sanitizeForLog(s);
      expect(out, contains('Bearer [redacted-token]'));
      expect(out, isNot(contains('abc.DEF-123_~+/xyz=')));
    });

    test('redacts long hex strings', () {
      final s = 'secret 0123456789abcdef0123456789abcdef';
      final out = sanitizeForLog(s);
      expect(out, contains('[redacted-hex]'));
    });

    test('redacts UUIDs', () {
      final s = 'uuid 123e4567-e89b-12d3-a456-426614174000';
      final out = sanitizeForLog(s);
      expect(out, contains('[redacted-uuid]'));
    });

    test('redacts SSN', () {
      final s = 'ssn 123-45-6789';
      final out = sanitizeForLog(s);
      expect(out, contains('[redacted-ssn]'));
    });

    test('redacts likely phone numbers', () {
      final s = 'call +1 (415) 555-2671 ext. 12';
      final out = sanitizeForLog(s);
      expect(out, contains('[redacted-phone]'));
    });

    test('redacts valid credit cards via Luhn', () {
      // 4111 1111 1111 1111 is a well-known Visa test card
      final s = 'cc 4111 1111 1111 1111';
      final out = sanitizeForLog(s);
      expect(out, contains('[redacted-cc]'));
    });

    test('does not redact Luhn-invalid 16-digit sequence', () {
      final s = 'digits 1234 5678 9012 3456'; // most likely fails Luhn
      final out = sanitizeForLog(s);
      // This sequence fails Luhn validation, so should not be redacted
      expect(out, contains('1234 5678 9012 3456'));
      expect(out, isNot(contains('[redacted-cc]')));
    });

    test('keeps neutral text unchanged', () {
      final s = 'operation completed successfully';
      expect(sanitizeForLog(s), equals(s));
    });
  });
}

