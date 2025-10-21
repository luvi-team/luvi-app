# Runbook – Analytics Backfill (Privacy‑First)

Zweck
- Fehlende/fehlerhafte Analytics‑Daten nacherzeugen – idempotent, EU‑respektierend, ohne PII.

Wann backfillen?
- Ingestion‑Ausfall/Zeitfenster; Schema‑Änderung mit Migration; korrigierende Reprocessings.

Datenquellen
- App/Edge Logs (EU); Queue/Archiv; DB‑Exports. Nur pseudonyme/aggregierbare Felder nutzen.

Vorbereitung
- Event‑Schema prüfen (`docs/analytics/taxonomy.md`); PII‑Filter anwenden; Testlauf in Staging.

Ausführung (Protokoll)
- Transform:
  - Rohlogs → Event-Schema (Version beachten) via `scripts/backfill_transform.dart --input s3://analytics-raw/${BATCH_ID}/ --output /tmp/backfill/${BATCH_ID}.ndjson`.
  - Event-IDs: `event_id = concat_ws(':', source, to_char(event_ts, 'YYYYMMDDHH24MISSMS'), sha256(payload)::text)` – immutable + global eindeutig.
  - Dedup-Vorbereitung: Transform-Skript schreibt `event_id` + `source_file` + `line_no` nach `analytics.backfill_event_checkpoint_raw`.
- Idempotenz & Checkpointing:
  - Dedup-Store `analytics.backfill_event_checkpoint` (PK `event_id`).
  - Importer prüft mit `SELECT 1 FROM analytics.backfill_event_checkpoint WHERE event_id = $1` bevor inserts laufen.
  - Atomic `UPSERT` per `INSERT INTO analytics.backfill_event_checkpoint(event_id, batch_id, seen_at) VALUES ($1, $2, clock_timestamp()) ON CONFLICT DO NOTHING RETURNING event_id;` – nur bei Erfolg Event übernehmen.
- Import:
  - Append-only in `analytics.events_backfill_staging` (Partition `batch_id`) – keine Updates.
  - Für Batches zwingend `BEGIN; INSERT ...; INSERT INTO analytics.backfill_batches(batch_id, source, checksum, row_count) VALUES ($BATCH_ID, $SOURCE, $CHECKSUM, $ROW_COUNT); COMMIT;`.
  - Für Streaming-Backfills `spanner`/`postgres_fdw`: Two-Phase-Commit (`PREPARE TRANSACTION 'bf_${BATCH_ID}'; COMMIT PREPARED 'bf_${BATCH_ID}';`) damit dedup + inserts atomar bleiben.
- Rollback & Wiederanlauf:
  - Jede Charge in `analytics.backfill_batches_metadata` (Spalten: `batch_id`, `snapshot_start`, `snapshot_end`, `checksum`, `applied_at`).
  - Tombstones anwenden: `psql -f scripts/backfill_apply_tombstones.sql --set batch_id=${BATCH_ID}` (setzt `deleted_at`, erhält Audit).
  - Snapshot-Restore (Fallback): `CALL analytics.restore_snapshot(p_batch_id := ${BATCH_ID});` nutzt Snapshot aus `s3://analytics-backfill/snapshots/${BATCH_ID}/`.
- Reprocess & Rohdaten:
  - Rohinput unverändert nach `s3://analytics-backfill/raw/${BATCH_ID}/` spiegeln (`aws s3 cp --recursive`); Pfad + Checksumme in `analytics.backfill_batches_metadata`.
  - Transform-Schritte reversibel halten (`scripts/backfill_transform.dart --replay --batch-id ${BATCH_ID}` liest Rohdaten und erzeugt Events neu).
  - Lineage-Log (`analytics.backfill_lineage`) aktualisieren: `INSERT INTO analytics.backfill_lineage(batch_id, event_id, source_file, line_no) VALUES (...)`.
