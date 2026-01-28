import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/onboarding/widgets/intro_speech_bubble.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_intro_player.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Animation phase state machine for intro screen.
enum _IntroPhase {
  intro, // Playing intro animation with speech bubble
  rainbow, // Playing rainbow transition before navigation
}

/// Onboarding Intro Screen - Luvienne's introduction.
///
/// Shows a Lottie animation sequence (Intro -> Rainbow) with a typewriter
/// speech bubble overlay. Auto-navigates to onboarding/01 after completion.
///
/// Race-safe: Uses [mounted] and [_navigated] flag to prevent double navigation.
class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  static const routeName = RoutePaths.onboardingIntro;
  static const navName = RouteNames.onboardingIntro;

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen>
    with SingleTickerProviderStateMixin {
  _IntroPhase _phase = _IntroPhase.intro;
  bool _navigated = false;

  /// Animation controller for driving the speech bubble typewriter effect.
  /// Synced with the intro Lottie animation duration.
  late AnimationController _introController;

  /// Tracks whether reduce motion is enabled for a11y.
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    // Controller duration matches intro Lottie (600f @ 100fps = 6s)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;

    // If reduce motion is enabled, skip directly to navigation
    if (_reduceMotion && !_navigated) {
      _navigateToOnboarding01();
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _onIntroComplete() {
    if (!mounted || _navigated) return;
    setState(() {
      _phase = _IntroPhase.rainbow;
    });
  }

  void _onRainbowComplete() {
    if (!mounted || _navigated) return;
    _navigateToOnboarding01();
  }

  void _navigateToOnboarding01() {
    if (_navigated) return;
    _navigated = true;

    // Use go() instead of push() to prevent back navigation to intro
    if (mounted) {
      context.go(RoutePaths.onboarding01);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      body: Semantics(
        label: l10n.onboardingIntroSemanticLabel,
        child: SafeArea(
          child: Stack(
            children: [
              // Lottie animation player (full screen)
              Positioned.fill(
                child: OnboardingIntroPlayer(
                  phase: _phase,
                  reduceMotion: _reduceMotion,
                  onIntroComplete: _onIntroComplete,
                  onRainbowComplete: _onRainbowComplete,
                  introController: _introController,
                ),
              ),
              // Speech bubble overlay (only during intro phase)
              if (_phase == _IntroPhase.intro && !_reduceMotion)
                Positioned(
                  left: Spacing.screenPadding,
                  right: Spacing.screenPadding,
                  top: Spacing.avatarToBubble,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _introController,
                      builder: (context, child) {
                        return IntroSpeechBubble(
                          progress: _introController.value,
                          line1: l10n.onboardingIntroLine1,
                          line2: l10n.onboardingIntroLine2,
                          line3: l10n.onboardingIntroLine3,
                          line4: l10n.onboardingIntroLine4,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
