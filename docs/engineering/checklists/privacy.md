# QA/DSGVO Checklist (Health/FemTech)

Ziel: Privacy by Design praktisch prüfen – Einwilligung, Rechte, TOMs, Evidenzen.

Rechtsgrundlagen & Prinzipien
- Art. 5 (Zweckbindung, Minimierung, Speicherbegrenzung), Art. 6/9 (Rechtsgrundlagen/Gesundheitsdaten), Art. 25 (PbD/Default).

Consent‑Lifecycle
- Granulare Scopes; informierte Opt‑ins; Widerruf so einfach wie Erteilung; Historie versioniert.

Betroffenenrechte (DSAR)
- SOPs für Auskunft/Berichtigung/Löschung; 1‑Monats‑Frist; Ident‑Prüfung; Backups im Löschkonzept.

TOMs & Logging
- Verschlüsselung (Transit/At‑rest); RLS; least‑privilege; keine PII in Logs (Redaction aktiv).

AVV/Transfers
- AVV für Vercel/Supabase/Analytics; EU‑Region; SCC/TIA nur wenn unvermeidbar.

Incident Response
- 72h‑Meldeweg; Rollen/On‑Call; Vorlagen; regelmäßige Übungen.

Evidenzen (bereit halten)
- Verarbeitungsverzeichnis, Privacy Policy, Consent‑Nachweise, DSAR‑Register, AVVs/SCCs, Pentest‑Report, Audit‑Logs‑Auszug, DSFA.

Anti‑Patterns
- Dark Patterns; PII in Logs/Crash; unbegrenzte Speicherung; Service‑Role im Client; Profiling ohne Basis.

Verweise
- Review‑Vorlage: `docs/privacy/reviews/` (bestehende Dateien/Template)
- IR-Runbook: `docs/runbooks/incident-response.md`
