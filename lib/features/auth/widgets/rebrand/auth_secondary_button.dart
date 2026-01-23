import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_button_base.dart';

/// Secondary CTA button for Auth Rebrand v3 screens.
///
/// Black (#030401) background with white text.
/// Used for "Weiter mit E-Mail" button in bottom sheets.
/// Figma: 329×50, radius 12, Figtree Bold 17px.
///
/// Note: Disabled state uses both background opacity (0.5) and text opacity
/// (0.7) for visual feedback. Text color inherits from ElevatedButton.styleFrom.
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
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

  /// Optional fixed width (defaults to button width from metrics)
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
      backgroundColor: DsColors.authRebrandCtaSecondary,
      isLoading: isLoading,
      width: width,
      height: height,
      loadingKey: loadingKey,
      loadingSemanticLabel: loadingSemanticLabel,
    );
  }
}
