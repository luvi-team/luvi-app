/// Centralized feature-flag registry for runtime configuration.
///
/// Flags fall back to compile-time `--dart-define` values so release builds can
/// ship with stable defaults, while local development keeps the same baseline.
/// Remote or in-app toggles can override defaults via the provided setters.
class FeatureFlags {
  const FeatureFlags._();

  // Note: Not thread-safe. Assumes single-threaded access or external synchronization.
  static bool? _dashboardV2Override;

  /// Allows runtime systems (e.g. remote config, QA toggles) to override
  /// Dashboard V2 availability without rebuilding the app.
  static void setDashboardV2Override(bool? value) {
    _dashboardV2Override = value;
  }

  /// Resets runtime overrides so tests remain isolated between runs.
  static void resetOverrides() {
    _dashboardV2Override = null;
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

  /// Consent v1 flag: defaults to `true` but can be toggled via
  /// `--dart-define=enable_consent_v1=false`.
  static bool get enableConsentV1 =>
      const String.fromEnvironment('enable_consent_v1', defaultValue: 'true') ==
      'true';

  /// FTUE backend allow flag (S0 backout): defaults to `true` but can be
  /// toggled via `--dart-define=allow_ftue_backend=false`.
  static bool get allowFtueBackend =>
      const String.fromEnvironment('allow_ftue_backend', defaultValue: 'true') ==
      'true';

  /// Google Sign-In enable flag: toggle via `--dart-define=enable_google_sign_in=false`.
  static bool get enableGoogleSignIn =>
      const String.fromEnvironment('enable_google_sign_in', defaultValue: 'true') ==
      'true';

  /// Apple Sign-In enable flag: toggle via `--dart-define=enable_apple_sign_in=false`.
  static bool get enableAppleSignIn =>
      const String.fromEnvironment('enable_apple_sign_in', defaultValue: 'true') ==
      'true';
}
