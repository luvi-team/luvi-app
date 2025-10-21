# Traycer Prompt (MVP · Slim)

Zweck
- Minimaler, konditionaler Plan-Generator für Feature‑Aufgaben (nicht für 2‑Min‑Bugfixes). Liefert kurze, ausführbare Pläne, die direkt mit Codex/Claude umgesetzt werden.

SSOT (nur referenzieren, nicht kopieren)
- Auto‑Role Map: `context/agents/_auto_role_map.md`
- Acceptance v1.1 (Core + Role Extensions): `context/agents/_acceptance_v1.1.md`
- Antwortformat (CLI): `docs/engineering/assistant-answer-format.md`

Grundregeln
- Keine PII/Secrets in den Plan geben. Nur Pfade/Kommandos, keine Tokens.
- Konditional: RLS/Privacy nur bei DSGVO‑Impact ≥ Medium; Health nur bei Gateway‑Touch.
- Output in Markdown, klar strukturiert; optional (nicht Pflicht) darf direkt danach ein JSON-Block folgen, max. 6 Zeilen, ausschließlich mit den Keys `role`, `keywords`, `acceptance_version`, `steps`, `prove`, `privacy_note`, ohne weitere Keys/Nesting und strikt ohne PII/Secrets/Tokens.

Pflichtfelder (kurz, prägnant)
- Role: <aus Auto‑Role Map> | Keywords: [k1, k2]
- DSGVO‑Impact: Low | Medium | High
- BMAD (je 1 Satz)
  - Business: …
  - Modeling: …
  - Architecture: …
  - DoD: … (rollen‑spezifisch)
- Plan (4–6 deterministische Schritte)
- Prove (rollen‑spezifisch, minimal)
  - UI/DataViz: `flutter analyze`, `flutter test` (≥1 Widget)
  - API/Backend: Runtime‑passend (z. B. TS/Edge: Lint/Tests; Health 200 nur bei Gateway‑Touch)
  - DB‑Admin: RLS‑Probe nur bei Medium/High (4 Policies + Trigger benennen)
- Privacy‑Note (1 Satz, warum Low/Medium/High)

Inline‑Self‑Check (für Codex/Claude vor dem Run)
- [ ] Tests passend zur Rolle (UI ≥1 Widget | API/DB passende Tests)
- [ ] RLS‑Probe nötig? (nur bei DSGVO Medium/High) Falls ja: im Plan erwähnt
- [ ] Health‑Check nötig? (nur bei Gateway‑Touch) Falls ja: im Plan erwähnt
- [ ] Privacy‑Note gesetzt (Low/Medium/High)
- [ ] Plan‑Schritte deterministisch (4–6), keine Platzhalter
- [ ] Fail-fast: Wenn eine Box offen bleibt, Implementierung abbrechen und Checkliste an Autor:in zurückgeben (nicht starten)

Durchsetzung: Umsetzung startet erst, wenn alle Boxes im Inline-Self-Check abgehakt sind.

Beispiel – UI (Low)
- Role: ui‑frontend | Keywords: [Widget, Screen] | DSGVO‑Impact: Low
- BMAD
  - Business: Onboarding‑Screen 02 portieren; keine PII, DSGVO Low.
  - Modeling: Stateless Widget + thematisierte Tokens; Route via GoRouter.
  - Architecture: Neues Widget, Theme‑Tokens, i18n; keine Edge/DB.
  - DoD: `flutter analyze` + ≥1 Widget‑Test; UI‑Polisher Kurz‑Review.
- Plan
  - Erstelle `lib/features/onboarding/onboarding_screen.dart` mit Token‑basiertem Layout.
  - Registriere Route in `lib/app_router.dart` und verknüpfe Navigation.
  - Wende Theme‑Tokens (Farben/Spacing/Typography) via `ThemeExtensions` an.
  - Schreibe Widget‑Test `test/features/onboarding/onboarding_screen_test.dart` (Titel + CTA vorhanden).
  - Ergänze knappe Doku `docs/ui/onboarding.md` (Token‑Mapping + Route).
- Prove
  - `flutter analyze`
  - `flutter test` (≥1 Widget)
  - Privacy‑Note: Low (keine PII/DB/Tracking)

Beispiel – API (Medium, Gateway‑Touch)
- Role: api‑backend | Keywords: [Edge, Health] | DSGVO‑Impact: Medium
- BMAD
  - Business: Health‑Endpoint als Betriebs‑Evidenz (200 JSON) für EU‑Gateway.
  - Modeling: Request=leer, Response=`{ ok: boolean, timestamp: string }`.
  - Architecture: Vercel Edge Handler `api/health.ts` (ESM + `.js` Imports), CORS kurzschließen.
  - DoD: Lint/Tests passend zur Runtime (TS/Edge: Contracts), Health 200 (Preview/Prod) gemäß Runbook.
- Plan
  - Implementiere `api/health.ts` mit `export const config = { runtime: 'edge' }` und JSON‑Antwort.
  - Sichere ESM‑Imports mit `.js` für lokale Utils; keine Node‑Only APIs.
  - CORS: OPTIONS kurzschließen mit Allow‑List; Health offen halten.
  - Ergänze Contract‑Test (Schema/Status 200) in `api/tests/health.test.ts`.
  - Verifiziere Preview/Prod laut `docs/runbooks/vercel-health-check.md`.
- Prove
  - Lint/Tests passend zur Runtime (z. B. TS/Edge: Contracts)
  - Health‑Check: `/api/health` → 200 + JSON (Preview & Prod)
  - Privacy‑Note: Medium (Betriebsmetadaten ohne PII)

Optionale JSON‑Zusammenfassung (nicht Pflicht)
```json
{
  "role": "ui-frontend",
  "keywords": ["Widget","Screen"],
  "acceptance_version": "1.1",
  "steps": ["…","…","…","…"],
  "prove": ["flutter analyze","flutter test"],
  "privacy_note": "Low"
}
```

Nutzung
- Für Feature‑/Story‑Tasks nutzen; für 2‑Min‑Bugfixes weglassen.
- Plan direkt in die PR‑Beschreibung kopieren; Codex/Claude wenden den Inline‑Self‑Check vor der Umsetzung an.
