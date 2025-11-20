import 'package:flutter/foundation.dart';

@immutable
class Recommendation {
  const Recommendation({
    required this.tag,
    required this.title,
    required this.imagePath,
    this.subtitle,
  });

  final String tag;
  final String title;
  final String imagePath;
  final String? subtitle;

  Recommendation copyWith({
    String? tag,
    String? title,
    String? imagePath,
    String? subtitle,
  }) {
    return Recommendation(
      tag: tag ?? this.tag,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Recommendation &&
        other.tag == tag &&
        other.title == title &&
        other.imagePath == imagePath &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(tag, title, imagePath, subtitle);
}

typedef RecommendationProps = Recommendation;
