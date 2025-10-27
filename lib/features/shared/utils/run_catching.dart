import 'package:flutter/foundation.dart';

/// Lightweight wrappers for non-critical work where errors may be safely ignored
/// once observed. Prefer normal try/catch for critical paths or when callers must
/// surface failures to the user. These helpers are best kept for background tasks,
/// speculative UI affordances, or telemetry that should not block the primary flow.
/// Errors are passed verbatim to [onError] so callers can log or surface them, while
/// the debug output only emits sanitized context (omitting the message entirely when
/// no redaction is possible) to avoid leaking PII.
T? tryOrNull<T>(
  T Function() fn, {
  String tag = 'safe',
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  try {
    return fn();
  } catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    final sanitized = _sanitizeError(error);
    final suffix = sanitized == null ? '' : ': $sanitized';
    debugPrint('[$tag] ${error.runtimeType}$suffix\n${_shortStackTrace(stackTrace)}');
    return null;
  }
}

/// Async counterpart to [tryOrNull] with the same PII-safe logging policy. Use it
/// only when occasional failures are acceptable and callers still capture the full
/// error through [onError] for observability.
Future<T?> tryOrNullAsync<T>(
  Future<T> Function() fn, {
  String tag = 'safe',
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return await fn();
  } catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    final sanitized = _sanitizeError(error);
    final suffix = sanitized == null ? '' : ': $sanitized';
    debugPrint('[$tag] ${error.runtimeType}$suffix\n${_shortStackTrace(stackTrace)}');
    return null;
  }
}

String _shortStackTrace(StackTrace stackTrace) =>
    stackTrace.toString().split('\n').take(3).join('\n');

String? _sanitizeError(Object error) {
  final raw = error.toString();

  final emailRedacted = RegExp(
    r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})',
    caseSensitive: false,
  );
  final phoneRedacted = RegExp(r'\b\+?\d[\d\s.-]{7,}\d\b');
  final idRedacted = RegExp(r'\b[A-F0-9]{8,}\b', caseSensitive: false);

  final sanitized = raw
      .replaceAll(emailRedacted, '[redacted-email]')
      .replaceAll(phoneRedacted, '[redacted-phone]')
      .replaceAll(idRedacted, '[redacted-id]');

  if (sanitized == raw || sanitized.trim().isEmpty) {
    return null;
  }

  return sanitized;
}
