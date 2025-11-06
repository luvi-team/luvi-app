import 'package:flutter/foundation.dart';
import 'package:luvi_app/core/privacy/sanitize.dart';

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

const String piiWarning =
    'DO NOT LOG PII (emails, phones, tokens, sessions, addresses) — redact identifiers.';

class Logger {
  const Logger();

  void d(String? message, {String? tag}) =>
      _print(_format('D', sanitizeForLog(message ?? ''), tag: tag));
  void i(String? message, {String? tag}) =>
      _print(_format('I', sanitizeForLog(message ?? ''), tag: tag));

  void w(String? message, {String? tag, Object? error, StackTrace? stack}) {
    final lines = StringBuffer(_format('W', sanitizeForLog(message ?? ''), tag: tag));
    if (error != null) {
      lines.write('\n');
      lines.write(sanitizeForLog('$error'));
    }
    if (stack != null) {
      lines.write('\n');
      // Stack traces rarely hold PII, but sanitize defensively to avoid
      // leaking embedded messages from exception toString().
      lines.write(sanitizeForLog(stack.toString()));
    }
    _print(lines.toString());
  }

  void e(String? message, {String? tag, Object? error, StackTrace? stack}) {
    final lines = StringBuffer(_format('E', sanitizeForLog(message ?? ''), tag: tag));
    if (error != null) {
      lines.write('\n');
      lines.write(sanitizeForLog('$error'));
    }
    if (stack != null) {
      lines.write('\n');
      lines.write(sanitizeForLog(stack.toString()));
    }
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
