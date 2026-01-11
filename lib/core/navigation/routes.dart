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
    return '${RoutePaths.splash}?skipAnimation=true';
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
    return '${RoutePaths.splash}?skipAnimation=true';
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
  final location = state.matchedLocation;

  // Route checks using RoutePaths (SSOT)
  final isLoggingIn = location.startsWith(RoutePaths.login);
  final isAuthSignIn = location.startsWith(RoutePaths.authSignIn);
  final isSigningUp = location.startsWith(RoutePaths.signup);
  final isResettingPassword = location.startsWith(RoutePaths.resetPassword);
  final isOnboarding = isOnboardingRoute(location);
  final isDashboard = location.startsWith(RoutePaths.heute);
  final isSplash = location == RoutePaths.splash;
  final isWelcome = isWelcomeRoute(location);
  final isPasswordRecoveryRoute = location.startsWith(RoutePaths.createNewPassword);
  final isPasswordSuccessRoute = location.startsWith(RoutePaths.passwordSaved);

  // Session access with defensive try-catch for resilience
  Session? session;
  if (sessionOverride != null) {
    session = sessionOverride;
  } else if (isInitialized) {
    try {
      session = SupabaseService.client.auth.currentSession;
    } catch (e, stack) {
      log.w(
        'auth_redirect_session_access_failed',
        tag: 'navigation',
        error: e.runtimeType.toString(),
        stack: stack,
      );
      session = null;
    }
  }

  // Allow password recovery routes without session
  if (isPasswordRecoveryRoute || isPasswordSuccessRoute) {
    return null;
  }

  // Dev-only bypass to allow opening onboarding without auth
  if (allowOnboardingDev && !kReleaseMode && isOnboarding) {
    return null;
  }

  // Dev-only bypass to allow opening dashboard without auth
  if (allowDashboardDev && !kReleaseMode && isDashboard) {
    return null;
  }

  // Always allow splash
  if (isSplash) {
    return null;
  }

  // Allow welcome without session (device-local gate, shown before auth)
  if (isWelcome) {
    return null;
  }

  // No session: redirect to auth unless on auth routes
  if (session == null) {
    if (isLoggingIn || isAuthSignIn || isSigningUp || isResettingPassword) {
      return null;
    }
    return RoutePaths.authSignIn;
  }

  // Has session: redirect from auth routes to splash
  // UX-Fix: skipAnimation=true verhindert erneute Splash-Animation nach Login
  if (isLoggingIn || isAuthSignIn) {
    return '${RoutePaths.splash}?skipAnimation=true';
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
