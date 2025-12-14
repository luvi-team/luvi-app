import 'package:luvi_app/core/logging/logger.dart';

/// Compiled regex for OAuth cancellation detection.
///
/// Uses word-boundary matching (\b) to avoid false positives from words
/// that contain cancellation substrings (e.g., "scandal" shouldn't match "cancel").
///
/// Pattern breakdown:
/// - \b(cancel|canceled|cancelled|aborted)\b - standalone words
/// - \bsign in canceled\b - google_sign_in pattern
/// - \berr request canceled\b - oauth2_client pattern
/// - \buser cancel(l)?ed\b - flutter_web_auth and iOS patterns
final RegExp _cancellationPattern = RegExp(
  r'\b(cancel|canceled|cancelled|aborted)\b'
  r'|'
  r'\bsign in canceled\b'
  r'|'
  r'\berr request canceled\b'
  r'|'
  r'\buser cancel(l)?ed\b',
  caseSensitive: false,
);

/// Detects user-initiated OAuth cancellations from error messages.
///
/// User cancellations are expected actions (not errors) and should be
/// handled silently without error reporting or snackbars.
///
/// This function checks for common cancellation patterns across various
/// OAuth providers and platform SDKs:
/// - PlatformException variants: "CANCELED", "canceled"
/// - google_sign_in: "sign_in_canceled"
/// - flutter_web_auth: "CANCELED", "user cancelled"
/// - oauth2_client: "ERR_REQUEST_CANCELED"
/// - ASWebAuthSession (iOS): "cancelled", "user_cancelled"
/// - Chrome Custom Tabs (Android): "canceled", "aborted"
///
/// Uses word-boundary regex matching to avoid false positives from words
/// like "scandal" or "scant" that contain partial matches.
///
/// NOTE: This relies on string matching in error messages. May need
/// updates if SDK behavior changes. Non-matching OAuth errors are
/// logged at debug level for observability.
bool isOAuthUserCancellation(String errorText) {
  final lower = errorText.toLowerCase();

  // Normalize: replace underscores with spaces for consistent matching
  final normalized = lower.replaceAll('_', ' ');

  // Use word-boundary regex to avoid false positives
  return _cancellationPattern.hasMatch(normalized);
}

/// Logs OAuth errors that don't match cancellation patterns.
///
/// This provides observability for missed cancellation patterns that
/// may need to be added in future updates.
///
/// [errorText] - The error message to check
/// [provider] - Optional provider name for context in logs
void logNonCancellationOAuthError(String errorText, {String? provider}) {
  if (!isOAuthUserCancellation(errorText)) {
    final providerTag = provider != null ? ' [$provider]' : '';
    // Note: log.d auto-sanitizes the message via sanitizeForLog
    log.d(
      'oauth_error_non_cancellation$providerTag: $errorText',
      tag: 'oauth',
    );
  }
}
