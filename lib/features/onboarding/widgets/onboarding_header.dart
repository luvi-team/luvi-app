import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_progress_bar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding header widget with progress bar, step label, and back button.
///
/// Layout (Figma specs):
/// - Row: [Back Button (if step > 1)] [Progress Bar (centered)]
/// - Below: "Frage X von 6" centered
/// - Below: Title centered
class OnboardingHeader extends StatelessWidget {
  OnboardingHeader({
    super.key,
    required this.title,
    required this.step,
    required this.totalSteps,
    required this.onBack,
    this.semanticsLabel,
    this.centerTitle = true,
  })  : assert(
          title.trim().isNotEmpty,
          'title must not be empty or whitespace.',
        ),
        assert(
          totalSteps >= 1,
          'totalSteps must be at least 1, but received $totalSteps.',
        ),
        assert(step >= 1, 'step must be at least 1, but received $step.'),
        assert(
          step <= totalSteps,
          'step $step cannot exceed totalSteps $totalSteps.',
        );

  final String title;
  final int step;
  final int totalSteps;
  final VoidCallback onBack;
  final String? semanticsLabel;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final showBackButton = step > 1;
    final stepLabel = l10n.onboardingProgressLabel(step, totalSteps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Back Button + Progress Bar
        _buildProgressRow(context, showBackButton, colorScheme, l10n),
        const SizedBox(height: Spacing.s),
        // Row 2: Step label "Frage X von 6"
        _buildStepLabel(stepLabel, textTheme, colorScheme, l10n),
        const SizedBox(height: Spacing.l),
        // Row 3: Title
        _buildTitle(textTheme, colorScheme),
      ],
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    bool showBackButton,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        // Back button (only if step > 1)
        // showCircle: false for Figma O2-O8 icon-only style
        if (showBackButton)
          BackButtonCircle(
            onPressed: onBack,
            iconColor: colorScheme.onSurface,
            showCircle: false,
            semanticLabel: l10n.authBackSemantic,
          )
        else
          const SizedBox(width: Sizes.touchTargetMin),
        const SizedBox(width: Spacing.s),
        // Progress bar (centered, takes remaining space)
        Expanded(
          child: Center(
            child: OnboardingProgressBar(
              currentStep: step,
              totalSteps: totalSteps,
            ),
          ),
        ),
        // Spacer to balance the back button
        const SizedBox(width: Spacing.s),
        const SizedBox(width: Sizes.touchTargetMin),
      ],
    );
  }

  Widget _buildStepLabel(
    String stepLabel,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Semantics(
      label: l10n.onboardingStepSemantic(step, totalSteps),
      child: Text(
        stepLabel,
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: DsColors.grayscaleBlack,
          fontSize: TypographyTokens.size14,
        ),
      ),
    );
  }

  Widget _buildTitle(TextTheme textTheme, ColorScheme colorScheme) {
    final titleWidget = Text(
      title,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      maxLines: 3,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: TypographyTokens.size24,
        height: TypographyTokens.lineHeightRatio32on24,
      ),
    );

    return semanticsLabel != null
        ? Semantics(
            header: true,
            label: semanticsLabel,
            child: ExcludeSemantics(child: titleWidget),
          )
        : Semantics(
            header: true,
            child: titleWidget,
          );
  }
}
