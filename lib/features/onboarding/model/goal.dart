import 'package:luvi_app/l10n/app_localizations.dart';

/// User goal options for onboarding O4 screen.
///
/// These goals help personalize training and content recommendations.
/// Serialized as enum names to Supabase JSONB.
enum Goal {
  fitter, // "Fitter & stärker werden"
  energy, // "Mehr Energie im Alltag"
  sleep, // "Besser schlafen und Stress reduzieren"
  cycle, // "Zyklus & Hormone verstehen"
  longevity, // "Langfristige Gesundheit und Longevity"
  wellbeing, // "Mich einfach wohlfühlen"
}

extension GoalExtension on Goal {
  /// Database key (enum name for consistency with FitnessLevel)
  String get dbKey => name;

  /// Localized label for UI
  String label(AppLocalizations l10n) => switch (this) {
        Goal.fitter => l10n.goalFitter,
        Goal.energy => l10n.goalEnergy,
        Goal.sleep => l10n.goalSleep,
        Goal.cycle => l10n.goalCycle,
        Goal.longevity => l10n.goalLongevity,
        Goal.wellbeing => l10n.goalWellbeing,
      };

  /// Icon asset path for this goal
  String get iconPath => switch (this) {
        Goal.fitter => 'assets/icons/onboarding/ic_muscle.svg',
        Goal.energy => 'assets/icons/onboarding/ic_energy.svg',
        Goal.sleep => 'assets/icons/onboarding/ic_sleep.svg',
        Goal.cycle => 'assets/icons/onboarding/ic_calendar.svg',
        Goal.longevity => 'assets/icons/onboarding/ic_run.svg',
        Goal.wellbeing => 'assets/icons/onboarding/ic_happy.svg',
      };

  /// Parse from database key
  static Goal? fromDbKey(String key) {
    for (final goal in Goal.values) {
      if (goal.dbKey == key) {
        return goal;
      }
    }
    return null;
  }
}
