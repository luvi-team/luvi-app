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

  group('permissiveDisplayNameValidator (onboarding)', () {
    test('rejects null and empty strings', () {
      expect(permissiveDisplayNameValidator(null), isFalse);
      expect(permissiveDisplayNameValidator(''), isFalse);
      expect(permissiveDisplayNameValidator('   '), isFalse);
    });

    test('accepts simple Latin names', () {
      expect(permissiveDisplayNameValidator('Claire'), isTrue);
      expect(permissiveDisplayNameValidator('  Claire  '), isTrue);
    });

    test('accepts international names (Unicode)', () {
      expect(permissiveDisplayNameValidator('Müller'), isTrue);
      expect(permissiveDisplayNameValidator('北京'), isTrue); // CJK
      expect(permissiveDisplayNameValidator('Андрей'), isTrue); // Cyrillic
      expect(permissiveDisplayNameValidator('محمد'), isTrue); // Arabic
      expect(permissiveDisplayNameValidator('שרה'), isTrue); // Hebrew
    });

    test('accepts names with emoji', () {
      expect(permissiveDisplayNameValidator('Sarah 💜'), isTrue);
      expect(permissiveDisplayNameValidator('🌟Star🌟'), isTrue);
    });

    test('accepts names with numbers and special characters', () {
      expect(permissiveDisplayNameValidator('Claire123'), isTrue);
      expect(permissiveDisplayNameValidator('O\'Connor'), isTrue);
      expect(permissiveDisplayNameValidator('Anna-Maria'), isTrue);
    });

    test('enforces max grapheme length (50)', () {
      expect(
        permissiveDisplayNameValidator(_repeatChar('a', 50)),
        isTrue,
        reason: '50 graphemes allowed',
      );
      expect(
        permissiveDisplayNameValidator(_repeatChar('a', 51)),
        isFalse,
        reason: '51 graphemes exceed max length',
      );
    });

    test('rejects control characters', () {
      expect(permissiveDisplayNameValidator('Claire\u0000'), isFalse);
      expect(permissiveDisplayNameValidator('Claire\u001F'), isFalse);
      expect(permissiveDisplayNameValidator('Claire\u007F'), isFalse);
      expect(permissiveDisplayNameValidator('\u0001Hidden'), isFalse);
    });

    test('counts emoji as single grapheme', () {
      // 49 'a' + 1 emoji = 50 graphemes
      final almostMax = '${_repeatChar('a', 49)}😀';
      expect(permissiveDisplayNameValidator(almostMax), isTrue);

      // 50 'a' + 1 emoji = 51 graphemes (too long)
      final tooLong = '${_repeatChar('a', 50)}😀';
      expect(permissiveDisplayNameValidator(tooLong), isFalse);
    });
  });
}
