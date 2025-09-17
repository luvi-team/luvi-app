import 'package:flutter/widgets.dart';

/// Converts an absolute Figma Y-position into the additional spacing needed
/// after the SafeArea top padding.
double topOffsetFromSafeArea(
  BuildContext context,
  double figmaY, {
  required double figmaSafeTop,
}) {
  final gap = figmaY - figmaSafeTop;
  return gap < 0 ? 0 : gap;
}
