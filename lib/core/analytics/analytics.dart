import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/analytics/analytics_recorder.dart';
import 'package:luvi_app/core/privacy/telemetry_sanitize.dart'
    show sanitizeTelemetryData;

/// Thin facade around the existing [AnalyticsRecorder] so call sites depend on
/// a stable API that can later swap implementations (e.g. PostHog) without
/// churn.
final analyticsProvider = Provider<Analytics>((ref) {
  final recorder = ref.watch(analyticsRecorderProvider);
  return Analytics._(recorder);
});

class Analytics {
  const Analytics._(this._recorder);

  final AnalyticsRecorder _recorder;

  /// Emit a structured analytics event using the current recorder.
  /// Unified signature: track(name, props)
  ///
  /// Null-valued properties are filtered out before forwarding so the
  /// underlying recorder/backends never receive `null` values.
  void track(String name, Map<String, Object?> props) {
    final nonNull = {
      for (final entry in props.entries)
        if (entry.value != null) entry.key: entry.value
    };
    // Apply privacy sanitization to drop/mask common PII patterns and
    // sensitive keys before recording.
    final clean = sanitizeAnalyticsProperties(nonNull);
    _recorder.recordEvent(name, properties: clean);
  }

  // NOTE: MVP keeps a flexible Map-based API for event properties.
  // For stronger typing later, consider introducing event classes that
  // implement a common AnalyticsEvent interface with toMap()/properties,
  // and add an overload like trackTyped<T extends AnalyticsEvent>(T event).
}

/// Sanitizes analytics properties by masking sensitive keys and scrubbing
/// common PII patterns (emails, phones, IPs, UUIDs, tokens) from string values.
/// Returns a new Map; the original is not mutated.
Map<String, Object?> sanitizeAnalyticsProperties(
  Map<String, Object?> properties,
) {
  // Reuse the generic telemetry sanitizer which handles nested Maps/Lists,
  // sensitive keys, and string pattern scrubbing.
  return sanitizeTelemetryData(properties);
}
