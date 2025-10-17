# ADR-00xx: Traycer-Integration (Trial)

Status: proposed
Owner: Developer Productivity Team
Date: 2025-10-14

## Kontext
Wir wollen die Planungs- und Frühreview-Phase verbessern, ohne unsere bestehenden Branch-Protection-Gates (CI, Privacy-Gate, CodeRabbit) zu verändern. Traycer bietet Plan/Phases/Review-Workflows in der IDE sowie eine optionale GitHub-Anbindung.

## Entscheidung
- Traycer dient als Plan-/Frühreview-Soft-Gate (Plan → Umsetzen → Self-Check).
- CodeRabbit bleibt das PR-Gate (Required Check); Traycer ist nicht-blockierend und kein Required Check.
- Nutzung nur mit Label `trial-traycer` (begrenzter Umfang, klare Auswertung).
- Pläne werden im PR dokumentiert (Feld „Traycer-Plan (Link/Text)“).

## Begründung
- Bessere BMAD-Qualität (klarere Schritte/Scope) und weniger Rework.
- Kein Risiko für Merge-Pfad (keine neuen Blocker), Governance bleibt konsistent.

## Konsequenzen
- Zusätzliche Disziplin: Self-Check ausführen und PR-Felder pflegen.
- Potenzielles Rauschen wird minimiert, da Traycer nicht blockiert und nur bei `trial-traycer` genutzt wird.

## Rollout (Trial)
- Phase 1 (IDE-only): Traycer für Plan/Phases/Review in Cursor nutzen; PR-Felder ausfüllen.
- Phase 2 (optional): GitHub-App nicht-blockierend, nur für PRs mit `trial-traycer`.
- Metriken: Nützliche Findings/PR, Iterationen/Story, Duplicate-Rate vs. CodeRabbit (<20%).

## Nicht-Ziele
- Keine Änderung der Required Checks.
- Keine Speicherung von Secrets/PII in Traycer-Artefakten.

## Security/Privacy Impact
- Traycer wird nur als Plan/Review-Artefakt genutzt, ohne produktive Datenverarbeitung.
- Keine PII/Secrets in Artefakten; Verweise nur auf interne, DSGVO-konforme Quellen.
- Keine Änderung an Auth/RLS/CI-Gates; CodeRabbit/Privacy-Gate bleiben maßgeblich.

## Hinweis (Ablage)
- Temporäre Ablage unter `docs/adr/`. Nach erfolgreichem Trial wird dieser ADR nach `context/ADR/0005-traycer-integration.md` überführt und finalisiert (keine funktionalen Änderungen, nur Verschiebung).
