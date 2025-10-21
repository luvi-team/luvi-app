# Analytics Taxonomy & Event Schema (EU/DSGVO)

Namenskonvention
- `context:object_action` (snake_case), präsentisches Verb, sprechend (z. B. `signup_flow:pricing_page_view`).
- Versionierung bei Bedeutungswechsel (`_v2`).

PII‑Policy
- Keine PII in Events; nur anonyme IDs/Hashes; Consent‑Gates strikt beachten.

Schema‑Template (Tabellarisch)

| Event Name | Beschreibung | Properties | Version | Consent | Owner |
|---|---|---|---|---|---|
| string | string | Key:Typ/Einheit | string | Ja/Nein | string |

Governance
- Änderungen via PR + Review (DataViz prüft auf Compliance, QA validiert Implementierung); Changelog führen; CI‑Hinweis im PR‑Report.
- CI validiert Event-Schema gegen diese Richtlinie und blockiert Merges bei Verstößen.
- Bei Fragen: [link zu ADR/Governance-Doc]; Disputes werden via [Eskalationspfad] gelöst.
