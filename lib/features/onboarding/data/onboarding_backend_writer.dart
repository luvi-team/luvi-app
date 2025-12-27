import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_services/supabase_service.dart';

/// Abstraction for onboarding backend persistence operations.
///
/// This minimal interface allows testing OnboardingSuccessScreen
/// without mocking static SupabaseService calls. Default implementation
/// delegates to SupabaseService.
abstract class OnboardingBackendWriter {
  /// Whether the user is authenticated
  bool get isAuthenticated;

  /// Upsert profile data to backend
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  });

  /// Upsert cycle data to backend
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  });

  /// Mark onboarding as completed in server SSOT (`public.profiles`).
  Future<Map<String, dynamic>?> markOnboardingComplete();
}

/// Default implementation that delegates to SupabaseService.
class SupabaseOnboardingBackendWriter implements OnboardingBackendWriter {
  const SupabaseOnboardingBackendWriter();

  @override
  bool get isAuthenticated => SupabaseService.isAuthenticated;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) {
    return SupabaseService.upsertProfile(
      displayName: displayName,
      birthDate: birthDate,
      fitnessLevel: fitnessLevel,
      goals: goals,
      interests: interests,
    );
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) {
    return SupabaseService.upsertCycleData(
      cycleLength: cycleLength,
      periodDuration: periodDuration,
      lastPeriod: lastPeriod,
      age: age,
    );
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() {
    return SupabaseService.upsertOnboardingGate(hasCompletedOnboarding: true);
  }
}

/// Provider for OnboardingBackendWriter.
/// Override this in tests to inject a fake implementation.
final onboardingBackendWriterProvider = Provider<OnboardingBackendWriter>(
  (ref) => const SupabaseOnboardingBackendWriter(),
);
