import 'package:flutter/foundation.dart' show immutable;
import 'package:luvi_app/features/dashboard/domain/models/category.dart';

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

  DashboardVM copyWith({
    double? cycleProgressRatio,
    HeroCtaState? heroCta,
    Category? selectedCategory,
  }) => DashboardVM(
    cycleProgressRatio: cycleProgressRatio ?? this.cycleProgressRatio,
    heroCta: heroCta ?? this.heroCta,
    selectedCategory: selectedCategory ?? this.selectedCategory,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardVM &&
        other.cycleProgressRatio == cycleProgressRatio &&
        other.heroCta == heroCta &&
        other.selectedCategory == selectedCategory;
  }

  @override
  int get hashCode =>
      Object.hash(cycleProgressRatio, heroCta, selectedCategory);
}

/// Hero CTA state: resumes a running program or starts a fresh one.
enum HeroCtaState { resumeActiveWorkout, startNewWorkout }
