# Traycer – Leichte Einführung (Trial)

Ziel: Traycer als Plan-/Frühreview‑Ergänzung nutzen, ohne Branch‑Protection zu ändern. Soft‑Gate via Labels, klare Hand‑offs an Codex/Claude.

## Wie wir Traycer nutzen (Plan → Umsetzen → Self‑Check)
- Plan (Traycer): In der IDE (Cursor) einen Plan oder Phasenplan erstellen/iterieren; bei Bedarf mit „plan:traycer“ labeln (Issue/PR‑Kontext).
- Umsetzen (Codex/Claude): Den finalen Plan an Codex/Claude übergeben (BMAD → PRP), kleinste Schritte, Tests/Privacy beachten.
- Self‑Check (Traycer Review): Vor „Ready for review“ den Traycer‑Self‑Check ausführen und im PR ausfüllen.

Empfehlung: PRs für den Trial mit `trial-traycer` labeln. Traycer bleibt nicht‑blockierend; CodeRabbit und CI behalten die Gates.

## Definition of Done (DoD)
- Plan vorhanden (Traycer‑Plan im PR verlinkt oder eingebettet)
- Traycer‑Self‑Check durchgeführt (PR‑Feld: ✅)
- CodeRabbit‑Review bestanden (grün oder Findings adressiert)
- CI/Privacy ok (analyze/test grün; Privacy‑Gate bei DB/AI‑Touches)

## Hinweise
- Keine Secrets/PII in Plan‑Texten ablegen.
- Traycer ist Soft‑Gate: Keine Required‑Checks, keine Merge‑Blockade.
- RAG‑First: interne Refs/ADRs bevorzugen; Traycer‑Plan kann auf `context/agents/*` verweisen.

