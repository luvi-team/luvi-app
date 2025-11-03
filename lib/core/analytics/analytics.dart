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
  void track(String name, Map<String, Object?> props) {
    _recorder.recordEvent(name, properties: props);
  }

  // NOTE: MVP keeps a flexible Map-based API for event properties.
  // For stronger typing later, consider introducing event classes that
  // implement a common AnalyticsEvent interface with toMap()/properties,
  // and add an overload like trackTyped<T extends AnalyticsEvent>(T event).
}
