import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

/// Onboarding CTA button widget matching Figma specs.
///
/// Figma specs:
/// - Padding: 16px vertical, 40px horizontal
/// - Border radius: 40
/// - Shadow: BoxShadow(0, 25, 50, -12)
/// - Disabled state: DsColors.gray300
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is enabled
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.m,
            horizontal: Spacing.onboardingButtonHorizontal,
          ),
          decoration: BoxDecoration(
            color: enabled ? DsColors.buttonPrimary : DsColors.gray300,
            borderRadius: BorderRadius.circular(Sizes.radiusXL),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: DsColors.shadowMedium,
                      offset: Offset(0, 25),
                      blurRadius: 50,
                      spreadRadius: -12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: enabled ? DsColors.white : DsColors.gray500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
