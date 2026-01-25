---
name: a11y-audit
description: Use when auditing screens for accessibility compliance (Semantics, touch targets ≥44dp)
---

# A11y Audit Skill

## When to Use

- Reviewing new screens for accessibility before PR submission
- Auditing button/toggle semantics (button: true, toggled: selected)
- Verifying touch targets ≥44dp (Sizes.touchTargetMin)
- Checking screen reader compatibility (VoiceOver/TalkBack)
- Validating header semantics (header: true)
- Ensuring image semantics (decorative images excluded)
- Pre-PR quality gate for user-facing UI
- Keywords: "accessibility", "A11y", "Semantics", "WCAG", "touch target", "screen reader", "VoiceOver", "TalkBack"

## When NOT to Use

- Pure design token audits (use `ui-polisher` agent for DsColors, Spacing)
- Color contrast checks (use `ui-polisher` agent for WCAG AA contrast)
- Typography audits (use `ui-polisher` agent for font sizes, line heights)
- Database/RLS policy creation (use `reqing-ball` agent)
- Privacy compliance (use `privacy-audit` or `qa-reviewer`)
- One-off stateless logic or helper functions

## LUVI A11y Architecture

### MUST-05 Rule (from CLAUDE.md)

**Rule:** All interactive elements need `Semantics` labels + touch targets ≥44dp

**Enforcement:** Widget tests + manual testing with VoiceOver/TalkBack

```dart
// ✅ Correct - Button with semantics + 44dp touch target
Semantics(
  label: l10n.backButtonLabel,
  button: true,
  child: IconButton(
    constraints: BoxConstraints(
      minWidth: Sizes.touchTargetMin,  // 44.0
      minHeight: Sizes.touchTargetMin,
    ),
    onPressed: onBack,
    icon: Icon(Icons.arrow_back),
  ),
)

// ❌ Wrong - Missing semantics, touch target too small
IconButton(
  onPressed: onBack,
  icon: Icon(Icons.arrow_back, size: 24),  // Only 24dp!
)
```

### Scope Clarity: a11y-audit vs ui-polisher

| Concern | Skill/Agent | Responsibility | Examples |
|---------|-------------|----------------|----------|
| **Semantics** | a11y-audit | `Semantics(label: ...)`, screen reader | button, header, toggled, selected |
| **Touch Targets** | a11y-audit | `≥44dp` enforcement | `Sizes.touchTargetMin`, ConstrainedBox |
| **Design Tokens** | ui-polisher | `DsColors.*`, `Spacing.*` | Color consistency, spacing values |
| **Contrast** | ui-polisher | WCAG AA color contrast | Text vs background |
| **Typography** | ui-polisher | Font sizes, line heights | `FontFamilies.*`, `TypographyTokens.*` |

**Key Insight:** ui-polisher handles **visual/design compliance**; a11y-audit handles **semantic/interaction accessibility**.

---

## Semantics Patterns

### Pattern 1: Button Semantics (Interactive Elements)

**Use Case:** Buttons, taps, interactive widgets

**From:** [lib/features/auth/widgets/rebrand/auth_back_button.dart](../../lib/features/auth/widgets/rebrand/auth_back_button.dart):31-34

```dart
Semantics(
  label: l10n.backButtonLabel,  // ✅ L10n key (MUST-03)
  button: true,                 // ✅ Announces as "button"
  child: ExcludeSemantics(      // ✅ Prevents duplicate announcements
    child: IconButton(
      constraints: BoxConstraints(
        minWidth: Sizes.touchTargetMin,
        minHeight: Sizes.touchTargetMin,
      ),
      onPressed: () => context.pop(),
      icon: SvgPicture.asset(Assets.icons.authBackChevron),
    ),
  ),
)
```

**Why ExcludeSemantics on child?**
- IconButton has default semantics → would announce twice
- Wrap child with `ExcludeSemantics` to prevent duplication
- Parent `Semantics` provides custom label

---

### Pattern 2: Header Semantics (Screen Titles)

**Use Case:** Screen titles, section headers

