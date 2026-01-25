import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:luvi_app/core/privacy/consent_types.dart';

class ConsentConfig {
  const ConsentConfig._();

  /// Consent policy version string for APIs/display.
  /// Single source of truth - [currentVersionInt] is derived from this.
  static const String currentVersion = 'v1.0';

  /// Lazily-computed cache for [currentVersionInt].
  ///
  /// Invariant: [currentVersion] is compile-time const; this cache is only
  /// invalidated via code updates (not hot reload). Use [resetCacheForTesting]
  /// in tests for isolation.
  static int? _cachedCurrentVersionInt;

  /// Numeric major version derived from [currentVersion].
  /// Throws [StateError] if currentVersion format is invalid.
  static int get currentVersionInt {
    if (_cachedCurrentVersionInt != null) {
      return _cachedCurrentVersionInt!;
    }
    final match = RegExp(r'^v(\d+)(?:\.\d+)?$').firstMatch(currentVersion);
    if (match == null) {
      throw StateError(
        'ConsentConfig.currentVersion "$currentVersion" does not match '
        'expected format v{major} or v{major}.{minor}',
      );
    }
    _cachedCurrentVersionInt = int.parse(match.group(1)!);
    return _cachedCurrentVersionInt!;
  }

  /// Resets cached version for test isolation.
  /// Call in test tearDown to ensure clean state between tests.
  @visibleForTesting
  static void resetCacheForTesting() {
    _cachedCurrentVersionInt = null;
  }

  /// Validates version format at startup.
  /// Called by app initialization to catch format errors early.
  /// Throws [StateError] in all builds (debug + release) if format is invalid.
  static void assertVersionFormatValid() {
    currentVersionInt; // Triggers validation via getter
  }

  // For APIs/analytics that expect string names.
  static final List<String> requiredScopeNames = List.unmodifiable(
    kRequiredConsentScopes.map((scope) => scope.name),
  );
}
