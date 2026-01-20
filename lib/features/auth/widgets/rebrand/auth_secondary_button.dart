import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_button_base.dart';

/// Secondary CTA button for Auth Rebrand v3 screens.
///
/// Black (#030401) background with white text.
/// Used for "Weiter mit E-Mail" button in bottom sheets.
/// Figma: 329×50, radius 12, Figtree Bold 17px.
///
/// Note: Text color is explicitly set in TextStyle (not via foregroundColor)
/// to ensure consistent rendering with variable font. Disabled state uses
/// background opacity (0.5) rather than text opacity for visual feedback.
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.loadingKey,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Optional fixed width (defaults to button width from metrics)
  final double? width;

  /// Optional key for the loading indicator (for testing)
  final Key? loadingKey;

  @override
  Widget build(BuildContext context) {
    return AuthButtonBase(
      label: label,
      onPressed: onPressed,
      backgroundColor: DsColors.authRebrandCtaSecondary,
      isLoading: isLoading,
      width: width,
      loadingKey: loadingKey,
    );
  }
}
