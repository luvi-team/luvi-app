# Consent-Scopes (Phase 1)

Consent-Scopes definieren, wofür wir explizite Nutzerzustimmungen einholen (z.\u202fB. notwendige AGB oder optionale Features wie AI-Journal). Diese Liste dient Produkt, Privacy und Engineering als gemeinsame Sprache.

Die technisch maßgebliche Quelle liegt in `config/consent_scopes.json` (ID + required-Flag). Änderungen müssen dort beginnen und anschließend synchron in Client, Backend und Tests nachgezogen werden.

| Scope-ID | Pflicht? | Kurzbeschreibung |
| --- | --- | --- |
| terms | Ja | AGB / Nutzungsbedingungen akzeptieren |
| health_processing | Ja | Gesundheitsdaten verarbeiten (DSGVO Art. 9) |
| analytics | Nein | Nutzungsanalyse (anonymisierte App-Nutzung) |
| marketing | Nein | Marketing-Kommunikation (Newsletter, Angebote) |
| ai_journal | Nein | AI-Journal-Funktionen (Inhalte auswerten) |
| model_training | Nein | KI-Modelle mit Nutzungsdaten verbessern |

Weitere Vertrags- oder Juristik-Details folgen in den entsprechenden Consent-Texten; dieses Dokument ist ein operativer Hinweis auf die SSOT.

## Change-Prozess (für Entwickler:innen)
- Scope-Änderung immer zuerst mit Produkt + Legal abstimmen (ID, Pflicht-Flag, Zweck/Kopie).
- `config/consent_scopes.json` anpassen (ID + `required` + Beschreibung aktualisieren oder ergänzen).
- `lib/features/consent/model/consent_types.dart` aktualisieren (`ConsentScope` Enum + `kRequiredConsentScopes`).
- `supabase/functions/log_consent/index.ts` prüfen und `VALID_SCOPES` an die JSON anpassen.
- Tests ausführen: `scripts/flutter_codex.sh test -j 1 test/features/consent/consent_scopes_ssot_test.dart` und `deno test supabase/functions/log_consent/consent_scopes_ssot.test.ts`.
- Bei grünen Tests → PR erstellen und im Beschreibungstext auf die Scope-Änderung hinweisen.
