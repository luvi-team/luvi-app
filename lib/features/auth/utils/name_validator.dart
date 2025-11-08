/// Default pattern for western/Latin-based personal names.
///
/// Supports the following characters:
/// - Letters: `A-Z`, `a-z`, and Latin-extended accents `À-Ö`, `Ø-ö`, `ø-ÿ`
/// - Separators: spaces, hyphens (`-`), apostrophes (`'`)
///
/// Not supported by default: Cyrillic, CJK, Arabic, Hebrew, Devanagari and
/// other non-Latin scripts. Consumers that need full international support
/// should provide a custom `allowedCharsPattern` to `nonEmptyNameValidator`.
///
/// The pattern enforces at least one letter and allows internal separators.
final RegExp defaultNamePattern = RegExp(
  r"^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ\u0300-\u036f]*([-' ][A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ\u0300-\u036f]*)*$",
);

/// Validates a personal name using basic, configurable constraints.
///
/// Rules (defaults chosen for MVP UX and common western names):
/// - Non-null and non-empty after trimming
/// - Length between [minLength] and [maxLength] (inclusive); defaults 2–50
/// - Characters match [allowedCharsPattern] (defaults to letters incl. accents,
///   spaces, hyphens, apostrophes) and contain at least one letter
///
/// Returns true when the name satisfies all constraints.
/// Optional [letterPattern] enforces the documented constraint "contains at
/// least one letter" independent from [allowedCharsPattern]. Defaults to a
/// Latin + extended accents pattern. For non‑Latin scripts, provide a custom
/// [letterPattern] matching the expected character classes.
bool nonEmptyNameValidator(
  String? value, {
  int minLength = 2,
  int maxLength = 50,
  RegExp? allowedCharsPattern,
  RegExp? letterPattern,
}) {
  if (minLength <= 0) {
    throw ArgumentError.value(minLength, 'minLength', 'must be positive');
  }
  if (maxLength <= 0) {
    throw ArgumentError.value(maxLength, 'maxLength', 'must be positive');
  }
  if (minLength > maxLength) {
    throw ArgumentError(
      'minLength ($minLength) must not exceed maxLength ($maxLength)',
    );
  }
  if (value == null) return false;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  final normalized = _normalizeToNfc(trimmed);
  if (normalized.length < minLength || normalized.length > maxLength) {
    return false;
  }

  final reAllowed = allowedCharsPattern ?? defaultNamePattern;
  if (!reAllowed.hasMatch(normalized)) return false;

  // Enforce at least one letter regardless of the allowedCharsPattern.
  final reLetter = letterPattern ?? RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ]");
  if (!reLetter.hasMatch(normalized)) return false;

  return true;
}

String _normalizeToNfc(String input) {
  return input;
}
