/// Router composition layer - allowed to import features.
///
/// This file lives outside lib/core/ to maintain the guardrail:
/// "lib/core/** must never import lib/features/**"
///
/// Entry points (main.dart, main_auth_entry.dart) use [createRouter] or
/// [routerProvider] to obtain a configured GoRouter instance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core imports (always allowed)
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/routes.dart' as routes;

// Feature imports (splash only - others delegated to route_builders)
import 'package:luvi_app/features/splash/screens/splash_screen.dart';

// Route builders (allowed to import features)
import 'package:luvi_app/router/route_builders/auth_routes.dart';
import 'package:luvi_app/router/route_builders/consent_routes.dart';
import 'package:luvi_app/router/route_builders/dashboard_routes.dart';
import 'package:luvi_app/router/route_builders/legal_routes.dart';
import 'package:luvi_app/router/route_builders/onboarding_routes.dart';
import 'package:luvi_app/router/route_builders/welcome_routes.dart';

/// Creates a GoRouter instance with all app routes.
///
/// [ref] is required for Riverpod provider access in route guards.
/// [enableRedirects] controls whether global auth redirects are active.
///   Set to false for preview/dev entry points.
/// [initialLocation] overrides the starting route (defaults to splash).
/// [refreshListenable] optional listenable for router refresh (auth changes).
/// [observers] optional list of navigator observers.
GoRouter createRouter(
  WidgetRef ref, {
  bool enableRedirects = true,
  String? initialLocation,
  Listenable? refreshListenable,
  List<NavigatorObserver>? observers,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? RoutePaths.splash,
    redirect: enableRedirects ? routes.supabaseRedirect : null,
    refreshListenable: refreshListenable,
    observers: observers ?? const [],
    routes: _buildRoutes(ref),
  );
}

/// Builds all application routes by composing route builders.
///
/// Kept as a separate function for testability and clarity.
/// Note: The [ref] parameter is kept for API consistency but routes access
/// providers via ProviderScope.containerOf(context) in builders.
List<RouteBase> _buildRoutes([WidgetRef? ref]) {
  return [
    // Splash (single route, kept inline)
    GoRoute(
      path: RoutePaths.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Composed route builders
    ...buildWelcomeRoutes(),
    ...buildConsentRoutes(),
    ...buildOnboardingRoutes(),
    ...buildAuthRoutes(),
    ...buildDashboardRoutes(),
    ...buildLegalRoutes(),
  ];
}

/// Returns the list of all application routes.
///
/// Use this when you need the raw route list without creating a full router.
/// Main.dart uses this to integrate with its own router orchestration.
List<RouteBase> buildAppRoutes(WidgetRef ref) => _buildRoutes(ref);

/// Returns all application routes for testing purposes.
///
/// This is equivalent to [buildAppRoutes] but doesn't require a [WidgetRef].
/// Routes that need provider access use ProviderScope.containerOf(context)
/// in their builders, which works when tests wrap widgets in [ProviderScope].
///
/// Usage in tests:
/// ```dart
/// final router = GoRouter(
///   routes: testAppRoutes,
///   initialLocation: '/auth/login',
/// );
/// ```
@visibleForTesting
List<RouteBase> get testAppRoutes => _buildRoutes();

/// Provider for GoRouter instance.
///
/// Use this in widgets that need router access via Riverpod.
/// For main.dart where ConsumerStatefulWidget is used, prefer [createRouter].
final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  throw UnimplementedError(
    'routerProvider must be overridden in ProviderScope. '
    'Use createRouter() in main.dart instead.',
  );
});
