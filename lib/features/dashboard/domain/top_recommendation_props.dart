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
}
