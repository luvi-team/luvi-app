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
      // FunctionException is thrown for ALL non-2xx status codes.
      // Status-based mapping to provide precise error codes.
      final status = e.status;
      final errorBody = _asJsonMap(e.details);
      final requestId = errorBody?['request_id']?.toString();
      log.w(
        'log_consent failed (status=$status, request_id=${requestId ?? 'n/a'})',
        tag: _logTag,
      );

      if (status == 401) {
        throw ConsentException(401, 'Unauthorized', code: 'unauthorized');
      } else if (status == 429) {
        throw ConsentException(429, 'Rate limit exceeded', code: 'rate_limit');
      } else if (status >= 500) {
        throw ConsentException(status, 'Server error', code: 'server_error');
      } else if (status == 404) {
        // Edge Function not deployed or not found
        throw ConsentException(
          404,
          'Function not found',
          code: 'function_unavailable',
        );
      } else {
        // Other client errors (4xx)
        throw ConsentException(
          status,
          'Client error',
          code: 'client_error',
        );
      }
    } on Exception catch (error, stackTrace) {
      // Network/transport errors (offline/DNS/timeout) are not FunctionException.
      // Classify as function_unavailable for consistent UX messaging.
      log.w(
        'log_consent invoke failed (transport)',
        tag: _logTag,
        error: error.runtimeType,
        stack: stackTrace,
      );
      throw ConsentException(
        503,
        'Service unavailable',
        code: 'function_unavailable',
      );
    }

    // 2xx success - validate response payload
    final responseBody = _asJsonMap(response.data);
    if (responseBody == null || responseBody['ok'] != true) {
      final diagnostics = payloadDiagnosticsShapeOnly(response.data);
      log.w(
        'log_consent returned unexpected payload (status=${response.status}, ok=${responseBody?['ok']}, payload=$diagnostics)',
        tag: _logTag,
      );
      throw ConsentException(
        response.status,
        'log_consent returned an unexpected response payload.',
        code: 'unexpected_response',
      );
    }

    final requestId = responseBody['request_id']?.toString();
    if (requestId != null) {
      log.i('log_consent succeeded (request_id=$requestId)', tag: _logTag);
    }
  }

  Map<String, dynamic>? _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

}

/// Riverpod provider for [ConsentService] to support DI and testability.
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});
