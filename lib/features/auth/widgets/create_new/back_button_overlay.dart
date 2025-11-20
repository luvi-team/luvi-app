import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class CreateNewBackButtonOverlay extends StatelessWidget {
  const CreateNewBackButtonOverlay({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 40,
    this.iconSize = 20,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeTop = mediaQuery.padding.top;
    final extraTop = math.max(AuthLayout.figmaSafeTop - safeTop, 0);

    return SafeArea(
      top: true,
      bottom: false,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(
            top: AuthLayout.backButtonTopInset + extraTop,
            left: AuthLayout.horizontalPadding,
          ),
          child: BackButtonCircle(
            key: const ValueKey('backButtonCircle'),
            onPressed: onPressed,
            size: size,
            innerSize: size,
            backgroundColor: backgroundColor,
            iconColor: iconColor,
            iconSize: iconSize,
            semanticLabel:
                (AppLocalizations.of(context)?.authBackSemantic) ?? 'Back',
          ),
        ),
      ),
    );
  }
}
