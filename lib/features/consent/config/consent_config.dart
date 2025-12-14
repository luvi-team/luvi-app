import 'package:luvi_app/features/consent/model/consent_types.dart';

class ConsentConfig {
  const ConsentConfig._();

  // Single source of truth for consent policy version used across app.
  static const String currentVersion = 'v1.0';

  /// Numeric version for gate-check comparisons (increment when consent changes).
  static const int currentVersionInt = 1;

  // For APIs/analytics that expect string names.
  static final List<String> requiredScopeNames = List.unmodifiable(
    kRequiredConsentScopes.map((scope) => scope.name),
  );
}
