import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

/// Radial gradient background for authentication screens.
///
/// **Usage Note:** This widget has no intrinsic size and relies on its parent
/// to provide bounded constraints. It should be used with:
/// - `Positioned.fill()` in a Stack (recommended)
/// - `SizedBox.expand()` wrapper
/// - Inside a parent with defined dimensions
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     Positioned.fill(child: AuthRadialGradientBackground()),
///     // content...
///   ],
/// )
/// ```
///
/// Figma Gradient Details:
/// - Type: Radial Gradient
/// - Center: (197, 230.5) - approximately upper-center of screen
/// - Radius-Transform: scale(19.55, 15.767) - elliptical
///
/// Stops:
/// - 0%: #D4B896
/// - 14.17%: #DBC4A7
/// - 32.86%: #E4D3BE
/// - 42.51%: #E9DBCA
/// - 49.82%: #EDE1D3
/// - 60.22%: #E8D9C7
/// - 74.22%: #E1CDB5
/// - 85.34%: #DBC4A8
/// - 99.99%: #D4B896
///
/// NOTE: Flutter RadialGradient supports focal/center but not matrix transforms.
/// This implementation approximates the elliptical effect by using an adjusted
/// radius. The visual result is close to Figma but not pixel-perfect.
class AuthRadialGradientBackground extends StatelessWidget {
  const AuthRadialGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          // Center slightly above middle (Figma: y=230.5 on 852px height ≈ 27%)
          center: Alignment(0, -0.46),
          // Radius large enough to fill screen with elliptical feel
          radius: 1.2,
          colors: [
            DsColors.authGradientBase, // 0% - #D4B896
            DsColors.authRadialStop1, // 14.17% - #DBC4A7
            DsColors.authRadialStop2, // 32.86% - #E4D3BE
            DsColors.authRadialStop3, // 42.51% - #E9DBCA
            DsColors.authGradientLight, // 49.82% - #EDE1D3
            DsColors.authRadialStop4, // 60.22% - #E8D9C7
            DsColors.authRadialStop5, // 74.22% - #E1CDB5
            DsColors.authRadialStop6, // 85.34% - #DBC4A8
            DsColors.authGradientBase, // 99.99% - #D4B896
          ],
          stops: [
            0.0,
            0.1417,
            0.3286,
            0.4251,
            0.4982,
            0.6022,
            0.7422,
            0.8534,
            1.0,
          ],
        ),
      ),
    );
  }
}
