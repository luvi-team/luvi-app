import 'package:luvi_app/core/logging/logger.dart';

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
/// NOTE: This relies on string matching in error messages. May need
/// updates if SDK behavior changes. Non-matching OAuth errors are
/// logged at debug level for observability.
bool isOAuthUserCancellation(String errorText) {
  final lower = errorText.toLowerCase();

  // Normalize: replace underscores with spaces for consistent matching
  final normalized = lower.replaceAll('_', ' ');

  // Check for cancellation patterns (case-insensitive, underscore/space agnostic)
  final isCancellation = normalized.contains('cancel') ||
      normalized.contains('canceled') ||
      normalized.contains('cancelled') ||
      normalized.contains('aborted') ||
      // Specific patterns from SDKs
      normalized.contains('sign in canceled') ||
      normalized.contains('err request canceled');

  return isCancellation;
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
    log.d(
      'oauth_error_non_cancellation$providerTag',
      tag: 'oauth',
    );
  }
}
