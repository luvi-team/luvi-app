import 'dart:async';
import 'dart:convert';
import 'dart:io';


/// IO implementation using HttpClient.
Future<String?> fetchRemoteMarkdown(Uri uri, {Duration timeout = const Duration(seconds: 5)}) async {
  final client = HttpClient();
  client.connectionTimeout = timeout;
  try {
    final request = await client.getUrl(uri).timeout(timeout);
    final response = await request.close().timeout(timeout);
    final status = response.statusCode;
    if (status < 200 || status >= 300) {
      return null;
    }
    final bytes = await response.fold<List<int>>(<int>[], (acc, chunk) {
      acc.addAll(chunk);
      return acc;
    }).timeout(timeout);
    // Try to decode as UTF-8; fall back to system encoding if needed
    return utf8.decode(bytes, allowMalformed: true);
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}
