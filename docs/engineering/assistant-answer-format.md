# Assistenten-Antwortformat (CLI – verbindlich)

Gilt verbindlich für alle Assistenten-Antworten in diesem Repo (Codex CLI-first).

## Struktur
- Mini-Kontext-Check – Sprint-Goal, DoD, relevante ADRs, Memory
- Warum – Business-Grund für diese Aktion
- Schritte – deterministisch, copy-paste-fähig
- Erfolgskriterien –
  - rollen-spezifisch gem. DoD (UI/DataViz inkl. Flutter-Tests; Backend/DB/QA ohne Flutter-Tests)
  - RLS/Consent (falls relevant) ✅
  - Sentry/PostHog Smoke (UI) ✅
  - Vercel Health (Preview/Prod: `/api/health → 200`) ✅
  - Greptile Review (Required Check) ✅ · CodeRabbit optional lokal
- Undo/Backout – Befehle zur Rücknahme (nur als Code-Block, niemals ausführen)
- Nächster minimaler Schritt – direkt folgend
- Stop-Kriterien – Security/Compliance-Verstöße, Pfad-Abweichungen

## Kurzregeln (CLI-Stil)
- Abschnittsüberschriften nur bei Mehrwert; in Title Case und fett: `**Kurzer Titel**`.
- Bullets mit `- `, eine Zeile je Punkt; verwandte Punkte zusammenfassen.
- Befehle, Dateipfade, Env-Variablen, Code-Bezeichner in Backticks: `flutter test`, `lib/main.dart`.
- Dateireferenzen als klickbarer Pfad mit Startzeile: `lib/home_screen.dart:42`; keine Bereiche, keine URLs.
- Erlaubte Formate: Repo-relativ (`lib/...`), Diff-Präfix `a/`/`b/`, Workspace-absolute Pfade (`/Users/.../lib/...`) nur wenn nötig.
- Kein tiefes Bullet-Nesting, keine langen Listen; 4–6 Punkte pro Block sind ideal.
- Ton: knapp, aktiv, ohne Füllwörter; einfache Antworten minimal halten.
- Für größere Aufgaben strukturierte Abschnitte nutzen; für einfache nur kurze Listen/Absätze.
- Keine schweren Formatierungen oder ANSI-Codes; keine Inline-Zitat-Formate.
- Vor Tool-Aufrufen kurze Preambles (1–2 Sätze) mit dem nächsten Schritt.
- Plan-Tool für mehrstufige Aufgaben nutzen; nicht bei trivialen Ein-Schritt-Aufgaben.
