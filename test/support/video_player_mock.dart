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
class VideoPlayerMock extends VideoPlayerPlatform {
  static void registerWith() {
    VideoPlayerPlatform.instance = VideoPlayerMock();
  }

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
    return Stream.value(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 1),
        size: const Size(1920, 1080),
      ),
    );
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
