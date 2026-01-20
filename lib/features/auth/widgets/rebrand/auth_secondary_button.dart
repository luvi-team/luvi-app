import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'auth_rebrand_metrics.dart';

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
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width ?? AuthRebrandMetrics.buttonWidth,
      height: AuthRebrandMetrics.buttonHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DsColors.authRebrandCtaSecondary,
          disabledBackgroundColor: DsColors.authRebrandCtaSecondary.withValues(alpha: 0.5),
          foregroundColor: DsColors.grayscaleWhite,
          disabledForegroundColor: DsColors.grayscaleWhite.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthRebrandMetrics.buttonRadius),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                key: loadingKey,
                width: AuthRebrandMetrics.loadingIndicatorSize,
                height: AuthRebrandMetrics.loadingIndicatorSize,
                child: const CircularProgressIndicator(
                  strokeWidth: AuthRebrandMetrics.loadingIndicatorStrokeWidth,
                  color: DsColors.grayscaleWhite,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontSize: AuthRebrandMetrics.buttonFontSize,
                  fontVariations: [FontVariation('wght', 700)], // Bold for variable font
                  height: AuthRebrandMetrics.bodyLineHeight, // 24/17
                  color: DsColors.grayscaleWhite,
                ),
              ),
      ),
    );
  }
}
