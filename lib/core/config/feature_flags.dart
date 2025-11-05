/// Centralized feature-flag registry for runtime configuration.
///
/// Flags fall back to compile-time `--dart-define` values so release builds can
/// ship with stable defaults, while local development keeps the same baseline.
/// Remote or in-app toggles can override defaults via the provided setters.
class FeatureFlags {
  const FeatureFlags._();

  // Note: Not thread-safe. Assumes single-threaded access or external synchronization.
  static bool? _dashboardV2Override;
  static bool? _consentV1Override;
  static bool? _enableFtueBackendOverride;
  static bool? _googleSignInOverride;
  static bool? _appleSignInOverride;
  static bool? _legalViewerTelemetryOverride;

  /// Allows runtime systems (e.g. remote config, QA toggles) to override
  /// Dashboard V2 availability without rebuilding the app.
  static void setDashboardV2Override(bool? value) {
    _dashboardV2Override = value;
  }

  /// Allows runtime systems to override Consent V1 availability.
  static void setConsentV1Override(bool? value) {
    _consentV1Override = value;
  }

  /// Allows runtime systems to override FTUE backend enable flag.
  static void setEnableFtueBackendOverride(bool? value) {
    _enableFtueBackendOverride = value;
  }

  /// Allows runtime systems to override Google Sign-In availability.
  static void setGoogleSignInOverride(bool? value) {
    _googleSignInOverride = value;
  }

  /// Allows runtime systems to override Apple Sign-In availability.
  static void setAppleSignInOverride(bool? value) {
    _appleSignInOverride = value;
  }

  /// Allows runtime systems to toggle telemetry for the legal viewer (e.g., Sentry).
  static void setLegalViewerTelemetryOverride(bool? value) {
    _legalViewerTelemetryOverride = value;
  }

  /// Resets runtime overrides so tests remain isolated between runs.
  static void resetOverrides() {
    _dashboardV2Override = null;
    _consentV1Override = null;
    _enableFtueBackendOverride = null;
    _googleSignInOverride = null;
    _appleSignInOverride = null;
    _legalViewerTelemetryOverride = null;
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
  /// `--dart-define=FEATURE_CONSENT_V1=false`.
  static bool get enableConsentV1 {
    final override = _consentV1Override;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment('FEATURE_CONSENT_V1', defaultValue: true);
  }

  /// FTUE backend enable flag (S0 backout): defaults to `true` but can be
  /// toggled via `--dart-define=FEATURE_ENABLE_FTUE_BACKEND=false`.
  static bool get enableFtueBackend {
    final override = _enableFtueBackendOverride;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment(
      'FEATURE_ENABLE_FTUE_BACKEND',
      defaultValue: true,
    );
  }

  /// Google Sign-In enable flag: toggle via `--dart-define=FEATURE_GOOGLE_SIGN_IN=false`.
  static bool get enableGoogleSignIn {
    final override = _googleSignInOverride;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment(
      'FEATURE_GOOGLE_SIGN_IN',
      defaultValue: true,
    );
  }

  /// Apple Sign-In enable flag: toggle via `--dart-define=FEATURE_APPLE_SIGN_IN=false`.
  static bool get enableAppleSignIn {
    final override = _appleSignInOverride;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment(
      'FEATURE_APPLE_SIGN_IN',
      defaultValue: true,
    );
  }
}

extension FeatureFlagsTelemetry on FeatureFlags {
  /// Enable Sentry/telemetry for legal viewer. Default false; gate via
  /// `--dart-define=FEATURE_SENTRY_LEGAL_VIEWER=true` or runtime override.
  static bool get enableLegalViewerTelemetry {
    final override = FeatureFlags._legalViewerTelemetryOverride;
    if (override != null) return override;
    return const bool.fromEnvironment(
      'FEATURE_SENTRY_LEGAL_VIEWER',
      defaultValue: false,
    );
  }
}
