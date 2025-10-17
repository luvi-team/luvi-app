# DataViz/Analytics Checklist (Privacy‑First)

Ziel: Nutzbare Insights ohne PII – klare Taxonomie, A11y‑Charts, EU‑Residency, Backfills.

Event‑Design
- Namensschema konsistent (context:object_action); snake_case; Versionierung (`*_v2`).
- Keine PII in Properties; anonyme IDs/Hashes; Consent‑Gates respektieren Opt‑in/Opt‑out.
- Sampling für hochvolumige Events; Schema/TAXonomie als SSOT pflegen.

Dashboards/KPIs
- Onboarding‑Funnel; Crash‑Free Sessions; DAU/MAU & DAU/MAU‑Ratio; Retention Cohorts.
- Visual‑Standards: klare Titel, passende Chart‑Typen, wenig Clutter.

Chart‑A11y
- Kontrast ≥ Richtwerte; keine Farb‑Only‑Kodierung; direkte Labels/Alt‑Text.
- Tastatur‑Bedienbarkeit bei Interaktivität; Mindest‑Fontgrößen.

Data Paths & EU‑Residency
- EU‑Hosting (z. B. PostHog EU) sicherstellen; IP/Geo nur grob oder gehasht.
- Retention je Datentyp; Exporte/Backups nur EU; Backfill‑Runbook bereit.

Quick Wins
- Event‑Schema‑Template nutzen; PII‑Scanner vor Ingestion; A11y‑Checkliste anwenden.

Verweise
- Taxonomie: `docs/analytics/taxonomy.md`
- Chart‑A11y: `docs/analytics/chart-a11y-checklist.md`
- Backfill Runbook: `docs/runbooks/analytics-backfill.md`

