import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

class BackButtonCircle extends StatelessWidget {
  const BackButtonCircle({
    super.key,
    required this.onPressed,
    this.size = Sizes.touchTargetMin,
    this.innerSize,
    this.backgroundColor,
    this.iconColor,
    this.isCircular = true,
    this.showCircle = true,
    this.iconSize = 20,
    this.semanticLabel,
  });

  final VoidCallback onPressed;
  final double size;
  final double? innerSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isCircular;
  /// Whether to show the circular/rectangular background.
  /// Set to false for icon-only back button (Figma O2-O8 style).
  final bool showCircle;
  final double iconSize;
  final String? semanticLabel;

  // Figma Auth Back Icon: 32×32px viewBox
  // Path coordinates scaled from 20×20 to 32×32 (scale factor 1.6).
  // stroke-width 2.5 is a deliberate visual adjustment matching Figma spec,
  // not a mathematically scaled value from the original coordinates.
  static const _chevronSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32" fill="none"><path d="M20 22.67L13.33 16L20 9.33" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBackground = backgroundColor ?? theme.colorScheme.primary;
    final resolvedIconColor = iconColor ?? theme.colorScheme.onPrimary;
    final ShapeBorder shape = isCircular
        ? const CircleBorder()
        : const RoundedRectangleBorder(borderRadius: BorderRadius.zero);

    // Size calculations:
    // 1. hitSize: enforce minimum touch target for accessibility
    // 2. visualCandidate: desired visual size (defaults to size-4 for circular)
    // 3. visualSize: ensure non-negative
    // 4. renderedSize: visual size clamped to hit target bounds
    const double minHitSize = Sizes.touchTargetMin;
    final double hitSize = size < minHitSize ? minHitSize : size;
    final double visualCandidate = innerSize ?? (isCircular ? size - 4 : size);
    final double visualSize = visualCandidate < 0 ? 0 : visualCandidate;
    final double renderedSize = visualSize > hitSize ? hitSize : visualSize;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: Sizes.touchTargetMin,
          minHeight: Sizes.touchTargetMin,
        ),
        child: SizedBox(
          width: hitSize,
          height: hitSize,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: onPressed,
              customBorder: shape,
              child: Center(
                // Visible component equals [renderedSize]; tap target stays >= Sizes.touchTargetMin.
                child: _buildIcon(
                  showCircle: showCircle,
                  renderedSize: renderedSize,
                  resolvedBackground: resolvedBackground,
                  isCircular: isCircular,
                  iconSize: iconSize,
                  resolvedIconColor: resolvedIconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the chevron icon, optionally wrapped in a circular/rectangular container.
  Widget _buildIcon({
    required bool showCircle,
    required double renderedSize,
    required Color resolvedBackground,
    required bool isCircular,
    required double iconSize,
    required Color resolvedIconColor,
  }) {
    final chevronIcon = SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.string(
        _chevronSvg,
        colorFilter: ColorFilter.mode(
          resolvedIconColor,
          BlendMode.srcIn,
        ),
      ),
    );

    if (!showCircle) return chevronIcon;

    return Container(
      width: renderedSize,
      height: renderedSize,
      decoration: BoxDecoration(
        color: resolvedBackground,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      alignment: Alignment.center,
      child: chevronIcon,
    );
  }
}
