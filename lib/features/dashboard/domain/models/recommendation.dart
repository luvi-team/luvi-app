import 'package:flutter/foundation.dart' hide Category;
import 'category.dart';

/// Tag-to-Category mapping. Add new tags here as content expands.
/// Keys are lowercase for case-insensitive matching.
const _tagCategoryMap = <String, Category>{
  // Training
  'kraft': Category.training,
  'cardio': Category.training,
  'hiit': Category.training,
  // Nutrition
  'supplements': Category.nutrition,
  'makros': Category.nutrition,
  'tagebuch': Category.nutrition,
  'rezepte': Category.nutrition,
  // Regeneration
  'achtsamkeit': Category.regeneration,
  'beweglichkeit': Category.regeneration,
  'beauty': Category.regeneration,
  'schlaf': Category.regeneration,
  // Mindfulness
  'meditation': Category.mindfulness,
  'wellness': Category.mindfulness,
  'entspannung': Category.mindfulness,
};

/// Maps a recommendation tag to its corresponding category.
/// Returns null if tag is unmapped (recommendation shows in all categories).
Category? categoryFromTag(String tag) => _tagCategoryMap[tag.trim().toLowerCase()];

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
    Object? subtitle = const _Unset(),
  }) {
    return Recommendation(
      tag: tag ?? this.tag,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      subtitle:
          identical(subtitle, const _Unset()) ? this.subtitle : subtitle as String?,
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

class _Unset {
  const _Unset();
}
