---
Status: Accepted
Date: 2026-01-11
Context: Identifier: ADR-0008-splash-gate-orchestration; canonical path: `context/ADR/0008-splash-gate-orchestration.md`.
Decision: Refer to canonical ADR for rationale behind Splash Controller extraction and gate orchestration patterns.
Consequences: Splash-Architektur-Dokumentation verweist auf diese Begründung.
---

# ADR-0008: Splash Gate Orchestration (Stub)

## Beschluss

Der vollständige Beschluss liegt unter `context/ADR/0008-splash-gate-orchestration.md`.

- [Zum ADR wechseln](../../context/ADR/0008-splash-gate-orchestration.md)

## Kurzfassung

- **Controller-Extraktion**: SplashScreen (650 LOC) → UI (156 LOC) + Controller (498 LOC)
- **State Machine**: Sealed `SplashState` (Initial/Resolved/Unknown)
- **Sequential Gates**: Welcome → Auth → Consent → Onboarding → Home
- **Remote SSOT**: Server-autoritativer State mit Local-Cache-Fallback
- **Race-Retry**: Eventual Consistency für Onboarding-Gate
- **Fail-Closed**: Bei Unsicherheit → sicherer Default (nie Home überspringen)
- **Concurrency Guards**: `_inFlight` + `_runToken` für Request-Deduplizierung
