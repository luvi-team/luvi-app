import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// IO implementation using HttpClient.
Future<String?> fetchRemoteMarkdown(
  Uri uri, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = HttpClient();
  try {
    // Apply an overall timeout to the operation.
    final String result = await () async {
      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      final status = response.statusCode;
      if (status < 200 || status >= 300) {
        return '';
      }
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      return body;
    }();
    return result.isEmpty ? null : result;
  } on TimeoutException {
    // Consider: logger.warning('Remote markdown fetch timed out: $uri');
    return null;
  } catch (_) {
    // Consider: logger.warning('Remote markdown fetch failed: $uri', _);
    return null;
  } finally {
    // Always close the client to avoid resource leaks.
    client.close(force: true);
  }
}
