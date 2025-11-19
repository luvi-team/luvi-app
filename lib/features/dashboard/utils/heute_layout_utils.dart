import 'dart:math' as math;

/// Compresses the first row of measured chip widths so they fit into the
/// available [contentWidth] while respecting [minGap] between items and
/// [minWidth] per item.
List<double> compressFirstRowWidths({
  required List<double> measured,
  required double contentWidth,
  required int columnCount,
  required double minGap,
  required double minWidth,
}) {
  final resolvedWidths = List<double>.from(measured);
  final gapCount = columnCount > 1 ? columnCount - 1 : 0;
  final minGapTotal = gapCount * minGap;
  final availableForItems = math.max(0, contentWidth - minGapTotal);

  if (columnCount > 0 && availableForItems > 0) {
    final totalWidth = resolvedWidths
        .take(columnCount)
        .fold<double>(0, (sum, width) => sum + width);
    if (totalWidth > availableForItems) {
      final shrinkFactor = availableForItems / totalWidth;
      for (var i = 0; i < columnCount; i++) {
        final scaledWidth = resolvedWidths[i] * shrinkFactor;
        resolvedWidths[i] = math.max(minWidth, scaledWidth);
      }
    }
  }

  return resolvedWidths;
}