**From:** [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart):461-473

```dart
Semantics(
  header: true,  // ✅ Announces as "heading" (screen reader navigation)
  child: Text(
    l10n.consentOptionsTitle,
    textAlign: TextAlign.center,
    style: theme.textTheme.headlineMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      fontFamily: FontFamilies.playfairDisplay,
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

**From:** [lib/features/welcome/screens/welcome_screen.dart](../../lib/features/welcome/screens/welcome_screen.dart):397-403

```dart
Semantics(
  header: true,
  child: Text(
    title,
    textAlign: TextAlign.center,
    style: titleStyle,
  ),
)
```

**Why header: true?**
- Screen readers use headers for navigation (swipe between sections)
- Improves VoiceOver rotor navigation
- Semantic hierarchy (h1 → h2 → h3 in HTML equivalent)

---

### Pattern 3: Toggle Semantics (Checkboxes, Switches)

**Use Case:** Checkboxes, switches, toggle buttons

**From:** [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart):351-354

```dart
final semanticLabel = selected
    ? l10n.consentOptionsCheckboxSelectedSemantic(
        semanticSection,
        resolvedSemanticText,
      )
    : l10n.consentOptionsCheckboxUnselectedSemantic(
        semanticSection,
        resolvedSemanticText,
      );

Semantics(
  label: semanticLabel,  // ✅ Dynamic label with state
  button: true,          // ✅ Announces as "button"
  toggled: selected,     // ✅ Announces "selected" or "not selected"
  child: InkWell(
    onTap: () {
      HapticFeedback.selectionClick();
      onTap();
    },
    borderRadius: BorderRadius.circular(Sizes.radiusM),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Sizes.touchTargetMin),
      child: Row(...),
    ),
  ),
)
```

**Critical:**
- `button: true` + `toggled: selected` → VoiceOver announces "selected, button" or "not selected, button"
- Dynamic `label` includes state context (e.g., "Required, Health data processing, selected")

---

### Pattern 4: TextField Semantics (Input Fields)

**Use Case:** Text inputs, search fields, form fields

**Generic Pattern** (inferred from LUVI patterns):

```dart
Semantics(
  label: l10n.nameInputSemantic,    // ✅ "Enter your name"
  textField: true,                  // ✅ Announces as "text field"
  child: TextField(
    decoration: InputDecoration(
      hintText: l10n.nameHint,      // ✅ Visual hint (not semantic)
    ),
  ),
)
```

**Why separate label and hintText?**
- `Semantics.label`: Screen reader announcement (brief instruction)
- `hintText`: Visual placeholder (can be longer)
- Both should use L10n keys (MUST-03)

---

### Pattern 5: Selected State Semantics (Navigation, Tabs)

**Use Case:** Bottom navigation, tabs, selected items

**Generic Pattern** (inferred from bottom nav best practices):

```dart
Semantics(
  label: l10n.homeTabSemantic,  // ✅ "Home"
  button: true,
  selected: isSelected,          // ✅ Announces "selected" if active
  child: GestureDetector(
    onTap: () => onTabChanged(0),
    child: Column(
      children: [
        Icon(Icons.home, color: isSelected ? DsColors.primary : DsColors.gray),
        Text(l10n.homeTab),
      ],
    ),
  ),
)
```

**Critical:**
- `selected: true` → VoiceOver announces "selected, button"
- Use for navigation items, tabs, filters

---

### Pattern 6: Image Semantics (Decorative vs Informative)

**Use Case:** Distinguish images that convey information vs decoration

**From:** [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart):448-457

**Informative Image:**
```dart
Semantics(
  label: l10n.consentOptionsShieldSemantic,  // ✅ "Security shield icon"
  child: Image.asset(
    Assets.consentImages.consentShield,
    width: ConsentSpacing.shieldIconWidth,
    height: ConsentSpacing.shieldIconHeight,
    fit: BoxFit.contain,
  ),
)
```

**From:** [lib/features/welcome/screens/welcome_screen.dart](../../lib/features/welcome/screens/welcome_screen.dart):117-122

**Decorative Image:**
```dart
ExcludeSemantics(  // ✅ Screen reader skips this
  child: Image.asset(
    Assets.images.welcomeHero02,
    fit: BoxFit.cover,
  ),
)
```

**Decision Matrix:**
- **Informative image** (conveys meaning): Use `Semantics(label: ...)`
- **Decorative image** (visual only): Use `ExcludeSemantics()`

---

## Touch Target Patterns

### WCAG / iOS HIG Requirement

**Minimum touch target:** 44dp × 44dp (iOS HIG, WCAG 2.1 AA Success Criterion 2.5.5)

**LUVI Constant:** `Sizes.touchTargetMin = 44.0` (from [lib/core/design_tokens/sizes.dart](../../lib/core/design_tokens/sizes.dart):37)

```dart
static const double touchTargetMin = 44.0; // iOS HIG / WCAG minimum tap target
```

---

### Pattern 1: ConstrainedBox for Custom Buttons

**Use Case:** Custom tap areas (InkWell, GestureDetector)

**From:** [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart):361-362

```dart
Semantics(
  label: semanticLabel,
  button: true,
  toggled: selected,
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Sizes.radiusM),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Sizes.touchTargetMin),  // ✅ 44dp
      child: Row(
        children: [
          Expanded(child: Text(text)),
          _ConsentCircleCheckbox(selected: selected),
        ],
      ),
    ),
  ),
)
```

**Pattern:**
1. Wrap interactive child with `ConstrainedBox`
2. Set `minHeight: Sizes.touchTargetMin`
3. Ensure `minWidth` is also ≥44dp (or full-width)

---

### Pattern 2: IconButton Constraints

**Use Case:** Icon buttons without text labels

**From:** [lib/features/auth/widgets/rebrand/auth_back_button.dart](../../lib/features/auth/widgets/rebrand/auth_back_button.dart):49-52

```dart
IconButton(
  constraints: BoxConstraints(
    minWidth: Sizes.touchTargetMin,   // ✅ 44dp
    minHeight: Sizes.touchTargetMin,  // ✅ 44dp
  ),
  onPressed: () => context.pop(),
  icon: SvgPicture.asset(
    Assets.icons.authBackChevron,
    width: Sizes.authBackIconSize,  // 32dp (visual size)
  ),
)
```

**Why constraints?**
- Icon size (32dp) is smaller than touch target requirement (44dp)
- `constraints` parameter ensures button area is ≥44dp
- Visual icon can be smaller than touch area

---

### Pattern 3: TextButton MinimumSize

**Use Case:** Text-only buttons

**Generic Pattern:**

```dart
TextButton(
  style: TextButton.styleFrom(
    minimumSize: Size(Sizes.touchTargetMin, Sizes.touchTargetMin),  // ✅ 44dp
  ),
  onPressed: onPressed,
  child: Text(l10n.buttonLabel),
)
```

---

### Pattern 4: SizedBox for Fixed Touch Areas

**Use Case:** Fixed-size interactive elements

**Generic Pattern:**

```dart
SizedBox(
  width: Sizes.touchTargetMin,   // ✅ 44dp
  height: Sizes.touchTargetMin,  // ✅ 44dp
  child: GestureDetector(
    onTap: onTap,
    child: Center(
      child: Icon(Icons.close, size: 24),  // Visual size 24dp
    ),
  ),
)
```

---

## Audit Checklists

### Checklist 1: Semantics Audit

- [ ] All buttons have `Semantics(button: true, ...)`
- [ ] Screen titles have `Semantics(header: true, ...)`
- [ ] Toggles/checkboxes have `toggled: selected` state
- [ ] Selected items (nav/tabs) have `selected: true` state
- [ ] Form fields have `Semantics(textField: true, ...)`
- [ ] Informative images have `Semantics(label: ...)`
- [ ] Decorative images wrapped in `ExcludeSemantics()`
- [ ] No duplicate announcements (use `ExcludeSemantics` on children)
- [ ] All semantics labels use `AppLocalizations` (MUST-03)

---

### Checklist 2: Touch Target Audit

- [ ] All interactive elements ≥44dp (Sizes.touchTargetMin)
- [ ] IconButton uses `constraints` parameter for touch area
- [ ] Custom buttons (InkWell/GestureDetector) wrapped in `ConstrainedBox`
- [ ] TextButton uses `minimumSize` parameter
- [ ] No GestureDetector without minimum size enforcement
- [ ] Close buttons, back buttons ≥44dp
- [ ] Checkbox/toggle touch area ≥44dp (entire row tappable)

---

### Checklist 3: Widget Test Audit

- [ ] Widget test verifies `Semantics` labels present
- [ ] Widget test checks `button: true` for buttons
- [ ] Widget test checks `header: true` for titles
- [ ] Widget test checks `toggled` state for checkboxes
- [ ] Widget test checks `selected` state for navigation
- [ ] Touch target dimensions verified in tests

**Test Pattern:**

```dart
testWidgets('consent checkbox has correct semantics', (tester) async {
  await tester.pumpWidget(buildTestApp(ConsentOptionsScreen()));

  final handle = tester.ensureSemantics();

  // Find checkbox by key
  final checkbox = find.byKey(Key('consent_options_health'));
  expect(checkbox, findsOneWidget);

  // Verify semantics
  final semantics = tester.getSemantics(checkbox);
  expect(semantics.label, contains('Health data processing'));
  expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
  expect(semantics.hasFlag(SemanticsFlag.isToggled), isFalse);  // Initially unselected

  handle.dispose();
});
```

---

## Audit Commands (Grep)

### Find Missing Button Semantics

```bash
# Search for IconButton without Semantics wrapper
grep -rn "IconButton(" lib/ --include="*.dart" -A 5 | grep -v "Semantics("
```

### Find Small Touch Targets

```bash
# Find IconButton without constraints parameter
grep -rn "IconButton(" lib/ --include="*.dart" -A 10 | grep -v "constraints:"
```

### Find Hardcoded English in Semantics

```bash
# Find Semantics with hardcoded strings (violates MUST-03)
grep -rn "Semantics(" lib/ --include="*.dart" -A 3 | grep "label: \"" | grep -v "l10n\\."
```

### Find Images Without Semantics

```bash
# Find Image.asset without Semantics or ExcludeSemantics
grep -rn "Image.asset(" lib/ --include="*.dart" -B 2 | grep -v "Semantics("
```

### Find GestureDetector Without Size

```bash
# Find GestureDetector without ConstrainedBox wrapper
grep -rn "GestureDetector(" lib/ --include="*.dart" -B 2 | grep -v "ConstrainedBox("
```

---

## Widget Test Patterns

### Pattern 1: Semantics Label Test

```dart
import 'package:flutter_test/flutter_test.dart';

