import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/validation/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('accepts two-character local parts', () {
      expect(EmailValidator.isValid('ab@example.com'), isTrue);
    });

    test('rejects one-character local parts', () {
      expect(EmailValidator.isValid('a@example.com'), isFalse);
    });

    test('rejects invalid TLDs', () {
      expect(EmailValidator.isValid('user@example.c'), isFalse);
    });
  });
}

