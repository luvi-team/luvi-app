# ADR-0004: Vercel Edge Gateway (EU/fra1)

Status: Accepted
Owner: Platform/Backend
Date: 2025-10-17

## Kontext
LUVI verarbeitet sensible (Gesundheits‑)Daten. Ein schlankes, EU‑basiertes Gateway soll als einzige Eintrittsschicht für externe Aufrufe (insb. AI/Webhooks) dienen und dabei Latenz minimieren sowie DSGVO‑Anforderungen (Region/Evidence/Logging‑Redaction) erfüllen.

## Entscheidung
- Gateway läuft als Vercel Edge Function, Region EU `fra1` (EU‑Only Verarbeitung).
- Health‑Soft‑Gate: Öffentlicher Endpoint `/api/health` muss 200 + JSON liefern (Preview & Prod) als Betriebs‑Evidenz.
- Sicherheitsprinzipien:
  - JWT‑Verifikation am Gateway; Secrets/AI‑Keys ausschließlich serverseitig.
  - CORS: dynamische Allow‑List; `OPTIONS` kurzschließen; keine `*` mit Credentials.
  - Rate‑Limit (Burst + Tages‑Quota) und Circuit‑Breaker für Downstreams.
  - Strukturierte Logs mit rekursiver PII‑Redaction; `request_id` propagieren.
- Edge‑Runtime‑Konventionen:
  - `export const config = { runtime: 'edge' }` (ohne `as const`).
  - ESM‑Imports mit `.js`‑Endungen für lokale Module; keine Node‑Only APIs.

## Begründung
- Edge (EU) senkt Latenz, wahrt Datenhoheit und reduziert Angriffsfläche (ein zentrales Tor).
- Health‑Soft‑Gate liefert prüfbare Betriebs‑Evidenz (DoD/Release‑Gate) ohne Overhead.
- Redaction/CORS/JWT/Rate‑Limit standardisieren Sicherheit/Compliance, reduzieren Fehler.

## Konsequenzen
- Entwicklung: ESM/Edge‑Kompatibilität und `.js`‑Endungen strikt beachten.
- Observability: SLIs (Verfügbarkeit, p95 Latenz, Fehlerquote) + Alerts einführen.
- EU‑Region ist verbindlich; Non‑EU Provider nur mit SCC/TIA und Pseudonymisierung.

## Rollout
- Preview per PR; Health 200 prüfen (Runbook). Danach Prod‑Smoke (Health 200) verlinken.
- Contract‑Tests: CORS/OPTIONS, 401/403/405/413/429, Schema‑Validation.

## Nicht‑Ziele
- Kein Persistenz‑Layer am Gateway (transient). Keine PII‑Logs. Kein Client‑Zugriff auf Service‑Keys.

## Verweise
- Implementation: `api/health.ts`, `api/utils/logger.ts`
- Runbook: `docs/runbooks/vercel-health-check.md`
- CI Gates: `/.github/workflows/ci.yml`
- ADRs: 0001 RAG‑First, 0002 Least‑Privilege/RLS, 0003 MIWF
