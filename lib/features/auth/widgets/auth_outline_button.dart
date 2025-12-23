import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/logging/logger.dart';

/// Unified auth button with pill shape for SignIn screen.
///
/// Figma Details:
/// - Height: 58px
/// - Border Radius: pill (29px for 58px height)
/// - Supports different color variants (Apple=black, Google/Email=white)
class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.svgAsset,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.semanticLabel,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Optional SVG asset path (e.g., 'assets/icons/google_g.svg')
  final String? svgAsset;

  /// Background color (default: white)
  final Color? backgroundColor;

  /// Text/icon color (default: authOutlineText)
  final Color? textColor;

  /// Border color (default: authOutlineBorder, null = no border for filled buttons)
  final Color? borderColor;

  /// Optional semantic label for screen readers (defaults to [text] if not provided).
  /// Use this when the icon conveys extra meaning not in the visible text.
  final String? semanticLabel;

  /// Factory constructor for Apple Sign In button (black with white text)
  factory AuthOutlineButton.apple({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return AuthOutlineButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: Icons.apple,
      backgroundColor: DsColors.black,
      textColor: DsColors.white,
      borderColor: null, // No border for filled black button
    );
  }

  /// Factory constructor for Google Sign In button (white with border + Google logo)
  factory AuthOutlineButton.google({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return AuthOutlineButton(
      key: key,
      text: text,
      onPressed: onPressed,
      svgAsset: Assets.icons.googleG,
      backgroundColor: DsColors.white,
      textColor: DsColors.authOutlineText,
      borderColor: DsColors.authOutlineBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? DsColors.white;
    final fgColor = textColor ?? DsColors.authOutlineText;
    final border = borderColor;

    return SizedBox(
      height: Sizes.buttonHeightOutline,
      width: double.infinity,
      child: Semantics(
        label: semanticLabel,
        button: true,
        excludeSemantics: semanticLabel != null,
        child: ElevatedButton(
          onPressed: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            elevation: 0,
            shadowColor: DsColors.transparent,
            side: border != null ? BorderSide(color: border) : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.buttonHeightOutline / 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Sizes.buttonPaddingHorizontal),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (svgAsset != null) ...[
                SvgPicture.asset(
                  svgAsset!,
                  width: Sizes.iconM,
                  height: Sizes.iconM,
                  placeholderBuilder: (_) => SizedBox(
                    width: Sizes.iconM,
                    height: Sizes.iconM,
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    log.e(
                      'SVG asset load failed: $svgAsset',
                      tag: 'AuthOutlineButton',
                      error: error,
                      stack: stackTrace,
                    );
                    return SizedBox(
                      width: Sizes.iconM,
                      height: Sizes.iconM,
                    );
                  },
                ),
                const SizedBox(width: Spacing.s),
              ] else if (icon != null) ...[
                Icon(icon, size: Sizes.iconM),
                const SizedBox(width: Spacing.s),
              ],
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
