import 'package:flutter/foundation.dart';

import 'privacy/sanitize.dart';

/// Logging facade for the services package (data/domain layer).
///
/// SECURITY NOTICE — DO NOT LOG PII
/// - Never log raw emails, phone numbers, tokens, session IDs, addresses,
///   or free‑form user input that may contain personal data.
/// - Prefer structured context (enums/IDs) and sanitized error details.
/// - If you must include identifiers, redact them before logging.

const String piiWarning =
    'DO NOT LOG PII (emails, phones, tokens, sessions, addresses) — redact identifiers.';

class Logger {
  const Logger();

  /// Maximum stack trace lines shown in release builds.
  /// Balances debuggability with log size constraints.
  static const int _maxReleaseStackLines = 12;

  void d(String? message, {String? tag}) =>
      _print(_format('D', sanitizeForLog(message ?? ''), tag: tag));
  void i(String? message, {String? tag}) =>
      _print(_format('I', sanitizeForLog(message ?? ''), tag: tag));

  void w(String? message, {String? tag, Object? error, StackTrace? stack}) =>
      _printStructured('W', message, tag: tag, error: error, stack: stack);

  void e(String? message, {String? tag, Object? error, StackTrace? stack}) =>
      _printStructured('E', message, tag: tag, error: error, stack: stack);

  // Print indirection: kept intentionally as a seam for testing and potential
  // output redirection (e.g., capture logs in tests or swap sink in the future).
  // If not needed, this could be inlined to debugPrint, but we keep it to make
  // redirection straightforward without touching all call sites.
  void _print(String line) {
    debugPrint(line);
  }

  String _format(String level, String message, {String? tag}) {
    final tagPart = (tag == null || tag.isEmpty) ? '' : ' [$tag]';
    return '[$level]$tagPart $message';
  }

  void _printStructured(
    String level,
    String? message, {
    String? tag,
    Object? error,
    StackTrace? stack,
  }) {
    final buffer =
        StringBuffer(_format(level, sanitizeForLog(message ?? ''), tag: tag));
    final sanitizedError = _sanitizeError(error);
    if (sanitizedError != null && sanitizedError.isNotEmpty) {
      buffer
        ..write('\n')
        ..write(sanitizedError);
    }
    final sanitizedStack = _sanitizeStack(stack);
    if (sanitizedStack != null && sanitizedStack.isNotEmpty) {
      buffer
        ..write('\n')
        ..write(sanitizedStack);
    }
    _print(buffer.toString());
  }

  String? _sanitizeError(Object? error) {
    if (error == null) return null;
    return sanitizeForLog(error is String ? error : '$error');
  }

  String? _sanitizeStack(StackTrace? stack) {
    if (stack == null) return null;
    final raw = stack.toString();
    if (raw.isEmpty) return '';
    final sanitized = sanitizeForLog(raw);
    if (!kReleaseMode) {
      return sanitized;
    }
    final lines = sanitized.split('\n');
    if (lines.length <= _maxReleaseStackLines) {
      return sanitized;
    }
    final truncated = lines.take(_maxReleaseStackLines).join('\n');
    return '$truncated\n[stack trimmed]';
  }
}

/// Global logger instance for convenience.
const log = Logger();
