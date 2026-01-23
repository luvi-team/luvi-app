# Greptile Checkliste – LUVI

## 1. Kurzfristige Aufgaben (jetzt / beim nächsten Setup-Schritt)

- [ ] Sicherstellen, dass `Greptile Review` in GitHub als **Required Check** aktiv ist (Branch Protection).
- [ ] Prüfen, dass `greptile.json` im Repo-Root nur folgendes enthält:
      `{ "statusCheck": true }`.
- [ ] Im Greptile-Dashboard:
  - [ ] Custom Rules für:
        - Security/RLS (Supabase, kein `service_role`)
        - Privacy/PII & Consent (kein PII-Logging, CMP)
        - Robustheit (async/await, Edge-Routen)
        - Flutter-Architektur (Riverpod, GoRouter, Null-Safety)
        - Archon/SSOT (keine ad-hoc Business-Logik)
  - [ ] Custom Context:
        - AGENTS.md, CLAUDE.md
        - `docs/engineering/ai-reviewer.md` (File Context, Pattern `**/*`)
- [ ] `docs/engineering/ai-reviewer.md` einmal vollständig querlesen, damit dir der Flow im Kopf ist.
- [ ] Prüfen, dass alle wichtigen Dokus (AGENTS, CLAUDE, Tech-Stack, Gold-Standard, BMAD, Roadmap)
      auf `ai-reviewer.md` verweisen uabbit **nur lokal** erwähnen.

---

## 2. Tägliche Aufgaben (bei jeder Änderung / jedem PR)

### 2.1 Lokal (vor dem PR)

- [ ] Feature- oder Fix-Branch von `main` erstellen.
- [ ] Änderungen implementieren.
- [ ] Lokale Checks:
  - [ ] `flutter format`
  - [ ] `flutter analyze`
  - [ ] `flutter test` (oder relevante Teiltests)
- [ ] Optional: lokales CodeRabbit-Review (CLI/IDE)
  - [ ] Offensichtliche Probleme/Verbesserungen übernehmen.
  - [ ] Ergebnis NICHT als Gate sehen – nur persönliches Feedback.

### 2.2 Pull Request Phase

- [ ] Branch pushen & PR gegen `main` öffnen.
- [ ] Warten, bis folgende Checks durchgelaufen sind:
  - [ ] Flutter CI / analyze-test
  - [ ] Flutter CI / privacy-gate
  - [ ] Supabase DB Dry-Run (falls aktiv)
  - [ ] Vercel Preview Health (`/api/health → 200`)
  - [ ] **Greptile Review**
- [ ] Greptile-Kommentare durchgehen:
  - [ ] **Must Fix** korrigieren:
        - Security (RLS, Secrets, Auth-Flows)
        - Privacy/PII & Consent
        - Crashes / klare Logik-Bu- fehlendes/kaputtes Error-Handling in kritischen Pfaden
  - [ ] **Strongly Recommended** abwägen:
        - Architektur-Probleme (State-Leaks, Navigation, falsch platziertes Business-Logic)
        - grobe Maintainability-Issues („God Widgets“, Duplikation etc.)
  - [ ] **Nice to have** nur übernehmen, wenn es leicht ist:
        - Style-/Mikro-Optimierungen mit geringem Risiko
- [ ] Greptile-Feedback geben:
  - [ ] Hilfreiche Kommentare: 👍 + „resolved“, wenn gefixt.
  - [ ] False Positives: 👎 + 1 Satz Erklärung (z. B. „intentional – consent handled in X“).
- [ ] Merge-Check vor dem Mergen:
  - [ ] Alle CI-Checks grün?
  - [ ] `Greptile Review` grün?
  - [ ] Du selbst zufrieden mit Code & Auswirkungen?
- [ ] PR mergen (meist Squash & Merge) und Branch aufräumen.

---

## 3. Wöchentliche Aufgaben (oder alle 5–10 PRs)

- [ ] Kurz reflektieren: Wie „gesund“ fühlt sich Greptile an?
  - [ ] Mindestens ~50 % der Kommentare hilfreich?
  - [ ] Kein Gefühl, von AI-Kommentaren erscechte „Zum Glück hat Greptile das gesehen“-Momente
        (z. B. RLS-/PII-/Error-Handling-Bugs)?
- [ ] Wiederkehrende False-Positive-Muster notieren:
  - [ ] In welchen Bereichen kommentiert Greptile häufig, obwohl du es fast immer ignorierst?
        (z. B. bestimmte generierte Dateien, bekannte Sonderfälle)
- [ ] Ggf. im Greptile-Dashboard **kleine** Justierungen vornehmen:
  - [ ] Custom Rule-Text klarer machen (z. B. „nur bei wirklich großen/verschachtelten Widgets meckern“).
  - [ ] Scope enger ziehen (z. B. bestimmte File-Patterns ausnehmen).
  - [ ] Falls nötig: bestimmte Kommentar-Typen in Settings leicht anpassen
        (aber immer mit Blick auf MVP und nicht übertreiben).

---

## 4. Monatliche Aufgaben (oder bei größeren Änderungen / Releases)

- [ ] `docs/engineering/ai-reviewer.md` prüfen:
  - [ ] Passt sie noch zu:
        - deinen aktuellen Greptile-Settings,
        - der Realität in CI/Branch Protection,
        - deiner Arbeitsweise?
  - [ ] Falls du Regeln/Scopes/FokuPolicy entsprechend aktualisieren.
- [ ] Doku-Sync mit Archon / Dossiers:
  - [ ] Sicherstellen, dass die neueste Version von `ai-reviewer.md` in Archon liegt
        (AI Reviewer Policy – Greptile & CodeRabbit).
  - [ ] Tech-Stack / Gold-Standard / BMAD Global / Roadmap bei Bedarf aktualisiert hochladen,
        damit dort auch das Greptile-Gate + CodeRabbit-lokal-Setup sichtbar ist.
- [ ] Einmal „Meta“ denken:
  - [ ] Gibt es neue Bereiche im Code (z. B. Payments, neue API-Routen), die einen eigenen Bullet
        in den Custom Rules brauchen?
  - [ ] Müssen bestehende Regeln verschärft oder entschärft werden (z. B. neue PII-Fälle, neue
        Supabase-Policies)?
- [ ] Für Handover-Fähigkeit:
  - [ ] Prüfen, ob ein externer Dev, der nur
        - README.md
        - App-Kontext
        - Tech-Stack
        - Gold-Standard
        - **ai-reviewer.md**
        liest, den Greptile/CodeRabbit-Flow verstehen würde.
  - [ ] Falls nein → kleine Ergänzungen in diesen Dokus machen.
