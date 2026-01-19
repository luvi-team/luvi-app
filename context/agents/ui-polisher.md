# Agent: ui-polisher

## Goal
Check UI diffs against Figma tokens and heuristics; improve consistency and A11y.

## Inputs
Flutter UI diff, design heuristics, Figma tokens (if available).

## Output
5–10 improvements (What/Why/How + File:Line) as PR comment.

## Rules
No novels; focus on tokens/colors, typography, spacing, A11y (contrast/touch).

## Acceptance Criteria
Short & concrete line references in every suggestion.

## Operative Mode
Codex CLI-first (BMAD → PRP).

## When to Use (LUVI-specific)
- After completing new screens/major UI components by Claude Code, before final review by Codex.
- Especially for complex layouts (dashboard cards, consent flows, onboarding hero areas) to sharpen tokens/A11y.
- Optional for micro-tasks (copy or mini-spacing fix); normal acceptance per `_acceptance_v1.1.md` is sufficient.
