import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/onboarding_success_tokens.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
    // Trophy celebrates success via a combined Lottie (50% -> 100% scale, 2s @50fps)
    // Falls back to the static PNG when reduceMotion is enabled for accessibility
    // Illustration zone stays fixed at 308×300 logical pixels from Figma audit
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
    return ExcludeSemantics(
      child: Center(
        child: SizedBox(
          key: const Key('onboarding_success_trophy'),
          width: OnboardingSuccessTokens.trophyWidth,
          height: OnboardingSuccessTokens.trophyHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: shouldAnimate
                ? OverflowBox(
                    minWidth: OnboardingSuccessTokens.trophyWidth,
                    maxWidth: OnboardingSuccessTokens.trophyWidth,
                    minHeight: OnboardingSuccessTokens.trophyHeight,
                    maxHeight:
                        OnboardingSuccessTokens.trophyHeight +
                        OnboardingSuccessTokens.celebrationBleedTop,
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      key: const Key('onboarding_success_trophy_transform'),
                      offset: Offset(0, baselineOffset),
                      child: Transform.scale(
                        scale: animationScale,
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
                              debugPrint(
                                'Lottie celebration failed to load: $error',
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
                  )
                : Transform.translate(
                    key: const Key('onboarding_success_trophy_transform_png'),
                    offset: Offset(0, baselineOffset),
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
                  debugPrint(
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
                debugPrint(
                  'markOnboardingComplete failed: $error\n$stackTrace',
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
                busyNotifier.setBusy(false);
              }
            },
      child: Text(l10n.commonStartNow),
    );
  }
}
