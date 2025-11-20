import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;

/// Minimal replacement for go_router's GoRouterRefreshStream to avoid
/// version-dependent API differences. Listens to a stream and notifies listeners
/// on every event, allowing GoRouter to refresh its redirects/state.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(
    Stream<dynamic> stream, {
    void Function(Object error, StackTrace stackTrace)? onError,
    VoidCallback? onDone,
  }) {
    // Register callbacks inline with listen() so synchronous emissions
    // are handled and not dropped.
    _subscription = stream.listen(
      (_) {
        _notifyIfNotDisposed();
      },
      onError: (Object error, StackTrace stackTrace) {
        log.w(
          'go_router_refresh_stream_error',
          error: sanitizeError(error) ?? error.runtimeType,
          stack: stackTrace,
        );
        onError?.call(error, stackTrace);
        if (!_isDisposed) dispose();
      },
      onDone: () {
        onDone?.call();
        if (!_isDisposed) dispose();
      },
      cancelOnError: false,
    );
  }

  late final StreamSubscription<dynamic> _subscription;
  bool _isDisposed = false;

  void _notifyIfNotDisposed() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }

}
