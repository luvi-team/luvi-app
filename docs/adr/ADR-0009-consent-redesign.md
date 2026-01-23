---
Status: Accepted
Date: 2026-01-21
Context: Identifier: ADR-0009-consent-redesign; canonical path: `context/ADR/0009-consent-redesign-2026-01.md`.
Decision: Refer to canonical ADR for rationale behind single-screen consent flow and analytics gating.
Consequences: Consent-Architektur-Dokumentation verweist auf diese Begründung.
---

# ADR-0009: Consent Flow Redesign (Stub)

## Beschluss

Der vollständige Beschluss liegt unter `context/ADR/0009-consent-redesign-2026-01.md`.

- [Zum ADR wechseln](../../context/ADR/0009-consent-redesign-2026-01.md)

## Kurzfassung

- **Single-Screen Flow**: 3 Screens → 1 Screen (`/consent/options`)
- **CTA-Logik**: "Weiter" disabled bis Required akzeptiert, "Alle akzeptieren" immer aktiv
- **Scroll-Gate entfernt**: Keine erzwungene Scroll-Position mehr
- **Analytics-Consent Gating**: Privacy-by-Default via `analyticsConsentGateProvider`
- **Append-only Consent Log**: UPDATE blockiert; DELETE nur für Erasure/Retention (GDPR)
- **Legacy-Redirects**: `/consent/intro`, `/consent/blocking`, `/consent/02` → `/consent/options`

## Erfolgskriterien

| # | Kriterium | Status |
|---|-----------|--------|
| 1 | Single Consent Screen | Done |
| 2 | CTA-Logik korrekt | Done |
| 3 | Legacy-Pfade redirecten | Done |
| 4 | 148 Tests grün | Done |
| 5 | Analytics nur mit Opt-in | Done |
| 6 | Consent-Log append-only | Done |
| 7 | ADR dokumentiert | Done |
