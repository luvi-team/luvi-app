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
  /// Throws [StateError] in all builds (debug + release) if versions don't match.
  static void assertVersionsMatch() {
    // Strict validation: v{major} or v{major}.{minor}
    // Anchored regex prevents false positives (e.g., v10.0 matching v1)
    final versionPattern =
        RegExp(r'^v' + currentVersionInt.toString() + r'(\.\d+)?$');
    if (!versionPattern.hasMatch(currentVersion)) {
      throw StateError(
        'ConsentConfig version drift: currentVersion="$currentVersion" '
        'does not match currentVersionInt=$currentVersionInt. '
        'Expected format: v$currentVersionInt or v$currentVersionInt.x',
      );
    }
  }

  // For APIs/analytics that expect string names.
  static final List<String> requiredScopeNames = List.unmodifiable(
    kRequiredConsentScopes.map((scope) => scope.name),
  );
}
