import 'package:luvi_app/core/logging/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final response = await Supabase.instance.client.functions.invoke(
      'log_consent',
      body: {'version': version, 'scopes': scopesMap},
    );

    final status = response.status;
    final responseBody = _asJsonMap(response.data);
    final requestId = responseBody?['request_id']?.toString();

    final isSuccessStatus = status >= 200 && status < 300;
    if (!isSuccessStatus) {
      final serverError = responseBody?['error'] as String?;
      final isRateLimited = status == 429;
      final isUnauthorized = status == 401;
      final message = isRateLimited
          ? 'Consent logging is temporarily rate limited. Please retry later.'
          : isUnauthorized
          ? (serverError ?? 'Unauthorized')
          : (serverError ?? 'Failed to log consent.');
      log.w(
        'log_consent failed (status=$status, request_id=${requestId ?? 'n/a'})',
        tag: _logTag,
      );
      throw ConsentException(
        status,
        message,
        code: isRateLimited
            ? 'rate_limit'
            : isUnauthorized
            ? 'unauthorized'
            : null,
      );
    }

    if (responseBody == null || responseBody['ok'] != true) {
      final payloadDiagnostics = _payloadDiagnostics(response.data);
      log.w(
        'log_consent returned unexpected payload (status=$status, ok=${responseBody?['ok']}, payload=$payloadDiagnostics)',
        tag: _logTag,
      );
      throw ConsentException(
        status,
        'log_consent returned an unexpected response payload.',
        code: 'unexpected_response',
      );
    }

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

  String _payloadDiagnostics(dynamic payload) {
    if (payload == null) return 'type=null, preview=null';
    final preview = payload.toString();
    final truncatedPreview =
        preview.length <= 200 ? preview : '${preview.substring(0, 200)}...';
    return 'type=${payload.runtimeType}, preview=$truncatedPreview';
  }
}

/// Riverpod provider for [ConsentService] to support DI and testability.
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});
