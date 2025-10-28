import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/l10n/app_localizations_de.dart';
import 'test_app_links.dart';

/// Centralized configuration for test-specific feature flags used by tests.
class TestConfig {
  TestConfig._();

  /// Ensures shared test-only configuration (feature flags, localized strings) is initialized.
  static void ensureInitialized() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AuthStrings.debugOverrideLocalizations(AppLocalizationsDe());
    AuthStrings.overrideResolver(() => ui.PlatformDispatcher.instance.locale);
    tearDown(() {
      AuthStrings.debugOverrideLocalizations(null);
      AuthStrings.overrideResolver(null);
    });
  }

  /// Preferred test bootstrap to configure shared bindings and test-only overrides.
  static void setup() {
    ensureInitialized();
  }

  static const TestAppLinks defaultAppLinks =
      TestAppLinks(bypassValidation: true);

  /// Controls whether tests verify Dashboard V2 (new) or V1 (legacy) behavior.
  ///
  /// Configure via `--dart-define=FEATURE_DASHBOARD_V2=true|false` when running
  /// Flutter tests to toggle the exercised code paths.
  static bool get featureDashboardV2 => FeatureFlags.featureDashboardV2;
}
