import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

/// Conic gradient background for the SignIn screen.
///
/// Figma Gradient Details:
/// - Type: Conic Gradient (transformed)
/// - Matrix: -23.89, -0.69962, 0.32271, -11.02
/// - Center: (197, 395.5)
///
/// Stops:
/// - -11.03%: #D4B896
/// - 10.15%: #D4B896
/// - 19.79%: #E5D3BF
/// - 29.13%: #EADDCD
/// - 40.04%: #D4B896
/// - 60.93%: #D6BC9C
/// - 71.72%: #EDE1D3
/// - 78.65%: #E2CFB8
/// - 88.97%: #D4B896
/// - 110.15%: #D4B896
///
/// NOTE: Flutter's SweepGradient doesn't support matrix transforms like Figma.
/// This implementation approximates the visual effect using a swept gradient
/// with adjusted stops. For pixel-perfect accuracy, a CustomPainter with
/// shader would be required.
class AuthConicGradientBackground extends StatelessWidget {
  const AuthConicGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConicGradientPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ConicGradientPainter extends CustomPainter {
  // Figma color stops (normalized to 0-1 range, clamped for negatives)
  static const List<Color> _colors = [
    DsColors.authGradientBase, // #D4B896 (0%)
    DsColors.authGradientBase, // #D4B896 (10.15%)
    DsColors.authGradientStop1, // #E5D3BF (19.79%)
    DsColors.authGradientStop2, // #EADDCD (29.13%)
    DsColors.authGradientBase, // #D4B896 (40.04%)
    DsColors.authGradientStop3, // #D6BC9C (60.93%)
    DsColors.authGradientLight, // #EDE1D3 (71.72%)
    DsColors.authGradientStop4, // #E2CFB8 (78.65%)
    DsColors.authGradientBase, // #D4B896 (88.97%)
    DsColors.authGradientBase, // #D4B896 (100%)
  ];

  // Stops normalized from Figma percentages (clipped to 0-1)
  static const List<double> _stops = [
    0.0, // -11.03% clamped
    0.1015, // 10.15%
    0.1979, // 19.79%
    0.2913, // 29.13%
    0.4004, // 40.04%
    0.6093, // 60.93%
    0.7172, // 71.72%
    0.7865, // 78.65%
    0.8897, // 88.97%
    1.0, // 110.15% clamped
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = SweepGradient(
      // Figma center (197, 395.5) on ~394×841 canvas → normalized to (0.5, 0.47) → Alignment(0.0, -0.06)
      center: const Alignment(0.0, -0.06),
      colors: _colors,
      stops: _stops,
      // Slight rotation to better match Figma's matrix transform effect
      transform: const GradientRotation(-math.pi / 6),
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ConicGradientPainter oldDelegate) => false;
}
