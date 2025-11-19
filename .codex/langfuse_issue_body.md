---
# Langfuse S0.5 Foundation – Edge-Tracing für AI-Routen

**Warum (Sinn & Nutzen)**  
Langfuse ist unser *Tacho & Flugschreiber* für KI-Aufrufe. Wir sehen pro Request Prompt/Antwort, Latenz, Token/Kosten und können Fehler/Spikes schnell finden. Grundlage für kontrollierte MVP-Features.

**Was bereits erledigt ist (aus unserer Umsetzung)**
- ENV in Vercel gesetzt: `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY`, `LANGFUSE_HOST=https://cloud.langfuse.com` (Preview/Prod).
- Redeploy durchgeführt (ENV aktiv in Edge).
- SDK in `api/` installiert; Helper `api/_lib/langfuse.ts` mit **flushAt:1**, **flushInterval:0**, **debug:true**, optional `shutdownAsync()`.
- Test-Route `api/ai/trace-test.ts` (Edge, `regions:['fra1']`), **NodeNext-Import** mit `.js`, `trace.generation(...)`, `gen.end()`, defensiv `trace.end()`.
- Debug-JSON: `ok`, `safe`, `posted`, `env`, `host`, `traceUrl`, `tookMs`.
- Typische Stolpersteine gelöst: falsches Dashboard (Vercel vs. Langfuse), falscher Projekt-Kontext beim Deeplink, fehlender Flush/Shutdown, NodeNext `.js`.
- Erster Trace in **korrektem** Langfuse-Projekt sichtbar; PR-DoD sieht Trace-Link vor.

**Scope dieses Issues**
Produktionalisierung & Abschluss der S0.5-Foundation:
1) **Routen instrumentieren**: `/api/ai/search`, `/api/ai/playlist`
   - pro Aufruf: `trace`, `generation`, `usage (promptTokens/completionTokens)`, `metadata:{requestId, feature, env, userId?}`
   - am Ende defensiv `shutdownAsync()` (falls vorhanden)
2) **PR-DoD festschreiben** (jede AI-Route):
   - Trace-Link im PR-Thread
   - Kein PII im Prompt/Metadata (Gateway-Masking prüfen)
   - Edge-Latenz P95 Zielwerte definiert
3) **Dashboards & Alerts** (Langfuse):
   - Board “Search/Playlist”: Calls/Tag, Fehlerquote, **P95 Latenz**, **geschätzte Kosten**
   - Alert bei Latenz- oder Kosten-Spike
4) **Docs/Housekeeping**:
   - README „Observability“ Abschnitt: Kurz-HowTo + DoD
   - Troubleshooting-Abschnitt (Keys/Projekt-Kontext/Flush/Deeplink)

**Akzeptanzkriterien (DoD)**
- `/api/ai/trace-test` liefert `ok:true`, `safe:true`, `posted:true`; Trace im richtigen Langfuse-Projekt sichtbar.
- `/api/ai/search` & `/api/ai/playlist` sind instrumentiert (Trace+Generation+usage+metadata).
- In Langfuse existiert ein Board „Search/Playlist“ + mind. 1 Alert (Latenz/Kosten).
- Beispiel-PR zeigt Trace-Link + kein PII im Prompt.
- NodeNext-Import `.js` bestätigt (keine Build-Errors).

**Troubleshooting (Kurz)**
- **Kein Trace** → Redeploy nach ENV-Set; Projekt-Kontext im Langfuse-Dashboard prüfen; Helper mit `flushAt:1` + `shutdownAsync()` nutzen.
- **Trace 404** → Deeplink ohne aktives Projekt; erst Projekt in UI wählen, dann Link öffnen.
- **NodeNext** → relative Imports mit `.js`.
- **Fehlende Kosten/Latenz** → `usage`/`metadata` ergänzen.

**Nächste Schritte**
- [ ] `/api/ai/search` instrumentieren, PR inkl. Trace-Link
- [ ] `/api/ai/playlist` instrumentieren, PR inkl. Trace-Link
- [ ] Dashboard + Alert(s) anlegen
- [ ] README-Abschnitt + Troubleshooting ergänzen
- [ ] DoD in PR-Template aufnehmen

_Assignee:_ <@your-username>  
_Komponenten:_ api, edge, observability, ci  
---
