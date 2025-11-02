# Runbook: Verify External Video Consent (YouTube IFrame)

Zweck: CMP/Consent vor dem Laden externer YouTube‑Inhalte verifizieren (Overlay, Events, Widerruf, Retention). No‑Ad‑Interference sicherstellen.

## Wann verwenden
- Neue/angepasste CMP‑Texte (Long/Short, DE/EN)
- Player/Overlay‑Änderungen, Routing oder Flags
- DSGVO‑Audit/Export, Regressionen, Dead‑Link/Fallback Tests

## Voraussetzungen
- Testaccount mit Login
- Mind. 1 Video mit `video_id` in Seed‑Daten
- Flags aktiv: `enable_stream_v1=true`, `enable_player_iframe=true`

## Schritt 1: Overlay vor IFrame‑Load
1. App → `/player/:id` öffnen (z. B. per Tap aus `Stream`).
2. Erwartung: Consent‑Overlay sichtbar, YouTube‑IFrame NICHT im DOM.
3. Netzwerk prüfen: Bis zur Zustimmung keine Requests zu `*.youtube.com`, `*.googlevideo.com`.
4. Event: `video_consent_shown` mit `{video_id, locale, cmp_variant}`.

## Schritt 2: Zustimmung (Accept)
1. Overlay → „Akzeptieren“.
2. Erwartung: YouTube‑IFrame mit `youtube-nocookie` geladen; Player‑UI unmodifiziert (No‑Ad‑Interference).
3. Events: `video_consent_accept`, anschließend `video_play_start`.
4. DB‑Log (owner‑RLS):
   ```sql
   select user_id, video_id, decision, ts, ua_hash, ip_hash, client_version, locale
   from consent_logs
   where user_id = auth.uid() and video_id = '<video_id>'
   order by ts desc limit 1;
   -- Erwartung: decision = 'accept'
   ```

## Schritt 3: Ablehnung (Decline)
1. Overlay → „Ablehnen“.
2. Erwartung: Kein IFrame; Button „Auf YouTube öffnen“ (Deep‑Link extern).
3. Events: `video_consent_reject`, bei Tap `video_open_youtube_external`.
4. DB‑Log: `decision = 'decline'` für `video_id`.

## Schritt 4: Widerruf (Settings)
1. Profil → Datenschutz → Consent‑Verwaltung → Externe Inhalte widerrufen.
2. Erwartung: Nächster Player‑Aufruf zeigt wieder Overlay (Long beim ersten Mal, sonst Short).
3. Events: `video_consent_shown` erneut; Logs bleiben append‑only (kein Delete).

## Schritt 5: Meilensteine/Performance
- Events (mindestens):
  - `video_milestone_25_percent|50_percent|95_percent`
  - `video_like|video_save|video_share|video_resume`
- Performance Budgets: Player‑Start P95 < 1.2 s nach Consent.

## Retention & Compliance
- `consent_logs` Retention 12 Monate, Export/Löschung in Settings; UA/IP als Hash.
- RLS: owner‑based; kein `service_role` im Client.
- Text benennt „Datenübertragung an Google/YouTube“ + „Cookies/Local Storage“. DE/EN vorhanden.

## Negative Tests
- Overlay umgehen: Direktaufruf Player → Overlay MUSS greifen (kein IFrame vorher).
- Offline: Overlay bleibt funktional, Fallback‑Copy sichtbar; kein IFrame.
- Dead‑Links: Nicht embed‑fähige Videos → „❌ Nicht verfügbar – ähnliche Videos“.

## Backout/Flags
- `enable_player_iframe=false` → Kein IFrame, nur Deep‑Link.
- `enable_stream_v1=false` → Player‑Route nicht erreichbar; Backout dokumentieren.

## Erfolgskriterien
- Kein externer Request vor Consent.
- Korrekte Events/Logs; Widerruf erzwingt Overlay erneut.
- No‑Ad‑Interference eingehalten; Performance‑Budget erfüllt.
