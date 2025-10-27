import 'package:flutter/foundation.dart';

/// Utility helpers to safely run code blocks and swallow errors without PII.
T? tryOrNull<T>(
  T Function() fn, {
  String tag = 'safe',
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  try {
    return fn();
  } catch (e, st) {
    onError?.call(e, st);
    debugPrint('[$tag] ${e.runtimeType}');
    return null;
  }
}

Future<T?> tryOrNullAsync<T>(
  Future<T> Function() fn, {
  String tag = 'safe',
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return await fn();
  } catch (e, st) {
    onError?.call(e, st);
    debugPrint('[$tag] ${e.runtimeType}');
    return null;
  }
}
