import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

/// Linear gradient background for Login, Reset, and NewPassword screens.
///
/// Figma Gradient Stops (top to bottom):
/// - 18.37%: #D4B896 (authGradientBase)
/// - 50.33%: #EDE1D3 (authGradientLight)
/// - 74.47%: #D4B896 (authGradientBase)
class AuthLinearGradientBackground extends StatelessWidget {
  const AuthLinearGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DsColors.authGradientBase, // #D4B896
            DsColors.authGradientLight, // #EDE1D3
            DsColors.authGradientBase, // #D4B896
          ],
          stops: [
            0.1837, // 18.37%
            0.5033, // 50.33%
            0.7447, // 74.47%
          ],
        ),
      ),
    );
  }
}
