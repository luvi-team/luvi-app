/// Route guards for onboarding and post-auth flows.
///
/// Guards access providers via ProviderScope.containerOf(context) to check
/// user state without requiring WidgetRef in route definitions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/route_query_params.dart';
import 'package:luvi_app/core/navigation/routes.dart' as routes;
import 'package:luvi_app/core/privacy/consent_config.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_services/user_state_service.dart';

/// Consent guard for onboarding routes - prevents deep-link bypass.
///
/// Returns:
/// - `/consent/options` if user needs consent (null or outdated version)
/// - `/splash?skipAnimation=true` if state is loading/error (fail-safe)
/// - `null` if consent is valid (allow access)
String? onboardingConsentGuard(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context, listen: false);
  final userStateAsync = container.read(userStateServiceProvider);

  return userStateAsync.when(
    data: (userState) {
      final acceptedVersion = userState.acceptedConsentVersionOrNull;
      final needsConsent = acceptedVersion == null ||
          acceptedVersion < ConsentConfig.currentVersionInt;

      return needsConsent ? RoutePaths.consentOptions : null;
    },
    loading: () =>
        '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}',
    error: (error, st) {
      log.w(
        'consent_guard_state_error',
        tag: 'router',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: st,
      );
      return '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}';
    },
  );
}

/// Post-Auth guard for main app routes - prevents deep-link bypass.
///
/// Checks both consent AND onboarding gates (Defense-in-Depth).
/// Returns:
/// - `/splash?skipAnimation=true` if state is loading/error (fail-safe)
/// - `/consent/options` if consent missing/outdated
/// - `/onboarding/01` if onboarding incomplete
/// - `null` if all gates passed (allow access)
String? postAuthGuard(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context, listen: false);
  final asyncValue = container.read(userStateServiceProvider);

  return asyncValue.when(
    data: (service) {
      final hasCompletedOnboarding = service.hasCompletedOnboardingOrNull;
      final acceptedConsentVersion = service.acceptedConsentVersionOrNull;
      final isStateKnown = hasCompletedOnboarding != null;

      return routes.homeGuardRedirectWithConsent(
        isStateKnown: isStateKnown,
        hasCompletedOnboarding: hasCompletedOnboarding,
        acceptedConsentVersion: acceptedConsentVersion,
        currentConsentVersion: ConsentConfig.currentVersionInt,
      );
    },
    loading: () =>
        '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}',
    error: (error, st) {
      log.w(
        'post_auth_guard_state_error',
        tag: 'router',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: st,
      );
      return '${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}';
    },
  );
}
