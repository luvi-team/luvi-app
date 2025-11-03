import 'package:flutter/foundation.dart';

/// Minimal logging facade for consistent, swappable logging.
///
/// Do not log PII. Prefer error types, IDs, and high‑level context.
typedef LogFn = void Function(String message, {String? tag, Object? error, StackTrace? stack});

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
