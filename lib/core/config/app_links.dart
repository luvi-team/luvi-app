/// Defines the API for retrieving legal link configuration (privacy/terms) and
/// validating whether configured URLs meet production requirements.
abstract class AppLinksApi {
  const AppLinksApi();

  /// Configured privacy policy URL.
  Uri get privacyPolicy;

  /// Configured terms of service URL.
  Uri get termsOfService;

  /// Validates a given URL against production requirements.
  bool isConfiguredUrl(Uri? uri);

  /// True when [privacyPolicy] passes [isConfiguredUrl].
  bool get hasValidPrivacy => isConfiguredUrl(privacyPolicy);

  /// True when [termsOfService] passes [isConfiguredUrl].
  bool get hasValidTerms => isConfiguredUrl(termsOfService);
}

/// Production implementation that reads URLs from --dart-define values and
/// enforces validation without any test-specific bypasses.
class ProdAppLinks implements AppLinksApi {
  const ProdAppLinks();

  static const _sentinelUrl = 'about:blank';
  static const _rawPrivacyUrl = String.fromEnvironment('PRIVACY_URL');
  static const _rawTermsUrl = String.fromEnvironment('TERMS_URL');
  static final Uri _sentinelUri = Uri.parse(_sentinelUrl);
  static final String _sentinelScheme =
      _sentinelUri.scheme.trim().toLowerCase();
  static final String _sentinelHost = _sentinelUri.host.trim().toLowerCase();
  static final String _sentinelPath = _sentinelUri.path.trim().toLowerCase();

  static final Uri _privacyPolicy = _parseConfiguredUri(
    rawValue: _rawPrivacyUrl,
    defaultValue: _sentinelUrl,
  );
  static final Uri _termsOfService = _parseConfiguredUri(
    rawValue: _rawTermsUrl,
    defaultValue: _sentinelUrl,
  );

  @override
  Uri get privacyPolicy => _privacyPolicy;

  @override
  Uri get termsOfService => _termsOfService;

  @override
  bool get hasValidPrivacy => isConfiguredUrl(privacyPolicy);

  @override
  bool get hasValidTerms => isConfiguredUrl(termsOfService);

  @override
  bool isConfiguredUrl(Uri? uri) {
    if (uri == null) return false;
    if (uri == _sentinelUri) return false;

    final scheme = uri.scheme.trim().toLowerCase();
    final host = uri.host.trim().toLowerCase();
    final path = uri.path.trim().toLowerCase();
    final isSentinelMatch =
        scheme == _sentinelScheme && host == _sentinelHost && path == _sentinelPath;
    if (isSentinelMatch) return false;
    if (scheme.isEmpty || host.isEmpty) return false;

    if (scheme != 'https') return false;
    const prohibitedExactHosts = {
      'example.com',
      'localhost',
      '::1',
      '0.0.0.0',
    };
    if (prohibitedExactHosts.contains(host)) {
      return false;
    }
    if (host.startsWith('127.')) return false;
    if (host.endsWith('.local') || host.endsWith('.localhost')) return false;
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
