import 'dart:async';
import 'package:flutter/foundation.dart';

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
    late final StreamSubscription<dynamic> sub;
    sub = stream.listen(
      (_) {
        if (_isDisposed) return;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('GoRouterRefreshStream stream error: $error\n$stackTrace');
        onError?.call(error, stackTrace);
        _isDisposed = true;
        sub.cancel();
      },
      onDone: () {
        onDone?.call();
        _isDisposed = true;
        sub.cancel();
      },
      cancelOnError: false,
    );
    _subscription = sub;
  }

  late final StreamSubscription<dynamic> _subscription;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
