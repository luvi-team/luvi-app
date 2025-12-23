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
class VideoPlayerMock extends VideoPlayerPlatform {
  /// Creates a VideoPlayerMock with optional custom events.
  ///
  /// If [events] is null, default initialized event is emitted.
  VideoPlayerMock({List<VideoEvent>? events}) : _events = events;

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
  /// ```
  static void registerWith({List<VideoEvent>? events}) {
    VideoPlayerPlatform.instance = VideoPlayerMock(events: events);
  }

  /// Custom events for this mock instance (null = default initialized event).
  final List<VideoEvent>? _events;

  int _nextTextureId = 0;
  final Map<int, String> _dataSources = {};

  @override
  Future<void> init() async {
    // Mock initialization - no-op
  }

  @override
  Future<void> dispose(int textureId) async {
    _dataSources.remove(textureId);
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

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
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
