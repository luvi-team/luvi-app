import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:luvi_services/supabase_service.dart';

part 'onboarding_gate_profile_reader.g.dart';

/// Interface for reading the onboarding completion state from the server.
///
/// This abstraction allows testability by enabling provider overrides in tests.
abstract class OnboardingGateProfileReader {
  /// Returns the `has_completed_onboarding` value from the server profile.
  ///
  /// Returns:
  /// - `true` if the user has completed onboarding (server SSOT)
  /// - `false` if the user has not completed onboarding
  /// - `null` if the profile could not be fetched (network error, timeout, etc.)
  Future<bool?> fetchRemoteOnboardingGate();
}

/// Default implementation that reads from the profiles table via SupabaseService.
class DefaultOnboardingGateProfileReader implements OnboardingGateProfileReader {
  const DefaultOnboardingGateProfileReader();

  @override
  Future<bool?> fetchRemoteOnboardingGate() async {
    final profile = await SupabaseService.getProfile();
    // No profile row = new user = hasn't completed onboarding
    if (profile == null) return false;

    final raw = profile['has_completed_onboarding'];
    // Defensive: only accept bool, treat anything else as unset
    return raw is bool ? raw : null;
  }
}

@Riverpod(keepAlive: true)
OnboardingGateProfileReader onboardingGateProfileReader(Ref ref) {
  return const DefaultOnboardingGateProfileReader();
}
