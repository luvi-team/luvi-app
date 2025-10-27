import 'package:flutter/foundation.dart';

class AppLinks {
  static final Uri privacyPolicy = Uri.parse(
    const String.fromEnvironment(
      'PRIVACY_URL',
      defaultValue: 'https://example.com/privacy',
    ),
  );

  static final Uri termsOfService = Uri.parse(
    const String.fromEnvironment(
      'TERMS_URL',
      defaultValue: 'https://example.com/terms',
    ),
  );

  static bool get hasValidPrivacy => privacyPolicy.host != 'example.com';
  static bool get hasValidTerms => termsOfService.host != 'example.com';

  static bool _bypassValidationForTests = false;

  @visibleForTesting
  static bool get bypassValidationForTests => _bypassValidationForTests;

  @visibleForTesting
  static set bypassValidationForTests(bool value) {
    _bypassValidationForTests = value;
  }
}
