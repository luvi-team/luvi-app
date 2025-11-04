import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/legal/legal_viewer.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared app link constants (non-instance based)
class AppLinks {
  AppLinks._(); // Private constructor prevents instantiation
  
  // OAuth redirect URI used for mobile deep linking. Configurable via --dart-define.
  static const String oauthRedirectUri = String.fromEnvironment(
    'OAUTH_REDIRECT_URI',
    defaultValue: 'luvi://auth-callback',
  );
}

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
class ProdAppLinks extends AppLinksApi {
  const ProdAppLinks();

  static const _sentinelUrl = 'about:blank';
  static const _rawPrivacyUrl = String.fromEnvironment('PRIVACY_URL');
  static const _rawTermsUrl = String.fromEnvironment('TERMS_URL');
  static final Uri _sentinelUri = Uri.parse(_sentinelUrl);

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
  bool isConfiguredUrl(Uri? uri) {
    if (uri == null) return false;
    if (uri == _sentinelUri) return false;

    final scheme = uri.scheme.trim().toLowerCase();
    final host = uri.host.trim().toLowerCase();
    if (scheme.isEmpty || host.isEmpty) return false;

    if (scheme != 'https') return false;
    const prohibitedExactHosts = {'example.com', 'localhost', '::1', '0.0.0.0'};
    if (prohibitedExactHosts.contains(host)) {
      return false;
    }
    if (host.startsWith('127.')) return false;
    // Block IPv6 local ranges: fe80:: (link-local), fc00:: and fd00:: (unique local)
    if (host.startsWith('fe80:') || host.startsWith('fc00:') || host.startsWith('fd00:')) {
      return false;
    }
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
      final fallback = Uri.tryParse(defaultValue);
      if (fallback == null) {
        throw FormatException('Invalid default URL: $defaultValue');
      }
      return fallback;
    }
    return parsed;
  }
}

/// Riverpod provider for [AppLinksApi].
///
/// Defaults to [ProdAppLinks] but can be overridden in tests or
/// higher in the widget tree for custom environments.
final appLinksProvider = Provider<AppLinksApi>((ref) => const ProdAppLinks());

/// Opens a legal link externally when valid, otherwise falls back to
/// an in-app Markdown viewer bundled with the app.
Future<void> openPrivacy(
  BuildContext context, {
  AppLinksApi appLinks = const ProdAppLinks(),
  String? title,
}) async {
  final l10n = AppLocalizations.of(context);
  final resolvedTitle =
      title ?? l10n?.privacyPolicyTitle ?? 'Privacy Policy';
  await _openLegal(
    context,
    uri: appLinks.privacyPolicy,
    isValid: appLinks.hasValidPrivacy,
    fallbackAsset: 'docs/privacy/privacy.md',
    title: resolvedTitle,
  );
}

/// Opens a legal link externally when valid, otherwise falls back to
/// an in-app Markdown viewer bundled with the app.
Future<void> openTerms(
  BuildContext context, {
  AppLinksApi appLinks = const ProdAppLinks(),
  String? title,
}) async {
  final l10n = AppLocalizations.of(context);
  final resolvedTitle =
      title ?? l10n?.termsOfServiceTitle ?? 'Terms of Service';
  await _openLegal(
    context,
    uri: appLinks.termsOfService,
    isValid: appLinks.hasValidTerms,
    fallbackAsset: 'docs/privacy/terms.md',
    title: resolvedTitle,
  );
}

Future<void> _openLegal(
  BuildContext context, {
  required Uri uri,
  required bool isValid,
  required String fallbackAsset,
  required String title,
}) async {
  // Try external if valid
  if (isValid) {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (ok) return;
  }
  if (!context.mounted) return;
  // Fallback to in-app Markdown viewer
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LegalViewer.asset(fallbackAsset, title: title),
    ),
  );
}
