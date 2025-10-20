/// Centralized configuration for test-specific feature flags used by tests.
class TestConfig {
  TestConfig._();

  /// Controls whether tests verify Dashboard V2 (new) or V1 (legacy) behavior.
  ///
  /// Configure via `--dart-define=FEATURE_DASHBOARD_V2=true|false` when running
  /// Flutter tests to toggle the exercised code paths.
  static const bool featureDashboardV2 = bool.fromEnvironment(
    'FEATURE_DASHBOARD_V2',
    defaultValue: true,
  );
}
