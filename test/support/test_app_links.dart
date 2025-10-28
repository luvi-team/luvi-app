import 'package:luvi_app/core/config/app_links.dart';

/// Test-only implementation that allows bypassing validation while optionally
/// supplying custom URIs.
class TestAppLinks implements AppLinksApi {
  const TestAppLinks({
    this.privacyOverride,
    this.termsOverride,
    this.bypassValidation = false,
  });

  final Uri? privacyOverride;
  final Uri? termsOverride;
  final bool bypassValidation;

  static const AppLinksApi _prod = ProdAppLinks();

  @override
  Uri get privacyPolicy =>
      privacyOverride ?? Uri.parse('https://example.test/privacy');

  @override
  Uri get termsOfService =>
      termsOverride ?? Uri.parse('https://example.test/terms');

  @override
  bool get hasValidPrivacy => isConfiguredUrl(privacyPolicy);

  @override
  bool get hasValidTerms => isConfiguredUrl(termsOfService);

  @override
  bool isConfiguredUrl(Uri? uri) {
    if (bypassValidation) {
      return true;
    }
    return _prod.isConfiguredUrl(uri);
  }
}
