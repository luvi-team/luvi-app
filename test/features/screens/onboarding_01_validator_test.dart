import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/utils/name_validator.dart';

void main() {
  test('nonEmptyNameValidator returns false for empty input', () {
    expect(nonEmptyNameValidator(''), isFalse);
  });

  test('nonEmptyNameValidator returns true for Claire', () {
    expect(nonEmptyNameValidator('Claire'), isTrue);
  });
}
