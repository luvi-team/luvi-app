import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
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
      svgIconPath: Assets.icons.googleG,
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
    final hasIcon = icon != null || svgIconPath != null;
    final disabledOpacity = onPressed == null ? 0.5 : 1.0;

    return SizedBox(
      width: width ?? AuthRebrandMetrics.buttonWidth,
      height: AuthRebrandMetrics.buttonHeight,
      child: Material(
        color: DsColors.authRebrandCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AuthRebrandMetrics.buttonRadius,
          ),
          side: BorderSide(
            color: DsColors.authRebrandInputBorder.withValues(
              alpha: disabledOpacity,
            ),
            width: AuthRebrandMetrics.inputBorderWidth,
          ),
        ),
        child: Semantics(
          button: true,
          label: label,
          enabled: onPressed != null,
          excludeSemantics: true,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(
              AuthRebrandMetrics.buttonRadius,
            ),
            child: Padding(
              // SSOT: Icon at left=53, icon=20, gap=26 → text starts at 99
              // Use zero padding and let Row handle positioning
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  // Left padding before icon (SSOT: 53px)
                  if (hasIcon)
                    const SizedBox(
                      width: AuthRebrandMetrics.outlineButtonIconLeftPadding,
                    ),
                  // Icon
                  if (icon != null)
                    Icon(
                      icon,
                      size: AuthRebrandMetrics.outlineButtonIconSize,
                      color: DsColors.authRebrandTextPrimary.withValues(
                        alpha: disabledOpacity,
                      ),
                    )
                  else if (svgIconPath != null)
                    // SVG icons (e.g., Google) preserve their original colors.
                    // Disabled state is indicated via opacity instead of colorFilter
                    // to avoid breaking multicolor brand icons.
                    Opacity(
                      opacity: disabledOpacity,
                      child: SvgPicture.asset(
                        svgIconPath!,
                        width: AuthRebrandMetrics.outlineButtonIconSize,
                        height: AuthRebrandMetrics.outlineButtonIconSize,
                      ),
                    ),
                  // Gap between icon and text (SSOT: 26px)
                  if (hasIcon)
                    const SizedBox(
                      width: AuthRebrandMetrics.outlineButtonIconToTextGap,
                    ),
                  // Text (will expand to fill remaining space, left-aligned after icon)
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontSize: AuthRebrandMetrics.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        color: DsColors.authRebrandTextPrimary.withValues(
                          alpha: disabledOpacity,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: hasIcon ? TextAlign.start : TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
