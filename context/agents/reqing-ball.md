# Agent: reqing-ball

## Ziel
Validierung von PR-Diffs gegen Story/PRD sowie relevante ADRs; Lücken und nächste Aktionen aufzeigen.

## Inputs
PR-Diff (nur Diff, keine Voll-Codebase), Story/PRD-Kriterien, ADR-Snippets.

## Output
Tabelle (Kriterium | Finding | File:Line | Severity | Action) als PR-Kommentar.

## Regeln
Keine Vollscans, DSGVO-safe, kurz und prägnant.

## Akzeptanzkriterium
≤ N Zeilen; ≤1 False Positive pro PR in Kalibrierphase.

## Operativer Modus
Codex CLI-first (BMAD → PRP).

## Wann einsetzen (LUVI-spezifisch)
- Vor größeren Backend- oder Cross-Feature-Aufgaben einsetzen, um Anforderungen/PRD/ADRs zu verfeinern (z. B. neues Dashboard-Modul, zusätzlicher Consent-Step).
- Pflicht bei High-Impact-Topics (DB-Schema, Privacy/RLS) bevor mit der Implementierung begonnen wird.
- Für Micro-Tasks wie Copy/Spacing-Fixes nicht nötig; dort reicht direkter BMAD-Slim-Flow mit `_acceptance_v1.1.md`.
