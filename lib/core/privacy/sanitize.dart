/*
 * Lightweight PII sanitizer for log lines.
 *
 * Redacts common sensitive patterns while preserving enough context for
 * debugging. Intended for use in non-PII logs and debug output.
 */

final RegExp _emailPattern = RegExp(
  r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})',
  caseSensitive: false,
);

final RegExp _uuidPattern = RegExp(
  // Keep in sync with services/lib/logger.dart and
  // lib/features/shared/utils/run_catching.dart
  r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
);

// Bearer tokens (JWT/Base64-ish/opaque).
final RegExp _bearerPattern = RegExp(
  r'\bBearer\s+([A-Za-z0-9\-._~+/=]+)',
);

// Long hex strings (20+ chars) which are often secrets/IDs.
final RegExp _longHexPattern = RegExp(r'\b[0-9a-fA-F]{20,}\b');

// US SSN like 123-45-6789.
final RegExp _ssnPattern = RegExp(r'\b\d{3}-\d{2}-\d{4}\b');

// Candidate phone numbers; filtered by digit count (>=10) to limit false positives.
final RegExp _phoneCandidatePattern = RegExp(r'\b\+?[\d()\s.-]{7,}\b');
final RegExp _extensionTokenPattern = RegExp(
  r'\b(?:ext(?:ension)?|x)\s*[:.]?\s*\d*',
  caseSensitive: false,
);
final RegExp _digitCounterPattern = RegExp(r'\d');

// Credit card: 13–19 digits with optional spaces/dashes; validated by Luhn.
final RegExp _ccCandidatePattern = RegExp(r'\b(?:\d[ -]?){12,18}\d\b');

// Prefixed tokens like token=abcdef..., id: ABCDEF..., session-<hex>...
final RegExp _prefixedTokenPattern = RegExp(
  r'\b(?:id|token|session|trace|request|user|auth|ref)[-_:= ]*([A-Fa-f0-9]{16,})\b',
  caseSensitive: false,
);

// IPv4 address (simple): 1-3 digits dot 4 times; not strict 0-255 validation
final RegExp _ipv4Pattern = RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b');

// IPv6 address (simple): 1-7 groups of 1-4 hex digits separated by ':'
final RegExp _ipv6Pattern = RegExp(
  r'\b(?:(?:[A-Fa-f0-9]{1,4}:){1,7}[A-Fa-f0-9]{0,4}|(?:[A-Fa-f0-9]{0,4}:){0,7}:[A-Fa-f0-9]{0,4})\b',
);

/// Sanitizes a string for safe logging.
String sanitizeForLog(String input) {
  var out = input;

  // Emails
  out = out.replaceAll(_emailPattern, '[redacted-email]');

  // UUIDs
  out = out.replaceAll(_uuidPattern, '[redacted-uuid]');

  // Bearer tokens
  out = out.replaceAllMapped(_bearerPattern, (m) => 'Bearer [redacted-token]');

  // Prefixed tokens (keep the prefix)
  out = out.replaceAllMapped(_prefixedTokenPattern, (m) {
    final full = m.group(0);
    final id = m.group(1);
    if (full == null || id == null) return m.group(0) ?? '';
    return full.replaceFirst(id, '[redacted-id]');
  });

  // Long hex
  out = out.replaceAll(_longHexPattern, '[redacted-hex]');

  // SSN
  out = out.replaceAll(_ssnPattern, '[redacted-ssn]');

  // IP addresses
  out = out.replaceAll(_ipv4Pattern, '[redacted-ip]');
  out = out.replaceAll(_ipv6Pattern, '[redacted-ip]');

  // Credit cards via Luhn check
  out = out.replaceAllMapped(_ccCandidatePattern, (m) {
    final candidate = m.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
    return _isLikelyCc(candidate) ? '[redacted-cc]' : m.group(0)!;
  });

  // Phone numbers
  out = out.replaceAllMapped(_phoneCandidatePattern, (m) {
    final candidate = m.group(0)!;
    return _isLikelyPhone(candidate) ? '[redacted-phone]' : candidate;
  });

  return out;
}

bool _isLikelyPhone(String candidate) {
  final stripped = candidate.replaceAll(_extensionTokenPattern, '');
  final digits = _digitCounterPattern.allMatches(stripped).length;
  // Treat as phone only for plausible E.164 ranges (10–15 digits).
  // Avoid redacting long 16+ digit sequences that may resemble credit cards
  // but fail Luhn (tests expect those not to be redacted as phones).
  return digits >= 10 && digits <= 15;
}

bool _isLikelyCc(String numeric) {
  if (numeric.length < 13 || numeric.length > 19) return false;
  return _luhnValid(numeric);
}

bool _luhnValid(String digits) {
  var sum = 0;
  var alt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.tryParse(digits[i]);
    if (n == null) return false;
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  return sum % 10 == 0;
}
