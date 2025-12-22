import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/onboarding/model/onboarding_option_ids.dart';

/// User goal options for onboarding O4 screen.
///
/// These goals help personalize training and content recommendations.
/// Serialized as stable IDs to Supabase JSONB.
enum Goal {
  fitter, // "Fitter & stärker werden"
  energy, // "Mehr Energie im Alltag"
  sleep, // "Besser schlafen und Stress reduzieren"
  cycle, // "Zyklus & Hormone verstehen"
  longevity, // "Langfristige Gesundheit und Longevity"
  wellbeing, // "Mich einfach wohlfühlen"
}

extension GoalExtension on Goal {
  /// Canonical, stable ID persisted in Supabase.
  GoalId get id => switch (this) {
        Goal.fitter => GoalIds.fitter,
        Goal.energy => GoalIds.energy,
        Goal.sleep => GoalIds.sleep,
        Goal.cycle => GoalIds.cycle,
        Goal.longevity => GoalIds.longevity,
        Goal.wellbeing => GoalIds.wellbeing,
      };

  /// Database key (legacy alias; use [id] for new code).
  String get dbKey => id;

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
    final id = canonicalizeGoalId(key);
    return switch (id) {
      GoalIds.fitter => Goal.fitter,
      GoalIds.energy => Goal.energy,
      GoalIds.sleep => Goal.sleep,
      GoalIds.cycle => Goal.cycle,
      GoalIds.longevity => Goal.longevity,
      GoalIds.wellbeing => Goal.wellbeing,
      _ => null,
    };
  }
}
