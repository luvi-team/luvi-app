# ADR: Legal Markdown Viewer

## Kontext
Die App zeigt rechtlich verbindliche Texte (Privacy Policy, Terms) über einen Markdown-Viewer an. Die Inhalte müssen offline verfügbar sein, mit App-Releases versioniert werden und eine definierte Fallback-Strategie besitzen.

## Entscheidungen
- **Speicherort:** Die autoritative Quelle liegt im Repo unter `docs/privacy/`. Für die App‑Auslieferung werden geprüfte Kopien unter `assets/legal/` gebündelt. Der Ordner `docs/privacy/` wird nicht als App‑Asset eingebunden.
- **Versionierung:** Jede App-Version verknüpft die angezeigten Texte mit dem Git-Tag des Builds (`SENTRY_RELEASE` / Release-Notes). Änderungen an Markdown-Dateien erfolgen per Pull Request und werden durch Git-Geschichte nachvollzogen. Siehe „CI/Release-Runbook" zur Durchsetzung.
- **Lade-Reihenfolge:** Viewer lädt zunächst Remote-URLs (`PRIVACY_URL`, `TERMS_URL`). Fällt der Abruf aus (5 s timeout), oder bei HTTP ≥ 400, wird automatisch auf die gebündelten Dateien (`assets/legal/privacy.md`, `assets/legal/terms.md`) zurückgegriffen.
- **Fallback-Benutzerführung:** Bei Remote-Fehler blendet die UI eine gelbe Banner-Warnung („Offline-Version“) ein, zeigt Dateiversion + Build-Tag und protokolliert einen Sentry-Breadcrumb `legal_viewer_fallback`.
  - Banner-Lifecycle: persistent bis Browser/App‑Refresh oder erfolgreichem Remote‑Load. Optionales Dismiss ist rein lokal und kosmetisch: Dismiss = nur UI ausblenden bis zum nächsten Refresh/Remote‑Load, keine Status‑Mutation und keine Unterdrückung/Änderung von Telemetrie (Sentry‑Signale bleiben unverändert).
  - Interaktion: non-blocking, als oberes Inline-Banner; Lesen der Inhalte bleibt möglich. Wenn sowohl Remote als auch lokal fehlschlagen, zeigt der Screen ein blockierendes Fehlermodul (siehe Fehlerfall).
  - Visual/Placement: Top-inline Banner, Farbe „Gelb/Warning“, Icon „Warning/Outline“. Copy-Format: „Offline-Version angezeigt – privacy.md (vX.Y) • Build {SENTRY_RELEASE}“. Referenz: Design/Wireframe `assets/ui/legal_viewer_banner.png` (oder Figma‑Spec ID, falls vorhanden).
- **Fehlerfall (Remote + Lokal):** Scheitern sowohl Remote- als auch lokale Ressourcen, blockiert der Screen mit einem Fehlermodul, schlägt einen Retry vor und verweist auf Support. Ereignis `legal_viewer_failed` wird erfasst.
  - Sentry-Semantik:
    - `legal_viewer_fallback`: Breadcrumb (kein Event), wenn Remote fehlschlägt, lokaler Fallback jedoch rendert. Felder: `remote_url`, `local_version`, `build_tag`, `timestamp`.
    - `legal_viewer_failed`: Vollständiges Sentry-Event nur wenn Remote UND Lokal scheitern. Felder: `error_stack`, `retry_attempts`, `user_action` (auto_retry|manual_retry|abandon).
    - Mutual Exclusion: Beide Signale schließen sich pro Ladevorgang gegenseitig aus.
- **Tests:** CI besitzt einen Smoke-Test-Satz, der Offline- und Fehlerpfade vollständig abdeckt:
  - Ziel der Smoke-Tests: die gebündelten Dateien unter `assets/legal/` (CI verwendet den gebauten/bündelten App‑Stand, nicht die Quell‑Ordner).
  - Dateien: Sowohl `assets/legal/privacy.md` als auch `assets/legal/terms.md` werden einzeln erzwungen (HTTP 503/Timeout), lokal gerendert und auf minimale Text‑Fingerprints geprüft.
  - Retry-Semantik: Automatischer einmaliger Retry mit Backoff (z. B. 500–1000 ms, Timeout 5 s) wird simuliert; anschließend manueller Retry-Button wird angeboten und getestet.
  - UI-Fallbacks: Gelbes Offline-Banner vorhanden (persistent, non-blocking); bei Doppel‑Fehler (Remote+Lokal) wird das Fehlermodul mit Support-Hinweis angezeigt.
  - Sentry-Assertions: Breadcrumb `legal_viewer_fallback` bei Remote‑Fail + lokalem Erfolg; Event `legal_viewer_failed` nur bei Doppel‑Fail. Assertions prüfen Felder gemäß oben definierten Schemas.
  - Referenz: Testpfad wird während der Implementierung konkretisiert (TBD). Falls stattdessen CI‑Logs als Referenz dienen, notiere den spezifischen Job („Flutter CI / analyze-test“) und den Build‑Run (Commit‑SHA) mit Direktlink in diesem ADR.

## CI/Release-Runbook (Durchsetzung Versionierung)
- Git-Tag-Pflicht: Releases erzeugen einen Git‑Tag; Verantwortlich: Release Owner. Tag wird an `SENTRY_RELEASE` gebunden.
- Release Notes: Änderungen an `docs/privacy/*.md` erfordern Update/Autogenerierung der Release Notes (Änderungsliste Abschnitt „Legal“).
- CI-Check: Pipeline extrahiert Version/Front‑Matter aus `docs/privacy/*.md` (oder Build‑Artefakten) und vergleicht mit `SENTRY_RELEASE`/Git‑Tag. Die Front‑Matter muss dem in `docs/adr/legal_front_matter.md` definierten Schema entsprechen (autoritative Quelle für Keys/Typen/Validierung). Bei Mismatch: Pipeline schlägt fehl und gibt eine klare Fehlermeldung aus („Legal docs version mismatch: expected {TAG}, found {DOC_VERSION} in {FILE}“).
- Runbook (Remediation): 1) Prüfe, ob Tag korrekt erstellt wurde; 2) Passe Dokument‑Version/Front‑Matter an; 3) Triggere Build erneut; 4) Prüfe, dass Smoke‑Tests (Fallback/Retry/Sentry) grün sind.

## Implementierungs-Checkliste (UI/Telemetry)
- Banner: persistent bis Refresh/Erfolg; optional manuelles Dismiss ohne Status‑Reset; top-inline, Gelb mit Warning‑Icon; Copy enthält Dateiname, lokale Version und Build‑Tag.
- Fehlermodul: erscheint nur bei Doppel‑Fail; bietet manuellen Retry + Support‑Verweis.
- Retry: Auto‑Retry einmalig mit Backoff; manueller Retry-Button verfügbar; Timeouts über Konstante.
- Telemetry: Breadcrumb/Event-Felder wie oben; mutual exclusion sicherstellen.

## Konsequenzen
- QA prüft jede Release-Kandidatur mit aktivierter Offline-Prüfung.
- Änderungen an der Ordnerstruktur `docs/privacy/` gelten als Breaking und benötigen Update der Build-Skripte und Golden-Tests.
