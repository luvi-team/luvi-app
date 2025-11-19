# DSGVO Review Checklist

Verbindliche Prüfliste für datenrelevante Tasks. Ausfüllen durch Feature-Owner (RLS Owner) und Compliance Reviewer; Dokumentation im PR erforderlich.

## Pflichtfelder
- **PII-Inventar:** Welche personenbezogenen Daten werden verarbeitet? Klassifiziere (PII, Sensitive PII, Aggregated) und begründe Notwendigkeit.
- **Identifier & Scope:** Auflistung aller IDs/Keys (User-ID, Device-ID, Session-ID, Drittanbieter-IDs); Prüfe Pseudonymisierung/Minimierung.
- **Retention & TTL:** Speicherdauer, Lösch-/Anonymisierungs-Trigger, TTL-Konfiguration und Cleanup-Prozess (inkl. Cron/Worker).
- **Consent & Rechtsgrundlage:** Dokumentiere Opt-in/Opt-out-Mechanik, Consent-Timestamps, Revocation-Flows und UI/Copy-Referenzen.
- **Third-Party Sharing:** Liste alle externen Empfänger (APIs, SaaS, Analytics), Vertragsstatus (AVV/DPA), Datenkategorien & Übertragungszweck.

## Zusätzliche Checks
- **Security Controls:** Verschlüsselung (in Transit/at Rest), Zugriffskontrollen, Audit-Logs.
- **RLS & Database Security:** Verify Row Level Security (RLS) policies for all database operations involving PII. Document RLS policy tests and edge-case coverage.
- **Data Subject Rights:** Export/Löschung korrigierbar? Verweise auf Umsetzung (CLI, Support Workflow, automatisiert).
- **Testing Evidence:** Links zu Unit/Integrationstests, simulierten Consent/Deletion-Flows, Monitoring/Alerting. Include `flutter test` results and `flutter analyze` output for data-handling code.
- **Reviewer-Sign-off:** Initialen + Datum von Owner & Compliance; optionale automatisierte Scanner/Reports anhängen.
