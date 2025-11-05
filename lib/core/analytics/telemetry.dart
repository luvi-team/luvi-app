import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/logging/logger.dart';

/// Minimal telemetry facade for MVP. Sentry can be wired behind this interface
/// when enabled via feature flag.
class Telemetry {
  Telemetry._();

  static bool get _enabled => FeatureFlagsTelemetry.enableLegalViewerTelemetry;

  /// Record a breadcrumb-like event (no stack) for diagnostics.
  static void maybeBreadcrumb(String name, {Map<String, Object?>? data}) {
    if (!_enabled) return;
    // MVP: log as info. Replace with Sentry.addBreadcrumb when available.
    log.i('breadcrumb: $name props=${data ?? const {}}', tag: 'telemetry');
  }

  /// Capture an exception-like event with optional stack and context.
  static void maybeCaptureException(
    String name, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? data,
  }) {
    if (!_enabled) return;
    // MVP: log as error. Replace with Sentry.captureException when available.
    log.e('event: $name props=${data ?? const {}}', tag: 'telemetry', error: error, stack: stack);
  }
}

