import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A decorative video player for Welcome screens.
///
/// Features:
/// - Asset-based video playback
/// - Autoplay, loop, muted (volume 0)
/// - App lifecycle awareness (pauses on background)
/// - Only plays when [isActive] is true (for PageView scenarios)
/// - Falls back to a neutral placeholder on error
/// - Excluded from semantics (purely decorative)
class WelcomeVideoPlayer extends StatefulWidget {
  const WelcomeVideoPlayer({
    super.key,
    required this.assetPath,
    this.isActive = true,
  });

  /// Path to the video asset (e.g., 'assets/videos/welcome/welcome_01.mp4')
  final String assetPath;

  /// Whether this video should be playing. Set to false when the screen
  /// is not visible (e.g., in a PageView).
  final bool isActive;

  @override
  State<WelcomeVideoPlayer> createState() => _WelcomeVideoPlayerState();
}

class _WelcomeVideoPlayerState extends State<WelcomeVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.assetPath);

    try {
      await _controller.initialize();
      // Configure: loop, muted
      await _controller.setLooping(true);
      await _controller.setVolume(0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Start playing if active
        if (widget.isActive) {
          _controller.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(WelcomeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle isActive changes
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive && _isInitialized && !_hasError) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }

    // Handle asset path changes (unlikely but defensive)
    if (oldWidget.assetPath != widget.assetPath) {
      _controller.dispose();
      _isInitialized = false;
      _hasError = false;
      _initializeVideo();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _hasError) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (widget.isActive) {
          _controller.play();
        }
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exclude from semantics – video is purely decorative
    return ExcludeSemantics(
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_hasError) {
      // Fallback: neutral placeholder using theme colors
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }

    if (!_isInitialized) {
      // Loading state: show transparent container to avoid layout jumps
      return const SizedBox.expand();
    }

    // Video is ready – use FittedBox to fill the available space
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
