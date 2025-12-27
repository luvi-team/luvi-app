import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding progress bar widget matching Figma specs.
///
/// Figma specs:
/// - Size: 227 × 18px (responsive: 80% of parent, max 307px)
/// - Border radius: 40
/// - Border: 1px black
/// - Fill: DsColors.signature
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  })  : assert(currentStep >= 1, 'currentStep must be >= 1'),
        assert(totalSteps >= 1, 'totalSteps must be >= 1'),
        assert(currentStep <= totalSteps, 'currentStep must be <= totalSteps');

  /// Current step (1-indexed)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  // Widget-specific layout constants (Figma Progress Bar specs v2)
  static const double _barHeight = Sizes.progressBarHeight; // 18px
  static const double _borderWidth = 1.0; // Figma: 1px

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      throw FlutterError(
        'AppLocalizations not found in context. Ensure MaterialApp has '
        'localizationsDelegates and supportedLocales configured.',
      );
    }
    final progress = currentStep / totalSteps;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width: 80% of parent, max 307px
        final barWidth = Sizes.progressBarWidthFor(constraints.maxWidth);

        return Semantics(
          label: l10n.onboardingProgressLabel(currentStep, totalSteps),
          child: SizedBox(
            width: barWidth,
            height: _barHeight,
            // Container with decoration renders border OUTSIDE the clip area
            // This fixes the border being clipped by ClipRRect
            child: Container(
              decoration: BoxDecoration(
                color: DsColors.white,
                borderRadius: BorderRadius.circular(Sizes.radiusXL),
                border: Border.all(
                  color: DsColors.grayscaleBlack,
                  width: _borderWidth,
                ),
              ),
              child: ClipRRect(
                // Inner radius = outer radius - border width for clean edges
                borderRadius:
                    BorderRadius.circular(Sizes.radiusXL - _borderWidth),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: DsColors.signature,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(Sizes.radiusXL - _borderWidth),
                        // Use integer comparison to avoid floating-point precision issues
                        right: currentStep == totalSteps
                            ? Radius.circular(Sizes.radiusXL - _borderWidth)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
