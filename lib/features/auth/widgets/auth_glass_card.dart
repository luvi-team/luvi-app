import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

/// Glassmorphism card for the SignIn screen.
///
/// Figma Details:
/// - Background: rgba(255, 255, 255, 0.1) - 10% white opacity
/// - Border Radius: 40px
/// - Width: 361px (responsive, fills available width with padding)
/// - Height: 204px (intrinsic based on content)
///
/// NOTE: The existing GlassTokens.light uses 55% opacity (#8CFFFFFF).
/// This widget uses 10% opacity as specified in Figma for Auth screens.
class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(Sizes.glassCardRadius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: DsColors.authGlassBackground,
            borderRadius: borderRadius,
            border: Border.all(
              color: DsColors.authGlassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
