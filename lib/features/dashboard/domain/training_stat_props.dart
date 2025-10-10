import 'package:flutter/foundation.dart';

@immutable
class TrainingStatProps {
  const TrainingStatProps({
    required this.label,
    required this.value,
    required this.iconAssetPath,
    this.unit,
    this.trend = const [],
    this.heartRateGlyphAsset,
  });

  final String label;
  final num value;
  final String iconAssetPath;
  final String? unit;
  final List<double> trend;
  final String? heartRateGlyphAsset;
}
