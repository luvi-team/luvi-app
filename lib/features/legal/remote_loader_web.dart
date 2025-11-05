// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

/// Web implementation using XMLHttpRequest.
Future<String?> fetchRemoteMarkdown(Uri uri, {Duration timeout = const Duration(seconds: 5)}) async {
  final completer = Completer<String?>();
  final req = html.HttpRequest();
  Timer? timer;
  // Keep track of subscriptions so we can cancel listeners on completion/timeout.
  StreamSubscription<html.Event>? loadSub;
  StreamSubscription<html.Event>? errorSub;
  void cleanup() {
    // Cancel timer and detach listeners to avoid leaks.
    timer?.cancel();
    timer = null;
    loadSub?.cancel();
    loadSub = null;
    errorSub?.cancel();
    errorSub = null;
  }
  try {
    req
      ..open('GET', uri.toString())
      ..responseType = 'text';
    // Attach listeners and capture subscriptions for cleanup.
    loadSub = req.onLoad.listen((_) {
      if (req.status != null && req.status! >= 200 && req.status! < 300) {
        if (!completer.isCompleted) completer.complete(req.responseText);
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
      cleanup();
    });
    errorSub = req.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
      cleanup();
    });

    timer = Timer(timeout, () {
      try {
        req.abort();
      } catch (_) {}
      if (!completer.isCompleted) completer.complete(null);
      cleanup();
    });
    req.send();
    return completer.future;
  } catch (_) {
    cleanup();
    try {
      req.abort();
    } catch (_) {}
    return null;
  }
}
