import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'auth_rebrand_metrics.dart';

/// Outline button for OAuth options in Auth Rebrand v3 bottom sheets.
///
/// White background with gray border (#DCDCDC).
/// Used for Apple/Google sign-in buttons.
/// Figma: 329×50, radius 12, border 1px.
class AuthRebrandOutlineButton extends StatelessWidget {
  const AuthRebrandOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.svgIconPath,
    this.width,
  });

  /// Factory constructor for Apple Sign In button
  factory AuthRebrandOutlineButton.apple({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    double? width,
  }) {
    return AuthRebrandOutlineButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: Icons.apple,
      width: width,
    );
  }

  /// Factory constructor for Google Sign In button
  factory AuthRebrandOutlineButton.google({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    double? width,
  }) {
    return AuthRebrandOutlineButton(
      key: key,
      label: label,
      onPressed: onPressed,
      svgIconPath: 'assets/icons/google_g.svg',
      width: width,
    );
  }

  /// Button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Optional icon from Material Icons
  final IconData? icon;

  /// Optional SVG icon path
  final String? svgIconPath;

  /// Optional fixed width (defaults to button width from metrics)
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? AuthRebrandMetrics.buttonWidth,
      height: AuthRebrandMetrics.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: DsColors.authRebrandCardSurface,
          foregroundColor: DsColors.authRebrandTextPrimary,
          disabledForegroundColor: DsColors.authRebrandTextPrimary.withValues(alpha: 0.5),
          side: BorderSide(
            color: onPressed != null
                ? DsColors.authRebrandInputBorder
                : DsColors.authRebrandInputBorder.withValues(alpha: 0.5),
            width: AuthRebrandMetrics.inputBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthRebrandMetrics.buttonRadius),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: DsColors.authRebrandTextPrimary,
              ),
              const SizedBox(width: Spacing.s),
            ] else if (svgIconPath != null) ...[
              SvgPicture.asset(
                svgIconPath!,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: Spacing.s),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontSize: AuthRebrandMetrics.buttonFontSize,
                  fontWeight: FontWeight.w600,
                  color: DsColors.authRebrandTextPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
