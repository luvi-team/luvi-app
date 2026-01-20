// Type-safe parsing utilities for dynamic map values.
// These helpers prevent unsafe `as` casts that can throw at runtime
// when server responses contain unexpected types.

/// Safe nullable bool extraction from dynamic value.
///
/// Returns the value if it is a bool, otherwise returns null.
/// Use this instead of unsafe `as bool?` casts on dynamic map values.
///
/// Example:
/// ```dart
/// final remoteGate = parseNullableBool(profile?['has_completed_onboarding']);
/// ```
bool? parseNullableBool(dynamic value) {
  return value is bool ? value : null;
}

/// Safe nullable int extraction from dynamic value.
///
/// Returns the value if it is an int, otherwise returns null.
/// Use this instead of unsafe `as int?` casts on dynamic map values.
///
/// Example:
/// ```dart
/// final version = parseNullableInt(profile?['accepted_consent_version']);
/// ```
int? parseNullableInt(dynamic value) {
  return value is int ? value : null;
}
