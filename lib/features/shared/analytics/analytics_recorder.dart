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

/// Global opt-out to disable analytics emission entirely.
///
/// - Override in tests or at app bootstrap when analytics handling is uncertain
///   (e.g., while hardening PII filters or during privacy reviews).
/// - Default: `false` (analytics enabled).
final analyticsOptOutProvider = Provider<bool>((_) => false);

/// Returns true when [properties] contains keys that look like PII indicators
/// (e.g., email, phone, name, address). Case-insensitive, substring match.
bool _containsSuspiciousPII(Map<String, Object?> properties) {
  if (properties.isEmpty) return false;
  const suspicious = <String>{
    'email', 'e-mail', 'mail',
    'phone', 'tel', 'telephone', 'mobile',
    'name', 'first_name', 'firstname', 'last_name', 'lastname', 'full_name', 'fullname',
    'address', 'street', 'city', 'zip', 'zipcode', 'postal', 'postcode',
  };
  for (final key in properties.keys) {
    final k = key.toLowerCase();
    for (final s in suspicious) {
      if (k.contains(s)) return true;
    }
  }
  return false;
}

/// Dev-only analytics recorder.
///
/// **Privacy**: Callers must ensure that properties are PII-free before
/// invoking recordEvent. This recorder forwards all properties to the backend
/// sink without filtering or redaction.
///
/// Strictly intended for development logging: in debug mode it prints events to
/// the console; in profile/release, it suppresses printing but still forwards to
/// an optional backend sink when provided via [analyticsBackendSinkProvider].
///
/// This avoids silently dropping analytics in production while allowing a
/// gradual rollout of a real backend. Replace the sink override with a concrete
/// implementation once the analytics SDK is integrated.
class DebugAnalyticsRecorder implements AnalyticsRecorder {
  const DebugAnalyticsRecorder({
    required this.enabled,
    this.backend,
  });

  /// Whether analytics are enabled. When false, events are dropped.
  final bool enabled;

  /// Optional backend sink to forward events to.
  final AnalyticsEventSink? backend;

  @override
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Event name must not be empty');
    }

    // Runtime guardrails (active in all build modes).
    if (!enabled) {
      debugPrint('[analytics] DROPPED (disabled via config): "$name"');
      return;
    }

    // Block events that appear to include PII-like keys; log and return early.
    if (_containsSuspiciousPII(properties)) {
      final keys = properties.keys.join(', ');
      debugPrint(
        '[analytics] BLOCKED (PII suspected): "$name" — offending keys among: $keys',
      );
      return;
    }

    if (kDebugMode) {
      final keys = properties.keys.join(', ');
      final suffix = properties.isEmpty ? '' : ' (keys: $keys)';
      debugPrint('[analytics] $name$suffix');
    }

    if (backend != null) {
      try {
        backend!(name, properties);
      } catch (error, stackTrace) {
        debugPrint('[analytics] Backend error: $error\n$stackTrace');
      }
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
  final optOut = ref.watch(analyticsOptOutProvider);
  return DebugAnalyticsRecorder(
    enabled: !optOut,
    backend: sink,
  );
});
