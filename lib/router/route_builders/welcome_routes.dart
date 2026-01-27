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
      path: '/onboarding/w1',
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: '/onboarding/w2',
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: '/onboarding/w3',
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: '/onboarding/w4',
      redirect: (context, state) => RoutePaths.welcome,
    ),
    GoRoute(
      path: '/onboarding/w5',
      redirect: (context, state) => RoutePaths.welcome,
    ),
  ];
}
