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
    final b = StringBuffer(_format('W', message, tag: tag));
    if (error != null) b.write('\n$error');
    if (stack != null) b.write('\n$stack');
    _print(b.toString());
  }

  void e(String message, {String? tag, Object? error, StackTrace? stack}) {
    final b = StringBuffer(_format('E', message, tag: tag));
    if (error != null) b.write('\n$error');
    if (stack != null) b.write('\n$stack');
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
