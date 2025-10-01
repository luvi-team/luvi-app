/// Validates that the provided name input is non-null and not empty after trimming.
bool nonEmptyNameValidator(String? value) =>
    value != null && value.trim().isNotEmpty;
