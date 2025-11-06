import'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/analytics/analytics.dart';
import 'package:luvi_app/features/shared/analytics/analytics_recorder.dart';

class _RecordingAnalyticsRecorder implements AnalyticsRecorder {
  final List<Map<String, Object?>> calls = [];

  @override
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    calls.add(<String, Object?>{
      'name': name,
      'properties': Map<String, Object?>.from(properties),
    });
  }
}

void main() {
  test('analytics.track filters null-valued properties', () {
    final recorder = _RecordingAnalyticsRecorder();
    final container = ProviderContainer(
      overrides: [
        analyticsRecorderProvider.overrideWithValue(recorder),
      ],
    );

    final analytics = container.read(analyticsProvider);
    analytics.track('evt', {
      'a': 1,
      'b': null,
      'c': 'x',
    });

    expect(recorder.calls, hasLength(1));
    final event = recorder.calls.single;
    expect(event['name'], 'evt');
    final props = event['properties'] as Map<String, Object?>;
    expect(props.containsKey('b'), isFalse);
    expect(props['a'], 1);
    expect(props['c'], 'x');

    container.dispose();
  });
}
 
