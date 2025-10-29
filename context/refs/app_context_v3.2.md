LUVI — App-Kontext (v3.2 – bereinigt & konsolidiert)
Version: 2025-10-15

1) Ziel & Haltung
LUVI ist eine holistische FemTech-App mit personalisierten Empfehlungen in den Bereichen Training, Ernährung, Regeneration und Achtsamkeit.  
Datenschutz steht an erster Stelle (DSGVO-first). Die App begleitet Nutzerinnen durch den Zyklus und steigert Wohlbefinden und Leistungsfähigkeit.

---

2) Value Proposition & Trainings-Abo
- Workout-Abonnement: Alle 4 Wochen erhält die Nutzerin einen maßgeschneiderten Plan, der sich an Zyklusstand, Intensität und Volumen anpasst.  
  Jeder Plan baut progressiv auf dem vorherigen auf (Mikro-/Makrozyklen, Load-Wochen).  
  Ziel: „Zero Decision Fatigue“ – alles ist fertig vorkonfiguriert.

---

3) Consent & Datenschutz
Vor Erstnutzung wird eine explizite Einwilligung eingeholt mit klarer Beschreibung von Zwecken, Datentypen, Rechten und optionaler KI-Nutzung (Opt-in).  
Privacy Policy und AGB sind jederzeit einsehbar.

---

4) Technische Grundlage & Betrieb
- EU-Only Gateway: Vercel Edge Functions (Region fra1) – transienter, verschlüsselter Proxy, keine persistente PII-Speicherung.  
  Öffentlicher `/api/health`-Endpoint als Betriebsnachweis.  
- Supabase (EU): Postgres + Auth + Storage + Realtime mit RLS (owner-based). PII-Redaction im Logging; keine IP/Health-Logs.  
- JWT-Verifikation am Gateway, API-Keys serverseitig.  
- Interne QS: AI-Tools (Traycer etc.) nur für Code-Review, nicht für personenbezogene Daten.

---

5) Onboarding Flow
- Splash → Welcome → Consent → Auth (OAuth · 2FA später) → Onboarding (Name, Geburtstag, Ziele, letzte Periode, Dauer der Periode, Dauer des Zyklus, Zyklusintensität, Trainingslevel, Onboarding-Success-Screen).  
- Auth-Screens: Auth Entry · Register · Login · PW-Reset · Verification (Code eingeben) · Success · Create new PW · Verification/E-Mail bestätigen

---

6) Informationsarchitektur & Navigation
Bottom-Navigation mit fünf Hauptbereichen:  
1. Home (Dashboard) – Übersicht  
2. Zyklus – Kalender & Verlauf  
3. LUVI Sync – tägliches/wöchentliches Briefing und Journal über Zyklus, Trainings, Biohacking, Regeneration, Achtsamkeit usw. (Yin-Yang-Logo)  
4. Puls – Wearable-Daten & Trends  
5. Profil – Einstellungen & Zyklus-Parameter

---

7) Home (Dashboard)
- Header: Titel + aktuelle Zyklusphase + Notification-Icon.  
- Zyklus-Kalender-Farben: Follikel #4169E1 · Ovulation #E1B941 · Luteal #A755C2 · Periode #FFB9B9  
- LUVI Sync Preview: wochen-/phasenbasiertes Briefing mit Top-Empfehlung; bei Training; bei Wearables: Schlaf/Regeneration tages- oder phasenbezogen.  
- Allgemeine Informationen zur aktuellen Zyklusphase
- Training der Woche: 2 Workouts (A/B) + Mobility + Cardio · horizontale Karten · „Erledigt“ = ✅.  
- Weitere Empfehlungen:  
  - Ernährung & Nutrition: Rezepte, Makros, Supplemente, KI-Q&A.  
  - Regeneration & Achtsamkeit: Meditation, Atmung, Stretching, Journaling (Vorlagen), Voice-Chat-KI, Sauna/Eisbaden, Schlaf-Tipps.

---

8) Einzel-Screens
- Zyklus: Kalender · Vergleich mehrerer Zyklen · Tipps je Phase.  
- LUVI Sync: Journal + Empfehlung + (bei Wearables) Schlaf/Regeneration.  
- Puls: Trends zu HR, HRV, Schritten, kcal; Integration Apple Health/Google Fit (geplant in M4.5).  
- Profil: User-Einstellungen + Zyklus-Parameter.

---

9) Trainingsbereich
Top-Empfehlung führt in den Workout-Screen (Übungen, Videos, Sets, Level).  
Weitere Workouts horizontal nach Phase.

---


10) AI-Personalisierung (Opt-in) & Sicherung
- Einsatz: Analysen, Trends, Empfehlungen  
- Sicherung: Alle AI-Requests über EU-Gateway (fra1) mit PII-Redaction & JWT-Verifikation; API-Keys serverseitig.

---

11) Monetarisierung
Freemium + 7-Tage-Testphase → Paywall für Premium-Funktionen (M6 Paywall in Roadmap).

---

12) Icons (UI-Konventionen)
Zyklus 🌸 · LUVI Sync ☯ · Puls 📊 · Profil 👤

---

13) Betrieb & Compliance
- Health-Check (`/api/health`) als Betriebsnachweis.  
- Logging: PII-redacted (keine IP/Health-Daten).  
- Supabase EU mit RLS (Owner-Policy).  
- Transiente Verarbeitung am Gateway – keine PII-Persistenz.
