import 'package:flutter/foundation.dart' show immutable;

/// Lightweight contract that mirrors the dashboard state documented in
/// `docs/ui/contracts/dashboard_state.md`.
@immutable
class DashboardVM {
  /// Drives the progress ring inside the hero card (0.0–1.0).
  final double cycleProgressRatio;

  /// Controls which CTA label is rendered in the hero card.
  final HeroCtaState heroCta;

  /// Highlights the active category chip and scopes recommendations.
  final Category selectedCategory;

  const DashboardVM({
    required this.cycleProgressRatio,
    required this.heroCta,
    required this.selectedCategory,
  });
}

/// Hero CTA state: resumes a running program or starts a fresh one.
enum HeroCtaState {
  resumeActiveWorkout,
  startNewWorkout,
}

/// Dashboard category chips used for recommendations and filtering.
enum Category {
  training,
  nutrition,
  regeneration,
  mindfulness,
}
