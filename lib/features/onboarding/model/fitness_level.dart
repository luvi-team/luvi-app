import 'package:luvi_app/l10n/app_localizations.dart';

/// Fitness level options for onboarding O3.
/// DB constraint: fitness_level IN ('beginner', 'occasional', 'fit')
enum FitnessLevel {
  beginner, // UI: "Nicht fit"
  occasional, // UI: "Fit"
  fit, // UI: "Sehr fit"
}

extension FitnessLevelExtension on FitnessLevel {
  /// Returns the DB key (enum name)
  String get dbKey => name;

  /// Returns the localized label for UI display
  String label(AppLocalizations l10n) => switch (this) {
        FitnessLevel.beginner => l10n.fitnessLevelBeginner,
        FitnessLevel.occasional => l10n.fitnessLevelOccasional,
        FitnessLevel.fit => l10n.fitnessLevelFit,
      };

  /// Maps selection index (0, 1, 2, 3) to FitnessLevel.
  /// Index 3 ("unknown") maps to beginner as fallback.
  static FitnessLevel fromSelectionIndex(int index) {
    // Onboarding08 has 4 options, but enum only has 3 values
    // Option 3 ("Weiß ich nicht") should default to beginner
    if (index >= FitnessLevel.values.length) {
      return FitnessLevel.beginner;
    }
    return FitnessLevel.values[index.clamp(0, FitnessLevel.values.length - 1)];
  }

  /// Maps FitnessLevel to selection index (null-safe).
  /// Returns null if level is null.
  static int? selectionIndexFor(FitnessLevel? level) {
    return level?.index;
  }
}
