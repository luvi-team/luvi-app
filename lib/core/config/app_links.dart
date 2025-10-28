class AppLinks {
  /// Sentinel placeholder to guard against missing --dart-define overrides.
  static const _sentinelUrl = 'about:blank';
  static const _rawPrivacyUrl = String.fromEnvironment('PRIVACY_URL');
  static const _rawTermsUrl = String.fromEnvironment('TERMS_URL');
  static bool bypassValidationForTests = false;

  /// Sentinel value signals that `PRIVACY_URL` is missing and must be provided for production builds.
  // Sentinel (about:blank) → in Produktion per --dart-define überschreiben.
  static final Uri privacyPolicy = _parseConfiguredUri(
    rawValue: _rawPrivacyUrl,
    defaultValue: _sentinelUrl,
  );

  /// Sentinel value signals that `TERMS_URL` is missing and must be provided for production builds.
  // Sentinel (about:blank) → in Produktion per --dart-define überschreiben.
  static final Uri termsOfService = _parseConfiguredUri(
    rawValue: _rawTermsUrl,
    defaultValue: _sentinelUrl,
  );

  static bool get hasValidPrivacy => _isConfiguredUrl(privacyPolicy);
  static bool get hasValidTerms => _isConfiguredUrl(termsOfService);

  static bool _isConfiguredUrl(Uri? uri) {
    if (bypassValidationForTests) return true;
    if (uri == null) return false;
    if (uri.toString() == _sentinelUrl) return false;

    final scheme = uri.scheme.trim().toLowerCase();
    final host = uri.host.trim().toLowerCase();
    if (scheme.isEmpty || host.isEmpty) return false;

    if (scheme != 'https') return false;
    const disallowedHosts = {'example.com', 'localhost', '127.0.0.1'};
    if (disallowedHosts.contains(host)) return false;
    return true;
  }

  static Uri _parseConfiguredUri({
    required String rawValue,
    required String defaultValue,
  }) {
    final effectiveValue = rawValue.isEmpty ? defaultValue : rawValue;
    final trimmed = effectiveValue.trim();
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) {
      return Uri.parse(defaultValue);
    }
    return parsed;
  }
}
