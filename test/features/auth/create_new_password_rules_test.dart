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

    test('requires letters, numbers, and specials', () {
      final result = validateNewPassword('Password1', 'Password1');
      expect(result.error, AuthPasswordValidationError.missingTypes);
    });

    test('flags common weak patterns', () {
      final result = validateNewPassword('ab!2ab!2', 'ab!2ab!2');
      expect(result.error, AuthPasswordValidationError.commonWeak);
    });

    test('accepts strong passwords', () {
      final result = validateNewPassword('Str0ng!Pass', 'Str0ng!Pass');
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });
  });

  group('computePasswordBackoffDelay', () {
    test('returns zero for non-positive attempts', () {
      expect(
        computePasswordBackoffDelay(0),
        Duration.zero,
      );
    });

    test('doubles delay with each failure up to the cap', () {
      expect(
        computePasswordBackoffDelay(1),
        const Duration(seconds: 4),
      );
      expect(
        computePasswordBackoffDelay(2),
        const Duration(seconds: 8),
      );
    });

    test('caps the delay at one minute', () {
      expect(
        computePasswordBackoffDelay(10),
        const Duration(seconds: 60),
      );
    });
  });
}
