import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:luvi_app/core/logging/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns shape-only diagnostics for payload (type + keys).
/// CRITICAL: Never log payload values - only structure for debugging.
/// Exposed for testing via @visibleForTesting.
@visibleForTesting
String payloadDiagnosticsShapeOnly(dynamic payload) {
  if (payload == null) return 'type=null';
  if (payload is Map) {
    final keys = payload.keys.take(20).map((k) => k.toString()).toList()..sort();
    final keysSuffix = payload.keys.length > 20 ? '...' : '';
    return 'type=Map, keys=[${keys.join(', ')}$keysSuffix]';
  }
  if (payload is List) {
    return 'type=List, length=${payload.length}';
  }
  return 'type=${payload.runtimeType}';
}

class ConsentException implements Exception {
  ConsentException(this.statusCode, this.message, {this.code});

  final int statusCode;
  final String message;
  final String? code;

  @override
  String toString() {
    final codeSuffix = code == null ? '' : ', code: $code';
    return 'ConsentException(status: $statusCode, message: $message$codeSuffix)';
  }
}

class ConsentService {
  static const _logTag = 'consent_service';

  Future<void> accept({
    required String version,
    required List<String> scopes,
  }) async {
    // Canonical format (SSOT): send scopes as a JSON object of boolean flags
    // instead of an array to avoid format drift in DB/event logs.
    final scopesMap = <String, bool>{for (final s in scopes) s: true};

    late final FunctionResponse response;
    try {
      response = await Supabase.instance.client.functions.invoke(
        'log_consent',
        body: {'version': version, 'scopes': scopesMap},
      );
    } on FunctionException catch (e) {
      throw _mapFunctionException(e);
    } on Exception catch (error, stackTrace) {
      // Network/transport errors (offline/DNS/timeout) are not FunctionException.
      log.w(
        'log_consent invoke failed (transport)',
        tag: _logTag,
        error: error.runtimeType,
        stack: stackTrace,
      );
      throw ConsentException(503, 'Service unavailable', code: 'function_unavailable');
    }

    // 2xx success - validate response payload
    _requireOkPayload(response);

    final responseBody = _asJsonMap(response.data);
    final requestId = responseBody?['request_id']?.toString();
    if (requestId != null) {
      log.i('log_consent succeeded (request_id=$requestId)', tag: _logTag);
    }
  }

  /// Maps FunctionException to ConsentException based on HTTP status code.
  ConsentException _mapFunctionException(FunctionException e) {
    final status = e.status;
    final errorBody = _asJsonMap(e.details);
    final requestId = errorBody?['request_id']?.toString();

    log.w(
      'log_consent failed (status=$status, request_id=${requestId ?? 'n/a'})',
      tag: _logTag,
    );

    return switch (status) {
      401 => ConsentException(401, 'Unauthorized', code: 'unauthorized'),
      429 => ConsentException(429, 'Rate limit exceeded', code: 'rate_limit'),
      404 => ConsentException(404, 'Function not found', code: 'function_unavailable'),
      >= 500 => ConsentException(status, 'Server error', code: 'server_error'),
      _ => ConsentException(status, 'Client error', code: 'client_error'),
    };
  }

  /// Validates response payload has ok=true. Throws ConsentException if invalid.
  void _requireOkPayload(FunctionResponse response) {
    final body = _asJsonMap(response.data);
    if (body == null || body['ok'] != true) {
      final diagnostics = payloadDiagnosticsShapeOnly(response.data);
      log.w(
        'log_consent returned unexpected payload (status=${response.status}, ok=${body?['ok']}, payload=$diagnostics)',
        tag: _logTag,
      );
      throw ConsentException(
        response.status,
        'log_consent returned an unexpected response payload.',
        code: 'unexpected_response',
      );
    }
  }

  Map<String, dynamic>? _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      final jsonMap = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key;
        if (key is String) {
          jsonMap[key] = entry.value;
        } else if (key is num || key is bool) {
          jsonMap[key.toString()] = entry.value;
        } else {
          // Log at warning level and fail-fast for unexpected complex keys
          log.w(
            '_asJsonMap: unexpected complex key type=${key.runtimeType}',
            tag: _logTag,
          );
          throw FormatException(
            'Unexpected non-primitive map key: ${key.runtimeType}',
          );
        }
      }
      return jsonMap;
    }
    return null;
  }
}

/// Riverpod provider for [ConsentService] to support DI and testability.
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});
