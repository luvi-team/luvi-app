import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';

/// Floating circular sync button with yin-yang icon.
/// Positioned above dock-bar center cutout.
/// Shows Gold tint when active (isActive=true).
///
/// Design tokens (from Figma audit 2025-10-06, Spec-JSON):
/// - Outer diameter: 64px (buttonDiameter)
/// - Ring: 2.0px stroke (ringStrokeWidth), accentPurple
/// - Background: surface (white, dark-mode ready)
/// - Icon: 42px tight (iconSizeTight), 65% fill ratio
/// - Shadow: blur 16px, offset (0,6), opacity 0.18
class FloatingSyncButton extends StatelessWidget {
  final VoidCallback onTap;
  final String iconPath;
  final double size;
  final double iconSize;
  final bool iconTight; // whether the SVG glyph tightly fits its viewBox (no padding)
  final Color? backgroundColor;
  final bool isActive;

  const FloatingSyncButton({
    super.key,
    required this.onTap,
    required this.iconPath,
    this.size = buttonDiameter, // Figma spec: 64px (from tokens)
    this.iconSize = iconSizeTight, // Default assumes tight SVG (42px → 65% fill)
    this.iconTight = true, // Current asset has padding → pass iconTight: false for compensation
    this.backgroundColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final dsTokens = Theme.of(context).extension<DsTokens>()!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Kodex: Use colorScheme.surface (not Colors.white) for future dark-mode compatibility
    final Color effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final Color iconColor = isActive
        ? colorScheme.primary // Gold #D9B18E when active
        : colorScheme.onSurface; // Black #030401 when inactive

    return Semantics(
      label: 'Sync',
      selected: isActive,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              shape: BoxShape.circle,
              // Kodex: Ring stroke from tokens (ringStrokeWidth = 2.0px)
              border: Border.all(
                color: dsTokens.accentPurple,
                width: ringStrokeWidth,
              ),
              // Shadow removed per visual feedback to avoid large grey disc under button
              boxShadow: const [],
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                // If the SVG has padding (non-tight), compensate so the visible glyph fills 65%
                width: iconTight ? iconSize : iconSizeCompensated,
                height: iconTight ? iconSize : iconSizeCompensated,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
