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

## Vercel Preview Health (200 OK)
- [ ] Preview geprüft (200 + JSON; Ziel: p95 < 300 ms, Payload < 5 KB)
- Preview-Link (PR → View deployment → /api/health):
- Kurznotiz: Erwartung `{ "ok": true, "timestamp": "…" }` (HTTP 200). Bei Gateway‑Touch kurz Latenz/Größe notieren.
 - Hinweis: Nach Merge Production erneut prüfen (`/api/health → 200`) und Link im PR/Merge-Kommentar ablegen.

## ADR-Referenzen
- 0001 RAG-First
- 0002 RLS
- 0003 MIWF
 - 0004 Edge Gateway (EU/fra1)


## DB/AI Checks
- [ ] Migrations vorhanden? → Supabase DB Dry-Run grün
- [ ] RLS Policies/FORCE RLS beachtet
- [ ] (optional) Langfuse Trace Link eingefügt
- [ ] (optional) MCP-Quelle/Trace verlinkt, falls Migrationsvorschlag aus MCP stammt
- Hinweis: Keine service_role im Client.

## RLS-Check
- [ ] Policies 4x (SELECT/INSERT/UPDATE/DELETE)
- [ ] auth.uid()
- [ ] kein service_role im Client
- [ ] keine PII-Logs

## Checkliste
- [ ] Antwortformat (CLI) eingehalten: Mini‑Kontext, Warum, Schritte, Erfolgskriterien, Undo/Backout (Code‑Block), Nächster Schritt, Stop‑Kriterien
- [ ] CI/DoD geprüft (flutter analyze/test; Privacy‑Gate falls DB)
- [ ] Greptile Review „green“ (Required Check) oder Findings adressiert; optional lokales CodeRabbit-Review
