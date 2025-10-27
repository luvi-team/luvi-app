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

  static bool get hasValidPrivacy => _isConfiguredUrl(privacyPolicy);
  static bool get hasValidTerms => _isConfiguredUrl(termsOfService);

  static bool _bypassValidationForTests = false;

  @visibleForTesting
  static bool get bypassValidationForTests => _bypassValidationForTests;

  @visibleForTesting
  static set bypassValidationForTests(bool value) {
    _bypassValidationForTests = value;
  }

  static bool _isConfiguredUrl(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final isHttpScheme = scheme == 'http' || scheme == 'https';
    if (!isHttpScheme) return false;
    if (host.isEmpty || host == 'example.com') return false;
    return true;
  }
}
