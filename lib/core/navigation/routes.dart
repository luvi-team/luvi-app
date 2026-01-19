/// Route guards and redirect helpers.
///
/// This file contains ONLY redirect logic and route predicates.
/// Route definitions (GoRoute list) have been moved to [lib/router.dart].
///
/// Guardrail: lib/core/** must never import lib/features/**
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session;

import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/route_query_params.dart';
import 'package:luvi_services/supabase_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route Path Constants (for predicate functions)
// ─────────────────────────────────────────────────────────────────────────────

/// Root onboarding path without trailing slash to allow exact match checks.
const String _onboardingRootPath = '/onboarding';

/// Short "/onboarding/w" prefix covers legacy welcome screens (w1–w5).
/// New welcome flow uses /welcome (single route with PageView).
const String _legacyWelcomeRootPath = '/onboarding/w';

/// New welcome route path (single screen with PageView).
const String _welcomePath = '/welcome';

const String _consentRootPath = '/consent';
const String _consentPathPrefix = '$_consentRootPath/';

// ─────────────────────────────────────────────────────────────────────────────
// Post-Auth Protected Routes
// ─────────────────────────────────────────────────────────────────────────────

/// All routes that require post-auth guards (consent + onboarding).
///
/// When adding new post-auth routes in router.dart:
/// 1. Add `redirect: _postAuthGuard` to the GoRoute
/// 2. Add the path here to ensure wiring test coverage
const List<String> kPostAuthPaths = [
  RoutePaths.heute,
  RoutePaths.workoutDetail,
  RoutePaths.trainingsOverview,
  RoutePaths.cycleOverview,
  RoutePaths.profile,
];

// ─────────────────────────────────────────────────────────────────────────────
// Route Predicates (Pure Functions - Testable)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns true if [location] is an onboarding route (O1-O8, success, done).
///
/// Excludes welcome screens (/onboarding/w* legacy and /welcome new).
bool isOnboardingRoute(String location) {
  final isOnboardingRoot =
      location == _onboardingRootPath ||
      location.startsWith('$_onboardingRootPath/');
  if (!isOnboardingRoot) return false;
  return !location.startsWith(_legacyWelcomeRootPath);
}

/// Returns true if [location] is a welcome screen route.
///
/// Matches both new /welcome route and legacy /onboarding/w* routes.
bool isWelcomeRoute(String location) {
  return location == _welcomePath ||
      location.startsWith('$_welcomePath/') ||
      location.startsWith(_legacyWelcomeRootPath);
}

/// Returns true if [location] is a consent flow route (/consent/*).
bool isConsentRoute(String location) {
  return location == _consentRootPath ||
      location.startsWith(_consentPathPrefix);
}

// ─────────────────────────────────────────────────────────────────────────────
// Home Guard Redirects
// ─────────────────────────────────────────────────────────────────────────────

/// Determines if access to Home should be blocked due to incomplete onboarding.
///
/// Fail-safe approach: When state is unknown (service not loaded), redirect to
/// Splash with skipAnimation to let the gate logic decide properly.
///
/// Returns:
/// - `/splash?skipAnimation=true` if state is unknown (fail-safe)
/// - Onboarding01 route if hasCompletedOnboarding is explicitly false
/// - null (allow) if hasCompletedOnboarding is true
@visibleForTesting
String? homeGuardRedirect({
  required bool isStateKnown,
  required bool? hasCompletedOnboarding,
}) {
  // Fail-safe: If state unknown, delegate to Splash (no visible animation).
  if (!isStateKnown) {
    return '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}';
  }
  // State is known - apply gate logic
  if (hasCompletedOnboarding == false) {
    return RoutePaths.onboarding01;
  }
  return null;
}

