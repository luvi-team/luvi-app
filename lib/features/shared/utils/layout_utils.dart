import 'dart:math' as math;

/// Converts an absolute Figma Y-position into the additional spacing needed
/// after the SafeArea top padding.
///
/// Both [figmaY] and [figmaSafeTop] should be non-negative finite values.
double topOffsetFromSafeArea(
  double figmaY, {
  required double figmaSafeTop,
}) {
  assert(figmaY >= 0 && figmaY.isFinite, 'figmaY must be non-negative and finite');
  assert(figmaSafeTop >= 0 && figmaSafeTop.isFinite, 'figmaSafeTop must be non-negative and finite');
  return math.max(0, figmaY - figmaSafeTop);
}
