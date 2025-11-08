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
/// (e.g., email, phone, name, address).
///
/// Implementation details:
/// - Normalizes keys to lowercase and trims whitespace.
/// - Checks against an explicit suspicious-keys set (exact matches) and a
///   conservative whole-word regex (word boundaries by start/end/underscore/hyphen/space).
/// - Applies an allowlist of safe keys to avoid false positives (e.g.,
///   `username`, `theme`, `customer_email_count`).
bool _containsSuspiciousPII(Map<String, Object?> properties) {
  if (properties.isEmpty) return false;

  // Safe keys that may otherwise falsely match (e.g., contain "email").
  const safeAllowlist = <String>{
    'theme',
    'username',
    'customer_email_count',
  };

  // Exact suspicious keys and common variations.
  const suspiciousExact = <String>{
    'email', 'email_address', 'e-mail',
    'emailverified', 'email_verified',
    'phone', 'phone_number', 'phonenumber', 'tel', 'telephone', 'mobile',
    'name', 'first_name', 'firstname', 'last_name', 'lastname', 'full_name', 'fullname',
    'address', 'street', 'city', 'zip', 'zipcode', 'postal', 'postcode',
    'ssn', 'social_security', 'social_security_number',
    'dob', 'date_of_birth', 'birthdate', 'birthday',
    'credit_card', 'card_number', 'cc_number', 'cvv', 'expiry',
  };

  // Whole-word pattern (start/end or separated by underscore/hyphen/space).
  final suspiciousWord = RegExp(
    r'(^|[_\s-])(email|e-mail|email_address|email_verified|phone|tel|telephone|mobile|address|street|city|zip|zipcode|postal|postcode|ssn|social_security(_number)?|dob|date_of_birth|birthdate|first_name|last_name|full_name|name|credit_card|card_number|cc_number|cvv|expiry)([_\s-]|$)',
  );

  for (final rawKey in properties.keys) {
    final k = rawKey.trim().toLowerCase();
    if (k.isEmpty) continue;
    if (safeAllowlist.contains(k)) continue;
    if (suspiciousExact.contains(k)) return true;
    if (suspiciousWord.hasMatch(k)) return true;
  }
  return false;
}

/// Dev-only analytics recorder.
///
/// Privacy: This recorder performs defensive PII detection on event property
/// keys. If suspicious PII-like keys are detected (e.g., `email`, `phone`,
/// name/address variants), the event is blocked and a debug log is emitted.
/// Callers should still avoid sending any PII and prefer coarse, non-identifying
/// telemetry. When no suspicious keys are present, properties are forwarded
/// unfiltered to the backend sink.
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
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Event name must not be empty');
    }

    // Runtime guardrails (active in all build modes).
    if (!enabled) {
      // Silently drop when disabled; opt-out is intentional.
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
