import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_button_base.dart';
import 'auth_rebrand_metrics.dart';

/// Primary CTA button for Auth Rebrand v3 screens.
///
/// Pink (#E91E63) background with white text.
/// Figma: 249×50, radius 12, Figtree Bold 17px, line-height 24px.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.loadingKey,
    this.loadingSemanticLabel,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Optional fixed width (defaults to CTA button width from metrics)
  final double? width;

  /// Optional fixed height (defaults to button height from metrics)
  final double? height;

  /// Optional key for the loading indicator (for testing)
  final Key? loadingKey;

  /// Optional semantic label announced when loading (a11y)
  final String? loadingSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return AuthButtonBase(
      label: label,
      onPressed: onPressed,
      backgroundColor: DsColors.authRebrandCtaPrimary,
      isLoading: isLoading,
      width: width ?? AuthRebrandMetrics.ctaButtonWidth,
      height: height,
      loadingKey: loadingKey,
      loadingSemanticLabel: loadingSemanticLabel,
    );
  }
}
