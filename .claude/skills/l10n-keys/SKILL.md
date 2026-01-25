---
name: l10n-keys
description: Use when adding user-facing text that needs localization
---

# L10n Keys Skill

## When to Use
- Adding new user-facing text to screens or widgets
- Creating new UI components with labels, hints, or instructions
- Displaying messages, titles, or descriptions to users
- Implementing new features that require multilingual support
- Keywords: "text", "label", "string", "translation", "localization", "L10n", "copy", "message", "title", "hint"

## When NOT to Use
- Debugging messages or logs (use logger facade, not L10n)
- Developer-facing comments or documentation
- Configuration keys or technical identifiers
- Code-level constants (use Dart constants)

## LUVI L10n Architecture

### Languages Supported
- **English (en):** Base language (`app_en.arb`)
- **German (de):** Primary target market (`app_de.arb`)

### File Structure
```
lib/l10n/
├── app_en.arb                      # English base (1,480 lines)
├── app_de.arb                      # German translations (1,477 lines)
└── app_localizations.dart          # Generated (DO NOT EDIT)
```

### Scale
- **~1,480 localization keys** across 2 languages
- **2,957 total lines** of ARB content
- Generated via `flutter gen-l10n` command

## Key Naming Convention (MUST-03)

### Pattern: `{feature}{step/component}{descriptor}`

```
{feature}     - Feature name in camelCase (e.g., onboarding, auth, dashboard)
{component}   - Optional step number or component (e.g., 01, 02, Callout, Header)
{descriptor}  - Text type (e.g., Title, Instruction, Hint, Label, Semantic)
```

### Examples from LUVI

| Key | Feature | Component | Descriptor | Use Case |
|-----|---------|-----------|------------|----------|
| `onboarding01Title` | onboarding | 01 (step) | Title | Screen header |
| `onboarding02CalloutBody` | onboarding | 02Callout | Body | Info box text |
| `authLoginButton` | auth | Login | Button | Button label |
| `dashboardGreeting` | dashboard | - | Greeting | Welcome message |
| `consentOptionsTitle` | consent | Options | Title | Consent screen header |

### Common Descriptors

| Descriptor | Purpose | Example |
|------------|---------|---------|
| `Title` | Screen/section headers | `onboarding01Title` |
| `Instruction` | User guidance text | `onboarding01Instruction` |
| `Hint` | Input placeholder text | `onboarding01NameHint` |
| `Semantic` | Accessibility labels | `onboarding01NameInputSemantic` |
| `Label` | UI element labels | `selectedDateLabel` |
| `Button` | Button text | `authLoginButton` |
| `Body` | Paragraph content | `onboarding02CalloutBody` |
| `Callout` | Info box content | `onboarding02CalloutSemantic` |
| `Error` | Error messages | `authErrInvalidEmail` |

## Workflow: Adding New Keys

### Step 1: Add to Base ARB (English)

File: `lib/l10n/app_en.arb`

```json
{
  "featureComponentDescription": "English text content",
  "@featureComponentDescription": {
    "description": "Context for translators: where and why this text is used"
  }
}
```

**Real Example:**
```json
{
  "onboarding01Title": "Welcome!\nWhat should we call you?",
  "@onboarding01Title": {
    "description": "Header title for onboarding step 1 (Figma v3). Contains forced line break."
  }
}
```

### Step 2: Add to German ARB

File: `lib/l10n/app_de.arb`

```json
{
  "featureComponentDescription": "Deutscher Text",
  "@featureComponentDescription": {
    "description": "Context for translators: where and why this text is used"
  }
}
```

**Real Example:**
```json
{
  "onboarding01Title": "Willkommen!\nWie dürfen wir dich nennen?",
  "@onboarding01Title": {
    "description": "Header title for onboarding step 1 (Figma v3). Contains forced line break."
  }
}
```

### Step 3: Regenerate Localization

```bash
flutter gen-l10n
```

This generates `lib/l10n/app_localizations.dart` with type-safe accessors.

### Step 4: Use in Code (MUST-03)

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In widget build method
final l10n = AppLocalizations.of(context)!;

Text(l10n.featureComponentDescription)
```

**Real Example:**
```dart
final l10n = AppLocalizations.of(context)!;