testWidgets('back button has semantics label', (tester) async {
  await tester.pumpWidget(buildTestApp(AuthBackButton()));

  final handle = tester.ensureSemantics();

  final backButton = find.byType(IconButton);
  expect(backButton, findsOneWidget);

  final semantics = tester.getSemantics(backButton);
  expect(semantics.label, 'Zurück');  // German L10n key
  expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);

  handle.dispose();
});
```

### Pattern 2: Touch Target Dimensions Test

```dart
testWidgets('button touch target is ≥44dp', (tester) async {
  await tester.pumpWidget(buildTestApp(MyScreen()));

  final button = find.byKey(Key('my_button'));
  expect(button, findsOneWidget);

  final size = tester.getSize(button);
  expect(size.width, greaterThanOrEqualTo(44.0));
  expect(size.height, greaterThanOrEqualTo(44.0));
});
```

---

## Common Mistakes

| Mistake | Severity | Fix | Source File |
|---------|----------|-----|-------------|
| Missing `button: true` on buttons | High | Add `Semantics(button: true, ...)` | auth_back_button.dart:33 (good example) |
| Hardcoded English in Semantics | Medium | Use `AppLocalizations.of(context)!.xxx` | MUST-03 violation |
| IconButton without constraints | High | Add `constraints: BoxConstraints(minWidth: 44, minHeight: 44)` | auth_back_button.dart:49-52 (good example) |
| Duplicate announcements | Medium | Wrap child with `ExcludeSemantics` | auth_back_button.dart:34 (good example) |
| GestureDetector without size | High | Wrap with `ConstrainedBox(minHeight: 44)` | Common pitfall |
| Missing `header: true` on titles | Medium | Add `Semantics(header: true, ...)` | consent_options_screen.dart:461 (good example) |
| Decorative images without ExcludeSemantics | Low | Wrap with `ExcludeSemantics` | welcome_screen.dart:117 (good example) |

---

## Integration with Agents/Skills

### Workflow: UI Implementation → A11y Audit → Polish

1. **ui-frontend agent** → Implements screen with design tokens
2. **a11y-audit skill** → Audits semantics + touch targets (this skill)
3. **ui-polisher agent** → Audits design tokens, contrast, typography
4. **widget-test skill** → Adds tests for semantics and touch targets

**Complementary Skills:**
- **l10n-keys skill**: Ensures semantics labels use L10n keys (MUST-03)
- **privacy-audit skill**: Ensures no PII in semantics labels
- **ui-polisher agent**: Handles visual/design compliance (scope separation)

**When to Use a11y-audit:**
- **After:** ui-frontend completes screen implementation
- **Before:** ui-polisher runs final quality gate
- **Always:** Before PR submission for user-facing UI

---

## Quick Reference: File Locations

### Example Files (SSOT)

**Button Semantics:**
- [lib/features/auth/widgets/rebrand/auth_back_button.dart](../../lib/features/auth/widgets/rebrand/auth_back_button.dart) (Lines 31-55)

**Header Semantics:**
- [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart) (Lines 461-473)
- [lib/features/welcome/screens/welcome_screen.dart](../../lib/features/welcome/screens/welcome_screen.dart) (Lines 397-403)

**Toggle Semantics:**
- [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart) (Lines 351-394)

**Image Semantics:**
- [lib/features/consent/screens/consent_options_screen.dart](../../lib/features/consent/screens/consent_options_screen.dart) (Lines 448-457)
- [lib/features/welcome/screens/welcome_screen.dart](../../lib/features/welcome/screens/welcome_screen.dart) (Lines 117-122)

**Touch Target Constants:**
- [lib/core/design_tokens/sizes.dart](../../lib/core/design_tokens/sizes.dart) (Line 37)

### Rules & Governance

- **MUST-05:** [CLAUDE.md](../../CLAUDE.md) (Semantics + touch target ≥44dp)
- **Scope Definition:** [context/agents/ui-polisher.md](../../context/agents/ui-polisher.md)

### Related Agents/Skills

- **ui-polisher agent:** Design token audits (complementary)
- **l10n-keys skill:** L10n key management (MUST-03)
- **widget-test skill:** A11y test patterns
- **privacy-audit skill:** PII in semantics labels

---

## Reference Files (SSOT)

**Primary Sources:**
- CLAUDE.md - MUST-05 rule (Semantics + touch target ≥44dp)
- auth_back_button.dart - Button semantics + ExcludeSemantics + touch target constraints
- consent_options_screen.dart - Header + toggle + image semantics, ConstrainedBox pattern
- welcome_screen.dart - Header semantics, ExcludeSemantics for decorative images
- sizes.dart - Touch target constant (Sizes.touchTargetMin = 44.0)

**Related:**
- ui-polisher agent - Design token audits (scope separation)
- l10n-keys skill - L10n compliance for semantics labels (MUST-03)
- widget-test skill - A11y test patterns
- privacy-audit skill - Security patterns (no PII in semantics)

---

## External References

- [WCAG 2.1 Success Criterion 2.5.5 (Target Size)](https://www.w3.org/WAI/WCAG21/Understanding/target-size.html)
- [iOS Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Flutter Semantics Class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [Flutter Accessibility Testing](https://docs.flutter.dev/testing/accessibility-and-localization)
