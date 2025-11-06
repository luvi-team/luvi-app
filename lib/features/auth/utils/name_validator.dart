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
  r"^[A-Za-zÀ-ÖØ-öø-ÿ]+(['\- ][A-Za-zÀ-ÖØ-öø-ÿ]+)*$",
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
bool nonEmptyNameValidator(
  String? value, {
  int minLength = 2,
  int maxLength = 50,
  RegExp? allowedCharsPattern,
}) {
  assert(minLength > 0, 'minLength must be positive');
  assert(maxLength > 0, 'maxLength must be positive');
  assert(minLength <= maxLength, 'minLength must not exceed maxLength');
  if (value == null) return false;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.length < minLength || trimmed.length > maxLength) return false;

  final re = allowedCharsPattern ?? defaultNamePattern;
  return re.hasMatch(trimmed);
}
