import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_services/supabase_service.dart';

/// Function type for synchronous boolean getters (e.g., isAuthenticated).
typedef BoolGetter = bool Function();

/// Function type for synchronous nullable string getters (e.g., currentUserId).
typedef StringGetter = String? Function();

/// Function type for async profile fetching.
typedef ProfileFetcher = Future<Map<String, dynamic>?> Function();

/// Function type for async onboarding gate backfill.
typedef OnboardingBackfill = Future<void> Function({
  required bool hasCompletedOnboarding,
});

/// Provider for authentication check function.
/// Returns a function that checks if user is currently authenticated.
/// Default delegates 1:1 to SupabaseService.isAuthenticated.
final isAuthenticatedFnProvider = Provider<BoolGetter>(
  (_) => () => SupabaseService.isAuthenticated,
);

/// Provider for current user ID getter function.
/// Returns a function that gets the current user's ID (or null if not authenticated).
/// Default delegates 1:1 to SupabaseService.currentUser?.id.
final currentUserIdFnProvider = Provider<StringGetter>(
  (_) => () => SupabaseService.currentUser?.id,
);

/// Provider for remote profile fetcher function.
/// Returns a function that fetches the user's profile from server.
/// Default delegates 1:1 to SupabaseService.getProfile.
final profileFetcherProvider = Provider<ProfileFetcher>(
  (_) => SupabaseService.getProfile,
);

/// Provider for onboarding gate backfill function.
/// Returns a function that upserts the onboarding completion state to server.
/// Default delegates 1:1 to SupabaseService.upsertOnboardingGate.
final onboardingBackfillProvider = Provider<OnboardingBackfill>(
  (_) => ({required bool hasCompletedOnboarding}) async {
    await SupabaseService.upsertOnboardingGate(
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  },
);
