import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/privacy/pii_keys.dart';

void main() {
  group('PiiKeys registry', () {
    test('includes last_name as exact-match key', () {
      expect(PiiKeys.suspiciousKeyNames.contains('last_name'), isTrue);
    });

    test('word pattern matches underscore/hyphen compound tokens', () {
      expect(PiiKeys.suspiciousWordPattern.hasMatch('user_id'), isTrue);
      expect(PiiKeys.suspiciousWordPattern.hasMatch('access_token'), isTrue);
      expect(
        PiiKeys.suspiciousWordPattern.hasMatch('prefix refresh_token suffix'),
        isTrue,
      );
      expect(
        PiiKeys.suspiciousWordPattern.hasMatch('ip-address log entry'),
        isTrue,
      );
      expect(PiiKeys.suspiciousWordPattern.hasMatch('theme'), isFalse);
    });
  });
}
