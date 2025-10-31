# ADR: Legal Markdown Viewer

## Kontext
Die App zeigt rechtlich verbindliche Texte (Privacy Policy, Terms) über einen Markdown-Viewer an. Die Inhalte müssen offline verfügbar sein, mit App-Releases versioniert werden und eine definierte Fallback-Strategie besitzen.

## Entscheidungen
- **Speicherort:** Verbindliche Markdown-Dateien liegen im Repo unter `assets/legal/`. Der Build bundelt sie unverändert ins App-Paket; Pfade werden im Viewer hart verdrahtet.
- **Versionierung:** Jede App-Version verknüpft die angezeigten Texte mit dem Git-Tag des Builds (`SENTRY_RELEASE` / Release-Notes). Änderungen an Markdown-Dateien erfolgen per Pull Request und werden durch Git-Historie nachvollzogen.
- **Lade-Reihenfolge:** Viewer lädt zunächst Remote-URLs (`PRIVACY_URL`, `TERMS_URL`). Fällt der Abruf aus (< 5 s Timeout oder HTTP ≥ 400), wird automatisch auf die gebündelten Dateien (`assets/legal/privacy.md`, `assets/legal/terms.md`) zurückgegriffen.
- **Fallback-Benutzerführung:** Bei Remote-Fehler blendet die UI eine gelbe Banner-Warnung („Offline-Version“) ein, zeigt Dateiversion + Build-Tag und protokolliert einen Sentry-Breadcrumb `legal_viewer_fallback`.
- **Fehlerfall (Remote + Lokal):** Scheitern sowohl Remote- als auch lokale Ressourcen, blockiert der Screen mit einem Fehlermodul, schlägt einen Retry vor und verweist auf Support. Ereignis `legal_viewer_failed` wird erfasst.
- **Tests:** CI besitzt einen Smoke-Test, der den Offline-Pfad erzwingt (Mock HTTP 503) und prüft, dass der Viewer die lokalen Dateien rendert.

## Konsequenzen
- QA prüft jede Release-Kandidatur mit aktivierter Offline-Prüfung.
- Änderungen an der Ordnerstruktur `assets/legal/` gelten als Breaking und benötigen Update der Build-Skripte und Golden-Tests.
