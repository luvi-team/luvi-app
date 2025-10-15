# LUVI – App-Kontext

## Ziel & Haltung
Holistische FemTech-App mit personalisierten Empfehlungen für Training, Ernährung und Regeneration/Mind. Datenschutz steht an erster Stelle (DSGVO-first).

## Consent & Datenschutz (vor Nutzung)
Explizite Einwilligung (Zwecke, Datentypen, Rechte), klare Erklärung optionaler KI-Nutzung (Opt-in). Privacy Policy und AGB jederzeit einsehbar.

## Onboarding Flow
Splash → Welcome → Auth (OAuth; 2FA später) → Consent → Zyklus-Eingabe (Länge, Periodendauer, LMP, Alter).

## Informationsarchitektur & Navigation
Bottom Navigation mit fünf Hauptbereichen:
- Home (Dashboard) – Übersicht
- Zyklus – Kalender & Verlauf
- LUVI Sync – tägliches/wöchentliches Briefing
- Puls – Wearable-Daten & Trends
- Profil – Einstellungen & Zyklus-Parameter

## Dashboard
- Header: Titel + aktuelle Zyklusphase + Notification-Icon.
- Zyklus-Kalender-Farben: Follikel #4169E1 · Ovulation #E1B941 · Luteal #A755C2 · Periode #FFB9B9.
- LUVI Sync Preview: wochen-/phasenbasiertes Briefing mit Top-Empfehlung; bei Wearables Schlaf/Regeneration tages- oder phasenbezogen.
- Training der Woche: 2 Workouts (A/B) + Mobility + Cardio; horizontale Karten; „Erledigt“ = ✅.
- Weitere Empfehlungen:
  - Ernährung & Nutrition: Rezepte, Makros, Supplemente, ggf. KI-Q&A.
  - Regeneration & Achtsamkeit: Meditation, Atmung, Stretching, Journaling (Vorlagen), Voice-Chat-KI optional, Sauna/Eisbaden, Schlaf-Tipps.
- Optional: Wetter, Verkehr, Kleidung, Kalender-Sync, News.

## LUVI Sync
Journal + Empfehlung + (bei Wearables) Schlaf/Regeneration. Briefing-Logik orientiert sich an Zyklusphasen; mit Wearables auch tägliche Akzente.

## Trainingsbereich
Top-Empfehlung führt in den Workout-Screen (Übungen, Videos, Sets, Level). Ein optionaler AI-Trainer schlägt Alternativen bei Einschränkungen vor. Weitere Workouts werden horizontal je nach Phase gelistet.

## Weitere Screens
- Zyklus: Kalender, Vergleich mehrerer Zyklen, Tipps je Phase.
- Puls: Trends zu HR, HRV, Schritten, kcal; Integration Apple Health / Google Fit (Roadmap M4.5).
- Profil: User-Einstellungen + Zyklus-Parameter.

## Betrieb & Compliance
- EU-Only Gateway: Vercel Edge Functions (Region fra1) – transienter, verschlüsselter Proxy; keine persistente PII-Speicherung. Öffentlicher `/api/health`-Endpoint als Betriebsnachweis.
- Supabase (EU): Postgres + Auth + Storage + Realtime mit RLS (owner-based). PII-Redaction im Logging; keine IP/Health-Logs.
- JWT-Verifikation am Gateway; API-Keys serverseitig.
- Interne QS: AI-Tools nur für Code-Review, nicht für personenbezogene Daten.

## Monetarisierung
Freemium + 7‑Tage‑Testphase → Paywall für Premium‑Funktionen (Roadmap M6 Paywall).
