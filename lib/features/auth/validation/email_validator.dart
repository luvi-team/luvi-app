import 'package:flutter/foundation.dart';

/// Canonical email validator used across auth flows.
///
/// Pattern requires at least 2 characters before the '@', and a TLD between
/// 2 and 63 characters. This intentionally keeps validation permissive while
/// catching common mistakes.
@immutable
class EmailValidator {
  const EmailValidator._();

  static final RegExp _pattern =
      RegExp(r'^[a-zA-Z0-9._%+-]{2,}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$');

  static bool isValid(String value) => _pattern.hasMatch(value.trim());
}

