import 'package:flutter/foundation.dart';

// Minimal logger for services package. Do not log PII.
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
