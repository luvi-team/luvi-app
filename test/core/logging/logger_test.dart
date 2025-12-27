import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/logging/logger.dart';

void main() {
  group('Logger', () {
    late List<String> capturedLogs;
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      capturedLogs = [];
      // Save original debugPrint before overwriting
      originalDebugPrint = debugPrint;
      // Capture debugPrint output for verification
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) capturedLogs.add(message);
      };
    });

    tearDown(() {
      // Restore original debugPrint behavior
      debugPrint = originalDebugPrint;
    });

    group('basic logging methods', () {
      test('log.d formats debug messages correctly', () {
        log.d('test debug message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first, contains('[D]'));
        expect(capturedLogs.first, contains('test debug message'));
      });

      test('log.i formats info messages correctly', () {
        log.i('test info message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first, contains('[I]'));
        expect(capturedLogs.first, contains('test info message'));
      });

      test('log.w formats warning messages correctly', () {
        log.w('test warning message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first, contains('[W]'));
        expect(capturedLogs.first, contains('test warning message'));
      });

      test('log.e formats error messages correctly', () {
        log.e('test error message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first, contains('[E]'));
        expect(capturedLogs.first, contains('test error message'));
      });
    });

    group('tag formatting', () {
      test('includes tag when provided', () {
        log.d('message', tag: 'TestTag');

        expect(capturedLogs.first, contains('[TestTag]'));
      });

      test('omits tag bracket when tag is null', () {
        log.d('message');

        expect(capturedLogs.first, isNot(contains('[]')));
      });

      test('omits tag bracket when tag is empty', () {
        log.d('message', tag: '');

        expect(capturedLogs.first, isNot(contains('[]')));
      });
    });

    group('error and stack handling', () {
      test('log.e includes error object', () {
        log.e('error occurred', error: Exception('test exception'));

        expect(capturedLogs.first, contains('error occurred'));
        expect(capturedLogs.first, contains('Exception'));
      });

      test('log.w includes error object', () {
        log.w('warning occurred', error: 'string error');

        expect(capturedLogs.first, contains('warning occurred'));
        expect(capturedLogs.first, contains('string error'));
      });

      test('log.e handles null message gracefully', () {
        log.e(null, error: 'some error');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first, contains('[E]'));
      });
    });

    group('sanitization', () {
      test('sanitizes potential email in message', () {
        log.d('User email: test@example.com logged in');

        // Sanitization should redact or mask the email
        expect(capturedLogs.first, isNot(contains('test@example.com')));
        expect(capturedLogs.first, contains('[redacted-email]'));
      });

      test('sanitizes Bearer token in message', () {
        log.d('Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');

        // Sanitization should redact Bearer tokens
        expect(capturedLogs.first, contains('[redacted-token]'));
        expect(capturedLogs.first, isNot(contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')));
      });

      test('sanitizes UUID in message', () {
        log.d('User ID: 550e8400-e29b-41d4-a716-446655440000');

        // Sanitization should redact UUIDs
        expect(capturedLogs.first, contains('[redacted-uuid]'));
        expect(capturedLogs.first, isNot(contains('550e8400-e29b-41d4-a716-446655440000')));
      });
    });

    group('piiWarning constant', () {
      test('piiWarning is defined and not empty', () {
        expect(piiWarning, isNotEmpty);
        expect(piiWarning, contains('DO NOT LOG PII'));
      });
    });

    group('global log instance', () {
      test('log is a const Logger instance', () {
        expect(log, isA<Logger>());
      });
    });
  });
}
