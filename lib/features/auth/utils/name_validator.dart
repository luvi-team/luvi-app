/// Validates a personal name using basic, configurable constraints.
///
/// Rules (defaults chosen for MVP UX and common western names):
/// - Non-null and non-empty after trimming
/// - Length between [minLength] and [maxLength] (inclusive); defaults 2–50
/// - Characters match [allowedCharsPattern] (defaults to letters incl. accents,
///   spaces, hyphens, apostrophes)
///
/// Returns true when the name satisfies all constraints.
bool nonEmptyNameValidator(
  String? value, {
  int minLength = 2,
  int maxLength = 50,
  RegExp? allowedCharsPattern,
}) {
  if (value == null) return false;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.length < minLength || trimmed.length > maxLength) return false;

  // Allow letters (ASCII + common accents), spaces, hyphens, apostrophes.
  // Must contain at least one letter.
  // Must contain at least one letter.
  final re = allowedCharsPattern ?? 
      RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]*[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ' -]*$");
  return re.hasMatch(trimmed);
}
