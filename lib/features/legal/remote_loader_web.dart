import 'dart:async';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// Web implementation using package:http with BrowserClient.
Future<String?> fetchRemoteMarkdown(
  Uri uri, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = BrowserClient(); // withCredentials=false by default
  try {
    final http.Response resp = await client.get(uri).timeout(timeout);
    final status = resp.statusCode;
    if (status < 200 || status >= 300) {
      return null;
    }
    return resp.body;
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  } finally {
    client.close();
  }
}
