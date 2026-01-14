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

## Common Fixes:
- `unused_import` → Remove import
- `prefer_const_constructors` → Add `const`
- `missing_required_param` → Add parameter
