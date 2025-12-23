import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/onboarding/model/onboarding_option_ids.dart';

/// Fitness level options for onboarding O3.
/// DB constraint: fitness_level IN ('beginner', 'occasional', 'fit')
enum FitnessLevel {
  beginner, // UI: "Nicht fit"
  occasional, // UI: "Fit"
  fit, // UI: "Sehr fit"
}

extension FitnessLevelExtension on FitnessLevel {
  /// Canonical, stable ID persisted in Supabase.
  FitnessLevelId get id => switch (this) {
        FitnessLevel.beginner => FitnessLevelIds.beginner,
        FitnessLevel.occasional => FitnessLevelIds.occasional,
        FitnessLevel.fit => FitnessLevelIds.fit,
      };

  /// Returns the DB key (legacy alias; use [id] for new code).
  String get dbKey => id;

  /// Returns the localized label for UI display
  String label(AppLocalizations l10n) => switch (this) {
        FitnessLevel.beginner => l10n.fitnessLevelBeginner,
        FitnessLevel.occasional => l10n.fitnessLevelOccasional,
        FitnessLevel.fit => l10n.fitnessLevelFit,
      };

  /// Parse a stored ID (or legacy value) into a [FitnessLevel].
  static FitnessLevel? fromStoredId(String? raw) {
    final id = canonicalizeFitnessLevelId(raw);
    return switch (id) {
      FitnessLevelIds.beginner => FitnessLevel.beginner,
      FitnessLevelIds.occasional => FitnessLevel.occasional,
      FitnessLevelIds.fit => FitnessLevel.fit,
      _ => null,
    };
  }

  /// Maps selection index (0, 1, 2, 3) to FitnessLevel.
  /// Index 3 ("unknown") maps to beginner as fallback.
  static FitnessLevel fromSelectionIndex(int index) {
    // Out-of-range indices (including "Weiß ich nicht" at index 3) default to beginner
    if (index < 0 || index >= FitnessLevel.values.length) {
      return FitnessLevel.beginner;
    }
    return FitnessLevel.values[index];
  }

  /// Maps FitnessLevel to selection index (null-safe).
  /// Returns null if level is null.
  static int? selectionIndexFor(FitnessLevel? level) {
    return level?.index;
  }
}
