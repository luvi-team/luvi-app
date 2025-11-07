# ADR-0006: Offline Resume Sync
Status: Accepted  
Datum: 2025-11-05

## Kontext
- Workout-Flow benötigt eine zuverlässige Resume-Position, auch ohne Netz.
- Signing-in Nutzer erwarten Cross-Device-Fortsetzung; anonyme Nutzer bleiben lokal.
- DSGVO/Sicherheits-Anforderungen verlangen Verschlüsselung, begrenzte Retention und nachvollziehbare Löschung.

## DSGVO – Betroffenenrechte (Erweiterung)
Zur ursprünglichen DSGVO-Nennung werden folgende Betroffenenrechte explizit adressiert. Für alle Endpunkte gilt: nur für angemeldete Nutzer; Auth über Supabase-JWT; RLS owner‑basiert (user_id = auth.uid()). Alle Aufrufe werden audit‑geloggt.

- Right of Access (Art. 15):
  - API: `GET /functions/v1/resume_snapshots` listet alle Snapshots des angemeldeten Nutzers (Pagination: `limit`, `cursor`). `GET /functions/v1/resume_snapshots/{id}` liefert ein einzelnes Snapshot.
  - Felder: `id, user_id, program_id, exercise_id, position_ms, pinned, device_id, updated_at, created_at`.
  - AuthZ: Edge Function verifiziert JWT (`sub`) und erzwingt `user_id == auth.uid()`; DB‑RLS spiegelt das ab. 403 bei Missmatch.
  - UI: „Privacy Center → Verlaufsansicht“ mit Filter (Programm/Zeitraum), Detailansicht je Snapshot.

- Right to Data Portability (Art. 20):
  - API: `GET /functions/v1/resume_snapshots/export?format=json|csv` liefert maschinenlesbare Exporte. Dateiname: `resume_history_<yyyy-mm-dd>.{json,csv}`; `Content‑Disposition: attachment`.
  - Formate:
    - JSON: Objekt `{ schema: {version: "1.0", fields:[...]}, data:[{...}] }`; Datumsfelder ISO‑8601, `position_ms` als Integer, `pinned` als Boolean.
    - CSV: Header exakt `id,user_id,program_id,exercise_id,position_ms,pinned,device_id,updated_at,created_at`.
  - AuthZ/Rate‑Limit: wie oben; zusätzlich Drosselung (z. B. 5/min) pro `user_id`.
  - UI: „Daten exportieren“ mit Formatwahl und kurzer Schema‑Beschreibung.

- Right to Erasure (Art. 17):
  - API: `DELETE /functions/v1/resume_snapshots` löscht alle serverseitigen Snapshots und zugehörige Metadaten des angemeldeten Nutzers. Antwort: `202 Accepted { job_id }`.
  - Löschmodell: Sofortige serverseitige Soft‑Delete (`deleted_at` gesetzt, RLS sperrt Zugriff) und Hintergrund‑Purge nach `purge_at = now() + 7d` via Job/cron. Hartlöschung umfasst Snapshots, Indizes, eventuelle Materialized Views und Telemetrie‑Joins (nur nicht‑aggregierte personenbezogene Felder). Wichtig: Pinning schützt nicht vor expliziten Löschaufträgen (Right to Erasure) oder unmittelbaren Purge‑Jobs – auch gepinnte Snapshots werden in diesem Fall gelöscht.
  - Kaskaden: FK‑Kaskade auf `resume_snapshot_events`/`resume_snapshot_conflicts`/ähnliche Neben‑Tabellen; Tombstones verhindern Re‑Import derselben Daten während der Purge‑Phase.
  - Client‑Verhalten: Bei `erase_requested` oder 410/Gone‑Signal löscht die App lokale, verschlüsselte Kopien und stoppt Upload‑Queues. Der Nutzer wird über den irreversiblen Schritt informiert.
  - UI: „Daten löschen“ mit Re‑Auth (z. B. Passworteingabe/OS‑Biometrie), Doppel‑Bestätigung (Eingabe „DELETE“) und Hinweis auf lokale Kopien.

- Audit‑Logging (alle Rechte):
  - Tabelle `audit_dsr_requests(user_id, event_type, scope, format, request_id, status, error, created_at)`; Eventtypen: `dsr.access`, `dsr.portability`, `dsr.erase_request`, `dsr.erase_complete`.
  - Aufbewahrung von Audit‑Logs: 24 Monate, getrennt von Nutzdaten; enthält keine Payload‑Inhalte, nur Meta.

