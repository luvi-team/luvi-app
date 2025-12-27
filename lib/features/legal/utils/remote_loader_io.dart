import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:luvi_app/core/logging/logger.dart';

/// IO implementation using HttpClient.
Future<String?> fetchRemoteMarkdown(
  Uri uri, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 3);
  try {
    // Apply an overall timeout to the entire operation rather than per step.
    final String result = await () async {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final status = response.statusCode;
      if (status < 200 || status >= 300) {
        // Propagate HTTP errors so callers can distinguish failures from
        // successful-but-empty responses.
        final reason = response.reasonPhrase;
        final suffix = reason.isNotEmpty ? ' $reason' : '';
        throw HttpException('HTTP $status$suffix', uri: uri);
      }
      final body = await utf8.decoder.bind(response).join();
      return body;
    }().timeout(timeout);
    // Return the actual body (including empty string) so callers can detect
    // empty-but-successful responses distinctly from errors.
    return result;
  } on Object catch (error, stackTrace) {
    // Return null on any failure to keep caller contract consistent (nullable on error).
    // Log with context for diagnostics via structured logger (PII-sanitized).
    const log = Logger();
    log.w(
      'fetchRemoteMarkdown failed for $uri',
      tag: 'RemoteLoader',
      error: error,
      stack: stackTrace,
    );
    return null;
  } finally {
    // Always close the client to avoid resource leaks.
    client.close(force: true);
  }
}