Text(
  l10n.onboarding01Title,
  style: TextStyle(fontSize: 24),
)
```

## Parameterized Strings

### Single Parameter

**ARB Definition:**
```json
{
  "onboarding02Title": "Hey {name},\nwhen is your birthday?",
  "@onboarding02Title": {
    "description": "Personalized header title for onboarding step 2.",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Usage in Code:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.onboarding02Title('Maria'))  // "Hey Maria,\nwhen is your birthday?"
```

### Multiple Parameters

**ARB Definition:**
```json
{
  "onboardingStepSemantic": "Step {current} of {total}",
  "@onboardingStepSemantic": {
    "description": "Spoken step indicator for onboarding progress.",
    "placeholders": {
      "current": {
        "type": "int"
      },
      "total": {
        "type": "int"
      }
    }
  }
}
```

**Usage in Code:**
```dart
final l10n = AppLocalizations.of(context)!;
Semantics(
  label: l10n.onboardingStepSemantic(2, 5),  // "Step 2 of 5"
  child: ProgressIndicator(current: 2, total: 5),
)
```

## Plural Forms (ICU MessageFormat)

### Plural with Count Display

**ARB Definition:**
```json
{
  "authErrWaitBeforeRetry": "Please wait {seconds, plural, one {# second} other {# seconds}} before retrying.",
  "@authErrWaitBeforeRetry": {
    "description": "Message advising user to wait before retrying. Uses ICU plural formatting.",
    "placeholders": {
      "seconds": {
        "type": "int"
      }
    }
  }
}
```

**Usage in Code:**
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.authErrWaitBeforeRetry(30))  // "Please wait 30 seconds before retrying."
Text(l10n.authErrWaitBeforeRetry(1))   // "Please wait 1 second before retrying."
```

### Complex Plural with Custom Text

**ARB Definition:**
```json
{
  "notificationsWithBadgeCount": "{count, plural, one {Notifications, {count} new} other {Notifications, {count} new}}",
  "@notificationsWithBadgeCount": {
    "description": "Semantics label for notifications icon with unread count badge.",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

**Usage in Code:**
```dart
final l10n = AppLocalizations.of(context)!;
Semantics(
  label: l10n.notificationsWithBadgeCount(3),  // "Notifications, 3 new"
  child: NotificationIcon(badgeCount: 3),
)
```

## Special Cases

### Line Breaks

Use `\n` for forced line breaks (common in Figma designs):

```json
{
  "onboarding01Title": "Welcome!\nWhat should we call you?"
}
```

### Accessibility-Only Text

Keys ending with `Semantic` are typically used for screen readers:

```json
{
  "onboarding01NameInputSemantic": "Enter your name",
  "@onboarding01NameInputSemantic": {
    "description": "Semantics label for the name input field on step 1."
  }
}
```

**Usage:**
```dart
Semantics(
  label: l10n.onboarding01NameInputSemantic,
  child: TextField(
    decoration: InputDecoration(
      hintText: l10n.onboarding01NameHint,  // Visual hint
    ),
  ),
)
```

### Callouts and Info Boxes

Use separate keys for callout semantics and body text:

```json
{
  "onboarding02CalloutSemantic": "Note: Your age helps us better understand your hormonal phase.",
  "onboarding02CalloutBody": "Your age helps us better understand your hormonal phase."
}
```

## MUST-03 Compliance

### Rule: All user-facing text via AppLocalizations

**Enforcement:** Audit-test (automated checks)

```dart
// ❌ WRONG - violates MUST-03
Text('Welcome to LUVI')
Text("Enter your name")
TextField(decoration: InputDecoration(hintText: 'Your name'))

// ✅ CORRECT - follows MUST-03
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcomeTitle)
Text(l10n.nameInstruction)
TextField(decoration: InputDecoration(hintText: l10n.nameHint))
```

### Exception: Developer-Facing Text

Only non-user-facing text may be hardcoded:
- Log messages (use logger, not L10n)
- Debug strings
- Code comments
- Technical identifiers

## ARB File Best Practices

### 1. Always Add Descriptions

**Good - has translator context:**
```json
{
  "authLoginButton": "Log in",
  "@authLoginButton": {
    "description": "Button label for login action on auth screen."
  }
}
```

**Bad - missing description:**
```json
{
  "authLoginButton": "Log in"
}
```

### 2. Specify Placeholder Types

**Good - typed placeholder:**
```json
{
  "greetingWithName": "Hello, {name}!",
  "@greetingWithName": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Bad - missing type definition:**
```json
{
  "greetingWithName": "Hello, {name}!"
}
```

### 3. Keep Keys Consistent

Both `app_en.arb` and `app_de.arb` must have:
- Same key names
- Same placeholder names
- Same metadata structure

## Common Mistakes

| Mistake | Violation | Fix |
|---------|-----------|-----|
| `Text('Sign Up')` | MUST-03, hardcoded string | `Text(l10n.authSignupButton)` |
| `TextField(hintText: 'Email')` | MUST-03, hardcoded hint | `TextField(decoration: InputDecoration(hintText: l10n.emailHint))` |
| Key: `login_button` | Naming convention (snake_case) | `loginButton` (camelCase) |
| Missing `@description` | Translator context | Add `"@keyName": {"description": "..."}` |
| Forgot `flutter gen-l10n` | Code doesn't compile | Run command after ARB changes |
| German key `anmelden`, English `loginButton` | Inconsistent keys | Use same key name in both languages |
| Placeholder type `"type": "string"` | Wrong case | Use `"type": "String"` (capital S) |

## Testing L10n Keys

### Widget Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

testWidgets('displays localized title', (tester) async {
  await tester.pumpWidget(buildTestApp(MyScreen()));

  // Test English (default)
  expect(find.text('Welcome!'), findsOneWidget);

  // Test German
  await tester.pumpWidget(buildTestApp(
    MyScreen(),
    locale: Locale('de'),
  ));
  expect(find.text('Willkommen!'), findsOneWidget);
});
```

### Check for Missing Keys

```bash
# Find hardcoded strings in lib/ (potential MUST-03 violations)
grep -rn "Text(['\"]" lib/ --include="*.dart" | grep -v "l10n\."
```

## Quick Reference: File Locations

### Localization Files
- **English Base:** [lib/l10n/app_en.arb](../../lib/l10n/app_en.arb)
- **German:** [lib/l10n/app_de.arb](../../lib/l10n/app_de.arb)
- **Generated (DO NOT EDIT):** [lib/l10n/app_localizations.dart](../../lib/l10n/app_localizations.dart)

### Configuration
- **L10n Config:** [l10n.yaml](../../l10n.yaml)
- **Pubspec:** [pubspec.yaml](../../pubspec.yaml) (flutter_localizations dependency)

### Rules & Enforcement
- **MUST-03:** [CLAUDE.md](../../CLAUDE.md) (L10n first rule)
- **Audit Tests:** Automated checks for hardcoded strings

### Examples
- **Onboarding Screens:** [lib/features/onboarding/screens/](../../lib/features/onboarding/screens/)
- **Consent Screen:** [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart)
- **Auth Screens:** [lib/features/auth/screens/](../../lib/features/auth/screens/)

## Generation Command Reference

### Generate Localization Files
```bash
# Standard generation (run after ARB changes)
flutter gen-l10n

# Clean and regenerate
flutter clean && flutter pub get && flutter gen-l10n
```

### Verify Generation
```bash
# Check generated file exists
ls -lh lib/l10n/app_localizations.dart

# Count generated keys
grep "String get" lib/l10n/app_localizations.dart | wc -l
```

## Reference Files (SSOT)

**Primary Sources:**
- ARB Files: [lib/l10n/app_en.arb](../../lib/l10n/app_en.arb), [lib/l10n/app_de.arb](../../lib/l10n/app_de.arb)
- MUST-03: [CLAUDE.md](../../CLAUDE.md) (L10n first rule)
- Config: [l10n.yaml](../../l10n.yaml)

**Related:**
- UI Frontend Agent: [.claude/agents/ui-frontend.md](../../.claude/agents/ui-frontend.md)
- Onboarding Screens: [lib/features/onboarding/screens/](../../lib/features/onboarding/screens/)
- Widget Test Skill: [.claude/skills/widget-test/SKILL.md](../widget-test/SKILL.md)

## External References
- [Flutter Internationalization](https://docs.flutter.dev/accessibility-and-localization/internationalization)
- [ICU MessageFormat](https://unicode-org.github.io/icu/userguide/format_parse/messages/)
- [ARB File Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
