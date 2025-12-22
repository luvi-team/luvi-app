import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

/// Glassmorphism card for onboarding screens (O1-O8).
///
/// Implements BackdropFilter + Blur + Border for authentic glass effect
/// matching Figma designs. Based on AuthGlassCard pattern.
///
/// Default values:
/// - Background: 10% white opacity
/// - Border: 70% white opacity, 1.5px width
/// - Blur sigma: 10.0 (from Sizes.glassBlurSigma)
/// - Border radius: 16.0 (from Sizes.radius16)
class OnboardingGlassCard extends StatelessWidget {
  const OnboardingGlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  /// Child widget to display inside the glass card.
  final Widget child;

  /// Border radius. Defaults to Sizes.radius16 (16.0).
  final double? borderRadius;

  /// Blur sigma for BackdropFilter. Defaults to Sizes.glassBlurSigma (10.0).
  final double? blurSigma;

  /// Background color. Defaults to 10% white opacity.
  final Color? backgroundColor;

  /// Border color. Defaults to 70% white opacity.
  final Color? borderColor;

  /// Border width. Defaults to 1.5.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? Sizes.radius16);
    final sigma = blurSigma ?? Sizes.glassBlurSigma;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? DsColors.white.withValues(alpha: 0.10),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? DsColors.white.withValues(alpha: 0.70),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
