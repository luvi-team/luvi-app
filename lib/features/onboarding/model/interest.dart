import 'package:luvi_app/l10n/app_localizations.dart';

/// User interest categories for personalization (O5 screen).
///
/// These are used to customize content recommendations.
/// Serialized as snake_case strings to Supabase JSONB.
enum Interest {
  strengthTraining,
  cardio,
  mobility,
  nutrition,
  mindfulness,
  hormonesCycle,
}

extension InterestExtension on Interest {
  /// Database key (snake_case for Supabase)
  String get key => switch (this) {
        Interest.strengthTraining => 'strength_training',
        Interest.cardio => 'cardio',
        Interest.mobility => 'mobility',
        Interest.nutrition => 'nutrition',
        Interest.mindfulness => 'mindfulness',
        Interest.hormonesCycle => 'hormones_cycle',
      };

  /// Localized label for UI
  String label(AppLocalizations l10n) => switch (this) {
        Interest.strengthTraining => l10n.interestStrengthTraining,
        Interest.cardio => l10n.interestCardio,
        Interest.mobility => l10n.interestMobility,
        Interest.nutrition => l10n.interestNutrition,
        Interest.mindfulness => l10n.interestMindfulness,
        Interest.hormonesCycle => l10n.interestHormonesCycle,
      };

  /// Parse from database key
  static Interest? fromKey(String key) {
    for (final interest in Interest.values) {
      if (interest.key == key) {
        return interest;
      }
    }
    return null;
  }
}
