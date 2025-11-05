import 'dart:async';
import 'dart:convert';
import 'dart:io';


/// IO implementation using HttpClient.
Future<String?> fetchRemoteMarkdown(Uri uri, {Duration timeout = const Duration(seconds: 5)}) async {
  final client = HttpClient();
  try {
    // Enforce a single overall deadline for the entire request/response.
    return await (() async {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final status = response.statusCode;
      if (status < 200 || status >= 300) {
        return null;
      }
      final bytes = await response.expand((chunk) => chunk).toList();
      // Decode as UTF-8; malformed sequences are replaced with U+FFFD
      return utf8.decode(bytes, allowMalformed: false);
    })().timeout(timeout);
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  } finally {
    // Always close the client to avoid resource leaks
    client.close(force: true);
  }
}
