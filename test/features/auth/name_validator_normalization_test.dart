import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/utils/name_validator.dart';

void main() {
  test('accepts names with combining accents (graphemes)', () {
    // José written with combining acute on o: Jo\u0301se
    const withCombining = 'Jo\u0301se';
    expect(nonEmptyNameValidator(withCombining), isTrue);
  });

  test('minLength compares grapheme clusters, not code units', () {
    // Single grapheme composed of base + combining: E\u0301
    const singleGrapheme = 'E\u0301';
    expect(nonEmptyNameValidator(singleGrapheme, minLength: 1), isTrue);
    expect(nonEmptyNameValidator(singleGrapheme, minLength: 2), isFalse);

    // Two graphemes: E\u0301 + a
    const twoGraphemes = 'E\u0301a';
    expect(nonEmptyNameValidator(twoGraphemes, minLength: 2), isTrue);
  });
}

