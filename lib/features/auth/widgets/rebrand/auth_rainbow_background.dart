import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_rebrand_metrics.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ring Data Structure
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable data for a single rainbow ring.
///
/// Consolidates color, width, and offsets to prevent parallel arrays
/// from getting out of sync.
class _RingData {
  const _RingData({
    required this.color,
    required this.width,
    required this.xOffset,
    required this.yOffset,
  });

  final Color color;
  final double width;
  final double xOffset;
  final double yOffset;
}

/// All ring data from outer (teal) to inner (beige).
/// SSOT: context/design/auth_screens_design_audit.yaml
// Optimized: Cached as a final list to prevent reallocation on every paint.
final List<_RingData> _rings = [
  _RingData(
    color: DsColors.authRebrandRainbowTeal,
    width: AuthRebrandMetrics.rainbowRingWidths[0],
    xOffset: AuthRebrandMetrics.ringTealX,
    yOffset: AuthRebrandMetrics.ringTealY,
  ),
  _RingData(
    color: DsColors.authRebrandRainbowPink,
    width: AuthRebrandMetrics.rainbowRingWidths[1],
    xOffset: AuthRebrandMetrics.ringPinkX,
    yOffset: AuthRebrandMetrics.ringPinkY,
  ),
  _RingData(
    color: DsColors.authRebrandRainbowOrange,
    width: AuthRebrandMetrics.rainbowRingWidths[2],
    xOffset: AuthRebrandMetrics.ringOrangeX,
    yOffset: AuthRebrandMetrics.ringOrangeY,
  ),
  _RingData(
    color: DsColors.authRebrandBackground,
    width: AuthRebrandMetrics.rainbowRingWidths[3],
    xOffset: AuthRebrandMetrics.ringBeigeX,
    yOffset: AuthRebrandMetrics.ringBeigeY,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Rainbow Background Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Custom painter for the rainbow background used in Auth Rebrand v3.
///
/// Creates 4 vertical "Pill" RRects with rounded tops, from outer to inner:
/// - Teal (#1B9BA4)
/// - Pink (#D42C82)
/// - Orange (#F57A25)
/// - Beige (background color)
///
/// The RRects extend downward and create the "stripe" effect at the bottom
/// as they continue past the visible arc portion.
///
/// SSOT: context/design/auth_screens_design_audit.yaml
class AuthRainbowBackground extends StatelessWidget {
  const AuthRainbowBackground({
    super.key,
    this.containerWidth,
    this.containerTop,
  });

  /// Width of the rainbow container. Defaults to SSOT value (371).
  final double? containerWidth;

  /// Top offset for rainbow container from screen top.
  /// If null, uses default from AuthRebrandMetrics.overlayRainbowContainerTop.
  /// For dynamic alignment with back button chevron, calculate as:
  /// MediaQuery.of(context).padding.top + AuthRebrandMetrics.rainbowContainerTopOffset
  final double? containerTop;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainbowPillPainter(
        containerWidth: containerWidth ?? AuthRebrandMetrics.overlayRainbowContainerWidth,
        containerTop: containerTop,
      ),
      size: Size.infinite,
    );
  }
}

/// Painter that draws 4 concentric pill-shaped RRects per SSOT specifications.
class _RainbowPillPainter extends CustomPainter {
  _RainbowPillPainter({
    required this.containerWidth,
    this.containerTop,
  });

  final double containerWidth;
  final double? containerTop;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final containerCenterX = containerWidth / 2;
    final effectiveContainerTop =
        containerTop ?? AuthRebrandMetrics.overlayRainbowContainerTop;

    // Paint rings from outer (teal) to inner (beige)
    for (final ring in _rings) {
      final radius = ring.width / 2; // Pill radius = half width for round top
      final yOffset = ring.yOffset + effectiveContainerTop;

      // Skip rings entirely below canvas (off-screen optimization)
      if (yOffset >= size.height) continue;

      // Dynamic height extending to canvas bottom
      final height = size.height - yOffset + radius;

      // Ring X position relative to canvas center
      final ringLeft = centerX - containerCenterX + ring.xOffset;

      final paint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.fill;

      // Draw RRect with rounded top corners only (pill shape)
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(ringLeft, yOffset, ring.width, height),
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        // Bottom corners are square (0 radius) - stripes extend straight down
      );

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainbowPillPainter oldDelegate) {
    return containerWidth != oldDelegate.containerWidth ||
        containerTop != oldDelegate.containerTop;
  }
}
