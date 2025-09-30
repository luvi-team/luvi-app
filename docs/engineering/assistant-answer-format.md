# Assistenten-Antwortformat (v2)

## Struktur
- Mini-Kontext-Check – Sprint-Goal, DoD, relevante ADRs, Memory
- Warum – Business-Grund für diese Aktion
- Schritte – deterministisch, copy-paste-fähig
- Erfolgskriterien – rollen-spezifisch gem. DoD oben (UI/DataViz inkl. Flutter-Tests; Backend/DB/QA ohne Flutter-Tests) · RLS/Consent (falls relevant) ✅ · Sentry/PostHog Smoke (UI) ✅ · CodeRabbit ✅
- Undo/Backout – Befehle zur Rücknahme (nur als Code-Block, niemals ausführen)
- Nächster minimaler Schritt – direkt folgend
- Stop-Kriterien – Security/Compliance-Verstöße, Pfad-Abweichungen

