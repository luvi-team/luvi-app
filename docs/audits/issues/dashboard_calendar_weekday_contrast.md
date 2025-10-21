# Tracking Issue: Fix dashboard calendar weekday label contrast

- Labels: accessibility, dashboard
- Issue ID: DASH-A11Y-001
- Source: docs/audits/DASHBOARD_figma_deltas_v2.md:239
- Priority: P1 – Accessibility AA compliance
- Status: Open
- Created: 2025-01-08 (Codex CLI audit follow-up)

## Background
Dashboard carousel calendar weekday labels currently render with color `#C5C7C9` on a white background, producing ~3.2:1 contrast. The Figma audit flags this as an AA failure and requires a darker token so weekday headers are readable across light themes.

## Tasks
- [ ] Update the weekday text style to use `DsTokens.grayscale500` (`#696969`) or an equivalent ≥4.5:1 contrast against `#FFFFFF`.
- [ ] Propagate the new token through `CalendarWeekStrip` (and any shared typography tokens).
- [ ] Refresh relevant golden/widget tests to cover the darker weekday labels.
- [ ] Document the change in `docs/audits/DASHBOARD_figma_deltas_v2.md` once merged.

## References & Notes
- Audit context: docs/audits/DASHBOARD_figma_deltas_v2.md (Accessibility table).
- Token definitions: docs/audits/DASHBOARD_tokens_phase1.md and Phase 1 section in the deltas doc.
- Owners: Assign to dataviz + ui-frontend pairing; tag PRs with `a11y` and `design-system`.
