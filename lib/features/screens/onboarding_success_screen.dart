import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/onboarding_success_tokens.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Final screen after onboarding completes.
/// Shows a trophy visual, celebratory title, CTA, and (when motion is allowed)
/// a Lottie-based confetti animation as lightweight micro-celebration.
class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({super.key});

  static const routeName = '/onboarding/success';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final spacing = OnboardingSpacing.of(context);
    final reduceMotion = mediaQuery.disableAnimations;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.l),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTrophy(reduceMotion),
                    SizedBox(height: spacing.trophyToTitle),
                    _buildTitle(textTheme, colorScheme, l10n),
                    SizedBox(height: spacing.titleToButton),
                    _buildButton(context, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(bool reduceMotion) {
    // Trophy is decorative (title already communicates success)
    // From Figma audit: Trophy bounding box 308×300px
    // PNG format ensures pixel-perfect match with complex Figma illustration
    return ExcludeSemantics(
      child: Center(
        child: SizedBox(
          width: OnboardingSuccessTokens.trophyWidth,
          height: OnboardingSuccessTokens.trophyHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Image.asset(
                Assets.images.onboardingSuccessTrophy,
                width: OnboardingSuccessTokens.trophyWidth,
                height: OnboardingSuccessTokens.trophyHeight,
                errorBuilder: Assets.defaultImageErrorBuilder,
                fit: BoxFit.contain,
              ),
              if (!reduceMotion)
                Positioned(
                  top: OnboardingSuccessTokens.confettiVerticalOffset,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: OnboardingSuccessTokens.trophyWidth,
                      height: OnboardingSuccessTokens.trophyHeight,
                      child: Lottie.asset(
                        Assets.animations.onboardingSuccessConfetti,
                        repeat: false,
                        frameRate: FrameRate.composition,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
            ],
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

  Widget _buildButton(BuildContext context, AppLocalizations l10n) {
    // ElevatedButton already provides accessible label from visible text
    return ElevatedButton(
      key: const Key('onboarding_success_cta'),
      onPressed: () => context.go(HeuteScreen.routeName),
      child: Text(l10n.onboardingSuccessButton),
    );
  }
}