- Operations & Monitoring:
  - Dry-Run: `scripts/backfill_transform.dart --dry-run --batch-id ${BATCH_ID}` + `scripts/backfill_import.dart --dry-run`.
  - Canary: Erste Einspielung `scripts/backfill_import.dart --batch-id ${BATCH_ID} --limit 1000` und Erfolg in `analytics.backfill_batches` markieren (`UPDATE ... SET canary_passed = TRUE`).
  - Monitoring Query: `SELECT batch_id, COUNT(*) AS staged, SUM(is_duplicate::int) AS duplicates FROM analytics.events_backfill_staging WHERE batch_id = ${BATCH_ID} GROUP BY 1;` → Alert bei Differenz > 0.1 %.
  - Rollback-Checklist:
    1. `SELECT * FROM analytics.backfill_batches_metadata WHERE batch_id = ${BATCH_ID};`
    2. `UPDATE analytics.backfill_batches SET status = 'halted' WHERE batch_id = ${BATCH_ID};`
    3. Tombstones oder Snapshot-Restore ausführen (s. oben).
    4. Post-Verifikation: `SELECT COUNT(*) FROM analytics.events WHERE batch_id = ${BATCH_ID};` muss 0 liefern.

Verifikation
- Erfolgs-Gates vor Unfreeze:
  - Event-Gesamtzahl: Differenz zwischen erwarteter Backfill-Menge und tatsächlicher Insert-Menge ≤ 2 %.
  - KPI-Deltas: Daily Active Sessions ±1.5 %, Activation Funnel Conversion ≤ 0.5 %-Punkte Abweichung.
  - Duplicate-Rate: ≤ 0.1 % (Unique Event IDs aus `event_id`-Hash prüfen).
  - Daten-Frische: Latest Timestamp ≤ 30 Minuten nach Backfill-Abschluss.
- Pflicht-Checks:
  - Pre-/Post-Counts pro Event-Typ in `analytics_backfill_verification.csv` dokumentieren.
  - Stichproben (≥ 20 Events) gegen Rohlogs und `docs/analytics/taxonomy.md` validieren.
  - Schema-Konformität via JSON-Schema-Linter (CLI `scripts/validate_events.sh`).
  - Sample-Query in Redshift/BigQuery zur KPI-Verifikation; Screenshots im Ticket ablegen.
- Freigabeprozess:
  - Data Engineering Lead + Product Analytics Manager prüfen gemeinsam die Gates.
  - Sign-off im Tracking-Ticket (JIRA `ANA-BF-###`) als Kommentar + Checkliste abhaken.
- Rollback-Kriterien & Actions:
  - Bei Verstoß gegen eines der Gates → sofortige Freeze-Verlängerung, Batch kennzeichnen.
  - Rollback-Skript `scripts/backfill_revert.sql` ausführen (nur Delta-Window).
  - Incident im `#analytics-alerts` melden, Post-Mortem innerhalb von 24h starten.
- Dokumentation:
  - Ergebnisse + Queries im Confluence-Runbook-Template `Analytics/Backfill Reports`.
  - Approval-Captures (Screenshots/Exports) an Ticket anhängen; Link in Changelog (`CHANGELOG.md`) ergänzen.

Kommunikation
- Stakeholder informieren (Zeitraum/Änderungen); Changelog notieren.

Hinweise
- Datenaufbewahrung:
  - Historische Rohlogs max. 90 Tage Speicherdauer; aggregierte Events max. 13 Monate.
  - Temporäre Staging-Tabellen nach Abschluss (≤ 24h) purgen (`scripts/purge_staging.sql`).
- Residency & Anonymität:
  - EU-Daten in `eu-central-1`/`europe-west4`; keine Kopien in US-Regionen.
  - Falls Daten aus Nicht-EU-Quellen einfließen → Vorab-Pseudonymisierung (SHA-256 + Salz `analytics_salt`).
- Genehmigungen & Eskalation:
  - Pflicht-Freigaben: Data Privacy Officer, Legal Counsel (Privacy), Product Owner (Journey).
  - Sign-off via Sammel-PR (`analytics/backfill/<date>`) + Genehmigung im JIRA-Ticket.
  - Bei Konflikten/Eskalation → CTO informieren, Entscheidung im Executive Sync protokollieren.
