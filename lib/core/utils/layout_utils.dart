import 'dart:math' as math;

/// Converts an absolute Figma Y-position into the additional spacing needed
/// after the SafeArea top padding.
///
/// Both [figmaY] and [figmaSafeTop] should be non-negative and finite.
double topOffsetFromSafeArea(
  double figmaY, {
  required double figmaSafeTop,
}) {
  if (figmaY < 0 || !figmaY.isFinite) {
    throw ArgumentError.value(
      figmaY,
      'figmaY',
      'must be non-negative and finite',
    );
  }
  if (figmaSafeTop < 0 || !figmaSafeTop.isFinite) {
    throw ArgumentError.value(
      figmaSafeTop,
      'figmaSafeTop',
      'must be non-negative and finite',
    );
  }
  return math.max(0, figmaY - figmaSafeTop);
}
