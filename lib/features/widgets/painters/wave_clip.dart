import 'package:flutter/material.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';

/// Custom clipper that creates a punch-out (circular hole) in the dock surface
/// underneath the floating sync button, preventing white edge/line visibility.
///
/// Clip shape: Rectangular dock area MINUS circular cutout at wave bottom.
/// Uses PathFillType.evenOdd to subtract the circle from the rectangle.
///
/// Design tokens (from Figma audit 2025-10-06, Spec-JSON):
/// - punchOutRadius: 35px (buttonDiameter/2 + ringStrokeWidth/2 + epsilon = 32+1+2)
/// - Punch-out center: (dockCenterX, cutoutDepth) = (centerX, 38px)
///
/// Kodex: Prevents white dock surface from showing between wave stroke and button.
/// Alternative to segment-stroke approach (this is cleaner for maintenance).
class WavePunchOutClipper extends CustomClipper<Path> {
  const WavePunchOutClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;

    // Draw outer rectangle (full dock area)
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Subtract circular punch-out at wave bottom center
    // Center: (centerX, cutoutDepth) - button sits here with gap above
    // Radius: punchOutRadius (35px) - covers button + ring + small margin
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX, cutoutDepth),
        radius: punchOutRadius,
      ),
    );

    // evenOdd: Subtracts the circle from the rectangle
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant WavePunchOutClipper oldClipper) {
    // No dynamic properties, never needs reclip
    return false;
  }
}
