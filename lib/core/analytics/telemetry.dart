import 'package:flutter/foundation.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/privacy/telemetry_sanitize.dart';

/// Minimal telemetry facade for MVP. Sentry can be wired behind this interface
/// when enabled via feature flag.
class Telemetry {
  const Telemetry._();

  static bool get _enabled => FeatureFlags.enableLegalViewerTelemetry;

  /// Record a breadcrumb-like event (no stack) for diagnostics.
  static void maybeBreadcrumb(String name, {Map<String, Object?>? data}) {
    if (!_enabled) return;
    // Sanitize payload before emitting.
    final sanitized = sanitizeTelemetryData(data);
    if (data != null && data.isNotEmpty && sanitized.isEmpty) {
      // Soft signal in debug if everything got stripped; do not include raw data.
      if (kDebugMode) {
        log.w('breadcrumb: $name props=[sanitized-empty]', tag: 'telemetry');
      }
      return;
    }
    log.i('breadcrumb: $name props=$sanitized', tag: 'telemetry');
  }

  /// Capture an exception-like event with optional stack and context.
  static void maybeCaptureException(
    String name, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? data,
  }) {
    if (!_enabled) return;
    // Sanitize both properties and error metadata. Do not log raw error or stack.
    final sanitizedProps = sanitizeTelemetryData(data);
    final meta = buildSanitizedExceptionMeta(
      error: error,
      stack: stack,
      props: sanitizedProps.isEmpty ? null : sanitizedProps,
    );
    // MVP: log as error with sanitized metadata only.
    log.e('event: $name meta=$meta', tag: 'telemetry');
  }
}
