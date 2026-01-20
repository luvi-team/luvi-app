import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/utils/create_new_password_rules.dart';

void main() {
  group('validateNewPassword', () {
    test('detects empty fields', () {
      final result = validateNewPassword('', '');
      expect(result.isValid, isFalse);
      expect(result.error, AuthPasswordValidationError.emptyFields);
    });

    test('detects mismatch', () {
      final result = validateNewPassword('Abcdef1!', 'Mismatch1!');
      expect(result.error, AuthPasswordValidationError.mismatch);
    });

    test('detects too short passwords', () {
      final result = validateNewPassword('Ab1!', 'Ab1!');
      expect(result.error, AuthPasswordValidationError.tooShort);
    });

    test('accepts passwords without special characters (NIST SP 800-63B)', () {
      // Per NIST SP 800-63B: Character composition rules are not recommended.
      // We only require minimum length (8+) and blocklist check.
      // Note: "Password1" is blocklisted, so we use a different example.
      final result = validateNewPassword('MySecret1', 'MySecret1');
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });

    test('flags common weak patterns', () {
      final result = validateNewPassword('ab!2ab!2', 'ab!2ab!2');
      expect(result.error, AuthPasswordValidationError.commonWeak);
    });

    test('accepts passwords meeting minimum length requirement', () {
      // Any 8+ character password not in blocklist should be valid
      final result = validateNewPassword('validTestPw8', 'validTestPw8');
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });
  });
}
