import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackButtonCircle extends StatelessWidget {
  const BackButtonCircle({
    super.key,
    required this.onPressed,
    this.size = 44,
    this.innerSize,
    this.backgroundColor,
    this.iconColor,
    this.isCircular = true,
    this.iconSize = 20,
  });

  final VoidCallback onPressed;
  final double size;
  final double? innerSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isCircular;
  final double iconSize;

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

    return Semantics(
      button: true,
      label: 'Zurück',
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: shape,
            child: Center(
              // Visible component equals [innerSize]; keeps legacy 40px circle
              // while allowing square 40px variant for forgot password.
              child: Container(
                width: innerSize ?? (isCircular ? size - 4 : size),
                height: innerSize ?? (isCircular ? size - 4 : size),
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
    );
  }
}
