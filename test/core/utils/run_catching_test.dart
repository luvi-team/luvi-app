import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/utils/run_catching.dart';

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

    test('strips control characters even without PII', () {
      final sanitized =
          debugSanitizeError('Line 1\r\nLine 2\twith tabs and newline');
      expect(sanitized, isNotNull);
      expect(sanitized, isNot(contains('\r')));
      expect(sanitized, isNot(contains('\n')));
      expect(sanitized, isNot(contains('\t')));
      expect(sanitized, contains('Line 1'));
      expect(sanitized, contains('Line 2'));
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

  group('tryOrNull (sync)', () {
    test('returns null and invokes onError for Exception', () {
      Object? capturedError;
      StackTrace? capturedStack;

      final result = tryOrNull<int>(
        () => throw Exception('boom'),
        onError: (e, s) {
          capturedError = e;
          capturedStack = s;
        },
      );

      expect(result, isNull);
      expect(capturedError, isA<Exception>());
      expect(capturedStack, isA<StackTrace>());
    });

    test('rethrows Error and invokes onError', () {
      Object? capturedError;
      StackTrace? capturedStack;

      expect(
        () => tryOrNull<void>(
          () => throw StateError('failure'),
          onError: (e, s) {
            capturedError = e;
            capturedStack = s;
          },
        ),
        throwsA(isA<StateError>()),
      );
      expect(capturedError, isA<StateError>());
      expect(capturedStack, isA<StackTrace>());
    });

    test('returns value on success', () {
      final result = tryOrNull<int>(() => 42);
      expect(result, 42);
    });
  });

  group('tryOrNullAsync (async)', () {
    test('returns null and invokes onError for Exception', () async {
      Object? capturedError;
      StackTrace? capturedStack;

      final result = await tryOrNullAsync<int>(
        () async => throw Exception('async boom'),
        onError: (e, s) {
          capturedError = e;
          capturedStack = s;
        },
      );

      expect(result, isNull);
      expect(capturedError, isA<Exception>());
      expect(capturedStack, isA<StackTrace>());
    });

    test('rethrows Error and invokes onError', () async {
      Object? capturedError;
      StackTrace? capturedStack;

      await expectLater(
        tryOrNullAsync<void>(
          () async => throw StateError('async failure'),
          onError: (e, s) {
            capturedError = e;
            capturedStack = s;
          },
        ),
        throwsA(isA<StateError>()),
      );
      expect(capturedError, isA<StateError>());
      expect(capturedStack, isA<StackTrace>());
    });

    test('returns awaited value on success', () async {
      final result = await tryOrNullAsync<int>(() async => 7);
      expect(result, 7);
    });
  });

  group('phone PII helper edge cases', () {
    test('does not count extension digits toward minimum threshold', () {
      // 9 digits + ext. 1 should NOT redact because ext digits are ignored.
      final sanitized = debugSanitizeError('Contact 123 456 789 ext. 1');
      expect(sanitized, isNull);
    });

    test('redacts when base number has >= 10 digits even with extension', () {
      final sanitized = debugSanitizeError('Call 123 456 7890 ext. 123');
      expect(sanitized, contains('[redacted-phone]'));
      expect(sanitized, isNot(contains('123 456 7890')));
    });
  });
}
