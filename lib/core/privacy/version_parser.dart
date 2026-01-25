/// Shared version parsing utilities for consent policy versions.
///
/// Format: v{major} or v{major}.{minor}
/// Examples: "v1", "v1.0", "v2.5"
///
/// This utility is the single source of truth for version format validation
/// across the app. The TypeScript equivalent exists at:
/// `supabase/functions/_shared/version_parser.ts`
class VersionParser {
  VersionParser._();

  /// Regex pattern matching v{major} or v{major}.{minor}
  static final _versionPattern = RegExp(r'^v(\d+)(?:\.(\d+))?$');

  /// Parse version string to major version integer.
  /// Throws [FormatException] if format is invalid.
  ///
  /// Examples:
  /// ```dart
  /// VersionParser.parseMajorVersion("v1.0") // Returns: 1
  /// VersionParser.parseMajorVersion("v2") // Returns: 2
  /// VersionParser.parseMajorVersion("bad") // Throws: FormatException
  /// ```
  static int parseMajorVersion(String version) {
    final match = _versionPattern.firstMatch(version);
    if (match == null) {
      throw FormatException(
        'Invalid version format: "$version". '
        'Expected format: v{major} or v{major}.{minor}',
      );
    }
    return int.parse(match.group(1)!);
  }

  /// Parse version string to minor version integer (or 0 if not specified).
  /// Throws [FormatException] if format is invalid.
  ///
  /// Examples:
  /// ```dart
  /// VersionParser.parseMinorVersion("v1.5") // Returns: 5
  /// VersionParser.parseMinorVersion("v2") // Returns: 0
  /// ```
  static int parseMinorVersion(String version) {
    final match = _versionPattern.firstMatch(version);
    if (match == null) {
      throw FormatException(
        'Invalid version format: "$version". '
        'Expected format: v{major} or v{major}.{minor}',
      );
    }
    final minorStr = match.group(2);
    return minorStr != null ? int.parse(minorStr) : 0;
  }

  /// Validate version string format.
  /// Returns true if valid, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// VersionParser.isValidFormat("v1.0") // true
  /// VersionParser.isValidFormat("1.0") // false
  /// ```
  static bool isValidFormat(String version) {
    return _versionPattern.hasMatch(version);
  }
}
