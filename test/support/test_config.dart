// Import ONLY inside tests (never from lib/). Provides shared test config.
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/l10n/app_localizations_de.dart';

/// Centralized configuration for test-specific feature flags used by tests.
class TestConfig {
  TestConfig._();

  /// Ensures shared test-only configuration (feature flags, localized strings) is initialized.
  static void ensureInitialized() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AuthStrings.debugOverrideLocalizations(AppLocalizationsDe());
  }

  /// Controls whether tests verify Dashboard V2 (new) or V1 (legacy) behavior.
  ///
  /// Configure via `--dart-define=FEATURE_DASHBOARD_V2=true|false` when running
  /// Flutter tests to toggle the exercised code paths.
  static bool get featureDashboardV2 => FeatureFlags.featureDashboardV2;
}
