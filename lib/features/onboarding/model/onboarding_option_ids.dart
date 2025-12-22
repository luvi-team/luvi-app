/// Canonical, stable IDs for onboarding options stored in Supabase.
///
/// Rationale (MVP):
/// - Persist only internal IDs, never localized UI labels.
/// - UI copy/order can change without meaning drift in stored data.
/// - Provide best-effort legacy parsing for older stored values.
///
/// Storage locations:
/// - `public.profiles.fitness_level` (text)
/// - `public.profiles.goals` (jsonb array of strings)
/// - `public.profiles.interests` (jsonb array of strings)
typedef FitnessLevelId = String;
typedef GoalId = String;
typedef InterestId = String;

class FitnessLevelIds {
  const FitnessLevelIds._();

  static const FitnessLevelId beginner = 'beginner';
  static const FitnessLevelId occasional = 'occasional';
  static const FitnessLevelId fit = 'fit';

  static const Set<FitnessLevelId> values = {beginner, occasional, fit};
}

class GoalIds {
  const GoalIds._();

  static const GoalId fitter = 'fitter';
  static const GoalId energy = 'energy';
  static const GoalId sleep = 'sleep';
  static const GoalId cycle = 'cycle';
  static const GoalId longevity = 'longevity';
  static const GoalId wellbeing = 'wellbeing';

  static const Set<GoalId> values = {
    fitter,
    energy,
    sleep,
    cycle,
    longevity,
    wellbeing,
  };
}

class InterestIds {
  const InterestIds._();

  static const InterestId strengthTraining = 'strength_training';
  static const InterestId cardio = 'cardio';
  static const InterestId mobility = 'mobility';
  static const InterestId nutrition = 'nutrition';
  static const InterestId mindfulness = 'mindfulness';
  static const InterestId hormonesCycle = 'hormones_cycle';

  static const Set<InterestId> values = {
    strengthTraining,
    cardio,
    mobility,
    nutrition,
    mindfulness,
    hormonesCycle,
  };

  /// Legacy alias map for values that were previously persisted in enum-name
  /// format (camelCase) instead of snake_case IDs.
  static const Map<String, InterestId> legacyAliases = {
    'strengthTraining': strengthTraining,
    'hormonesCycle': hormonesCycle,
  };
}

String? _normalizeRawId(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

FitnessLevelId? canonicalizeFitnessLevelId(String? raw) {
  final normalized = _normalizeRawId(raw)?.toLowerCase();
  if (normalized == null) return null;

  if (FitnessLevelIds.values.contains(normalized)) {
    return normalized;
  }

  return null;
}

GoalId? canonicalizeGoalId(String? raw) {
  final normalized = _normalizeRawId(raw)?.toLowerCase();
  if (normalized == null) return null;

  if (GoalIds.values.contains(normalized)) {
    return normalized;
  }

  // Best-effort legacy aliases.
  switch (normalized) {
    case 'well_being':
      return GoalIds.wellbeing;
  }

  return null;
}

InterestId? canonicalizeInterestId(String? raw) {
  final normalizedRaw = _normalizeRawId(raw);
  if (normalizedRaw == null) return null;

  final alias = InterestIds.legacyAliases[normalizedRaw];
  if (alias != null) return alias;

  final normalized = normalizedRaw.toLowerCase();
  if (InterestIds.values.contains(normalized)) {
    return normalized;
  }

  return null;
}
