import 'package:flutter/foundation.dart';

/// Logging facade for the services package (data/domain layer).
///
/// SECURITY NOTICE — DO NOT LOG PII
/// - Never log raw emails, phone numbers, tokens, session IDs, addresses,
///   or free‑form user input that may contain personal data.
/// - Prefer structured context (enums/IDs) and sanitized error details.
/// - If you must include identifiers, redact them before logging.
const String piiWarning = 'DO NOT LOG PII (emails, phones, tokens, sessions, addresses) — redact identifiers.';

class Logger {
  const Logger();
  void d(String message, {String? tag}) => _print(_format('D', message, tag: tag));
  void i(String message, {String? tag}) => _print(_format('I', message, tag: tag));
  void w(String message, {String? tag, Object? error, StackTrace? stack}) {
    _printWithError('W', message, tag: tag, error: error, stack: stack);
  }

  void e(String message, {String? tag, Object? error, StackTrace? stack}) {
    _printWithError('E', message, tag: tag, error: error, stack: stack);
  }

  void _printWithError(String level, String message, {String? tag, Object? error, StackTrace? stack}) {
    final b = StringBuffer(_format(level, message, tag: tag));
    if (error != null) {
      final errStr = _sanitizeForLog('$error');
      b.write('\n');
      b.write(errStr);
    }
    if (stack != null) {
      final stStr = _sanitizeForLog(stack.toString());
      b.write('\n');
      b.write(stStr);
    }
    _print(b.toString());
  }

  // Private print seam for testing and future redirection.
  void _print(String line) {
    debugPrint(line);
  }

  String _format(String level, String message, {String? tag}) {
    final tagPart = tag?.isNotEmpty == true ? ' [$tag]' : '';
    return '[$level]$tagPart $message';
  }

}

const log = Logger();

// --- Lightweight sanitizer (services-local) ---

final RegExp _emailPattern = RegExp(
  r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})',
  caseSensitive: false,
);
final RegExp _uuidPattern = RegExp(
  r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\b',
);
final RegExp _bearerPattern = RegExp(r'\bBearer\s+([A-Za-z0-9\-._~+/=]+)');
final RegExp _longHexPattern = RegExp(r'\b[0-9a-fA-F]{20,}\b');

String _sanitizeForLog(String input) {
  var out = input;
  out = out.replaceAll(_emailPattern, '[redacted-email]');
  out = out.replaceAll(_uuidPattern, '[redacted-uuid]');
  out = out.replaceAllMapped(_bearerPattern, (m) => 'Bearer [redacted-token]');
  out = out.replaceAll(_longHexPattern, '[redacted-hex]');
  // Guard against excessively long lines.
  const max = 4000; // conservative cap for logs
  if (out.length > max) {
    out = '${out.substring(0, max)}…';
  }
  return out;
}
