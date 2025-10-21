# Actions TODO – Agenten (Codex)

- [x] README: Spaltenkopf Operativer Prompt → Interop-Prompt (Legacy) (Klarstellung).
 - [x] reqing-ball.md: Operativer Modus (Codex CLI-first) 1-Zeiler ergänzen.
 - [x] ui-polisher.md: Operativer Modus (Codex CLI-first) 1-Zeiler ergänzen.
- [ ] CLAUDE.md: Optionaler Zusatz Links können veraltet sein (Legacy) (nur Hinweis).
- [ ] Bei Änderungen an DoD/Checks: context/agents/_acceptance_v1.1.md Version anheben und Dossiers acceptance_version aktualisieren.
- [x] Optional: Non-blocking Drift-Check-Skript unter context/agents/_drift_check.sh (nur Report, kein Gate) einführen.

- [ ] CI Maint: GitHub Actions-Pinning (checkout, upload-artifact, github-script v7) quartalsweise prüfen/aktualisieren; aktueller Stand: github-script v7.1.0 → f28e40c7f34bde8b3046d885e986cb6290c5673b.

- [ ] Video Fullscreen (YouTube) — Owner: @sofia.luvi · Due: 2025-02-28 · Risk: Medium
  Acceptance: Landscape nur auf der dedizierten Fullscreen-Route aktivieren, Portrait nach Exit wiederherstellen, iOS `Info.plist` + Android `AndroidManifest.xml` um benötigte Orientierungen ergänzen, Tests auf iOS/Android/Web durchführen.
  References: Ticket: https://linear.app/luvi/issue/MOB-482/video-fullscreen-youtube · Code TODO: `lib/main.dart:1`.
  Notes: Minimaler Route-/Orientation-Guard-Snippet + Manifest-Checklist stehen bereit und sollen eingebunden werden.

Hinweis: Keine Dateien löschen/umbenennen. CI/Infra bleibt unverändert.
