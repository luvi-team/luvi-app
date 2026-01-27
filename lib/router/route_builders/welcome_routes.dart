/// Welcome screen routes including legacy redirects.
library;

import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/welcome/screens/welcome_screen.dart';

/// Builds welcome routes including legacy w1-w5 redirects.
List<RouteBase> buildWelcomeRoutes() {
  return [
    GoRoute(
      path: RoutePaths.welcome,
      name: RouteNames.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    // Legacy welcome screen redirects (w1-w5 -> unified /welcome)
    GoRoute(
      path: RoutePaths.legacyWelcome1,
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: RoutePaths.legacyWelcome2,
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: RoutePaths.legacyWelcome3,
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: RoutePaths.legacyWelcome4,
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: RoutePaths.legacyWelcome5,
      redirect: (context, state) => RoutePaths.welcome,
    ),
  ];
}
