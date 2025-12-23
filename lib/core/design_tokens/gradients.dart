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

  /// Consent Screen Background Color - solid cream (Figma: #FFF8F0)
  ///
  /// Use this for direct color access when gradient API is not required.
  /// Preferred over [consentBackground] for simple backgrounds.
  static const Color consentBackgroundColor = DsColors.bgCream;

  /// Consent Screen Background as Gradient - for gradient container compatibility.
  ///
  /// This is intentionally a "degenerate" gradient with identical colors.
  /// Use [consentBackgroundColor] instead when possible. This gradient exists
  /// for consumers that require a Gradient type (e.g., Container.decoration
  /// with gradient parameter).
  static const LinearGradient consentBackground = LinearGradient(
    colors: [
      DsColors.bgCream,
      DsColors.bgCream,
    ],
  );
}
