import 'package:flutter/foundation.dart';
import 'package:luvi_app/core/logging/logger.dart';

final RegExp _emailPattern = RegExp(
  r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})',
  caseSensitive: false,
);
// Intentionally broad to capture varied phone formatting. Downstream logic removes
// extension markers (ext, extension, x) and requires at least ten digits before
// treating a match as PII, which filters out most version-like sequences while
// still catching loosely formatted phone numbers.
final RegExp _phoneCandidatePattern = RegExp(r'\b\+?[\d()\s.-]{7,}\b');
final RegExp _extensionTokenPattern = RegExp(
  r'\b(?:ext(?:ension)?|x)\s*[:.]?\s*\d*',
  caseSensitive: false,
);
final RegExp _digitCounterPattern = RegExp(r'\d');
final RegExp _uuidPattern = RegExp(
  // Match any RFC4122-like UUID without enforcing version/variant bits to
  // stay consistent with services/lib/logger.dart.
  r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
);
// Extend the prefix list cautiously if new identifier types require masking.
final RegExp _prefixedTokenPattern = RegExp(
  r'\b(?:id|token|session|trace|request|user|auth|ref)[-_:= ]*([A-Fa-f0-9]{16,})\b',
  caseSensitive: false,
);
final RegExp _controlCharPattern = RegExp(r'[\r\n\t\x00-\x1F\x7F]');

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
    if (error is Error) {
      // Do not swallow Dart Errors; surface them while still notifying onError.
      if (onError != null) {
        try {
          onError(error, stackTrace);
        } catch (_) {
          // Keep null-contract; ignore failures from the onError callback.
        }
      }
      rethrow;
    }
    _reportHandledError(
      error: error,
      stackTrace: stackTrace,
      tag: tag,
      onError: onError,
    );
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
    if (error is Error) {
      if (onError != null) {
        try {
          onError(error, stackTrace);
        } catch (_) {}
      }
      rethrow;
    }
    _reportHandledError(
      error: error,
      stackTrace: stackTrace,
      tag: tag,
      onError: onError,
    );
    return null;
  }
}

void _reportHandledError({
  required Object error,
  required StackTrace stackTrace,
  required String tag,
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  if (onError != null) {
    try {
      onError(error, stackTrace);
    } catch (_) {
      // Swallow secondary failures from the error handler to keep null-contract.
    }
  }

  if (kDebugMode) {
    try {
      final sanitized = sanitizeError(error) ?? error.runtimeType;
      log.w(
        'run_catching_handled_error',
        tag: tag,
        error: sanitized,
        stack: stackTrace,
      );
    } catch (_) {
      log.w(
        'run_catching_handled_error',
        tag: tag,
        error: error.runtimeType,
        stack: stackTrace,
      );
    }
  }
}

String? _sanitizeError(Object error) {
  final raw = error.toString();

  String sanitized = raw;
  var changed = false;

  if (_controlCharPattern.hasMatch(sanitized)) {
    sanitized = sanitized.replaceAll(_controlCharPattern, ' ');
    changed = true;
  }

  if (_emailPattern.hasMatch(sanitized)) {
    sanitized = sanitized.replaceAll(_emailPattern, '[redacted-email]');
    changed = true;
  }

  if (_uuidPattern.hasMatch(sanitized)) {
    sanitized = sanitized.replaceAll(_uuidPattern, '[redacted-uuid]');
    changed = true;
  }

  sanitized = sanitized.replaceAllMapped(_phoneCandidatePattern, (match) {
    final candidate = match.group(0)!;
    if (_isPiiPhone(candidate)) {
      changed = true;
      return '[redacted-phone]';
    }
    return candidate;
  });

  if (_prefixedTokenPattern.hasMatch(sanitized)) {
    sanitized = sanitized.replaceAllMapped(_prefixedTokenPattern, (match) {
      final fullMatch = match.group(0)!;
      final identifier = match.group(1)!;
      changed = true;
      // Keep the descriptive prefix while masking the sensitive identifier.
      return fullMatch.replaceFirst(identifier, '[redacted-id]');
    });
  }

  return changed ? sanitized : null;
}

@visibleForTesting
String? debugSanitizeError(Object error) => _sanitizeError(error);

/// Public wrapper for sanitized error messages usable outside tests.
String? sanitizeError(Object error) => _sanitizeError(error);

bool _isPiiPhone(String candidate) {
  // Remove extension markers (e.g., "ext. 123") before counting digits so the
  // minimum length check focuses on the core phone number.
  final stripped = candidate.replaceAll(_extensionTokenPattern, '');
  final digits = _digitCounterPattern.allMatches(stripped).length;
  return digits >= 10;
}
