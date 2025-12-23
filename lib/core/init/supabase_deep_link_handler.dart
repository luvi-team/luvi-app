import 'dart:async';

import 'package:app_links/app_links.dart' as platform_links;
import 'package:luvi_app/core/config/app_links.dart' as config_links;
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Supabase deep links manually so we can enforce explicit
/// scheme/host validation before handing control to Supabase's auth client.
///
/// Once [dispose] is called, this handler cannot be restarted. Create a new
/// instance if you need to handle deep links again after disposal.
class SupabaseDeepLinkHandler {
  SupabaseDeepLinkHandler({
    platform_links.AppLinks? appLinks,
    Uri? allowedUri,
  })  : _appLinks = appLinks ?? platform_links.AppLinks(),
        _allowedUri = allowedUri ?? config_links.AppLinks.authCallbackUri;

  /// Timeout for initial deep link fetch. Exposed for testing.
  static const deepLinkTimeout = Duration(seconds: 5);

  final platform_links.AppLinks _appLinks;
  final Uri _allowedUri;
  StreamSubscription<Uri?>? _subscription;
  bool _started = false;
  bool _disposed = false;

  /// Pending URI to be processed when Supabase initialization completes.
  /// This preserves deep links that arrive before Supabase is ready.
  Uri? _pendingUri;

  /// Counter for monitoring overwritten deep links in production.
  /// Exposed for testing and analytics integration.
  int _overwrittenUriCount = 0;

  /// Returns the count of overwritten pending URIs (for analytics/monitoring).
  int get overwrittenUriCount => _overwrittenUriCount;

  Future<void> start() async {
    if (_disposed) {
      throw StateError(
        'SupabaseDeepLinkHandler has been disposed and cannot be restarted. '
        'Create a new instance instead.',
      );
    }
    if (_started) return;
    _started = true;
    await _handleInitialUri();
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error, StackTrace stackTrace) {
        log.w(
          'supabase_deeplink_stream_error',
          tag: 'supabase_deeplink',
          error: sanitizeError(error) ?? error.runtimeType,
          stack: stackTrace,
        );
      },
    );
  }

  /// Disposes resources and marks this handler as unusable.
  ///
  /// After calling dispose, [start] will throw a [StateError]. Create a new
  /// instance if you need to handle deep links again.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _pendingUri = null; // Clear pending URI to release references
    _disposed = true;
  }

  Future<void> _handleInitialUri() async {
    try {
      final initial = await _appLinks
          .getInitialLink()
          .timeout(deepLinkTimeout);
      if (initial != null) {
        await _handleUri(initial);
      }
    } on TimeoutException catch (_, stackTrace) {
      log.w(
        'supabase_deeplink_initial_timeout',
        tag: 'supabase_deeplink',
        error: 'getInitialLink timed out after ${deepLinkTimeout.inSeconds}s',
        stack: stackTrace,
      );
    } catch (error, stackTrace) {
      log.w(
        'supabase_deeplink_initial_error',
        tag: 'supabase_deeplink',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
    }
  }

  Future<void> _handleUri(Uri? uri) async {
    if (uri == null) return;
    if (!_matchesAllowed(uri)) return;
    if (!SupabaseService.isInitialized) {
      // Detect and log when a pending URI is being overwritten
      if (_pendingUri != null) {
        _overwrittenUriCount++;
        log.w(
          'supabase_deeplink_overwritten: Previous pending URI replaced '
          '(count: $_overwrittenUriCount)',
          tag: 'supabase_deeplink_overwritten',
        );
      }
      // NOTE: Last-one-wins design - if multiple deep links arrive before
      // Supabase init completes, only the most recent URI is preserved.
      // This is acceptable for MVP as deep links are rare events and the
      // most recent link is typically the one the user actually wants.
      _pendingUri = uri;
      log.i(
        'supabase_deeplink_queued: Supabase not initialized, URI queued for later processing',
        tag: 'supabase_deeplink',
      );
      return;
    }

    await _processUri(uri);
  }

  /// Processes a validated deep link URI with Supabase.
  Future<void> _processUri(Uri uri) async {
    try {
      // Let Supabase SDK process the redirect and update auth state.
      // The onAuthStateChange listener will propagate state changes.
      await SupabaseService.client.auth.getSessionFromUrl(uri);
    } on AuthException catch (error, stackTrace) {
      // Log auth failures for diagnostics. The auth state listener will
      // handle the unauthenticated state appropriately.
      log.w(
        'supabase_deeplink_auth_error',
        tag: 'supabase_deeplink',
        error: sanitizeError(error) ?? error.message,
        stack: stackTrace,
      );
    } catch (error, stackTrace) {
      log.w(
        'supabase_deeplink_session_error',
        tag: 'supabase_deeplink',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
    }
  }

  /// Processes any pending deep link URI that was received before Supabase
  /// was initialized. Should be called after Supabase initialization completes.
  Future<void> processPendingUri() async {
    final pending = _pendingUri;
    if (pending == null) return;

    if (!SupabaseService.isInitialized) {
      log.w(
        'supabase_deeplink_pending_skipped: Supabase still not initialized',
        tag: 'supabase_deeplink',
      );
      return; // Keep _pendingUri intact for retry
    }

    // Only clear after confirming we can process
    _pendingUri = null;

    log.i(
      'supabase_deeplink_pending_processing: Processing queued URI',
      tag: 'supabase_deeplink',
    );
    await _processUri(pending);
  }

  /// Returns true if there is a pending URI waiting to be processed.
  bool get hasPendingUri => _pendingUri != null;

  bool _matchesAllowed(Uri uri) {
    if (uri.scheme.toLowerCase() != _allowedUri.scheme.toLowerCase()) {
      return false;
    }
    if (uri.host.toLowerCase() != _allowedUri.host.toLowerCase()) {
      return false;
    }
    // Also validate path if the allowed URI specifies one
    if (_allowedUri.path.isNotEmpty) {
      // Normalize paths by trimming trailing slashes for comparison
      final normalizedUriPath = _normalizePath(uri.path);
      final normalizedAllowedPath = _normalizePath(_allowedUri.path);
      return normalizedUriPath == normalizedAllowedPath;
    }
    return true;
  }

  /// Normalizes a path by trimming trailing slashes and converting to lowercase.
  /// Treats empty path and "/" as equivalent (both become "").
  String _normalizePath(String path) {
    final normalized = path.toLowerCase().replaceAll(RegExp(r'/+$'), '');
    return normalized.isEmpty ? '' : normalized;
  }
}
