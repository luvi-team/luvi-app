import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/bottom_nav_tokens.dart';

/// Painter for violet top-border wave with center cutout (concave down for sync button).
/// Two-pass rendering: (1) surface fill for the dock body, (2) violet stroke on top.
/// Callers should pass their theme surface color for dark-mode parity; falls back to white.
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
  final Color fillColor;

  BottomWaveBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    Color? fillColor,
  }) : fillColor = fillColor ?? Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    // Pass 2 (stroke) paint setup
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round;

    // Pass 1: fill the navigation area below the wave with theme-provided surface color
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final fillPath = Path();
    final strokePath = Path();
    final muldePath = Path();
    final centerX = size.width / 2;

    // Kodex: Use tokens (no magic numbers)
    final a = cutoutHalfWidth; // 59px
    final d = cutoutDepth; // 38px

    // Control point offsets for smooth cubic curve with horizontal tangents
    // Tunable via tokens: waveCpAlpha and waveCpBeta
    final alpha = waveCpAlpha * a; // default ≈ 0.55×a → circle-like

    // Start from left edge (inset from top to avoid AA seam)
    fillPath.moveTo(0, waveTopInset);
    strokePath.moveTo(0, waveTopInset);
    muldePath.moveTo(centerX - a, waveTopInset);

    // Line to left side of cutout
    fillPath.lineTo(centerX - a, waveTopInset);
    strokePath.lineTo(centerX - a, waveTopInset);

    // Cutout curve: Two symmetrical cubic Bezier segments
    // Segment 1: (-a, 0) → (0, -d)
    void appendWave(Path target, {bool closeToTop = false}) {
      target
        ..cubicTo(
          centerX - a + alpha,
          waveTopInset, // cp1: horizontal tangent at left endpoint
          centerX - waveCpBeta * a,
          waveTopInset + d, // cp2: smooth approach to center bottom
          centerX,
          waveTopInset + d, // endpoint: center bottom of wave
        )
        ..cubicTo(
          centerX + waveCpBeta * a,
          waveTopInset + d, // cp1: smooth departure from center bottom
          centerX + a - alpha,
          waveTopInset, // cp2: horizontal tangent at right endpoint
          centerX + a,
          waveTopInset, // endpoint: right side of cutout
        );

      if (closeToTop) {
        target
          ..lineTo(centerX + a, waveTopInset)
          ..lineTo(centerX - a, waveTopInset);
      }
    }

    appendWave(fillPath);
    appendWave(muldePath, closeToTop: true);
    appendWave(strokePath);

    // Line to right edge
    fillPath.lineTo(size.width, waveTopInset);
    strokePath.lineTo(size.width, waveTopInset);

    // Close fill path down to bottom of canvas so only area below wave is painted
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Close mulde path so only the concave pocket is removed
    muldePath.close();

    final dockFillWithoutMulde = Path.combine(
      PathOperation.difference,
      fillPath,
      muldePath,
    );

    canvas.drawPath(dockFillWithoutMulde, fillPaint);
    canvas.drawPath(strokePath, paint);
  }

  @override
  bool shouldRepaint(covariant BottomWaveBorderPainter oldDelegate) {
    // Repaint only when paint‑relevant inputs change. Token geometry is stable at runtime.
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.fillColor != fillColor;
  }
}
