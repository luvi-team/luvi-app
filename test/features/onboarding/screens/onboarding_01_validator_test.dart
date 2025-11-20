import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/utils/name_validator.dart';

// Onboarding reuses the auth name validator; keep the test nearby to guard
// regressions until we extract shared validator fixtures.

String _repeatChar(String char, int count) => List.filled(count, char).join();

void main() {
  group('nonEmptyNameValidator (default constraints)', () {
    test('rejects empty or whitespace-only names', () {
      expect(nonEmptyNameValidator(''), isFalse);
      expect(nonEmptyNameValidator('   '), isFalse);
    });

    test('accepts trimmed names while ignoring surrounding whitespace', () {
      expect(nonEmptyNameValidator('Claire'), isTrue);
      expect(nonEmptyNameValidator('  Claire  '), isTrue);
    });

    test('rejects names with special characters or numbers', () {
      expect(nonEmptyNameValidator('Cl@ire123'), isFalse);
    });

    test('enforces min/max grapheme length boundaries', () {
      expect(nonEmptyNameValidator('A'), isFalse); // too short (<2)
      expect(nonEmptyNameValidator('Al'), isTrue); // min length
      expect(
        nonEmptyNameValidator(_repeatChar('a', 50)),
        isTrue,
        reason: '50 characters allowed',
      );
      expect(
        nonEmptyNameValidator(_repeatChar('a', 51)),
        isFalse,
        reason: '51 characters exceed default max length (50)',
      );
    });
  });
}
