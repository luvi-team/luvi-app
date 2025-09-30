import 'package:flutter_test/flutter_test.dart';

bool nonEmptyNameValidator(String? value) =>
    value != null && value.trim().isNotEmpty;

void main() {
  test('nonEmptyNameValidator returns false for empty input', () {
    expect(nonEmptyNameValidator(''), isFalse);
  });

  test('nonEmptyNameValidator returns true for Claire', () {
    expect(nonEmptyNameValidator('Claire'), isTrue);
  });
}
