import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Circular progress ring widget with animation for success screen (O9).
///
/// Figma specs:
/// - Size: 200 × 200px
/// - Stroke width: 8
/// - Color: DsColors.signature (progress), DsColors.gray300 (track)
class CircularProgressRing extends StatefulWidget {
  const CircularProgressRing({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.onAnimationComplete,
    this.size = 200,
    this.strokeWidth = 8,
  });

  /// Duration of the animation from 0% to 100%
  final Duration duration;

  /// Callback when animation reaches 100%
  final VoidCallback? onAnimationComplete;

  /// Size of the ring (width and height)
  final double size;

  /// Stroke width of the ring
  final double strokeWidth;

  @override
  State<CircularProgressRing> createState() => CircularProgressRingState();
}

class CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Current progress value (0.0 to 1.0)
  double get progress => _controller.value;

  /// Current progress percentage (0 to 100)
  int get progressPercent => (progress * 100).round();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    // Start animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Restart the animation from 0%
  void restart() {
    _controller.reset();
    _controller.forward();
  }

  /// Set progress to a specific value (0.0 to 1.0)
  void setProgress(double value) {
    _controller.value = value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.semanticLoadingProgress,
      value: l10n.semanticProgressPercent(progressPercent),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Background track
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: 1.0,
                    strokeWidth: widget.strokeWidth,
                    color: DsColors.gray300,
                  ),
                ),
                // Progress arc
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: _controller.value,
                    strokeWidth: widget.strokeWidth,
                    color: DsColors.signature,
                  ),
                ),
                // Percentage text
                Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: DsColors.grayscaleBlack,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  final double progress;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Start from top (-90 degrees)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
