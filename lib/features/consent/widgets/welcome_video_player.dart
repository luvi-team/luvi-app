import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A decorative video player for Welcome screens.
///
/// Features:
/// - Asset-based video playback
/// - Autoplay, loop, muted (volume 0)
/// - App lifecycle awareness (pauses on background)
/// - Falls back to [fallbackAsset] on error or when reduce-motion is enabled
/// - Excluded from semantics (purely decorative)
///
/// Usage:
/// ```dart
/// WelcomeVideoPlayer(
///   assetPath: Assets.videos.welcomeVideo01,
///   fallbackAsset: Assets.images.welcomeFallback01,
/// )
/// ```
class WelcomeVideoPlayer extends StatefulWidget {
  const WelcomeVideoPlayer({
    super.key,
    required this.assetPath,
    this.fallbackAsset,
    this.honorReduceMotion = true,
  });

  /// Path to the video asset (e.g., 'assets/videos/welcome/welcome_01.mp4')
  final String assetPath;

  /// Optional fallback image shown during loading, on error, or when
  /// reduce-motion is enabled. If null, a neutral colored box is shown.
  final String? fallbackAsset;

  /// When true, respects the system's reduce-motion accessibility setting
  /// and shows the fallback image instead of playing video.
  final bool honorReduceMotion;

  @override
  State<WelcomeVideoPlayer> createState() => _WelcomeVideoPlayerState();
}

class _WelcomeVideoPlayerState extends State<WelcomeVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _useStaticFallback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkReduceMotionAndInitialize();
  }

  void _checkReduceMotionAndInitialize() {
    if (_controller != null || _useStaticFallback) return;

    // Check reduce-motion preference
    if (widget.honorReduceMotion) {
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery?.disableAnimations == true) {
        setState(() {
          _useStaticFallback = true;
        });
        return;
      }
    }

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.assetPath);

    try {
      await _controller!.initialize();
      // Configure: loop, muted
      await _controller!.setLooping(true);
      await _controller!.setVolume(0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Start playing immediately
        _controller!.play();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _hasError || _controller == null) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller!.pause();
        break;
      case AppLifecycleState.resumed:
        _controller!.play();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
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
    // Reduce-motion: show static fallback
    if (_useStaticFallback) {
      return _buildFallbackImage();
    }

    // Error state: show fallback or neutral placeholder
    if (_hasError) {
      return _buildFallbackImage();
    }

    // Loading state: show fallback image if available, else transparent
    if (!_isInitialized) {
      if (widget.fallbackAsset != null) {
        return _buildFallbackImage();
      }
      return const SizedBox.expand();
    }

    // Video is ready – use FittedBox to fill the available space
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    if (widget.fallbackAsset != null) {
      return SizedBox.expand(
        child: Image.asset(
          widget.fallbackAsset!,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      );
    }

    // Ultimate fallback: neutral colored box
    return SizedBox.expand(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
