import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/onboarding_success_tokens.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/l10n/app_localizations_en.dart';
import 'package:luvi_services/user_state_service.dart';

class _SuccessBtnBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setBusy(bool value) => state = value;
}

final _successBtnBusyProvider =
    NotifierProvider.autoDispose<_SuccessBtnBusyNotifier, bool>(
      _SuccessBtnBusyNotifier.new,
    );

/// Final screen after onboarding completes.
/// Shows a trophy celebration (combined Lottie with trophy + confetti, or PNG
/// fallback when motion is disabled), celebratory title, and CTA.
class OnboardingSuccessScreen extends ConsumerWidget {
  const OnboardingSuccessScreen({super.key, required this.fitnessLevel});

  static const routeName = '/onboarding/success';

  final FitnessLevel fitnessLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final spacing = OnboardingSpacing.of(context);
    final reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.l),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTrophy(context, reduceMotion),
                    SizedBox(height: spacing.trophyToTitle),
                    _buildTitle(textTheme, colorScheme, l10n),
                    SizedBox(height: spacing.titleToButton),
                    _buildButton(context, ref, l10n, fitnessLevel),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(BuildContext context, bool reduceMotion) {
    final config =
        _computeTrophyConfig(context, reduceMotion: reduceMotion);
    return _buildTrophyPresentation(context, config);
  }

  _OnboardingTrophyConfig _computeTrophyConfig(
    BuildContext context, {
    required bool reduceMotion,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final usableHeight = mediaQuery.size.height - mediaQuery.padding.vertical;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final celebrationConfig = reduceMotion
        ? null
        : OnboardingSuccessTokens.celebrationConfig(
            viewHeight: usableHeight,
            textScaleFactor: textScale,
          );
    final baselineOffset =
        celebrationConfig?.baselineOffset ??
        OnboardingSuccessTokens.minBaselineOffset;
    final animationScale = celebrationConfig?.scale ?? 1.0;
    final shouldAnimate = !reduceMotion && celebrationConfig != null;
    return _OnboardingTrophyConfig(
      baselineOffset: baselineOffset,
      animationScale: animationScale,
      shouldAnimate: shouldAnimate,
    );
  }

  Widget _buildTrophyPresentation(
    BuildContext context,
    _OnboardingTrophyConfig config,
  ) {
    return ExcludeSemantics(
      child: Center(
        child: SizedBox(
          key: const Key('onboarding_success_trophy'),
          width: OnboardingSuccessTokens.trophyWidth,
          height: OnboardingSuccessTokens.trophyHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: config.shouldAnimate
                ? _AnimatedTrophy(config: config)
                : Transform.translate(
                    key: const Key('onboarding_success_trophy_transform_png'),
                    offset: Offset(0, config.baselineOffset),
                    child: Image.asset(
                      Assets.images.onboardingSuccessTrophy,
                      width: OnboardingSuccessTokens.trophyWidth,
                      height: OnboardingSuccessTokens.trophyHeight,
                      errorBuilder: Assets.defaultImageErrorBuilder,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    // From Figma audit: Playfair Display Regular 24px/32px (Heading 2 token)
    return Semantics(
      header: true,
      child: Text(
        key: const Key('onboarding_success_title'),
        l10n.onboardingSuccessTitle,
        textAlign: TextAlign.center,
        style: textTheme.headlineMedium?.copyWith(
          fontFamily: FontFamilies.playfairDisplay,
          fontSize: TypographyTokens.size24,
          height: TypographyTokens.lineHeightRatio32on24,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FitnessLevel fitnessLevel,
  ) {
    // ElevatedButton already provides accessible label from visible text
    final isBusy = ref.watch(_successBtnBusyProvider);
    return ElevatedButton(
      key: const Key('onboarding_success_cta'),
      onPressed: isBusy
          ? null
          : () async {
              final busyNotifier = ref.read(_successBtnBusyProvider.notifier);
              busyNotifier.setBusy(true);
              try {
                final userState = await tryOrNullAsync(
                  () => ref.read(userStateServiceProvider.future),
                  tag: 'userState',
                );
                if (userState == null) {
                  log.w(
                    'onboarding_user_state_unavailable',
                    tag: 'onboarding_success',
                    error:
                        'Cannot complete onboarding: user state service unavailable',
                  );
                  if (context.mounted) {
                    final cs = Theme.of(context).colorScheme;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: cs.error,
                        content: Text(l10n.onboardingSuccessStateUnavailable),
                      ),
                    );
                  }
                  return;
                }
                await userState.markOnboardingComplete(
                  fitnessLevel: fitnessLevel,
                );
                if (context.mounted) {
                  context.go(HeuteScreen.routeName);
                }
              } catch (error, stackTrace) {
                log.e(
                  'onboarding_mark_complete_failed',
                  error: sanitizeError(error) ?? error.runtimeType,
                  stack: stackTrace,
                );
                if (context.mounted) {
                  final cs = Theme.of(context).colorScheme;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: cs.error,
                      content: Text(l10n.onboardingSuccessGenericError),
                    ),
                  );
                }
              } finally {
                try {
                  busyNotifier.setBusy(false);
                } on StateError catch (_) {
                  // Provider may have been disposed while awaiting async work; ignore.
                } catch (e, stackTrace) {
                  assert(() {
                    log.w(
                      'onboarding_success_busy_reset_failed',
                      error: sanitizeError(e) ?? e.runtimeType,
                      stack: stackTrace,
                    );
                    return true;
                  }());
                }
              }
            },
      child: Text(l10n.commonStartNow),
    );
  }

}

class _AnimatedTrophy extends StatelessWidget {
  const _AnimatedTrophy({required this.config});

  final _OnboardingTrophyConfig config;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minWidth: OnboardingSuccessTokens.trophyWidth,
      maxWidth: OnboardingSuccessTokens.trophyWidth,
      minHeight: OnboardingSuccessTokens.trophyHeight,
      maxHeight:
          OnboardingSuccessTokens.trophyHeight +
          OnboardingSuccessTokens.celebrationBleedTop,
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        key: const Key('onboarding_success_trophy_transform'),
        offset: Offset(0, config.baselineOffset),
        child: Transform.scale(
          scale: config.animationScale,
          child: RepaintBoundary(
            key: const Key('onboarding_success_lottie_boundary'),
            child: Lottie.asset(
              Assets.animations.onboardingSuccessCelebration,
              repeat: false,
              frameRate: FrameRate.composition,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) {
                log.w(
                  'onboarding_trophy_lottie_failed',
                  error: sanitizeError(error) ?? error.runtimeType,
                  stack: stackTrace,
                );
                return Image.asset(
                  Assets.images.onboardingSuccessTrophy,
                  width: OnboardingSuccessTokens.trophyWidth,
                  height: OnboardingSuccessTokens.trophyHeight,
                  fit: BoxFit.contain,
                  errorBuilder: Assets.defaultImageErrorBuilder,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingTrophyConfig {
  const _OnboardingTrophyConfig({
    required this.baselineOffset,
    required this.animationScale,
    required this.shouldAnimate,
  });

  final double baselineOffset;
  final double animationScale;
  final bool shouldAnimate;
}
