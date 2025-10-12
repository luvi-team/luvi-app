import 'package:flutter/material.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';

/// Painter for violet top-border wave with center cutout (concave down for sync button).
/// Stroke only (no fill), round caps/joins.
///
/// Design tokens (from Figma audit 2025-10-06, Spec-JSON):
/// - cutoutHalfWidth: 59px (from tokens)
/// - cutoutDepth: 38px (from tokens, was 25px)
/// - Curve: Two symmetrical cubic Bezier segments with horizontal tangents at endpoints
/// - strokeWidth: 1.5px (waveStrokeWidth)
///
/// Kodex: Formula-based parameters (no magic numbers). Cubic curves provide smooth,
/// natural wave shape matching Figma, unlike single quadratic which was too angular.
class BottomWaveBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;

  BottomWaveBorderPainter({
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final centerX = size.width / 2;

    // Kodex: Use tokens (no magic numbers)
    final a = cutoutHalfWidth; // 59px
    final d = cutoutDepth; // 38px

    // Control point offsets for smooth cubic curve with horizontal tangents
    // Tunable via tokens: waveCpAlpha and waveCpBeta
    final alpha = waveCpAlpha * a; // default ≈ 0.55×a → circle-like

    // Start from left edge (inset from top to avoid AA seam)
    path.moveTo(0, waveTopInset);

    // Line to left side of cutout
    path.lineTo(centerX - a, waveTopInset);

    // Cutout curve: Two symmetrical cubic Bezier segments
    // Segment 1: (-a, 0) → (0, -d)
    // - cp1 at (-a + α, 0) for horizontal tangent at left end
    // - cp2 at (-0.275×a, -d) for smooth transition at center
    path.cubicTo(
      centerX - a + alpha, waveTopInset, // cp1: horizontal tangent at left endpoint
      centerX - waveCpBeta * a, waveTopInset + d, // cp2: smooth approach to center bottom
      centerX, waveTopInset + d, // endpoint: center bottom of wave
    );

    // Segment 2: (0, -d) → (+a, 0)
    // - cp1 at (+0.275×a, -d) for smooth transition from center
    // - cp2 at (+a - α, 0) for horizontal tangent at right end
    path.cubicTo(
      centerX + waveCpBeta * a, waveTopInset + d, // cp1: smooth departure from center bottom
      centerX + a - alpha, waveTopInset, // cp2: horizontal tangent at right endpoint
      centerX + a, waveTopInset, // endpoint: right side of cutout
    );

    // Line to right edge
    path.lineTo(size.width, waveTopInset);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BottomWaveBorderPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
           borderWidth != oldDelegate.borderWidth;
  }
}
