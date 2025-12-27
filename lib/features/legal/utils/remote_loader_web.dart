import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

typedef BrowserClientFactory = http.Client Function();

http.Client _defaultClientFactory() => BrowserClient();

BrowserClientFactory _clientFactory = _defaultClientFactory;

@visibleForTesting
void debugOverrideBrowserClientFactory(BrowserClientFactory factory) {
  _clientFactory = factory;
}

@visibleForTesting
void debugResetBrowserClientFactory() {
  _clientFactory = _defaultClientFactory;
}

/// Fetches remote markdown content from the given [uri].
///
/// Returns the markdown content as a string on success (2xx response),
/// or null if the request fails, times out, or returns a non-2xx status.
///
/// The [timeout] defaults to 5 seconds to prevent hanging on slow connections.
Future<String?> fetchRemoteMarkdown(
  Uri uri, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = _clientFactory(); // withCredentials=false by default
  try {
    final http.Response resp = await client.get(uri).timeout(timeout);
    if (resp.statusCode ~/ 100 != 2) {
      return null;
    }
    return resp.body;
  } on TimeoutException {
    return null;
  } catch (e) {
    // Log or handle specific exceptions if needed
    // For now, return null for any network/parse errors
    return null;
  } finally {
    client.close();
  }
}
