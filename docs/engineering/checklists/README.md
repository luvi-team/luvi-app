# Checklists — Owner Map (Solo‑Dev)

Zweck: Schnelle Zuordnung „welche Checkliste öffne ich bei welcher Änderung?“ für 2–5‑Minuten‑Self‑Checks. Kein neuer Prozess, nur Spickzettel.

Änderung → Checkliste/Runbook
- UI/Navigation/Theme/Widgets → `docs/engineering/checklists/ui.md`
- Edge/API‑Route/CORS/Logger/Health → `docs/engineering/checklists/api.md` · Health: `docs/runbooks/vercel-health-check.md`
- DB/Migration/Policy/Trigger/RLS → `docs/engineering/checklists/db.md` · RLS: `docs/runbooks/debug-rls-policy.md`
- Analytics/Events/Dashboards → `docs/engineering/checklists/dataviz.md` · Taxonomie: `docs/analytics/taxonomy.md` · Chart‑A11y: `docs/analytics/chart-a11y-checklist.md` · Backfill: `docs/runbooks/analytics-backfill.md`
- Privacy/Consent/Payments/3rd‑Party/Data‑Exports → `docs/engineering/checklists/privacy.md` · DSGVO‑Review: `docs/privacy/reviews/`

2–5‑Min‑Routine (Self‑Check)
- Öffne passende Checkliste, prüfe 3–5 Kernpunkte (Do/Don’t, Quick‑Wins).
- Falls relevant: Runbook kurz scannen (Health/RLS/Backfill/IR).
- PR‑Template ausfüllen (Health‑Link, DSGVO‑Review, ADR‑IDs), Häkchen setzen.

Referenzen
- ADRs: 0001 RAG‑First · 0002 RLS · 0003 MIWF · 0004 Edge Gateway (EU/fra1)
- Gates: CI (analyze/test, privacy‑gate), Health‑Soft‑Gate (Preview/Prod 200)

Pflege
- Solo‑Dev = Owner aller Checklisten. Bei ADR‑Änderungen oder Lessons Learned Checklisten aktualisieren.
