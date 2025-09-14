import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackButtonCircle extends StatelessWidget {
  const BackButtonCircle({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const _chevronSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12.5007 14.1666L8.33398 9.99992L12.5007 5.83325" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Zurück',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                alignment: Alignment.center,
                child: SvgPicture.string(
                  _chevronSvg,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
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

