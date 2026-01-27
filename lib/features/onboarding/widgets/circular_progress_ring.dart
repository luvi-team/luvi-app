import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Circular progress ring widget with 4 segments and rotation for O9.
///
/// Figma specs v3:
/// - Size: 200 × 200px
/// - Stroke width: 8
/// - 4 magenta segments with gaps
/// - Rotation animation during loading/saving
/// - Stops rotating when complete
class CircularProgressRing extends StatefulWidget {
  const CircularProgressRing({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.onAnimationComplete,
    this.size = 200,
    this.strokeWidth = 8,
    this.isSpinning = true,
  });

  /// Duration of the progress animation from 0% to 100%
  final Duration duration;

  /// Callback when animation reaches 100%
  final VoidCallback? onAnimationComplete;

  /// Size of the ring (width and height)
  final double size;

  /// Stroke width of the ring
  final double strokeWidth;

  /// Whether the ring should spin (true during animating/saving, false on success)
  final bool isSpinning;

  @override
  State<CircularProgressRing> createState() => CircularProgressRingState();
}

class CircularProgressRingState extends State<CircularProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _rotationController;

  // Ring segment specifications (Figma v3)
  static const int _segmentCount = 4;
  static const double _segmentAngle = 70.0; // Degrees per segment
  static const double _gapAngle = 20.0; // Degrees between segments

  /// Current progress value (0.0 to 1.0)
  double get progress => _progressController.value;

  /// Current progress percentage (0 to 100)
  int get progressPercent => (progress * 100).round();

  @override
  void initState() {
    super.initState();

    // Progress animation (0-100%)
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Stop rotation when progress complete
        _rotationController.stop();
        widget.onAnimationComplete?.call();
      }
    });

    // Rotation animation (continuous spin)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Start both animations
    _progressController.forward();
    if (widget.isSpinning) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle isSpinning changes
    if (widget.isSpinning && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isSpinning && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// Restart the animation from 0%
  void restart() {
    _progressController.reset();
    _progressController.forward();
    if (widget.isSpinning) {
      _rotationController.repeat();
    }
  }

  /// Set progress to a specific value (0.0 to 1.0)
  void setProgress(double value) {
    _progressController.value = value.clamp(0.0, 1.0);
  }

  /// Animate progress to specific value smoothly
  void animateToProgress(double value, {Duration? duration}) {
    _progressController.animateTo(
      value.clamp(0.0, 1.0),
      duration: duration ?? const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      throw FlutterError(
        'AppLocalizations not found. Ensure MaterialApp includes localization delegates.',
      );
    }
    return SizedBox(
      key: const Key(TestKeys.circularProgressRingContainer),
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressController, _rotationController]),
        builder: (context, child) {
          // Semantics inside AnimatedBuilder for reactive a11y updates
          return Semantics(
            label: l10n.semanticLoadingProgress,
            value: l10n.semanticProgressPercent(progressPercent),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background track (gray full circle)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _TrackPainter(
                    strokeWidth: widget.strokeWidth,
                    color: DsColors.gray300,
                  ),
                ),
                // Rotating 4 segments
                Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _SegmentedRingPainter(
                      progress: _progressController.value,
                      strokeWidth: widget.strokeWidth,
                      color: DsColors.signature,
                      segmentCount: _segmentCount,
                      segmentAngle: _segmentAngle,
                      gapAngle: _gapAngle,
                    ),
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
            ),
          );
        },
      ),
    );
  }
}

/// Painter for the gray background track (full circle)
class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.strokeWidth,
    required this.color,
  });

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for 4 magenta segments with gaps
class _SegmentedRingPainter extends CustomPainter {
  const _SegmentedRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.segmentCount,
    required this.segmentAngle,
    required this.gapAngle,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final int segmentCount;
  final double segmentAngle;
  final double gapAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Convert degrees to radians
    final segmentAngleRad = segmentAngle * math.pi / 180;
    final gapAngleRad = gapAngle * math.pi / 180;

    // Total angle covered by all segments and gaps
    final totalAnglePerSegment = segmentAngleRad + gapAngleRad;

    // Start from top (-90 degrees)
    const startOffset = -math.pi / 2;

    // Draw each segment based on progress
    for (int i = 0; i < segmentCount; i++) {
      // Calculate how much of this segment should be visible based on progress
      final segmentStartProgress = i / segmentCount;
      final segmentEndProgress = (i + 1) / segmentCount;

      if (progress <= segmentStartProgress) {
        // This segment hasn't started yet
        continue;
      }

      // Calculate segment start angle
      final segmentStartAngle = startOffset + (i * totalAnglePerSegment);

      // Calculate how much of this segment to draw
      double segmentProgress;
      if (progress >= segmentEndProgress) {
        // Full segment
        segmentProgress = 1.0;
      } else {
        // Partial segment
        segmentProgress =
            (progress - segmentStartProgress) / (segmentEndProgress - segmentStartProgress);
      }

      final sweepAngle = segmentAngleRad * segmentProgress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segmentStartAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.segmentCount != segmentCount ||
        oldDelegate.segmentAngle != segmentAngle ||
        oldDelegate.gapAngle != gapAngle;
  }
}
