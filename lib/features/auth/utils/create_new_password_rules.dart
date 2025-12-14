import 'package:flutter/foundation.dart';

/// Possible validation failures for the password creation screen.
///
/// Note: Per NIST SP 800-63B and OWASP guidance, we do NOT enforce character
/// composition rules (requiring uppercase, lowercase, digits, symbols).
/// Instead we rely on minimum length + blocklist of common weak passwords.
enum AuthPasswordValidationError {
  emptyFields,
  mismatch,
  tooShort,
  commonWeak,
}

@immutable
class AuthPasswordValidationResult {
  const AuthPasswordValidationResult(this.error);

  const AuthPasswordValidationResult.valid() : error = null;

  final AuthPasswordValidationError? error;

  bool get isValid => error == null;
}

const int _kMinPasswordLength = 8;

final List<RegExp> _commonWeakPatterns = <RegExp>[
  RegExp(r'^password\d*$', caseSensitive: false),
  RegExp(r'^qwerty\d*$', caseSensitive: false),
  RegExp(r'^letmein\d*$', caseSensitive: false),
  RegExp(r'^welcome\d*$', caseSensitive: false),
  RegExp(r'^admin\d*$', caseSensitive: false),
  RegExp(r'^monkey\d*$', caseSensitive: false),
  RegExp(r'^dragon\d*$', caseSensitive: false),
  RegExp(r'^zxcvbn\d*$', caseSensitive: false),
  RegExp(r'^asdfgh\d*$', caseSensitive: false),
  RegExp(r'^iloveyou\d*$', caseSensitive: false),
  RegExp(r'^abc123$', caseSensitive: false),
  RegExp(r'^abcdef$', caseSensitive: false),
  RegExp(r'^123456(7|78|789)?$'),
  RegExp(r'^654321$'),
  RegExp(r'^12345$'),
  RegExp(r'^123123$'),
  RegExp(r'^password1$|^password123$', caseSensitive: false),
  RegExp(r'^qwerty123$', caseSensitive: false),
  RegExp(r'^000000$'),
  RegExp(r'^111111$'),
  RegExp(r'^222222$'),
  RegExp(r'^aaaaaa$', caseSensitive: false),
];

bool _isRepetitive(String s) => RegExp(r'^(.)\1{5,}$').hasMatch(s);

bool _isNumericSequence(String s) {
  if (!RegExp(r'^\d+$').hasMatch(s)) return false;
  if (s.length < 5) return false;
  final codes = s.codeUnits;
  var asc = true;
  var desc = true;
  for (var i = 1; i < codes.length; i++) {
    if (codes[i] != codes[i - 1] + 1) asc = false;
    if (codes[i] != codes[i - 1] - 1) desc = false;
    if (!asc && !desc) break;
  }
  return asc || desc;
}

bool _isRepeatedBlock(String s) {
  final re = RegExp(r'^(.{2,})\1+$');
  return re.hasMatch(s);
}

AuthPasswordValidationResult validateNewPassword(
  String newPassword,
  String confirmation,
) {
  if (newPassword.isEmpty || confirmation.isEmpty) {
    return const AuthPasswordValidationResult(
      AuthPasswordValidationError.emptyFields,
    );
  }
  if (newPassword != confirmation) {
    return const AuthPasswordValidationResult(
      AuthPasswordValidationError.mismatch,
    );
  }

  // NIST SP 800-63B: Minimum length is the primary strength factor.
  // Character composition rules are explicitly discouraged.
  final hasMinLen = newPassword.length >= _kMinPasswordLength;

  // Blocklist check for common weak passwords (NIST-compliant)
  final trimmed = newPassword.trim();
  final isCommonWeak = _commonWeakPatterns.any((r) => r.hasMatch(trimmed)) ||
      _isRepetitive(trimmed) ||
      _isNumericSequence(trimmed) ||
      _isRepeatedBlock(trimmed);

  if (!hasMinLen) {
    return const AuthPasswordValidationResult(
      AuthPasswordValidationError.tooShort,
    );
  }
  if (isCommonWeak) {
    return const AuthPasswordValidationResult(
      AuthPasswordValidationError.commonWeak,
    );
  }

  return const AuthPasswordValidationResult.valid();
}

const int _kBackoffBaseSeconds = 2;
const int _kBackoffMaxSeconds = 60;

Duration computePasswordBackoffDelay(int consecutiveFailures) {
  if (consecutiveFailures <= 0) {
    return Duration.zero;
  }
  final multiplier = 1 << consecutiveFailures;
  final clampedSeconds =
      (_kBackoffBaseSeconds * multiplier).clamp(0, _kBackoffMaxSeconds);
  final seconds = clampedSeconds.toInt();
  return Duration(seconds: seconds);
}
