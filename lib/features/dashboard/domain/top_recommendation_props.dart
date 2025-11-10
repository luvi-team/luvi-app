import 'package:flutter/foundation.dart';

@immutable
class TopRecommendationProps {
  const TopRecommendationProps({
    required this.id,
    required this.tag,
    required this.title,
    required this.imagePath,
    required this.badgeAssetPath,
    this.fromLuviSync = true,
    this.duration,
  });

  final String id;
  final String tag;
  final String title;
  final String imagePath;
  final String badgeAssetPath;
  final bool fromLuviSync;
  final String? duration;

  static const Object _unset = Object();

  /// Uses the [_unset] sentinel so callers can keep the existing [duration],
  /// pass `null` to clear it, or provide a new value; the `as String?` cast is
  /// safe because `_unset` is the only non-string sentinel accepted here.
  TopRecommendationProps copyWith({
    String? id,
    String? tag,
    String? title,
    String? imagePath,
    String? badgeAssetPath,
    bool? fromLuviSync,
    Object? duration = _unset,
  }) => TopRecommendationProps(
    id: id ?? this.id,
    tag: tag ?? this.tag,
    title: title ?? this.title,
    imagePath: imagePath ?? this.imagePath,
    badgeAssetPath: badgeAssetPath ?? this.badgeAssetPath,
    fromLuviSync: fromLuviSync ?? this.fromLuviSync,
    duration: identical(duration, _unset) ? this.duration : duration as String?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopRecommendationProps &&
        other.id == id &&
        other.tag == tag &&
        other.title == title &&
        other.imagePath == imagePath &&
        other.badgeAssetPath == badgeAssetPath &&
        other.fromLuviSync == fromLuviSync &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(
    id,
    tag,
    title,
    imagePath,
    badgeAssetPath,
    fromLuviSync,
    duration,
  );
}
