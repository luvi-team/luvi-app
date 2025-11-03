import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/shared/analytics/analytics_recorder.dart';

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
    final clean = Map<String, Object?>.from(props)
      ..removeWhere((_, v) => v == null);
    _recorder.recordEvent(name, properties: clean);
  }

  // NOTE: MVP keeps a flexible Map-based API for event properties.
  // For stronger typing later, consider introducing event classes that
  // implement a common AnalyticsEvent interface with toMap()/properties,
  // and add an overload like trackTyped<T extends AnalyticsEvent>(T event).
}