- Retention & Soft‑Delete Policy:
  - Standard‑Retention für Snapshots: 90 Tage Inaktivität. Opt‑in „Pinnen“ hebt ausschließlich die automatische 90‑Tage‑Retention auf (gepinnt = von geplanten Retention‑Jobs ausgenommen), schützt aber nicht vor expliziten Löschaufträgen (Right to Erasure) oder sofortigen Purge‑Jobs.
  - Inaktivitätsdefinition (präzise):
    - Serverseitig maßgeblich ist `resume_snapshots.updated_at` (UTC) des jeweiligen Snapshot‑Datensatzes. Ein Snapshot gilt als inaktiv, wenn sein `updated_at` ≥ 90 Tage zurückliegt und er nicht gepinnt ist.
    - `updated_at` wird serverseitig gesetzt/überschrieben (DB/Edge), Client‑Timestamps dienen nur zur Telemetrie. So bleiben Zeitzonen/Clock‑Skews ohne Einfluss.
    - Hinweis: Serverzustand ist autoritativ; Client‑Clock‑Skew und Eskalationspfade werden im Runbook gepflegt (siehe `docs/runbooks/resume_sync_operational_runbook.md`).
    - Clientseitige Bereinigung (anonyme Nutzer/offline): basiert auf lokalem `updated_at` und spiegelt dieselbe 90‑Tage‑Logik wider; beim ersten erfolgreichen Sync führt der Server die Autorität.
  - Erasure überschreibt Retention/Pinning; Soft‑Delete → Purge nach 7 Tagen, es sei denn gesetzliche Aufbewahrungspflichten greifen (nicht einschlägig für diese Datenklasse).

- Tests (Compliance):
  - Access: Nur eigene Datensätze sichtbar; 403 Cross‑Tenant.
  - Portability: JSON und CSV entsprechen Schema/Headers; Inhalte vollständig für Zeitraum.
  - Erasure: Nach `DELETE` sind Daten sofort unzugänglich (RLS), nach Purge physisch entfernt; Audit‑Events `erase_request` und `erase_complete` vorhanden; Kaskaden greifen.
  - UI: Re‑Auth + Doppel‑Bestätigung; Export‑Download startet mit korrektem Mime/Dateiname; lokale Löschung wird ausgelöst.

## Entscheidung
- Persistenz: Resume-Position wird lokal verschlüsselt in einer sicheren SQLite-Instanz (`sqflite_sqlcipher` + Schlüssel in Secure Storage) gespeichert.
- Sync: Beim Pause-/Exit-Event sendet der Client ein `resume_snapshot` mit "`program_id`, `exercise_id`, `position_ms`, `updated_at`" an den Server; nur für angemeldete Nutzer.
- Konfliktlösung: Server hält 90 Tage Verlauf und nimmt das Snapshot mit dem neuesten `updated_at` pro Programm als Quelle der Wahrheit. Anonyme Nutzer bleiben strikt lokal (kein Upload).
- Retention: Snapshots verfallen nach 90 Tagen Inaktivität (Server-Cron + Client-Cleanup beim Fetch); Nutzer können einen Stand „pinnen“, dann bleibt er erhalten bis explizit gelöscht.
- Offline-Semantik: Ohne Netz greift der Client auf den lokalen Store zurück und queued Snapshots; Sync-Job sendet Batch sobald Connectivity vorhanden ist.

## Implementierungsplan (Server + App)
- Server (Edge Functions/Supabase):
  - `GET /functions/v1/resume_snapshots` (list) + `GET /functions/v1/resume_snapshots/{id}` (detail) mit JWT‑Verifikation, RLS owner‑Policies, Pagination.
  - `GET /functions/v1/resume_snapshots/export` mit JSON/CSV‑Renderer, konsistentem Schema, Rate‑Limit, Audit‑Logs.
  - `DELETE /functions/v1/resume_snapshots` mit Soft‑Delete (Flag/Timestamp), Audit‑Event, Job‑Enqueue und Cron‑Purge nach 7 Tagen; Kaskaden prüfen.
  - Tabellen/Policies: `resume_snapshots` (RLS ON), Neben‑Tabellen, `audit_dsr_requests` (RLS: nur Owner SELECT; INSERT/UPDATE nur via Service‑Role).

  - App (Flutter):
  - Privacy Center: Screens/Flows „Verlauf ansehen“, „Daten exportieren“, „Daten löschen“ mit Re‑Auth, Doppel‑Bestätigung, Fehlerzustände, Progress.
  - API‑Clients: typed Endpunkt‑Wrapper; Buffered download (Default); CSV/JSON Handling; Timeouts/Retry begrenzt. Hinweise zu Streaming (Schwellen, Speicherfußabdruck) sind operativ und werden im Runbook geführt (siehe „Operational Notes“).
  - Lokale Behandlung: On‑Signal Erasure → Secure‑Storage + SQLite Wipe der Snapshots; Upload‑Queue leeren und deaktivieren bis Neustart.
  - Telemetrie: Nicht‑PII Events für Flow‑Erfolg/Fehler (keine Inhalte), korrelierbar via `request_id`.

- Tests:
  - Unit: Schema‑Serializer, CSV‑Exporter, RLS‑Policy Regelsätze (SQL Tests), Client‑Flows.
  - Integration: Endpunkte gegen lokale DB/Emulator; Erasure‑Ablauf inkl. Audit und Kaskaden; Export‑Konsistenz; Access‑Isolation.
  - UI‑Tests: Re‑Auth‑Dialoge, Bestätigungsfluss, Download‑Trigger, Accessibility.

