import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_rebrand_metrics.dart';

/// Custom painter for the rainbow arc background used in Auth Rebrand v3.
///
/// Creates concentric half-circle arcs from outer to inner:
/// - Teal (#1B9BA4)
/// - Pink (#D42C82)
/// - Orange (#F57A25)
/// - Beige (background color)
///
/// Also paints the rainbow stripes at the bottom of the screen.
class AuthRainbowBackground extends StatelessWidget {
  const AuthRainbowBackground({
    super.key,
    this.showTopArcs = true,
    this.showBottomStripes = true,
    this.topArcsHeight = 280.0,
    this.bottomStripesHeight = 200.0,
  });

  /// Whether to show the top rainbow arcs
  final bool showTopArcs;

  /// Whether to show the bottom rainbow stripes
  final bool showBottomStripes;

  /// Height of the top arcs section
  final double topArcsHeight;

  /// Height of the bottom stripes section
  final double bottomStripesHeight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainbowPainter(
        showTopArcs: showTopArcs,
        showBottomStripes: showBottomStripes,
        topArcsHeight: topArcsHeight,
        bottomStripesHeight: bottomStripesHeight,
      ),
      size: Size.infinite,
    );
  }
}

class _RainbowPainter extends CustomPainter {
  _RainbowPainter({
    required this.showTopArcs,
    required this.showBottomStripes,
    required this.topArcsHeight,
    required this.bottomStripesHeight,
  });

  final bool showTopArcs;
  final bool showBottomStripes;
  final double topArcsHeight;
  final double bottomStripesHeight;

  // Rainbow colors from outer to inner
  static const List<Color> _arcColors = [
    DsColors.authRebrandRainbowTeal,
    DsColors.authRebrandRainbowPink,
    DsColors.authRebrandRainbowOrange,
    DsColors.authRebrandBackground, // Beige center
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    final backgroundPaint = Paint()..color = DsColors.authRebrandBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    if (showTopArcs) {
      _paintTopArcs(canvas, size);
    }

    if (showBottomStripes) {
      _paintBottomStripes(canvas, size);
    }
  }

  void _paintTopArcs(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final ringWidths = AuthRebrandMetrics.rainbowRingWidths;

    // Paint arcs from outer to inner
    for (int i = 0; i < ringWidths.length; i++) {
      final radius = ringWidths[i] / 2;
      final paint = Paint()
        ..color = _arcColors[i]
        ..style = PaintingStyle.fill;

      // Draw semicircle (top half)
      final rect = Rect.fromCircle(
        center: Offset(centerX, topArcsHeight),
        radius: radius,
      );

      canvas.drawArc(
        rect,
        3.14159, // Start from left (PI radians)
        3.14159, // Sweep 180 degrees (PI radians)
        true, // Use center
        paint,
      );
    }
  }

  void _paintBottomStripes(Canvas canvas, Size size) {
    final stripeWidth = size.width / 7; // 7 stripes
    final stripeTop = size.height - bottomStripesHeight;

    // Stripe colors from left to right (based on Figma)
    const stripeColors = [
      DsColors.authRebrandRainbowTeal,
      DsColors.authRebrandRainbowPink,
      DsColors.authRebrandRainbowOrange,
      DsColors.authRebrandBackground, // Beige
      DsColors.authRebrandRainbowOrange,
      DsColors.authRebrandRainbowPink,
      DsColors.authRebrandRainbowTeal,
    ];

    for (int i = 0; i < 7; i++) {
      final paint = Paint()..color = stripeColors[i];
      canvas.drawRect(
        Rect.fromLTWH(
          stripeWidth * i,
          stripeTop,
          stripeWidth,
          bottomStripesHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainbowPainter oldDelegate) {
    return showTopArcs != oldDelegate.showTopArcs ||
        showBottomStripes != oldDelegate.showBottomStripes ||
        topArcsHeight != oldDelegate.topArcsHeight ||
        bottomStripesHeight != oldDelegate.bottomStripesHeight;
  }
}
