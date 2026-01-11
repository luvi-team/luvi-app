import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_app.dart';
import '../../support/test_config.dart';

/// Wiring tests for post-auth route guards.
///
/// These tests verify that the router configuration (not the guard logic)
/// correctly assigns redirect guards to protected routes.
///
/// Purpose: Prevent regression when adding new routes - ensures developers
/// don't forget to add the guard to post-auth routes.
void main() {
  TestConfig.ensureInitialized();

  group('Post-Auth Routes Wiring', () {
    late List<RouteBase> routes;

    setUp(() {
      routes = testAppRoutes;
    });

    group('post-auth routes must have redirect guard', () {
      final postAuthPaths = [
        RoutePaths.heute,
        RoutePaths.workoutDetail,
        RoutePaths.trainingsOverview,
        RoutePaths.cycleOverview,
        RoutePaths.profile,
      ];

      for (final path in postAuthPaths) {
        test('$path has redirect guard', () {
          final route = _findRouteByPath(routes, path);

          expect(
            route,
            isNotNull,
            reason: 'Route $path should exist in router configuration',
          );
          expect(
            route!.redirect,
            isNotNull,
            reason: 'Post-auth route $path must have a redirect guard '
                'to prevent consent/onboarding bypass',
          );
        });
      }
    });

    group('legal routes must NOT have redirect guard', () {
      final legalPaths = [
        RoutePaths.legalPrivacy,
        RoutePaths.legalTerms,
      ];

      for (final path in legalPaths) {
        test('$path has no redirect guard', () {
          final route = _findRouteByPath(routes, path);

          expect(
            route,
            isNotNull,
            reason: 'Route $path should exist in router configuration',
          );
          expect(
            route!.redirect,
            isNull,
            reason: 'Legal route $path must be accessible without consent '
                'so users can read legal docs before accepting',
          );
        });
      }
    });

    test('all post-auth routes use consistent guard (same redirect function)',
        () {
      final postAuthPaths = [
        RoutePaths.heute,
        RoutePaths.workoutDetail,
        RoutePaths.trainingsOverview,
        RoutePaths.cycleOverview,
        RoutePaths.profile,
      ];

      final redirectFunctions = postAuthPaths
          .map((path) => _findRouteByPath(routes, path)?.redirect)
          .whereType<GoRouterRedirect>()
          .toSet();

      // All post-auth routes should use the same redirect function (_postAuthGuard)
      expect(
        redirectFunctions.length,
        equals(1),
        reason: 'All post-auth routes should use the same guard function '
            'for consistent behavior',
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Integration Tests (Widget-Tests with real router)
  // ─────────────────────────────────────────────────────────────────────────
  group('Post-Auth Routes Integration', () {
    testWidgets('post-auth route redirects to splash when state unknown',
        (tester) async {
      // Setup: Create router with post-auth route as initial location
      // No userStateServiceProvider mock = unknown state = fail-safe redirect
      final router = GoRouter(
        initialLocation: RoutePaths.heute,
        routes: testAppRoutes,
        redirect: null, // Disable global auth redirect for isolated test
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify: Guard should redirect to splash due to unknown state
      final location =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(
        location,
        contains(RoutePaths.splash),
        reason: 'Post-auth route should redirect to splash when state unknown '
            '(fail-safe behavior)',
      );
    });

    testWidgets('legal route accessible without consent', (tester) async {
      // Setup: Create router with legal route as initial location
      final router = GoRouter(
        initialLocation: RoutePaths.legalPrivacy,
        routes: testAppRoutes,
        redirect: null, // Disable global auth redirect for isolated test
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify: Legal route should NOT redirect (no guard)
      final location =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(
        location,
        equals(RoutePaths.legalPrivacy),
        reason: 'Legal route should be accessible without redirect '
            'so users can read legal docs before accepting consent',
      );
    });
  });
}

/// Recursively finds a GoRoute by its path in the route tree.
///
/// Returns null if no route with the given path exists.
GoRoute? _findRouteByPath(List<RouteBase> routes, String path) {
  for (final route in routes) {
    if (route is GoRoute && route.path == path) {
      return route;
    }
    // Check nested routes (ShellRoute, etc.)
    if (route is ShellRoute) {
      final nested = _findRouteByPath(route.routes, path);
      if (nested != null) return nested;
    }
    if (route is GoRoute && route.routes.isNotEmpty) {
      final nested = _findRouteByPath(route.routes, path);
      if (nested != null) return nested;
    }
  }
  return null;
}
