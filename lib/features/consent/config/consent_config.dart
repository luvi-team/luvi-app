import 'package:luvi_app/features/consent/model/consent_types.dart';

class ConsentConfig {
  const ConsentConfig._();

  /// Consent policy version string for APIs/display.
  /// ⚠️ SYNC: Must match currentVersionInt (format: "v{major}.{minor}").
  static const String currentVersion = 'v1.0';

  /// Numeric version for gate-check comparisons.
  /// ⚠️ SYNC: Must match major version in currentVersion.
  static const int currentVersionInt = 1;

  /// Validates version constants are synchronized.
  /// Called at app startup to catch drift early.
  static void assertVersionsMatch() {
    assert(
      currentVersion.startsWith('v$currentVersionInt.'),
      'ConsentConfig version drift: currentVersion="$currentVersion" '
      'does not match currentVersionInt=$currentVersionInt. '
      'Update both constants together.',
    );
  }

  // For APIs/analytics that expect string names.
  static final List<String> requiredScopeNames = List.unmodifiable(
    kRequiredConsentScopes.map((scope) => scope.name),
  );
}
