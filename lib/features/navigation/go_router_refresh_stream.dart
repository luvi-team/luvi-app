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
    // Create the subscription first and assign to the field immediately to avoid
    // LateInitializationError if the stream emits synchronously during listen().
    final subscription = stream.listen(null);
    _subscription = subscription;

    subscription.onData((_) {
      if (_isDisposed) return;
      notifyListeners();
    });
    subscription.onError((Object error, StackTrace stackTrace) {
      debugPrint('GoRouterRefreshStream stream error: $error\n$stackTrace');
      onError?.call(error, stackTrace);
      subscription.cancel();
    });
    subscription.onDone(() {
      onDone?.call();
      subscription.cancel();
    });
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
