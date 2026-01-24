import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';

void main() {
  group('payloadDiagnosticsShapeOnly (P0.2 Privacy Fix)', () {
    test('returns type=null for null payload', () {
      expect(payloadDiagnosticsShapeOnly(null), equals('type=null'));
    });

    test('returns type and sorted keys for Map payload', () {
      final result = payloadDiagnosticsShapeOnly({
        'zebra': 'secret_value',
        'apple': 123,
        'banana': true,
      });
      // Keys should be sorted alphabetically, values should NOT appear
      expect(result, equals('type=Map, keys=[apple, banana, zebra]'));
      expect(result, isNot(contains('secret_value')));
      expect(result, isNot(contains('123')));
    });

    test('truncates keys to 20 with ellipsis for large Maps', () {
      final largeMap = {for (var i = 0; i < 25; i++) 'key$i': 'value$i'};
      final result = payloadDiagnosticsShapeOnly(largeMap);

      expect(result, startsWith('type=Map, keys=['));
      expect(result, endsWith('...]'));
      // Should only have 20 keys listed
      final keyMatches = RegExp(r'key\d+').allMatches(result);
      expect(keyMatches.length, equals(20));
    });

    test('returns type and length for List payload', () {
      final result = payloadDiagnosticsShapeOnly([
        'secret1',
        'secret2',
        {'nested': 'data'},
      ]);
      expect(result, equals('type=List, length=3'));
      // Values should NOT appear
      expect(result, isNot(contains('secret')));
      expect(result, isNot(contains('nested')));
    });

    test('returns runtimeType for other types (String)', () {
      final result = payloadDiagnosticsShapeOnly('sensitive_string_data');
      expect(result, equals('type=String'));
      expect(result, isNot(contains('sensitive')));
    });

    test('returns runtimeType for other types (int)', () {
      expect(payloadDiagnosticsShapeOnly(42), equals('type=int'));
    });

    test('returns runtimeType for other types (bool)', () {
      expect(payloadDiagnosticsShapeOnly(true), equals('type=bool'));
    });

    test('handles empty Map correctly', () {
      expect(payloadDiagnosticsShapeOnly({}), equals('type=Map, keys=[]'));
    });

    test('handles empty List correctly', () {
      expect(payloadDiagnosticsShapeOnly([]), equals('type=List, length=0'));
    });

    test('handles nested Map without exposing nested values', () {
      final result = payloadDiagnosticsShapeOnly({
        'user': {'email': 'test@example.com', 'password': 'secret123'},
        'token': 'jwt_token_here',
      });
      expect(result, equals('type=Map, keys=[token, user]'));
      expect(result, isNot(contains('email')));
      expect(result, isNot(contains('password')));
      expect(result, isNot(contains('secret')));
      expect(result, isNot(contains('jwt')));
    });

    test('PRIVACY: never exposes actual values in any scenario', () {
      // This is the critical privacy test - ensure no PII leaks
      const sensitivePayloads = [
        {'email': 'user@example.com', 'ssn': '123-45-6789'},
        ['password123', 'credit_card_number'],
        'raw_user_input_with_pii',
      ];

      for (final payload in sensitivePayloads) {
        final result = payloadDiagnosticsShapeOnly(payload);
        expect(result, isNot(contains('user@')));
        expect(result, isNot(contains('123-45')));
        expect(result, isNot(contains('password')));
        expect(result, isNot(contains('credit')));
        expect(result, isNot(contains('raw_user')));
      }
    });

    test('handles Map with complex keys (reports type only)', () {
      // Complex keys like List as key - payloadDiagnosticsShapeOnly should
      // report type info without values (keys are complex, not iterable as strings)
      final complexKeyMap = <Object, dynamic>{
        const ['list', 'key']: 'value', // List as key
      };

      final result = payloadDiagnosticsShapeOnly(complexKeyMap);

      // Verify basic type reporting
      expect(result, startsWith('type=Map'));

      // Verify keys structure indicator is present
      expect(
        result,
        contains('keys='),
        reason: 'Output should include keys= to show structure',
      );

      // PRIVACY: Should not expose actual map values
      expect(
        result,
        isNot(contains('value')),
        reason: 'Map values must not be exposed',
      );

      // PRIVACY: Complex keys should be redacted to '<complex:Type>' format
      expect(
        result,
        contains('<complex:'),
        reason: 'Complex keys should be redacted with type placeholder',
      );

      // Verify no List.toString() output leaks (would be "[list, key]")
      // Note: We don't check for bare 'key' as it conflicts with format 'keys='
      expect(
        result,
        isNot(contains('[list')),
        reason: 'List.toString() bracketed content must not appear',
      );
      expect(
        result,
        isNot(contains(', key]')),
        reason: 'List.toString() bracketed content must not appear',
      );
    });
  });
}
