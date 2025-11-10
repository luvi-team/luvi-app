import 'package:flutter/foundation.dart';

@immutable
class TrainingStatProps {
  TrainingStatProps({
    required this.label,
    required this.value,
    required this.iconAssetPath,
    this.unit,
    List<double> trend = const [],
    this.heartRateGlyphAsset,
  }) : trend = List.unmodifiable(trend);

  final String label;
  final num value;
  final String iconAssetPath;
  final String? unit;
  final List<double> trend;
  final String? heartRateGlyphAsset;

  static const Object _unset = Object();

  TrainingStatProps copyWith({
    String? label,
    num? value,
    String? iconAssetPath,
    Object? unit = _unset,
    List<double>? trend,
    Object? heartRateGlyphAsset = _unset,
  }) => TrainingStatProps(
    label: label ?? this.label,
    value: value ?? this.value,
    iconAssetPath: iconAssetPath ?? this.iconAssetPath,
    unit: identical(unit, _unset) ? this.unit : unit as String?,
    trend: trend == null ? this.trend : List.unmodifiable(trend),
    heartRateGlyphAsset: identical(heartRateGlyphAsset, _unset)
        ? this.heartRateGlyphAsset
        : heartRateGlyphAsset as String?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingStatProps &&
        other.label == label &&
        other.value == value &&
        other.iconAssetPath == iconAssetPath &&
        other.unit == unit &&
        listEquals(other.trend, trend) &&
        other.heartRateGlyphAsset == heartRateGlyphAsset;
  }

  @override
  int get hashCode => Object.hash(
    label,
    value,
    iconAssetPath,
    unit,
    Object.hashAll(trend),
    heartRateGlyphAsset,
  );
}
