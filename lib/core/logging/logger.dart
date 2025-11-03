import 'package:flutter/foundation.dart';

// TODO(#15): Consolidate with services/lib/logger.dart into a shared module
// while preserving the public API (d/i/w/e signatures and tag/error/stack).

/// Logging facade for app code (UI layer).
///
/// SECURITY NOTICE — DO NOT LOG PII
/// - Never log raw emails, phone numbers, tokens, session IDs, addresses,
///   or free‑form user input that may contain personal data.
/// - Prefer structured context (enums/IDs) and sanitized error details.
/// - If you must include identifiers, redact them before logging.
///
/// This facade focuses on consistent formatting and a single, clear surface for
/// log calls. It intentionally keeps implementation simple and avoids external
/// deps; a future consolidation with the services logger is planned.
typedef LogFn = void Function(String message, {String? tag, Object? error, StackTrace? stack});

// ignore: constant_identifier_names
const String PII_WARNING = 'DO NOT LOG PII (emails, phones, tokens, sessions, addresses) — redact identifiers.';

class Logger {
  const Logger();

  void d(String message, {String? tag}) => _print(_format('D', message, tag: tag));
  void i(String message, {String? tag}) => _print(_format('I', message, tag: tag));

  void w(String message, {String? tag, Object? error, StackTrace? stack}) {
    final lines = StringBuffer(_format('W', message, tag: tag));
    if (error != null) lines.write('\n$error');
    if (stack != null) lines.write('\n$stack');
    _print(lines.toString());
  }

  void e(String message, {String? tag, Object? error, StackTrace? stack}) {
    final lines = StringBuffer(_format('E', message, tag: tag));
    if (error != null) lines.write('\n$error');
    if (stack != null) lines.write('\n$stack');
    _print(lines.toString());
  }

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
}

/// Global logger instance for convenience.
const log = Logger();
