# Flutter Analyze

Run Flutter analysis and fix all errors.

```bash
scripts/flutter_codex.sh analyze
```

## On Errors:
1. Read the error message
2. Navigate to the affected file
3. Fix the error
4. Repeat until no errors remain

**Severity:** Errors (blocking) > Warnings (should fix) > Info (style)
**Cadence:** Fix blocking errors immediately; batch style fixes.
**Priority:** Security → Compilation → Runtime → Style

## Common Fixes:
- `unused_import` → Remove import
- `prefer_const_constructors` → Add `const`
- `missing_required_param` → Add argument (legacy)
- `missing_required_argument` → Add argument
- `avoid_print` → Use `log` facade
- `prefer_final_fields` → Add `final`
- `use_key_in_widget_constructors` → Add `super.key`
- `unnecessary_null_comparison` → Remove null check
- `prefer_single_quotes` → Use single quotes
- `always_use_package_imports` → Use `package:luvi_app/...`
