# ADR-0006: Offline Resume Sync
Status: Accepted  
Datum: 2025-01-16

## Kontext
- Workout-Flow benötigt eine zuverlässige Resume-Position, auch ohne Netz.
- Signing-in Nutzer erwarten Cross-Device-Fortsetzung; anonyme Nutzer bleiben lokal.
- DSGVO/Sicherheits-Anforderungen verlangen Verschlüsselung, begrenzte Retention und nachvollziehbare Löschung.

## Entscheidung
- Persistenz: Resume-Position wird lokal verschlüsselt in einer sicheren SQLite-Instanz (`sqflite_sqlcipher` + Schlüssel in Secure Storage) gespeichert.
- Sync: Beim Pause-/Exit-Event sendet der Client ein `resume_snapshot` mit "`program_id`, `exercise_id`, `position_ms`, `updated_at`" an den Server; nur für angemeldete Nutzer.
- Konfliktlösung: Server hält 90 Tage Verlauf und nimmt das Snapshot mit dem neuesten `updated_at` pro Programm als Quelle der Wahrheit. Anonyme Nutzer bleiben strikt lokal (kein Upload).
- Retention: Snapshots verfallen nach 90 Tagen Inaktivität (Server-Cron + Client-Cleanup beim Fetch); Nutzer können einen Stand „pinnen“, dann bleibt er erhalten bis explizit gelöscht.
- Offline-Semantik: Ohne Netz greift der Client auf den lokalen Store zurück und queued Snapshots; Sync-Job sendet Batch sobald Connectivity vorhanden ist.

## Konsequenzen
- Tests: Unit-Tests prüfen Persistenz, Verschlüsselungs-Init und TTL-Löschung; Integrationstests decken Signed-In Sync, Konfliktlösung und Offline-Replay ab.
- Compliance: DSGVO-Checkliste referenziert neue Datenkategorie „Workout Resume Snapshot“ (PII: User-ID, Device-ID optional).
- Monitoring: Telemetrie-Events `resume_snapshot_saved`, `resume_snapshot_synced`, `resume_snapshot_conflict` validieren Pipeline; Alerts bei Sync-Fehlern > 5 %/Tag.
- Dokumentation: `docs/product/roadmap.md` verweist auf diese ADR; Entwickler aktualisieren API-Spezifikation (`lib/features/workout/state/progress_store.dart`, `/functions/v1/resume_snapshot`) bei Änderungen.
