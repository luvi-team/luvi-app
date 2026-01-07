import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/logging/logger.dart';

/// A video player for the Splash screen with completion callback.
///
/// Features:
/// - Asset-based video playback (plays once, no loop)
/// - Muted playback (volume 0)
/// - App lifecycle awareness (pauses on background)
/// - Falls back to [fallbackAsset] on error or when reduce-motion is enabled
/// - Fires [onComplete] exactly once when video ends, on timeout, or on error
/// - Timeout fail-safes: [initializationTimeout] for init, max duration guard
/// - Excluded from semantics (purely decorative)
///
/// Usage:
/// ```dart
/// SplashVideoPlayer(
///   assetPath: Assets.videos.splashScreen,
///   fallbackAsset: Assets.images.splashFallback,
///   onComplete: () => navigateToNextScreen(),
/// )
/// ```
class SplashVideoPlayer extends StatefulWidget {
  const SplashVideoPlayer({
    super.key,
    required this.assetPath,
    required this.onComplete,
    this.fallbackAsset,
    this.honorReduceMotion = true,
    this.initializationTimeout = const Duration(seconds: 3),
    this.maxPlaybackDuration = const Duration(seconds: 6),
  });

  /// Path to the video asset (e.g., 'assets/videos/splash/splash_screen.mp4')
  final String assetPath;

  /// Called exactly once when video playback completes, times out, or errors.
  /// Guaranteed to fire even if video never loads (fail-safe for navigation).
  final VoidCallback onComplete;

  /// Optional fallback image shown during loading, on error, or when
  /// reduce-motion is enabled. If null, a neutral colored box is shown.
  final String? fallbackAsset;

  /// When true, respects the system's reduce-motion accessibility setting
  /// and shows the fallback image instead of playing video.
  final bool honorReduceMotion;

  /// Timeout for video initialization. If init takes longer, onComplete fires.
  /// Default: 3 seconds.
  final Duration initializationTimeout;

  /// Maximum time from init success to forced completion (fail-safe).
  /// Prevents "stuck splash" if video duration detection fails.
  /// Default: 6 seconds.
  final Duration maxPlaybackDuration;

  @override
  State<SplashVideoPlayer> createState() => _SplashVideoPlayerState();
}

class _SplashVideoPlayerState extends State<SplashVideoPlayer>
    with WidgetsBindingObserver {
  /// Tolerance for video completion detection.
  /// Video players may report position slightly before actual end.
  static const _completionTolerance = Duration(milliseconds: 100);

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _useStaticFallback = false;
  bool _initializationStarted = false;

  /// Idempotency guard: ensures onComplete fires exactly once.
  bool _hasCompleted = false;

  /// Timer for initialization timeout.
  Timer? _initTimeoutTimer;

  /// Timer for max playback duration (fail-safe).
  Timer? _maxDurationTimer;

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
    // Guard: prevent multiple initializations
    if (_initializationStarted || _controller != null || _useStaticFallback) {
      return;
    }
    _initializationStarted = true;

    // Check reduce-motion preference
    if (widget.honorReduceMotion) {
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery?.disableAnimations == true) {
        setState(() {
          _useStaticFallback = true;
        });
        // A11y: Show poster briefly, then complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fireOnComplete();
        });
        return;
      }
    }

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.assetPath);
    _initTimeoutTimer = Timer(widget.initializationTimeout, _handleInitTimeout);

    try {
      await _controller!.initialize();
      _cancelInitTimeout();
      if (!mounted || _controller == null || _hasCompleted) return;

      await _configureController();
      if (!mounted || _hasCompleted) return;

      _startPlaybackWithGuard();
    } catch (e, stack) {
      _cancelInitTimeout();
      log.w('video_init_failed', tag: 'splash_video', error: e, stack: stack);
      if (mounted) {
        setState(() => _hasError = true);
        _fireOnComplete();
      }
    }
  }

  /// Cancels initialization timeout timer.
  void _cancelInitTimeout() {
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = null;
  }

  /// Configures controller after successful initialization (no loop, muted).
  Future<void> _configureController() async {
    await _controller!.setLooping(false);
    if (!mounted || _controller == null || _hasCompleted) return;

    await _controller!.setVolume(0);
    if (!mounted || _controller == null || _hasCompleted) return;

    setState(() => _isInitialized = true);
    _controller!.addListener(_checkVideoCompletion);
  }

  /// Starts playback with max-duration fail-safe timer.
  void _startPlaybackWithGuard() {
    _maxDurationTimer = Timer(widget.maxPlaybackDuration, _handleMaxDuration);
    _controller!.play().catchError((Object e, StackTrace stack) {
      log.w('video_play_failed', tag: 'splash_video', error: e, stack: stack);
      _fireOnComplete();
    });
  }

  void _handleInitTimeout() {
    if (_hasCompleted || !mounted) return;
    log.w('splash_video_init_timeout', tag: 'splash_video');
    _fireOnComplete();
  }

  void _handleMaxDuration() {
    if (_hasCompleted || !mounted) return;
    log.w('splash_video_max_duration_reached', tag: 'splash_video');
    _fireOnComplete();
  }

  void _checkVideoCompletion() {
    if (_controller == null || !mounted || _hasCompleted) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    // Video is complete when position >= duration (with tolerance)
    if (duration > Duration.zero &&
        position >= duration - _completionTolerance) {
      _controller!.removeListener(_checkVideoCompletion);
      _fireOnComplete();
    }
  }

  /// Fires onComplete exactly once (idempotent).
  void _fireOnComplete() {
    // Cancel all timers
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = null;
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;

    if (_hasCompleted || !mounted) return;
    _hasCompleted = true;
    widget.onComplete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _hasError || _controller == null || _hasCompleted) {
      return;
    }

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller!.pause();
        break;
      case AppLifecycleState.resumed:
        _controller!.play().catchError((Object e, StackTrace stack) {
          log.w(
            'video_play_failed',
            tag: 'splash_video',
            error: e,
            stack: stack,
          );
        });
        break;
    }
  }

  @override
  void dispose() {
    _initTimeoutTimer?.cancel();
    _maxDurationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_checkVideoCompletion);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exclude from semantics – video is purely decorative
    return ExcludeSemantics(child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    // Reduce-motion: show static fallback
    if (_useStaticFallback) {
      return _buildFallbackImage();
    }

    // Error state: show fallback
    if (_hasError) {
      return _buildFallbackImage();
    }

    // Loading state: show background color for seamless transition from launch screen.
    // Fallback image is only shown on error or reduce-motion.
    if (!_isInitialized) {
      return SizedBox.expand(
        key: const Key('splash_video_loading'),
        child: ColoredBox(color: DsColors.splashBg),
      );
    }

    // Video is ready – use FittedBox to fill the available space
    final videoSize = _controller!.value.size;
    if (videoSize.isEmpty) {
      // Guard against zero-sized video (edge case: corrupted files)
      return _buildFallbackImage();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
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
