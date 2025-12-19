import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/widgets/calendar_mini_widget.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_progress_bar.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding06: Cycle Intro screen (O6)
/// Figma: 06_Onboarding (Zyklus Intro)
/// Explains cycle tracking before calendar input
class Onboarding06CycleIntroScreen extends StatelessWidget {
  const Onboarding06CycleIntroScreen({super.key});

  static const routeName = '/onboarding/cycle-intro';

  void _handleContinue(BuildContext context) {
    context.pushNamed('onboarding_06_period');
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding05InterestsScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        // Gradient fills entire screen (Figma v2)
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: DsGradients.onboardingStandard,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: spacing.topPadding),
                // Header with progress bar
                _buildHeader(context, l10n, colorScheme),
                // Step label directly under progressbar (like O1-O5)
                SizedBox(height: Spacing.s),
                _buildStepLabel(textTheme, colorScheme, l10n),
                const Spacer(),
                // Title
                _buildTitle(textTheme, colorScheme, l10n),
                SizedBox(height: Spacing.xl),
                // Calendar mini preview
                const CalendarMiniWidget(highlightedDay: 25),
                const Spacer(),
                // CTA Button (centered)
                Center(child: _buildCta(context, l10n)),
                SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      children: [
        // Back button (icon-only style, Figma O6)
        BackButtonCircle(
          onPressed: () => _handleBack(context),
          iconColor: colorScheme.onSurface,
          showCircle: false,
          semanticLabel: l10n.authBackSemantic,
        ),
        const SizedBox(width: Spacing.s),
        // Progress bar (Flexible prevents overflow)
        Expanded(
          child: Center(
            child: OnboardingProgressBar(
              currentStep: 6,
              totalSteps: kOnboardingTotalSteps,
            ),
          ),
        ),
        const SizedBox(width: Spacing.s),
        // Placeholder for symmetry
        const SizedBox(width: Sizes.touchTargetMin),
      ],
    );
  }

  /// Step label "Frage 6 von 6" (Figma v2: manual, not via OnboardingHeader)
  Widget _buildStepLabel(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Text(
      l10n.onboardingStepLabel(6, kOnboardingTotalSteps),
      textAlign: TextAlign.center,
      style: textTheme.bodySmall?.copyWith(
        fontSize: TypographyTokens.size14,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildTitle(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Semantics(
      header: true,
      child: Text(
        l10n.onboardingCycleIntroTitle,
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

  Widget _buildCta(BuildContext context, AppLocalizations l10n) {
    return OnboardingButton(
      label: l10n.onboardingCycleIntroButton,
      onPressed: () => _handleContinue(context),
    );
  }
}
