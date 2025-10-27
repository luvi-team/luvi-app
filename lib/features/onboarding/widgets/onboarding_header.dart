import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.title,
    required this.step,
    required this.totalSteps,
    required this.onBack,
    this.semanticsLabel,
    this.centerTitle = true,
  });

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
    final l10n = AppLocalizations.of(context);
    final stepSemantic = l10n?.onboardingStepSemantic(step, totalSteps) ??
        'Step $step of $totalSteps';
    final stepFraction = l10n?.onboardingStepFraction(step, totalSteps) ??
        '$step/$totalSteps';

    final showBackButton = step > 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBackButton)
          BackButtonCircle(
            onPressed: onBack,
            iconColor: colorScheme.onSurface,
          )
        else
          const SizedBox(width: 44, height: 44),
        const SizedBox(width: Spacing.s),
        Expanded(
          child: Semantics(
            header: true,
            label: semanticsLabel,
            child: Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: TypographyTokens.size24,
                height: TypographyTokens.lineHeightRatio32on24,
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.s),
        Semantics(
          label: stepSemantic,
          child: Text(
            stepFraction,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
