/// Centralized feature-flag registry for runtime configuration.
///
/// Flags fall back to compile-time `--dart-define` values so release builds can
/// ship with stable defaults, while local development keeps the same baseline.
/// Remote or in-app toggles can override defaults via the provided setters.
class FeatureFlags {
  const FeatureFlags._();

  static bool? _dashboardV2Override;

  /// Allows runtime systems (e.g. remote config, QA toggles) to override
  /// Dashboard V2 availability without rebuilding the app.
  static void setDashboardV2Override(bool? value) {
    _dashboardV2Override = value;
  }

  /// Dashboard V2 flag: defaults to `true` but can be toggled via
  /// `--dart-define=FEATURE_DASHBOARD_V2=false` or runtime overrides.
  static bool get featureDashboardV2 {
    final override = _dashboardV2Override;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment(
      'FEATURE_DASHBOARD_V2',
      defaultValue: true,
    );
  }
}
