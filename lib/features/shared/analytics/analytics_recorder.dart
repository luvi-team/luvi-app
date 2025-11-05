import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight analytics recorder contract so UI flows can emit structured
/// events while allowing tests to override the implementation.
abstract class AnalyticsRecorder {
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  });
}

/// Callback signature for forwarding analytics events to a backend.
typedef AnalyticsEventSink = void Function(
  String name,
  Map<String, Object?> properties,
);

/// Pluggable backend sink provider.
///
/// - Tests or production code can override this provider to hook up a real
///   analytics backend (e.g., PostHog/Mixpanel/Amplitude).
/// - Default is `null`, which means no backend forwarding is performed.
final analyticsBackendSinkProvider = Provider<AnalyticsEventSink?>((_) => null);

/// Dev-only analytics recorder.
///
/// Strictly intended for development logging: in debug mode it prints events to
/// the console; in profile/release, it suppresses printing but still forwards to
/// an optional backend sink when provided via [analyticsBackendSinkProvider].
///
/// This avoids silently dropping analytics in production while allowing a
/// gradual rollout of a real backend. Replace the sink override with a concrete
/// implementation once the analytics SDK is integrated.
class DebugAnalyticsRecorder implements AnalyticsRecorder {
  const DebugAnalyticsRecorder({this.backend});

  /// Optional backend sink to forward events to.
  final AnalyticsEventSink? backend;

  @override
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    assert(name.isNotEmpty, 'Analytics event name must not be empty');
    if (kDebugMode) {
      final sanitizedProps = properties.isEmpty
          ? ''
          : ' (keys: ${properties.keys.join(', ')})';
      debugPrint('[analytics] $name$sanitizedProps');
    }
    // Always forward to backend (if provided), regardless of build mode.
    if (backend != null) {
      backend!(name, properties);
    }
  }
}

/// Recorder selector: debug uses [DebugAnalyticsRecorder] with console prints;
/// release/profile also use [DebugAnalyticsRecorder] but only forward to an
/// optional backend sink.
///
/// TODO: Replace with a concrete Prod recorder when the analytics SDK is ready.
final analyticsRecorderProvider = Provider<AnalyticsRecorder>((ref) {
  final sink = ref.watch(analyticsBackendSinkProvider);
  return DebugAnalyticsRecorder(backend: sink);
});
