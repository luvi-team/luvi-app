# Figma Screen Implementation

Implement a screen based on Figma design.

## Input: $ARGUMENTS
- Screenshot path OR
- Design description

## Workflow:
1. **Analyze** the design (colors, spacing, layout)
2. **Search tokens** in:
   - `lib/core/design_tokens/colors.dart`
   - `lib/core/design_tokens/spacing.dart`
   - `lib/core/design_tokens/sizes.dart`
   - `lib/core/design_tokens/typography.dart`
3. **Create missing tokens** with `/// Figma: xxx` comment
4. **Implement** the screen
5. **Create Widget Test**
6. **Run**: `scripts/flutter_codex.sh analyze`
