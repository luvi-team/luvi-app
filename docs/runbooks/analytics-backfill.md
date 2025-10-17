# Runbook – Analytics Backfill (Privacy‑First)

Zweck
- Fehlende/fehlerhafte Analytics‑Daten nacherzeugen – idempotent, EU‑respektierend, ohne PII.

Wann backfillen?
- Ingestion‑Ausfall/Zeitfenster; Schema‑Änderung mit Migration; korrigierende Reprocessings.

Datenquellen
- App/Edge Logs (EU); Queue/Archiv; DB‑Exports. Nur pseudonyme/aggregierbare Felder nutzen.

Vorbereitung
- Event‑Schema prüfen (`docs/analytics/taxonomy.md`); PII‑Filter anwenden; Testlauf in Staging.

Ausführung (Skizze)
- Transform: Rohlogs → Event‑Schema (Version beachten); eindeutige Event‑IDs setzen.
- Import: Batch/Streaming über API/Bulk; Idempotenz per Event‑ID.

Verifikation
- Zählungen vorher/nachher; Key‑KPIs plausibel; Stichproben auf doppelte Events.

Kommunikation
- Stakeholder informieren (Zeitraum/Änderungen); Changelog notieren.

Hinweise
- EU‑Residency wahren; keine Klartext‑PII exportieren; Retention‑Fristen respektieren.

