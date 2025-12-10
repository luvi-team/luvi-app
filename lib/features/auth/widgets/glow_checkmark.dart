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
        // Figma: Radial Gradient with 9 stops for beige glow effect
        gradient: RadialGradient(
          colors: [
            DsColors.authGradientBase,   // 0%: #D4B896
            DsColors.authRadialStop1,    // 14.17%: #DBC4A7
            DsColors.authRadialStop2,    // 32.86%: #E4D3BE
            DsColors.authRadialStop3,    // 42.51%: #E9DBCA
            DsColors.authGradientLight,  // 49.82%: #EDE1D3 (center highlight)
            DsColors.authRadialStop4,    // 60.22%: #E8D9C7
            DsColors.authRadialStop5,    // 74.22%: #E1CDB5
            DsColors.authRadialStop6,    // 85.34%: #DBC4A8
            DsColors.authGradientBase,   // 99.99%: #D4B896
          ],
          stops: const [
            0.0,
            0.1417,
            0.3286,
            0.4251,
            0.4982,
            0.6022,
            0.7422,
            0.8534,
            0.9999,
          ],
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
