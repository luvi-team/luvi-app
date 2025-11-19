# LUVI — App-Kontext 

1) Ziel & Haltung
LUVI ist eine kuratierte, zyklus-personalisierte Health & Lifestyle Content-Plattform für Frauen (DACH).
Wir liefern täglich passende Video-Impulse (Workout, Ernährung & Biohacking, Regeneration & Achtsamkeit, Beauty/Lifestyle).
Datenschutz ist Kernprinzip (EU-Only, DSGVO-first). Coach-Programme & KI-Suche/Playlists bilden den Premium-Mehrwert.
 
2) Value Proposition & Premium
• Free (Stream): Täglicher Video-Feed, „Heute in deiner Phase“, Daily-5 Kurzimpulse, Speichern/Playlist-Basis, Teilen.
• Premium (IAP): Coach-Programme (LUVI-eigene Pläne), KI-Suche & KI-Playlists (semantisch, phasebewusst), optional ad-light/ad-free im Feed (nie im YouTube-Player).
• Nutzenversprechen: „Öffne LUVI und sieh in 30 Sekunden, was heute gut für dich ist.“

3) Consent & Datenschutz (Externe Inhalte)
• Vor dem Abspielen von YouTube-Videos erscheint ein Einwilligungs-Overlay (Long beim ersten Mal, danach Short; DE/EN).
• Klar benannt: Datenübertragung an Google/YouTube, Speicherung (Cookies/Local Storage), Widerruf jederzeit.
• Ablehnen → „Auf YouTube öffnen“ (kein IFrame). Akzeptieren → offizieller YouTube-IFrame (youtube-nocookie).
• Consent-Logs (user_id, video_id, decision, timestamp, ua_hash, ip_hash, client_version, locale), Retention 12 Monate; Export/Löschung über Einstellungen.
  
  Datenschutz-Update (ip_hash, DSGVO):
  • Rechtsgrundlage: Speicherung von IP-Hashs erfolgt primär auf Basis berechtigter Interessen (Art. 6 Abs. 1 lit. f DSGVO) zur IT‑Sicherheit, Missbrauchs-/Fraud‑Prävention, Abuse‑Rate‑Limiting und Audit‑Nachweis; alternativ über Einwilligung (Art. 6 Abs. 1 lit. a DSGVO) sofern im Consent‑Flow ausgewählt. Freigabe/Dokumentation: „Legal‑Freigabe v1.1“; Hinterlegung in docs/privacy/ (inkl. Abwägung und Zweckbindung).
  • Hashing‑Verfahren: Strikt einweg, mit starker Salz/Pepper‑Strategie.
    – Algorithmus/Versionierung: ip_hash_version = v1 (HMAC‑SHA256 mit systemweiter Pepper, im Secret Store), optional v2 (Argon2id mit Pepper+Salt).
    – Pepper wird getrennt vom Datenbankzugriff verwaltet (z. B. Secret Manager/Edge‑Config). Salts werden pro Eintrag generiert oder über rotierende System‑Pepper gelöst. Keine Möglichkeit zur Rückrechnung (kein Reversing).
  • Aufbewahrung: Standard 12 Monate – Begründung: (a) Rechts-/Nachweisinteressen (Audit/Abuse), (b) Betrugsprävention/Rate‑Limiting, (c) Qualitäts-/Sicherheitsaudits im Jahreszyklus. Retention als Policy konfigurierbar (z. B. 3/6/12 Monate) und dokumentiert; automatische Löschung/Archivierung via Scheduled Job/Edge Function (inkl. Löschprotokoll) nach Ablauf.
  • Verträge/Notizen: AV‑/DPA‑Ergänzung und interne Privacy Notes um „gehashte IPs“ erweitern; Datenexport umfasst ip_hash (inkl. Version) und erlaubt nutzerinitiierte Löschung. Die in Abschnitt „Consent‑Logs“ referenzierten Export‑/Löschmechanismen decken ip_hash vollständig ab (inkl. referenzieller Kaskaden/Löschroutinen).

