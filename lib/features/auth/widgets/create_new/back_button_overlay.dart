import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class CreateNewBackButtonOverlay extends StatelessWidget {
  const CreateNewBackButtonOverlay({
    super.key,
    required this.safeTop,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 40,
    this.iconSize = 20,
  });

  final double safeTop;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: safeTop + AuthLayout.backButtonTopInset,
      left: AuthLayout.horizontalPadding,
      child: BackButtonCircle(
        onPressed: onPressed,
        size: size,
        innerSize: size,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        iconSize: iconSize,
      ),
    );
  }
}

