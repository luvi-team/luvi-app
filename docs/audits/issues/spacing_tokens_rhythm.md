# Tracking Issue: Add spacing tokens `rhythm/90` and `rhythm/24`

- Labels: design-token, spacing
- Source: docs/audits/ONB_07_figma_specs.md:186
- Status: Open
- Created: 2025-10-01 audit follow-up (documented via Codex CLI)

## Background
Figma specs for onboarding (see audit source above) reference spacing tokens named `rhythm/90` (used four times across screen headers) and `rhythm/24` (option gap value). These tokens are not yet defined in `lib/core/tokens/spacing.dart`, so engineers hard-code equivalents, causing drift from the shared design language.

## Tasks
- [ ] Define `rhythm90` (alias for the `rhythm/90` token, expected 90.0 px) in `lib/core/tokens/spacing.dart`.
- [ ] Define `rhythm24` (alias for the `rhythm/24` token, expected 24.0 px) in the same file.
- [ ] Document intended usage in code comments (e.g., `OnboardingSpacing.headerToFirstOption06`, option gaps) and update consumers to use the new tokens instead of literal values.
- [ ] Align naming with the existing spacing token conventions (confirm whether the slash-styled Figma name should map to camelCase `rhythm90` or another agreed format).
- [ ] After adoption, remove obsolete hard-coded values from the onboarding layout helpers.

## References & Notes
- Figma spacing scale: `rhythm/90` corresponds to 90 px vertical spacing around onboarding hero content; `rhythm/24` is the 24 px gap between selectable cards.
- Related audit: docs/audits/ONB_07_figma_specs.md (Spacing Tokens section).
- Owners: assign to design system/front-end pairing; tag with `design-token` and `spacing` labels when creating the GitHub issue.
