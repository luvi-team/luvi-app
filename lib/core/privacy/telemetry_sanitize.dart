import 'dart:convert';

import 'package:luvi_app/core/privacy/pii_keys.dart';
import 'package:luvi_app/core/privacy/sanitize.dart' as log_sanitize;

/// Sanitizes arbitrary telemetry properties by:
/// - Masking known sensitive keys
/// - Recursively traversing Maps/Lists
/// - Sanitizing string values with the log sanitizer
Map<String, Object?> sanitizeTelemetryData(Map<String, Object?>? data) {
  if (data == null || data.isEmpty) return const <String, Object?>{};
  return _sanitizeMap(data);
}

/// Privacy level for DateTime sanitization in telemetry payloads.
/// - day: normalize to UTC and keep only YYYY-MM-DD
/// - hour: normalize to UTC and keep only YYYY-MM-DDTHH:00Z
/// - redacted: replace with a stable marker
/// - hash: deterministic hash of the UTC epoch millis
enum TelemetryDateSanitization { day, hour, redacted, hash }

// Prefer day granularity for MVP; adjust if needed via code change/DI.
const TelemetryDateSanitization _dateSanitization =
    TelemetryDateSanitization.day;


// Common sensitive keys; match in a case-insensitive manner.
const Set<String> _sensitiveKeys = PiiKeys.suspiciousKeyNames;

Map<String, Object?> _sanitizeMap(Map<String, Object?> input) {
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
    if (value is Map<String, Object?>) {
      return _sanitizeMap(value);
    }
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
  if (value is num || value is bool) return value;
  // Any other object: avoid dumping toString() which may include PII
  if (value is DateTime) {
    return _sanitizeDateTime(value);
  }
  final typeName = value.runtimeType.toString();
  // Fallback to a type marker only
  return '<$typeName>';
}

Object _sanitizeDateTime(DateTime dt) {
  final utc = dt.toUtc();
  switch (_dateSanitization) {
    case TelemetryDateSanitization.day:
      final y = utc.year.toString().padLeft(4, '0');
      final m = utc.month.toString().padLeft(2, '0');
      final d = utc.day.toString().padLeft(2, '0');
      // ISO-like date string with day granularity
      return '$y-$m-$d';
    case TelemetryDateSanitization.hour:
      final y = utc.year.toString().padLeft(4, '0');
      final m = utc.month.toString().padLeft(2, '0');
      final d = utc.day.toString().padLeft(2, '0');
      final h = utc.hour.toString().padLeft(2, '0');
      return '$y-$m-${d}T$h:00Z';
    case TelemetryDateSanitization.redacted:
      return '<DateTime>';
    case TelemetryDateSanitization.hash:
      // Deterministic non-crypto hash of epoch millis to bucket identical moments
      final ms = utc.millisecondsSinceEpoch.toString();
      return _hashHex(ms);
  }
}

Object? _maskValue(Object? value) {
  if (value == null) return null;
  if (value is String) {
    // Always mask string values regardless of length to prevent leaking
    // short tokens or identifiers.
    return '[redacted]';
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
