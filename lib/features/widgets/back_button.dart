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
    this.iconSize = 20,
    this.semanticLabel,
  });

  final VoidCallback onPressed;
  final double size;
  final double? innerSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isCircular;
  final double iconSize;
  final String? semanticLabel;

  static const _chevronSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12.5007 14.1666L8.33398 9.99992L12.5007 5.83325" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBackground = backgroundColor ?? theme.colorScheme.primary;
    final resolvedIconColor = iconColor ?? theme.colorScheme.onPrimary;
    final ShapeBorder shape = isCircular
        ? const CircleBorder()
        : const RoundedRectangleBorder(borderRadius: BorderRadius.zero);

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
                child: Container(
                  width: renderedSize,
                  height: renderedSize,
                  decoration: BoxDecoration(
                    color: resolvedBackground,
                    shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircular ? null : BorderRadius.zero,
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: SvgPicture.string(
                      _chevronSvg,
                      colorFilter: ColorFilter.mode(
                        resolvedIconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
