// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

/// Web implementation using XMLHttpRequest.
Future<String?> fetchRemoteMarkdown(Uri uri, {Duration timeout = const Duration(seconds: 5)}) async {
  final completer = Completer<String?>();
  final req = html.HttpRequest();
  Timer? timer;
  void cleanup() {
    timer?.cancel();
  }
  try {
    req
      ..open('GET', uri.toString())
      ..responseType = 'text'
      ..onLoad.listen((_) {
        if (req.status != null && req.status! >= 200 && req.status! < 300) {
          if (!completer.isCompleted) completer.complete(req.responseText ?? '');
        } else {
          if (!completer.isCompleted) completer.complete(null);
        }
        cleanup();
      })
      ..onError.listen((_) {
        if (!completer.isCompleted) completer.complete(null);
        cleanup();
      });
    timer = Timer(timeout, () {
      try {
        req.abort();
      } catch (_) {}
      if (!completer.isCompleted) completer.complete(null);
    });
    req.send();
    return completer.future;
  } catch (_) {
    cleanup();
    return null;
  }
}
