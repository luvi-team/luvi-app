// Default pattern: letters (ASCII + common accents), spaces, hyphens,
// apostrophes; must contain at least one letter.
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