/// Defense-in-Depth: Home guard with consent version check.
///
/// Unlike [homeGuardRedirect], this also validates that the user has accepted
/// the current consent version. This prevents bypassing consent via deep link
/// or saved route to /heute.
///
/// Gate priority (matches Splash logic):
/// 1. State unknown → Splash (fail-safe)
/// 2. Consent outdated/missing → ConsentIntroScreen
/// 3. Onboarding incomplete → Onboarding01
/// 4. All gates passed → null (allow)
String? homeGuardRedirectWithConsent({
  required bool isStateKnown,
  required bool? hasCompletedOnboarding,
  required int? acceptedConsentVersion,
  required int currentConsentVersion,
}) {
  // Fail-safe: If state unknown, delegate to Splash (no visible animation).
  if (!isStateKnown) {
    return '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}';
  }

  // Defense-in-Depth: Check consent version FIRST (matches Splash gate order)
  final needsConsent = acceptedConsentVersion == null ||
      acceptedConsentVersion < currentConsentVersion;
  if (needsConsent) {
    return RoutePaths.consentIntro;
  }

  // Then check onboarding
  if (hasCompletedOnboarding == false) {
    return RoutePaths.onboarding01;
  }

  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Supabase Auth Redirect Guard
// ─────────────────────────────────────────────────────────────────────────────

/// Redirect-Guard für GoRouter - delegiert an [supabaseRedirectWithSession].
String? supabaseRedirect(BuildContext context, GoRouterState state) =>
    supabaseRedirectWithSession(context, state);

/// Route classification for redirect logic.
class _RouteFlags {
  const _RouteFlags({
    required this.isAuthRoute,
    required this.isLoginOrSignIn,
    required this.isSplash,
    required this.isWelcome,
    required this.isOnboarding,
    required this.isDashboard,
    required this.isPasswordRecovery,
  });

  /// True if route is an auth flow route (login, signup, reset password).
  final bool isAuthRoute;

  /// True if route is specifically login or signIn (not signup/reset).
  final bool isLoginOrSignIn;

  /// True if route is the splash screen.
  final bool isSplash;

  /// True if route is a welcome screen (device-local, pre-auth).
  final bool isWelcome;

  /// True if route is an onboarding route (post-auth).
  final bool isOnboarding;

  /// True if route is the dashboard/heute route.
  final bool isDashboard;

  /// True if route is password recovery or success.
  final bool isPasswordRecovery;
}

/// Classifies a route location into logical groups.
_RouteFlags _classifyRoute(String location) {
  final uri = Uri.parse(location);
  final path = uri.path;

  // Helper for safe prefix check (prevent /heute matching /heute-old)
  bool matchesPrefix(String prefix) {
    if (path == prefix) return true;
    return path.startsWith('$prefix/');
  }

  final isLogin = matchesPrefix(RoutePaths.login);
  final isSignIn = matchesPrefix(RoutePaths.authSignIn);

  return _RouteFlags(
    isAuthRoute: isLogin ||
        isSignIn ||
        matchesPrefix(RoutePaths.signup) ||
        matchesPrefix(RoutePaths.resetPassword),
    isLoginOrSignIn: isLogin || isSignIn,
    isSplash: path == RoutePaths.splash,
    isWelcome: isWelcomeRoute(path),
    isOnboarding: isOnboardingRoute(path),
    isDashboard: matchesPrefix(RoutePaths.heute),
    isPasswordRecovery: matchesPrefix(RoutePaths.createNewPassword) ||
        matchesPrefix(RoutePaths.passwordSaved),
  );
}

/// Safely extracts session from Supabase, returns null on error.
Session? _getSessionSafely({
  Session? sessionOverride,
  required bool isInitialized,
}) {
  if (sessionOverride != null) return sessionOverride;
  if (!isInitialized) return null;

  try {
    return SupabaseService.client.auth.currentSession;
  } catch (e, stack) {
    log.w(
      'auth_redirect_session_access_failed',
      tag: 'navigation',
      error: e.runtimeType.toString(),
      stack: kDebugMode ? stack : null,
    );
    return null;
  }
}

/// Checks if a route should bypass session validation.
///
/// Returns true if the route is allowed without further auth checks.
bool _isBypassRoute({
  required _RouteFlags flags,
  required bool allowDashboardDev,
  required bool allowOnboardingDev,
}) {
  // Password recovery routes always bypass (token-gated by email link)
  if (flags.isPasswordRecovery) return true;

  // Dev-only bypasses (only in debug mode)
  if (allowOnboardingDev && !kReleaseMode && flags.isOnboarding) return true;
  if (allowDashboardDev && !kReleaseMode && flags.isDashboard) return true;

  // Splash and welcome always allowed (pre-auth gates)
  if (flags.isSplash || flags.isWelcome) return true;

  return false;
}

/// Testbare Version des Redirect-Guards mit optionalen Overrides.
///
/// In Production wird [sessionOverride] und [isInitializedOverride] ignoriert.
/// In Tests können diese Parameter genutzt werden, um verschiedene
/// Session-Szenarien zu simulieren ohne Supabase-Client zu mocken.
@visibleForTesting
String? supabaseRedirectWithSession(
  BuildContext context,
  GoRouterState state, {
  Session? sessionOverride,
  bool? isInitializedOverride,
}) {
  // Dev-only bypass flags
  const allowDashboardDev = bool.fromEnvironment(
    'ALLOW_DASHBOARD_DEV',
    defaultValue: false,
  );
  const allowOnboardingDev = bool.fromEnvironment(
    'ALLOW_ONBOARDING_DEV',
    defaultValue: false,
  );

  final isInitialized = isInitializedOverride ?? SupabaseService.isInitialized;
  final flags = _classifyRoute(state.matchedLocation);

  // Check bypass routes first
  if (_isBypassRoute(
    flags: flags,
    allowDashboardDev: allowDashboardDev,
    allowOnboardingDev: allowOnboardingDev,
  )) {
    return null; // Allowed - no redirect
  }

  // Get session for auth-dependent decisions
  final session = _getSessionSafely(
    sessionOverride: sessionOverride,
    isInitialized: isInitialized,
  );

  // No session: redirect to auth unless already on auth routes
  if (session == null) {
    return flags.isAuthRoute ? null : RoutePaths.authSignIn;
  }

  // Has session: redirect from login/signIn to splash (skip animation)
  if (flags.isLoginOrSignIn) {
    return '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}';
  }

  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy Compatibility
// ─────────────────────────────────────────────────────────────────────────────

/// Legacy class for onboarding route constants.
/// Prefer using [RoutePaths] directly.
class OnboardingRoutes {
  static const done = '/onboarding/done';
}

// NOTE: featureRoutes has been moved to lib/router.dart
// This file now only contains redirect guards and route predicates.
