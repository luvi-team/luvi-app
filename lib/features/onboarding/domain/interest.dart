import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/onboarding/domain/onboarding_option_ids.dart';

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
  /// Canonical, stable ID persisted in Supabase.
  InterestId get id => switch (this) {
        Interest.strengthTraining => InterestIds.strengthTraining,
        Interest.cardio => InterestIds.cardio,
        Interest.mobility => InterestIds.mobility,
        Interest.nutrition => InterestIds.nutrition,
        Interest.mindfulness => InterestIds.mindfulness,
        Interest.hormonesCycle => InterestIds.hormonesCycle,
      };

  /// Database key (legacy alias; use [id] for new code).
  String get key => id;

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
    final id = canonicalizeInterestId(key);
    return switch (id) {
      InterestIds.strengthTraining => Interest.strengthTraining,
      InterestIds.cardio => Interest.cardio,
      InterestIds.mobility => Interest.mobility,
      InterestIds.nutrition => Interest.nutrition,
      InterestIds.mindfulness => Interest.mindfulness,
      InterestIds.hormonesCycle => Interest.hormonesCycle,
      _ => null,
    };
  }
}