4) Technische Grundlage & Betrieb
• EU-Only Gateway: Vercel Edge (fra1) als verschlüsselter Proxy; /api/health als Betriebsnachweis.
• Supabase (EU): Postgres + Auth + Storage + Realtime; RLS owner-based; PII-Redaction im Logging; kein service_role im Client.
• YouTube: offizieller IFrame-Player, keine Player-Overlays/Ad-Interferenz, kein Download; Fallback-Link.
• AI (Premium): Edge in EU; stateless; keine PII-Persistenz der Prompts.

5) Onboarding Flow
Splash → Welcome → Consent (App) → Auth → Onboarding (Zyklus-Eckdaten, Ziele, Intensität) + Content-Präferenzen (Kategorien, Sprache) → Success Screen.

6) Informationsarchitektur & Navigation
1. Home — „Heute in deiner Phase“ (Hero 3–6) + Daily-5 (kurze Impulse) + „Weiter ansehen“ + „Neu im LUVI“.
2. Stream — Endlos-Feed mit Filtern (Kategorie, Dauer, Sprache, Creator), Tabs: Alle • Shorts • Langform • Gespeichert.
3. Coach (Premium) — Programme/Workouts (Preview sichtbar, Start Premium).
4. Puls — Health-Baseline & Trends (Post-MVP, read only).
5. Profil — Einstellungen, Datenschutz (Consent/Export/Löschung), Präferenzen, Sprache.

7) Home (Dashboard)
• Phase-Badge + Hinweistext.
• Reihen: „Heute in deiner Phase“ → Daily-5 (< 10–12 min) → „Weiter ansehen“ → „Neu“.
• Dezent: Coach-Teaser (kontextuell, nicht aufdringlich).

8) Screens (MVP)
• Stream: Karten (Thumbnail, Phase-Badge, Dauer, Kategorie, Mini-Takeaway, CTAs).
• Player: Consent-Overlay (Long/Short; DE/EN) → YouTube-IFrame; darunter Tags/Phase-Scores, ähnliche Videos, Speichern/Teilen.
• Coach (Preview): Programm-Übersicht, Wochenstruktur, Badges; Start über Paywall (Premium).
• Suche (Premium): „Frag LUVI …“ (semantisch); Treffer + „Als Playlist speichern“.
• Profil: Datenschutz (Consent-Verwaltung, Export/Löschung), Präferenzen, Sprache, Restore Purchases.

9) Coach/Trainingsbereich (Premium)
• 4-Wochen-Pläne (2× Ganzkörper, 1× Mobility, 1× Cardio), progressiv; Hinweise je Phase.
• Coach-Content ist LUVI-eigen (nicht YouTube), optional offline-fähig.

10) Personalisierung & KI
• Ranking v1: Phase-Match → Recency/Qualität → Affinität (save/like/watchtime) – einfach & performant.
• KI v1 (Premium): semantische Suche/Playlists über eigene Metadaten (Titel, Kurzbeschreibung, Tags, Phase-Scores) mit pgvector; stateless, EU-Edge.

11) Monetarisierung
• IAP-Abo (StoreKit/Play Billing): Trial 7 Tage (MVP), Preis DE/AT/CH konsistent; Restore Purchases; klare Kündigungswege.
• Sponsoring/Affiliate (Post-MVP): nur außerhalb des YouTube-Players, klar gekennzeichnet.

12) Wording & Marken
• „zyklusbasiert/zyklussynchron“ statt geschützter Begriffe; Privacy & EU-Only als Vertrauensvorteil.
• Store-Listing: defensiv („kuratiert aus DACH & global“), keine unbelegten Mengenclaims.

13) Betrieb & Compliance
• Health-Gate (/api/health), Crash/Perf (Sentry/PostHog), Owner-basierte RLS-Policies.
• Consent-by-Design, Export/Löschung nutzergeführt, Quartals-Audit (Legal) und monatliche YouTube-API-Prüfung.
• Keine Modifikation/Blockierung des YouTube-Players (No-Ad-Interference), kein Download.

14) Erfolgsmessung (Auszug)
• North Star: Watch-Time/DAU (phase-angepasst) oder D7-Retention im Stream.
• Inputs: CTR Home-Hero, Daily-5 Completion, Save-/Share-Rate, Feed→Coach-Click, Trial→Paid %, Play→95 % Completion.
