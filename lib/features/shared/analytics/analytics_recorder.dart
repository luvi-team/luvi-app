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

class DebugAnalyticsRecorder implements AnalyticsRecorder {
  const DebugAnalyticsRecorder();

  @override
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    assert(name.isNotEmpty, 'Analytics event name must not be empty');
    if (!kDebugMode) return;
    final payload = properties.isEmpty ? '' : ' $properties';
    debugPrint('[analytics] $name$payload');
  }
}

final analyticsRecorderProvider = Provider<AnalyticsRecorder>((ref) {
  return const DebugAnalyticsRecorder();
});
