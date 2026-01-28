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
/// Supports reduce motion preference by skipping to completion immediately.
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
  /// Accepts any enum with 'intro' in its name for intro phase.
  final Object phase;

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

class _OnboardingIntroPlayerState extends State<OnboardingIntroPlayer> {
  bool _introCompleted = false;
  bool _rainbowCompleted = false;

  @override
  void initState() {
    super.initState();

    // Listen for intro animation completion
    widget.introController.addStatusListener(_onIntroStatusChange);

    // If reduce motion is enabled, skip animations
    if (widget.reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onRainbowComplete();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.introController.removeStatusListener(_onIntroStatusChange);
    super.dispose();
  }

  void _onIntroStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _handleIntroComplete();
    }
  }

  void _handleIntroLoaded(LottieComposition composition) {
    // Start the intro controller when Lottie is loaded
    widget.introController.duration = composition.duration;
    widget.introController.forward();
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

  @override
  Widget build(BuildContext context) {
    // Skip rendering if reduce motion is enabled
    if (widget.reduceMotion) {
      return const SizedBox.expand();
    }

    // Determine which animation to show based on phase
    final isIntroPhase = widget.phase.toString().contains('intro');

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
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return const SizedBox.expand();
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
        onLoaded: (composition) {
          // Rainbow animation plays independently
        },
        onWarning: (warning) {
          debugPrint('Lottie warning: $warning');
        },
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return const SizedBox.expand();
          }
          return _RainbowAnimationWrapper(
            onComplete: _handleRainbowComplete,
            child: child,
          );
        },
      );
    }
  }
}

/// Wrapper widget that detects when the rainbow animation completes.
class _RainbowAnimationWrapper extends StatefulWidget {
  const _RainbowAnimationWrapper({
    required this.child,
    required this.onComplete,
  });

  final Widget child;
  final VoidCallback onComplete;

  @override
  State<_RainbowAnimationWrapper> createState() =>
      _RainbowAnimationWrapperState();
}

class _RainbowAnimationWrapperState extends State<_RainbowAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Rainbow animation: 100f @ 100fps = 1s
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
