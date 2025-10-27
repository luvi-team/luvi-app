// Import ONLY inside tests (never from lib/). Provides shared test config.
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/config/feature_flags.dart';

/// Centralized configuration for test-specific feature flags used by tests.
class TestConfig {
  TestConfig._();

  /// Controls whether tests verify Dashboard V2 (new) or V1 (legacy) behavior.
  ///
  /// Configure via `--dart-define=FEATURE_DASHBOARD_V2=true|false` when running
  /// Flutter tests to toggle the exercised code paths.
  static bool get featureDashboardV2 => FeatureFlags.featureDashboardV2;
}

bool _legalLinksBypassRegistered = false;

void _registerLegalLinksBypass() {
  if (_legalLinksBypassRegistered) {
    return;
  }
  _legalLinksBypassRegistered = true;
  AppLinks.bypassValidationForTests = true;
}

// ignore: unused_element
final bool _testConfigBootstrap = (() {
  _registerLegalLinksBypass();
  return true;
})();
