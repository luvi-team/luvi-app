import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

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
    final stepSemantic = l10n.onboardingStepSemantic(step, totalSteps);
    final stepFraction = l10n.onboardingStepFraction(step, totalSteps);
    final stepTextStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface,
    );
    final stepPainter = TextPainter(
      text: TextSpan(text: stepFraction, style: stepTextStyle),
      textDirection: Directionality.of(context),
    )..layout();

    // Measure width, then dispose
    final stepWidth = stepPainter.width;
    stepPainter.dispose();

    final showBackButton = step > 1;
    const double backButtonHitSize = Sizes.touchTargetMin;
    const double interSlotSpacing = Spacing.s;
    final double reservedLeft = backButtonHitSize + interSlotSpacing;
    final double reservedRight = interSlotSpacing + stepWidth;
    final double centeredPadding = math.max(reservedLeft, reservedRight);
    final EdgeInsets titlePadding = centerTitle
        ? EdgeInsets.symmetric(horizontal: centeredPadding)
        : EdgeInsets.only(left: reservedLeft, right: reservedRight);

    final titleWidget = Padding(
      padding: titlePadding,
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
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBackButton)
                BackButtonCircle(
                  onPressed: onBack,
                  iconColor: colorScheme.onSurface,
                  semanticLabel: l10n.authBackSemantic,
                )
              else
                const SizedBox(
                  width: backButtonHitSize,
                  height: backButtonHitSize,
                ),
              const SizedBox(width: Spacing.s),
            ],
          ),
        ),
        Align(
          alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
          child: semanticsLabel != null
              ? Semantics(
                  header: true,
                  label: semanticsLabel,
                  child: ExcludeSemantics(child: titleWidget),
                )
              : Semantics(
                  header: true,
                  child: titleWidget,
                ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: Spacing.s),
              Semantics(
                label: stepSemantic,
                child: ExcludeSemantics(
                  child: Text(stepFraction, style: stepTextStyle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
