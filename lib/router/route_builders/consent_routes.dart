/// Consent flow routes including legacy redirects.
library;

import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';

/// Builds consent routes including legacy redirects.
List<RouteBase> buildConsentRoutes() {
  return [
    GoRoute(
      path: RoutePaths.consentOptions,
      name: RouteNames.consentOptions,
      builder: (context, state) => const ConsentOptionsScreen(),
    ),
    // Legacy redirects for backward compatibility
    GoRoute(
      path: RoutePaths.consentIntro,
      redirect: (context, state) => RoutePaths.consentOptions,
    ),
    GoRoute(
      path: RoutePaths.consentBlocking,
      redirect: (context, state) => RoutePaths.consentOptions,
    ),
    GoRoute(
      path: RoutePaths.consentIntroLegacy, // /consent/02
      redirect: (context, state) => RoutePaths.consentOptions,
    ),
  ];
}
