# Analytics Taxonomy & Event Schema (EU/DSGVO)

Namenskonvention
- `context:object_action` (snake_case), präsentisches Verb, sprechend (z. B. `signup_flow:pricing_page_view`).
- Versionierung bei Bedeutungswechsel (`_v2`).

PII‑Policy
- Keine PII in Events; nur anonyme IDs/Hashes; Consent‑Gates strikt beachten.

Schema‑Template (Tabellarisch)
- Felder: Event Name · Beschreibung · Properties (Key:Typ/Einheit) · Version · Consent (Ja/Nein) · Owner

Beispiel
- `signup_flow:pricing_page_view` · „Pricing im Signup gesehen“ · `plan_tier:string`, `page_duration_sec:number` · v2 · Consent: Nein · Owner: Growth

Governance
- Änderungen via PR + Review (DataViz + QA); Changelog führen; CI‑Hinweis im PR‑Report.

