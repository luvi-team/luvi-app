/// Legal document routes (no auth/consent guard).
///
/// Users must be able to read legal docs BEFORE accepting consent.
library;

import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/legal/screens/legal_viewer.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Builds legal routes (intentionally NO consent/onboarding guard).
List<RouteBase> buildLegalRoutes() {
  return [
    GoRoute(
      path: RoutePaths.legalPrivacy,
      name: RouteNames.legalPrivacy,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return LegalViewer.asset(
          'assets/legal/privacy.md',
          title: l10n?.privacyPolicyTitle ?? 'Datenschutzerklärung',
          appLinks: const ProdAppLinks(),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.legalTerms,
      name: RouteNames.legalTerms,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return LegalViewer.asset(
          'assets/legal/terms.md',
          title: l10n?.termsOfServiceTitle ?? 'Nutzungsbedingungen',
          appLinks: const ProdAppLinks(),
        );
      },
    ),
  ];
}
