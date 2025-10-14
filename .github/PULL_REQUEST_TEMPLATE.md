## Summary
<Kurzbeschreibung der Änderung>

## Assistenten-Antwort (CLI – verbindlich)
Siehe `docs/engineering/assistant-answer-format.md`.

- Mini‑Kontext‑Check:
- Warum:
- Schritte:
- Erfolgskriterien:
- Undo/Backout: (nur als Code‑Block)
- Nächster minimaler Schritt:
- Stop‑Kriterien:

## Babysitting-Level
- [ ] Low
- [ ] Medium
- [ ] High

## AI Pre-Commit
- [ ] durchgeführt
- Notiz (optional):

## AI Post-Commit
- [ ] zusammengefasst
- Notiz (optional):

## DSGVO-Review
- [ ] aktualisiert: docs/privacy/reviews/<id>.md

## Traycer Trial (non-blocking)
- Traycer-Plan (Link/Text):
- Traycer-Self-Check (✅/❌):
- Risiken (Stichworte):

- [ ] Traycer Privacy Mode ON
- [ ] Keine PII/Secrets in Plan/PR

## ADR-Referenzen
- 0001 RAG-First
- 0002 RLS
- 0003 MIWF

## RLS-Check
- [ ] Policies 4x (SELECT/INSERT/UPDATE/DELETE)
- [ ] auth.uid()
- [ ] kein service_role im Client
- [ ] keine PII-Logs

## Checkliste
- [ ] Antwortformat (CLI) eingehalten: Mini‑Kontext, Warum, Schritte, Erfolgskriterien, Undo/Backout (Code‑Block), Nächster Schritt, Stop‑Kriterien
- [ ] CI/DoD geprüft (flutter analyze/test; Privacy‑Gate falls DB)
- [ ] CodeRabbit „green“ oder Findings adressiert
