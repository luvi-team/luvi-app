import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:luvi_app/features/onboarding/domain/fitness_level.dart';
import 'package:luvi_app/features/onboarding/domain/goal.dart';
import 'package:luvi_app/features/onboarding/domain/interest.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';

part 'onboarding_state.g.dart';

/// Immutable data class holding all onboarding form state.
@immutable
class OnboardingData {
  /// Creates an immutable OnboardingData instance.
  /// Lists are wrapped with [List.unmodifiable] to enforce immutability.
  OnboardingData({
    this.name,
    this.birthDate,
    this.fitnessLevel,
    List<Goal>? selectedGoals,
    List<Interest>? selectedInterests,
    this.periodStart,
    this.periodDuration = kDefaultPeriodDuration,
    this.cycleLength = kDefaultCycleLength,
  })  : selectedGoals = selectedGoals != null
            ? List<Goal>.unmodifiable(selectedGoals)
            : const <Goal>[],
        selectedInterests = selectedInterests != null
            ? List<Interest>.unmodifiable(selectedInterests)
            : const <Interest>[];

  /// User's display name
  final String? name;

  /// User's birth date
  final DateTime? birthDate;

  /// User's fitness level selection
  final FitnessLevel? fitnessLevel;

  /// Selected goals (multi-select)
  final List<Goal> selectedGoals;

  /// Selected interests (3-5 required)
  final List<Interest> selectedInterests;

  /// Period start date
  final DateTime? periodStart;

  /// Period duration in days (default: 7)
  final int periodDuration;

  /// Cycle length in days (default: 28)
  final int cycleLength;

  /// Factory for empty initial state
  factory OnboardingData.empty() => OnboardingData();

  /// Copy with updated fields.
  /// Use [clearPeriodStart] to explicitly set periodStart to null
  /// (for "I don't remember" flow in O6/O7).
  OnboardingData copyWith({
    String? name,
    DateTime? birthDate,
    FitnessLevel? fitnessLevel,
    List<Goal>? selectedGoals,
    List<Interest>? selectedInterests,
    DateTime? periodStart,
    int? periodDuration,
    int? cycleLength,
    bool clearPeriodStart = false,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      periodStart: clearPeriodStart ? null : (periodStart ?? this.periodStart),
      periodDuration: periodDuration ?? this.periodDuration,
      cycleLength: cycleLength ?? this.cycleLength,
    );
  }

  /// Check if minimum required data is present for DB save.
  /// Note: periodStart is OPTIONAL to support "I don't remember" flow.
  /// The interests <= kMaxInterestSelections constraint is enforced by UI.
  /// Defense-in-depth: trim() here ensures whitespace-only names are rejected
  /// even if notifier.setName() trimming was bypassed.
  bool get isComplete =>
      name != null &&
      name!.trim().isNotEmpty &&
      birthDate != null &&
      fitnessLevel != null &&
      selectedGoals.isNotEmpty &&
      selectedInterests.length >= kMinInterestSelections;
}

/// Riverpod notifier for onboarding state management.
/// keepAlive: true ensures state persists across all onboarding screens
/// (prevents name/data loss when navigating between O1-O9).
@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingData build() => OnboardingData.empty();

  /// Set user name (O1)
  void setName(String name) {
    state = state.copyWith(name: name.trim());
  }

  /// Set birth date (O2)
  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  /// Set fitness level (O3)
  void setFitnessLevel(FitnessLevel level) {
    state = state.copyWith(fitnessLevel: level);
  }

  /// Toggle a goal selection (O4)
  void toggleGoal(Goal goal) {
    final goals = List<Goal>.from(state.selectedGoals);
    if (goals.contains(goal)) {
      goals.remove(goal);
    } else {
      goals.add(goal);
    }
    state = state.copyWith(selectedGoals: goals);
  }

  /// Toggle an interest selection (O5).
  /// Returns true if the selection changed, false if the add was ignored
  /// due to max selections limit.
  bool toggleInterest(Interest interest) {
    final interests = List<Interest>.from(state.selectedInterests);
    if (interests.contains(interest)) {
      interests.remove(interest);
      state = state.copyWith(selectedInterests: interests);
      return true;
    } else {
      // Limit to kMaxInterestSelections (shared constant)
      if (interests.length < kMaxInterestSelections) {
        interests.add(interest);
        state = state.copyWith(selectedInterests: interests);
        return true;
      }
      // Max reached, selection ignored
      return false;
    }
  }

  /// Set period start date (O7)
  void setPeriodStart(DateTime date) {
    state = state.copyWith(periodStart: date);
  }

  /// Set period duration (O8)
  void setPeriodDuration(int days) {
    // Clamp to valid range (kMinPeriodDuration-kMaxPeriodDuration)
    state = state.copyWith(
      periodDuration: days.clamp(kMinPeriodDuration, kMaxPeriodDuration),
    );
  }

  /// Clear period start date (for "I don't remember" flow)
  /// Privacy-safe: ensures no implicit cycle data is created when user
  /// selects "unknown" option in O7.
  void clearPeriodStart() {
    state = state.copyWith(
      clearPeriodStart: true,
      periodDuration: kDefaultPeriodDuration,
      cycleLength: kDefaultCycleLength,
    );
  }

  /// Reset all state (for testing or restart)
  void reset() {
    state = OnboardingData.empty();
  }
}
