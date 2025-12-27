# Auth Feature

## Non-Standard Subdirectories

This feature uses additional subdirectories beyond the standard `screens/`, `widgets/`, `state/`, `data/` pattern:

### layout/
- Contains layout wrapper widgets specific to auth screens
- Files: `auth_layout.dart`, `auth_entry_layout.dart`

### strings/
- Contains string constants/keys for auth-specific text
- Files: `auth_strings.dart`
- Note: General l10n keys are in `lib/l10n/`, this is for auth-internal string handling

### validation/
- Contains validation logic for auth forms
- Files: `email_validator.dart`

## Rationale
This is an intentional deviation from the standard feature structure for MVP.
These subdirectories keep auth-specific concerns contained within the auth feature.
Do not replicate this pattern in other features without discussion.
