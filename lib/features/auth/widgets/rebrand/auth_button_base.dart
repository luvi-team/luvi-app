import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'auth_rebrand_metrics.dart';

/// Base widget for Auth Rebrand CTA buttons.
///
/// Shared by [AuthPrimaryButton] and [AuthSecondaryButton].
/// Internal to auth rebrand widgets - use the specific button classes instead.
class AuthButtonBase extends StatelessWidget {
  const AuthButtonBase({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.isLoading = false,
    this.width,
    this.height,
    this.loadingKey,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Background color for the button
  final Color backgroundColor;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Optional fixed width (defaults to button width from metrics)
  final double? width;

  /// Optional fixed height (defaults to button height from metrics)
  final double? height;

  /// Optional key for the loading indicator (for testing)
  final Key? loadingKey;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width ?? AuthRebrandMetrics.buttonWidth,
      height: height ?? AuthRebrandMetrics.buttonHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
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
                  fontVariations: [FontVariation('wght', 700)],
                  height: AuthRebrandMetrics.bodyLineHeightRatio,
                  color: DsColors.grayscaleWhite,
                ),
              ),
      ),
    );
  }
}
