/**
 * Shared version parsing utilities for consent policy versions.
 *
 * Format: v{major} or v{major}.{minor}
 * Examples: "v1", "v1.0", "v2.5"
 *
 * This utility is the single source of truth for version format validation
 * across Edge Functions. The Dart equivalent exists at:
 * `lib/core/privacy/version_parser.dart`
 */

const VERSION_PATTERN = /^v(\d+)(?:\.(\d+))?$/;

export interface VersionParseResult {
  valid: boolean;
  major?: number;
  minor?: number;
  error?: string;
}

/**
 * Parse and validate version string.
 * Returns parse result with major/minor or error.
 *
 * Examples:
 * - parseVersion("v1.0") → {valid: true, major: 1, minor: 0}
 * - parseVersion("v2") → {valid: true, major: 2, minor: 0}
 * - parseVersion("bad") → {valid: false, error: "Invalid version format..."}
 */
export function parseVersion(version: string): VersionParseResult {
  const match = VERSION_PATTERN.exec(version);
  if (!match) {
    return {
      valid: false,
      error: `Invalid version format: "${version}". Expected format: v{major} or v{major}.{minor}`,
    };
  }
  return {
    valid: true,
    major: parseInt(match[1], 10),
    minor: match[2] ? parseInt(match[2], 10) : 0,
  };
}

/**
 * Validate version format (boolean check).
 */
export function isValidVersionFormat(version: string): boolean {
  return VERSION_PATTERN.test(version);
}
