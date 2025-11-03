import 'package:flutter/foundation.dart';

/// Logging facade for the services package (data/domain layer).
///
/// SECURITY NOTICE — DO NOT LOG PII
/// - Never log raw emails, phone numbers, tokens, session IDs, addresses,
///   or free‑form user input that may contain personal data.
/// - Prefer structured context (enums/IDs) and sanitized error details.
/// - If you must include identifiers, redact them before logging.
// ignore: constant_identifier_names
const String PII_WARNING = 'DO NOT LOG PII (emails, phones, tokens, sessions, addresses) — redact identifiers.';

class Logger {
  const Logger();
  void d(String message, {String? tag}) => debugPrint(_format('D', message, tag: tag));
  void i(String message, {String? tag}) => debugPrint(_format('I', message, tag: tag));
  void w(String message, {String? tag, Object? error, StackTrace? stack}) {
    final b = StringBuffer(_format('W', message, tag: tag));
    if (error != null) b.write('\n$error');
    if (stack != null) b.write('\n$stack');
    debugPrint(b.toString());
  }

  void e(String message, {String? tag, Object? error, StackTrace? stack}) {
    final b = StringBuffer(_format('E', message, tag: tag));
    if (error != null) b.write('\n$error');
    if (stack != null) b.write('\n$stack');
    debugPrint(b.toString());
  }

  String _format(String level, String message, {String? tag}) {
    final tagPart = (tag == null || tag.isEmpty) ? '' : ' [$tag]';
    return '[$level]$tagPart $message';
  }
}

const log = Logger();
