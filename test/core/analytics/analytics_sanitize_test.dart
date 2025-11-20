import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/analytics/analytics.dart';
import 'package:luvi_app/core/analytics/analytics_recorder.dart';

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
  test('analytics.track sanitizes common PII patterns and keys', () {
    final recorder = _RecordingAnalyticsRecorder();
    final container = ProviderContainer(
      overrides: [
        analyticsRecorderProvider.overrideWithValue(recorder),
      ],
    );

    final analytics = container.read(analyticsProvider);
    analytics.track('evt', {
      'a': 1,
      'email': 'user@example.com', // sensitive key → masked
      'userId': '123e4567-e89b-12d3-a456-426614174000', // UUID-like
      'ip': '192.168.1.23', // sensitive key → masked
      'note': 'Contact me at foo@example.com or +1 202-555-0143',
      'text': 'from 10.0.0.42 and fe80::1', // inline IPs should be scrubbed
    });

    expect(recorder.calls, hasLength(1));
    final event = recorder.calls.single;
    final props = event['properties'] as Map<String, Object?>;

    // Non-PII preserved
    expect(props['a'], 1);

    // Sensitive keys masked
    expect(props['email'], '[redacted]');
    expect(props['ip'], '[redacted]');

    // UUID-like userId scrubbed or masked (string values are sanitized)
    // sanitizeTelemetryData masks sensitive keys like 'userId' → [redacted]
    expect(props['userId'], '[redacted]');

    // Inline patterns scrubbed
    expect(props['note'], contains('[redacted-email]'));
    expect(props['note'], contains('[redacted-phone]'));
    expect(props['text'], contains('[redacted-ip]'));
    expect(props['text'], contains('[redacted-ip]'));

    container.dispose();
  });

  test('sanitizeAnalyticsProperties preserves non-PII props unchanged', () {
    final clean = sanitizeAnalyticsProperties({
      'count': 3,
      'flag': true,
      'message': 'hello world',
    });
    expect(clean['count'], 3);
    expect(clean['flag'], true);
    expect(clean['message'], 'hello world');
  });
}

