import 'dart:math' as math;

/// Converts an absolute Figma Y-position into the additional spacing needed
/// after the SafeArea top padding.
double topOffsetFromSafeArea(
  double figmaY, {
  required double figmaSafeTop,
}) {
  return math.max(0, figmaY - figmaSafeTop);
}