## Konsequenzen
- Tests: Unit-Tests prüfen Persistenz, Verschlüsselungs-Init und TTL-Löschung; Integrationstests decken Signed-In Sync, Konfliktlösung und Offline-Replay ab.
- Compliance: DSGVO-Checkliste referenziert neue Datenkategorie „Workout Resume Snapshot" (PII: User-ID, Device-ID). Device-ID wird immer als PII behandelt, wenn erfasst, und unterliegt Einwilligung, 90‑Tage‑Retention sowie Löschung/Export auf Anfrage. Wenn Device-ID nicht erfasst wird, wird sie weder übertragen noch gespeichert.
- Zeit & Zeitzonen:
  - Alle persistierten Zeitfelder sind in UTC zu führen; `updated_at` wird ausschließlich serverseitig (DB‑Default/Trigger oder Edge) gesetzt (`now()` in UTC). Clients dürfen lokale Zeiten für UI/Telemetry verwenden, nicht für Persistenzentscheidungen.

- Security – Key Management (Zusammenfassung, Details ausgelagert):
  - Lokale Verschlüsselung verwendet eine gerätespezifische, zufällig generierte Schlüsselableitung (nicht aus dem Nutzerpasswort). Der Schlüssel wird OS‑gestützt im Secure Storage (Keychain/Keystore) abgelegt und nur im App‑Kontext genutzt. Details zu Ableitung (PBKDF2‑Parameter), Rotation/Rekey, Gerätemigration, Kompromittierung/Root‑Erkennung und Multi‑Device sind im Security‑Design dokumentiert; siehe `docs/security/offline_resume_key_management.md`.

- Compliance & DPIA:
  - DPIA: Wird nach Risikoprüfung festgelegt. Diese ADR erhebt keinen Anspruch auf „High‑Risk“; falls die Bewertung (Skalierung, Drittlandtransfer, Sensitivität) ein hohes Risiko ergibt, folgt eine eigenständige DPIA vor Launch.
  - Device‑ID als PII: Standardmäßig wird `device_id` nicht erhoben. Eine optionale Erhebung erfordert explizite Einwilligung und wird in der Datenschutzerklärung dokumentiert (Zweck, Trigger, Widerruf).

- Monitoring & Alerts:
  - Telemetrie-Events `resume_snapshot_saved`, `resume_snapshot_synced`, `resume_snapshot_conflict` validieren die Pipeline.
  - Messmethode (täglich): `error_rate_events = failed_sync_events / total_sync_events` (angemeldete Nutzer); zusätzlich `error_rate_users = users_with_≥1_failure / users_with_≥1_sync` zur Betroffenheitsabschätzung.
  - Baseline: Zielwert < 1 % (Events) pro Tag; p95‑Tageswert < 2 % unter Normalbetrieb (Mobilfunkfluktuation eingerechnet).
  - Schwellwerte & Eskalation:
    - Warnung (asynchron): ≥ 2 % über ≥ 60 min ODER Trend +0,5 %/h → Ticket im Board, Owner: Feature‑Team Workout.
    - Page (SEV‑3): ≥ 5 % über rollierendes 24h‑Fenster ODER ≥ 7 % über ≥ 30 min → On‑Call wird gepaged.
    - SEV‑2: ≥ 10 % über ≥ 30 min ODER ≥ 2 000 betroffene Nutzer/Tag → Incident Commander, dedizierter Channel.
    - SEV‑1: ≥ 15 % über ≥ 15 min ODER ≥ 3 000 betroffene Nutzer/Tag ODER Datenkorruptionssignale → globaler Write‑Stopp für Snapshots, Feature‑Flag „local‑only“ aktivieren.
  - Begründung 5 %: Resume‑Sync ist wichtig für Cross‑Device‑Kontinuität, aber nicht transaktional‑kritisch für den Live‑Workout, da der lokale Offline‑Fallback den Fortgang am aktuellen Gerät sicherstellt. 5 % vermeidet Pager‑Fatigue bei regionalen Netzausfällen, liegt deutlich über dem < 1 %‑Baseline‑Ziel und signalisiert spürbaren Nutzer‑Impact, der aktives Eingreifen rechtfertigt.
  - Operational Notes: Schwellen, Streaming‑Leitplanken und Eskalationspfade werden in `docs/runbooks/resume_sync_operational_runbook.md` gepflegt und nach Go‑Live anhand realer Daten kalibriert.

### Referenzen
- Security Design: `docs/security/offline_resume_key_management.md` (Stand: 2025‑11‑04 · Version: v1.0)
- Operational Runbook: `docs/runbooks/resume_sync_operational_runbook.md` (Stand: 2025‑11‑04 · Version: v1.0)
- Dokumentation: `docs/product/roadmap.md` verweist auf diese ADR; Entwickler aktualisieren API‑Spezifikation (`lib/features/workout/state/progress_store.dart`, Endpunkte unter `/functions/v1/resume_snapshots*`) bei Änderungen.
