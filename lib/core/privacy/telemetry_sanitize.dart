import 'dart:convert';

import 'package:luvi_app/core/privacy/sanitize.dart' as log_sanitize;

/// Sanitizes arbitrary telemetry properties by:
/// - Masking known sensitive keys
/// - Recursively traversing Maps/Lists
/// - Sanitizing string values with the log sanitizer
Map<String, Object?> sanitizeTelemetryData(Map<String, Object?>? data) {
  if (data == null || data.isEmpty) return const <String, Object?>{};
  return _sanitizeMap(data, topLevel: true);
}

// Common sensitive keys; match in a case-insensitive manner.
const Set<String> _sensitiveKeys = {
  'email',
  'name',
  'first_name',
  'firstname',
  'last_name',
  'lastname',
  'full_name',
  'phone',
  'user',
  'user_id',
  'userid',
  'session',
  'session_id',
  'token',
  'auth',
  'authorization',
  'password',
  'secret',
  'ssn',
  'address',
  'path',
  'file',
  'filepath',
};

Map<String, Object?> _sanitizeMap(Map<String, Object?> input, {bool topLevel = false}) {
  final out = <String, Object?>{};
  for (final entry in input.entries) {
    final key = entry.key;
    final lower = key.toLowerCase();
    final value = entry.value;

    if (_sensitiveKeys.contains(lower)) {
      out[key] = _maskValue(value);
      continue;
    }
    out[key] = _sanitizeValue(value);
  }
  return out;
}

Object? _sanitizeValue(Object? value) {
  if (value == null) return null;
  if (value is Map) {
    // Best-effort: convert to String keys, skip non-String keys
    final stringMap = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is String) {
        stringMap[key] = entry.value;
      } else {
        // Skip non-String keys to avoid potential PII in toString()
        continue;
      }
    }
    return _sanitizeMap(stringMap);
  }
  if (value is List) {
    return value.map(_sanitizeValue).toList(growable: false);
  }
  if (value is String) {
    return log_sanitize.sanitizeForLog(value);
  }
  // Primitive types (int/double/bool): keep as-is
  // Any other object: avoid dumping toString() which may include PII
  final typeName = value.runtimeType.toString();
  if (typeName == 'DateTime') {
    return value.toString();
  }
  // Fallback to a type marker only
  return '<$typeName>';
}

Object? _maskValue(Object? value) {
  if (value == null) return null;
  if (value is String) {
    // Keep very short identifiers; otherwise replace with redacted marker.
    final sanitized = log_sanitize.sanitizeForLog(value);
    return sanitized.length <= 6 ? sanitized : '[redacted]';
  }
  if (value is num || value is bool) return '[redacted]';
  if (value is Map || value is List) return '[redacted]';
  return '[redacted]';
}

/// Build a sanitized exception metadata map suitable for logging.
/// Does not include raw error messages or stack frames; returns only:
/// - errorType: the Dart type name
/// - stackHash: hex hash of a sanitized, truncated stack (top 8 lines)
/// - props: caller-supplied sanitized props (if any) — recommended to be the
///   output of [sanitizeTelemetryData]
Map<String, Object?> buildSanitizedExceptionMeta({
  Object? error,
  StackTrace? stack,
  Map<String, Object?>? props,
}) {
  final typeName = error == null ? 'UnknownError' : error.runtimeType.toString();
  final sanitizedStack = _sanitizedTruncatedStack(stack);
  final stackHash = _hashHex(sanitizedStack);
  return <String, Object?>{
    'errorType': typeName,
    'stackHash': stackHash,
    if (props != null && props.isNotEmpty) 'props': props,
  };
}

String _sanitizedTruncatedStack(StackTrace? stack) {
  if (stack == null) return '';
  final lines = stack.toString().split('\n').take(8);
  final sanitized = lines.map((l) => log_sanitize.sanitizeForLog(l)).join('\n');
  return sanitized;
}

String _hashHex(String s) {
  if (s.isEmpty) return '';
  // Simple non-crypto 32-bit FNV-1a
  const int fnvOffset = 0x811C9DC5;
  const int fnvPrime = 0x01000193;
  int hash = fnvOffset;
  for (final codeUnit in utf8.encode(s)) {
    hash ^= codeUnit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
