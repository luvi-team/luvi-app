import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Mock VideoPlayerPlatform for widget tests
///
/// Usage in tests:
/// ```dart
/// void main() {
///   TestConfig.ensureInitialized();
///   VideoPlayerMock.registerWith();  // ADD this line
///
///   testWidgets('...', (tester) async {
///     // Test with video player widgets
///   });
/// }
/// ```
///
/// For lifecycle tests with custom events:
/// ```dart
/// setUp(() {
///   VideoPlayerMock.registerWith(events: [
///     VideoEvent(eventType: VideoEventType.initialized, duration: Duration(seconds: 10), size: Size(1920, 1080)),
///     VideoEvent(eventType: VideoEventType.completed),
///   ]);
/// });
/// // No tearDown needed - each registerWith() creates fresh instance
/// ```
///
/// For timeout tests where initialization should never complete:
/// ```dart
/// setUp(() {
///   VideoPlayerMock.registerWith(neverEmits: true);
/// });
/// ```
class VideoPlayerMock extends VideoPlayerPlatform {
  /// Creates a VideoPlayerMock with optional custom events.
  ///
  /// If [events] is null and [neverEmits] is false, default initialized event
  /// is emitted.
  ///
  /// If [neverEmits] is true, the event stream never emits any events and
  /// never completes. This is useful for testing initialization timeouts.
  VideoPlayerMock({
    List<VideoEvent>? events,
    bool neverEmits = false,
  })  : _events = events,
        _neverEmits = neverEmits;

  /// Register a new VideoPlayerMock instance.
  ///
  /// Each call creates a fresh instance, avoiding state leakage between tests.
  ///
  /// Usage:
  /// ```dart
  /// setUp(() {
  ///   VideoPlayerMock.registerWith();
  /// });
  ///
  /// // Or with custom events:
  /// setUp(() {
  ///   VideoPlayerMock.registerWith(events: [
  ///     VideoEvent(eventType: VideoEventType.completed),
  ///   ]);
  /// });
  ///
  /// // Or for timeout tests (stream never emits):
  /// setUp(() {
  ///   VideoPlayerMock.registerWith(neverEmits: true);
  /// });
  /// ```
  static void registerWith({
    List<VideoEvent>? events,
    bool neverEmits = false,
  }) {
    VideoPlayerPlatform.instance = VideoPlayerMock(
      events: events,
      neverEmits: neverEmits,
    );
  }

  /// Custom events for this mock instance (null = default initialized event).
  final List<VideoEvent>? _events;

  /// When true, videoEventsFor() returns a stream that never emits and never
  /// closes. Used for deterministic timeout testing.
  final bool _neverEmits;

  /// Controllers for neverEmits mode, keyed by textureId.
  /// Cleaned up in dispose().
  final Map<int, StreamController<VideoEvent>> _pendingControllers = {};

  int _nextTextureId = 0;
  final Map<int, String> _dataSources = {};

  @override
  Future<void> init() async {
    // Mock initialization - no-op
  }

  @override
  Future<void> dispose(int textureId) async {
    _dataSources.remove(textureId);
    // Clean up neverEmits controller for this textureId
    final controller = _pendingControllers.remove(textureId);
    await controller?.close();
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    // Simulate error for invalid asset paths (realistic behavior for tests)
    final assetPath = dataSource.asset ?? dataSource.uri ?? '';
    if (assetPath.contains('invalid') || assetPath.contains('nonexistent')) {
      throw PlatformException(
        code: 'VideoError',
        message: 'Asset not found: $assetPath',
      );
    }

    final textureId = _nextTextureId++;
    _dataSources[textureId] = assetPath;
    return textureId;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    // Mock - no-op
  }

  @override
  Future<void> play(int textureId) async {
    // Mock - no-op
  }

  @override
  Future<void> pause(int textureId) async {
    // Mock - no-op
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    // Mock - no-op
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    // Mock - no-op
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    // Mock - no-op
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return Duration.zero;
  }

  /// Returns a stream of video events for the given texture ID.
  ///
  /// **Default behavior:** Uses `Stream.fromIterable()` which emits all
  /// events synchronously when subscribed and then completes immediately.
  /// This is suitable for testing initialization and simple lifecycle events.
  ///
  /// **neverEmits mode:** When [neverEmits] is true, returns a stream that
  /// never emits any events and never closes. This is deterministic and
  /// suitable for testing initialization timeout behavior.
  ///
  /// **Limitations (default mode):**
  /// - Events emit synchronously, not over time
  /// - Stream completes after emitting all events
  /// - Not suitable for testing ongoing playback position updates
  ///
  /// For tests requiring ongoing event streams, consider:
  /// 1. Using multiple `registerWith()` calls with different event sequences
  /// 2. Testing state changes via widget rebuilds rather than stream events
  ///
  /// Example usage:
  /// ```dart
  /// // Normal initialization
  /// VideoPlayerMock.registerWith(events: [
  ///   VideoEvent(eventType: VideoEventType.initialized, ...),
  ///   VideoEvent(eventType: VideoEventType.completed),
  /// ]);
  ///
  /// // Timeout testing (initialization never completes)
  /// VideoPlayerMock.registerWith(neverEmits: true);
  /// ```
  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    // neverEmits mode: Return stream that never emits and never closes
    if (_neverEmits) {
      final controller = StreamController<VideoEvent>.broadcast();
      _pendingControllers[textureId] = controller;
      return controller.stream;
    }

    // Default mode: Emit events synchronously
    final events = _events ??
        [
          VideoEvent(
            eventType: VideoEventType.initialized,
            duration: const Duration(seconds: 1),
            size: const Size(1920, 1080),
          ),
        ];
    return Stream.fromIterable(events);
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {
    // Mock - no-op
  }

  @override
  Widget buildView(int textureId) {
    // Return empty container for mock video rendering
    return const SizedBox.shrink(key: Key('mock_video_player'));
  }
}
