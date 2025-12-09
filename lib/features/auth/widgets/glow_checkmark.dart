import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

/// Glow checkmark icon for the Success screen.
///
/// Figma Details:
/// - Outer Circle: 104px × 104px
/// - Circle Color: Radial Gradient (Beige Glow)
/// - Inner Icon: 48px × 48px, Checkmark
/// - Icon Color: #FFFFFF (white with stroke)
///
/// NOTE: The existing _SuccessIcon uses green (#04B155).
/// This widget uses a beige radial gradient glow as per Figma.
class GlowCheckmark extends StatelessWidget {
  const GlowCheckmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AuthLayout.successIconCircle,
      height: AuthLayout.successIconCircle,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            DsColors.authGradientLight, // Center: lighter
            DsColors.authGradientBase, // Edge: base color
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: DsColors.authGradientBase.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.check_rounded,
          size: AuthLayout.successIconInner,
          color: DsColors.white,
        ),
      ),
    );
  }
}
