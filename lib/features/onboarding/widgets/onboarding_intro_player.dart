import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';

/// Animation phase state machine for intro screen.
enum IntroPhase {
  intro, // Playing intro animation with speech bubble
  rainbow, // Playing rainbow transition before navigation
}

/// Lottie animation player for the onboarding intro sequence.
///
/// Handles the two-phase animation:
/// 1. Intro animation (Luvienne introduction, ~6s)
/// 2. Rainbow animation (transition effect, ~1s)
///
/// Supports reduce motion preference by rendering nothing (caller decides how to
/// handle navigation when animations are disabled).
class OnboardingIntroPlayer extends StatefulWidget {
  const OnboardingIntroPlayer({
    super.key,
    required this.phase,
    required this.reduceMotion,
    required this.onIntroComplete,
    required this.onRainbowComplete,
    required this.introController,
  });

  /// Current animation phase (intro or rainbow).
  final IntroPhase phase;

  /// Whether reduce motion is enabled (a11y preference).
  final bool reduceMotion;

  /// Callback when intro animation completes.
  final VoidCallback onIntroComplete;

  /// Callback when rainbow animation completes.
  final VoidCallback onRainbowComplete;

  /// Animation controller for syncing speech bubble with intro animation.
  final AnimationController introController;

  @override
  State<OnboardingIntroPlayer> createState() => _OnboardingIntroPlayerState();
}

class _OnboardingIntroPlayerState extends State<OnboardingIntroPlayer>
    with SingleTickerProviderStateMixin {
  bool _introCompleted = false;
  bool _rainbowCompleted = false;

  late final AnimationController _rainbowController;

  @override
  void initState() {
    super.initState();

    // Listen for intro animation completion
    widget.introController.addStatusListener(_onIntroStatusChange);

    _rainbowController = AnimationController(vsync: this);
    _rainbowController.addStatusListener(_onRainbowStatusChange);
  }

  @override
  void dispose() {
    widget.introController.removeStatusListener(_onIntroStatusChange);
    _rainbowController.removeStatusListener(_onRainbowStatusChange);
    _rainbowController.dispose();
    super.dispose();
  }

  void _onIntroStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _handleIntroComplete();
    }
  }

  void _onRainbowStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _handleRainbowComplete();
    }
  }

  void _handleIntroLoaded(LottieComposition composition) {
    // Start the intro controller when Lottie is loaded
    widget.introController.duration = composition.duration;
    widget.introController.forward();
  }

  void _handleRainbowLoaded(LottieComposition composition) {
    _rainbowController
      ..duration = composition.duration
      ..reset()
      ..forward();
  }

  void _handleIntroComplete() {
    if (_introCompleted) return;
    _introCompleted = true;
    widget.onIntroComplete();
  }

  void _handleRainbowComplete() {
    if (_rainbowCompleted) return;
    _rainbowCompleted = true;
    widget.onRainbowComplete();
  }

  Widget _buildFallbackPortrait() {
    return Image.asset(
      Assets.images.luviennePortrait,
      fit: BoxFit.contain,
      errorBuilder: Assets.defaultImageErrorBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Skip rendering if reduce motion is enabled
    if (widget.reduceMotion) {
      return const SizedBox.expand();
    }

    // Determine which animation to show based on phase
    final isIntroPhase = widget.phase == IntroPhase.intro;

    if (isIntroPhase) {
      return Lottie.asset(
        Assets.animations.onboardingIntro,
        fit: BoxFit.contain,
        repeat: false,
        onLoaded: _handleIntroLoaded,
        onWarning: (warning) {
          // Silently handle warnings in release builds
          debugPrint('Lottie warning: $warning');
        },
        errorBuilder: (context, error, stackTrace) {
          // Failsafe: still run intro controller so screen can progress
          if (!widget.introController.isAnimating &&
              !widget.introController.isCompleted) {
            widget.introController.forward();
          }
          return _buildFallbackPortrait();
        },
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return _buildFallbackPortrait();
          }
          return child;
        },
        controller: widget.introController,
      );
    } else {
      // Rainbow phase
      return Lottie.asset(
        Assets.animations.onboardingRainbow,
        fit: BoxFit.contain,
        repeat: false,
        onLoaded: _handleRainbowLoaded,
        onWarning: (warning) {
          debugPrint('Lottie warning: $warning');
        },
        errorBuilder: (context, error, stackTrace) {
          // If rainbow fails, proceed to next screen (mandatory flow).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleRainbowComplete();
          });
          return const SizedBox.expand();
        },
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return const SizedBox.expand();
          }
          return child;
        },
        controller: _rainbowController,
      );
    }
  }
}
