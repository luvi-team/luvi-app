import 'package:luvi_app/core/navigation/route_paths.dart';

/// Determines the target route based on auth state, consent version, and
/// onboarding completion.
///
/// Extracted for testability and reusability.
///
/// Logic:
/// - Not authenticated → AuthSignInScreen
/// - Authenticated + needs consent (null or outdated version) → ConsentIntroScreen
/// - Authenticated + consent OK + hasCompletedOnboarding != true → Onboarding01
/// - Authenticated + consent OK + hasCompletedOnboarding == true → defaultTarget
String determineTargetRoute({
  required bool isAuth,
  required int? acceptedConsentVersion,
  required int currentConsentVersion,
  required bool hasCompletedOnboarding,
  required String defaultTarget,
}) {
  if (!isAuth) {
    return RoutePaths.authSignIn;
  }
  // Consent-Version-Gate: Show consent if not accepted or version is outdated
  final needsConsent = acceptedConsentVersion == null ||
      acceptedConsentVersion < currentConsentVersion;
  if (needsConsent) {
    return RoutePaths.consentIntro;
  }
  // Onboarding Gate: User has completed consent but not onboarding
  if (!hasCompletedOnboarding) {
    return RoutePaths.onboarding01;
  }
  return defaultTarget;
}

/// Determines a safe fallback route when state loading fails.
///
/// Fail-safe approach: Never route directly to Home when state is unknown.
/// - Not authenticated → AuthSignInScreen (login required anyway)
/// - Authenticated → ConsentIntroScreen (safe entry point for gate flow)
///
/// This ensures consent/onboarding gates are never bypassed due to errors.
String determineFallbackRoute({required bool isAuth}) {
  if (!isAuth) {
    return RoutePaths.authSignIn;
  }
  // Safe fallback: Consent flow will re-check all gates properly.
  // Never go directly to Home when state is unknown.
  return RoutePaths.consentIntro;
}

/// Result type for [determineOnboardingGateRoute].
///
/// Three outcomes:
/// - [RouteResolved]: Navigation target determined
/// - [RaceRetryNeeded]: Local/remote mismatch (remote=false, local=true), retry required
/// - [StateUnknown]: Both gates null, or remote null with local true (offline but locally positive)
sealed class OnboardingGateResult {
  const OnboardingGateResult();
}

/// Navigation target has been determined.
final class RouteResolved extends OnboardingGateResult {
  const RouteResolved(this.route);
  final String route;
}

/// Race condition detected: local=true but remote=false.
/// Caller should retry after a short delay.
final class RaceRetryNeeded extends OnboardingGateResult {
  const RaceRetryNeeded();
}

/// State is truly unknown: both gates null, or remote null with local true.
/// Caller should show fallback UI (never route to Home when server SSOT unavailable).
final class StateUnknown extends OnboardingGateResult {
  const StateUnknown();
}

/// Result record from consent gate resolution.
/// Contains consent route (if needed) plus gate values for onboarding check.
typedef ConsentGateResult = ({
  String? consentRoute,
  bool? remoteGate,
  bool? localGate,
});

/// Determines the onboarding gate outcome based on remote and local state.
///
/// Returns:
/// - [RouteResolved] with home route if remote gate is true
/// - [RouteResolved] with onboarding route if either gate is explicitly false
/// - [RaceRetryNeeded] if remote=false but local=true (race condition)
/// - [StateUnknown] if both gates are null, or if remote is null and local is true
OnboardingGateResult determineOnboardingGateRoute({
  required bool? remoteGate,
  required bool? localGate,
  required String homeRoute,
}) {
  // Remote SSOT takes priority when available
  if (remoteGate == true) return RouteResolved(homeRoute);

  // Race-condition guard: local true + remote false → needs race-retry
  // Don't immediately route to Onboarding; let caller handle retry
  if (remoteGate == false && localGate == true) return const RaceRetryNeeded();

  // Remote false + local not true → Onboarding (first-time user)
  if (remoteGate == false) return RouteResolved(RoutePaths.onboarding01);

  // Remote null (network unavailable) - use local as fallback
  // Fail-safe: never route to Home when server SSOT is unavailable.
  // Local cache may be stale or cross-account; only allow the safe direction.
  if (localGate == false) return RouteResolved(RoutePaths.onboarding01);

  // Both null → truly unknown
  return const StateUnknown();
}
