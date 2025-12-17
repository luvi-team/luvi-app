import 'package:flutter/material.dart';
import 'colors.dart';

/// Design system gradient tokens for Onboarding and Consent screens.
///
/// All gradients are derived from Figma designs (2024-12 Refactor).
class DsGradients {
  const DsGradients._();

  /// Standard Onboarding Background Gradient (vertical)
  /// Figma: goldMedium → goldLight → goldMedium
  /// Stops: 0.18, 0.50, 0.75
  static const LinearGradient onboardingStandard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      DsColors.goldMedium,
      DsColors.goldLight,
      DsColors.goldMedium,
    ],
    stops: [0.18, 0.50, 0.75],
  );

  /// Success Screen Background Gradient (vertical)
  /// Figma: signature → goldMedium → goldLight
  /// Stops: 0.04, 0.52, 0.98
  static const LinearGradient successScreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      DsColors.signature,
      DsColors.goldMedium,
      DsColors.goldLight,
    ],
    stops: [0.04, 0.52, 0.98],
  );

  /// Consent Screen Background - Solid cream color as gradient for consistency
  /// Use when a gradient container is needed but solid color is desired
  static const LinearGradient consentBackground = LinearGradient(
    colors: [
      DsColors.bgCream,
      DsColors.bgCream,
    ],
  );
}
