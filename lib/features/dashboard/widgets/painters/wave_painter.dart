import 'package:flutter/material.dart';

/// Painter for the dashboard hero/phase waves with configurable curvature
/// direction. The wave fills the canvas with [color] and then carves a curved
/// section using [background], producing either a downward bulge
/// (`flipVertical == false`) or an upward bulge (`flipVertical == true`).
///
/// The curve uses cubic Bezier control points derived from the original
/// design asset (`consent_wave.svg`), preserving the visual ratios
/// (85.5, 214, 342.5 of a 428px width). This painter is used by
/// `HeuteScreen` for the hero overlay and phase recommendations sections.
class WavePainter extends CustomPainter {
  const WavePainter({
    required this.color,
    required this.amplitude,
    required this.background,
    this.flipVertical = false,
    this.useBlendCutout = false,
  });

  final Color color;
  final double amplitude;
  final Color background;
  // If true, curve bulges upward; if false, curve bulges downward.
  final bool flipVertical;
  final bool useBlendCutout;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final double w = size.width;
    final double h = size.height;
    if (w == 0 || h == 0) {
      return;
    }
    final double arc = amplitude.clamp(0.0, h);
    if (arc <= 0) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    // Ratios derived from consent_wave.svg control points (85.5, 214, 342.5 of width 428).
    const double c1Ratio = 85.5 / 428.0;
    const double midRatio = 214.0 / 428.0;
    const double c2Ratio = 342.5 / 428.0;
    const double endEaseRatio = 0.95;

    final double baseY = flipVertical ? arc : h - arc;
    // Calculate curve offset based on flip direction.
    final double curveOffset = flipVertical ? baseY - arc : baseY + arc;

    final Path path = Path()
      ..moveTo(0, baseY)
      ..cubicTo(0, baseY, w * c1Ratio, curveOffset, w * midRatio, curveOffset)
      ..cubicTo(
        w * c2Ratio,
        curveOffset,
        w * endEaseRatio,
        baseY,
        w,
        baseY,
      );

    if (flipVertical) {
      path
        ..lineTo(w, 0)
        ..lineTo(0, 0);
    } else {
      path
        ..lineTo(w, h)
        ..lineTo(0, h);
    }
    path.close();

    if (useBlendCutout) {
      canvas.saveLayer(Offset.zero & size, Paint());
      canvas.drawRect(Offset.zero & size, paint);
      final Paint maskPaint = Paint()..blendMode = BlendMode.dstOut;
      canvas.drawPath(path, maskPaint);
      canvas.restore();
      return;
    }

    canvas.drawRect(Offset.zero & size, paint);
    final Paint cutPaint = Paint()..color = background;
    canvas.drawPath(path, cutPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.background != background ||
        oldDelegate.flipVertical != flipVertical ||
        oldDelegate.useBlendCutout != useBlendCutout;
  }
}
