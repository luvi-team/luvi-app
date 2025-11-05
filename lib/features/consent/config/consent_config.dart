import 'package:luvi_app/features/consent/model/consent_types.dart';

class ConsentConfig {
  // Single source of truth for consent policy version used across app.
  static const String currentVersion = 'v1.0';

  // Canonical required consent scopes (typed). Keep in sync with server.
  static const Set<ConsentScope> requiredScopes = kRequiredConsentScopes;

  // For APIs/analytics that expect string names.
  static final List<String> requiredScopeNames =
      List.unmodifiable(requiredScopes.map((e) => e.name));
}
