import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_rebrand_metrics.dart';

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
    this.containerHeight,
    this.isOverlay = false,
  });

  /// Width of the rainbow container. Defaults to SSOT value (371).
  final double? containerWidth;

  /// Height of the rainbow container. Defaults to full available height.
  final double? containerHeight;

  /// If true, shifts Y-offsets down by rainbowContainerTop for overlay positioning.
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainbowPillPainter(
        containerWidth: containerWidth ?? AuthRebrandMetrics.overlayRainbowContainerWidth,
        isOverlay: isOverlay,
      ),
      size: Size.infinite,
    );
  }
}

/// Painter that draws 4 concentric pill-shaped RRects per SSOT specifications.
class _RainbowPillPainter extends CustomPainter {
  _RainbowPillPainter({
    required this.containerWidth,
    required this.isOverlay,
  });

  final double containerWidth;
  final bool isOverlay;

  // Rainbow colors from outer to inner (SSOT)
  static const List<Color> _ringColors = [
    DsColors.authRebrandRainbowTeal, // #1B9BA4
    DsColors.authRebrandRainbowPink, // #D42C82
    DsColors.authRebrandRainbowOrange, // #F57A25
    DsColors.authRebrandBackground, // Beige center
  ];

  // Ring widths from SSOT: teal=329, pink=249, orange=167, beige=87
  static const List<double> _ringWidths = [329.0, 249.0, 167.0, 87.0];

  // Ring X offsets relative to container (SSOT: auth_email_form.ring_offsets)
  static const List<double> _ringXOffsets = [
    AuthRebrandMetrics.ringTealX, // 21
    AuthRebrandMetrics.ringPinkX, // 58
    AuthRebrandMetrics.ringOrangeX, // 99
    AuthRebrandMetrics.ringBeigeX, // 139
  ];

  // Ring Y offsets relative to rainbow container (SSOT: auth_email_form.ring_offsets)
  static const List<double> _ringYOffsets = [
    AuthRebrandMetrics.ringTealY, // 7
    AuthRebrandMetrics.ringPinkY, // 56
    AuthRebrandMetrics.ringOrangeY, // 112
    AuthRebrandMetrics.ringBeigeY, // 168
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final containerCenterX = containerWidth / 2;

    // Paint rings from outer (teal) to inner (beige)
    for (int i = 0; i < _ringWidths.length; i++) {
      final width = _ringWidths[i];
      final radius = width / 2; // Pill radius = half width for perfect round top
      final xOffset = _ringXOffsets[i];

      // Overlay: Y-Offsets um rainbowContainerTop verschieben (SSOT: 53px)
      // Non-overlay (Entry): Y-Offsets unverändert
      final yOffset = isOverlay
          ? _ringYOffsets[i] + AuthRebrandMetrics.overlayRainbowContainerTop
          : _ringYOffsets[i];

      // Dynamische Höhe bis zum Canvas-Bottom
      // Mathematisch äquivalent zu SSOT-Höhen, aber geräteunabhängig
      final height = size.height - yOffset + radius;

      // Ring X position relative to canvas center
      // xOffset is relative to container left edge, containerCenterX is half of container
      final ringLeft = centerX - containerCenterX + xOffset;

      final paint = Paint()
        ..color = _ringColors[i]
        ..style = PaintingStyle.fill;

      // Draw RRect with rounded top corners only (pill shape)
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(ringLeft, yOffset, width, height),
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
        isOverlay != oldDelegate.isOverlay;
  }
}
