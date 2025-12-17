import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding progress bar widget matching Figma specs.
///
/// Figma specs:
/// - Size: 227 × 18px
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

  // Widget-specific layout constants (Figma Progress Bar specs)
  static const double _barWidth = 227.0;
  static const double _barHeight = 18.0;
  static const double _borderWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = currentStep / totalSteps;

    return Semantics(
      label: l10n.onboardingProgressLabel(currentStep, totalSteps),
      child: SizedBox(
        width: _barWidth,
        height: _barHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Sizes.radiusXL),
            border: Border.all(
              color: DsColors.grayscaleBlack,
              width: _borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.radiusXL),
            child: Stack(
              children: [
                // Background (transparent/white)
                Container(
                  color: DsColors.transparent,
                ),
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: DsColors.signature,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
