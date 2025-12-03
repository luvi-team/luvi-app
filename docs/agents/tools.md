# LUVI – Agents & Tools v1.0

> Quelle: Archon-Dossier „LUVI – Agents & Tools v1.0“ (Stand 2025-11-23)

## Zweck
Dieses Dokument beschreibt die Archon-Agents im LUVI-Ökosystem. Es definiert für jeden Agenten seinen Purpose, erlaubte Eingaben/Ausgaben, verbindliche Dossiers sowie Fehlverhalten. Ziel ist, klar festzuhalten, welche Aufgaben ein Agent übernimmt und welche Informationen er berücksichtigen muss.

## Agent-Liste (MVP)
- `luvi.feed_ranker`
- `luvi.cycle_explainer`
- `luvi.search_playlist_builder`
- `luvi.coach_recommender`

## Agent-Contracts

### `luvi.feed_ranker`
- **Purpose:** Berechnet Scores für Videos im Stream basierend auf Phase, Zielen, Recency und weiteren Signalen; liefert eine sortierte Liste von Video-IDs.
- **Inputs:** `phase` (string), `goals` (Liste von Pillar-/Ziel-IDs), `history_events` (zuletzt angesehene/gespeicherte Video-IDs), optionale `user_preferences`.
- **Outputs:** JSON `{ "videos": [ { "video_id": string, "score": float } ] }`.
- **Verbindliche Dossiers:** `docs/ranking_heuristic.md`, `docs/phase_definitions.md`, `docs/product/safety_scope.md`.
- **Fehlerverhalten:** Fehlende Eingaben ⇒ Fallbacks aus Ranking-Heuristik anwenden; bei leerem Ergebnis neutrale Liste (Top Editorial); keine Inhalte zurückgeben, die Safety & Scope verletzen.

### `luvi.cycle_explainer`
- **Purpose:** Erstellt eine kurze, nutzerorientierte Erklärung der aktuellen Zyklusphase für Lifestyle-Empfehlungen.
- **Inputs:** `cycle_day`, `phase` (string), optionale `cycle_flags` (z. B. `assumed_cycle`, `irregular_cycle`).
- **Outputs:** JSON `{ "text": string }` mit lokalisierter Copy.
- **Verbindliche Dossiers:** `docs/phase_definitions.md`, `docs/product/safety_scope.md`, (optional) Glossar/Wording.
- **Fehlerverhalten:** Bei unbekannter Phase neutrale Beschreibung liefern; keine Diagnosen/medizinischen Aussagen; Standard-Disclaimer berücksichtigen.

### `luvi.search_playlist_builder`
- **Purpose:** Generiert aus einer Nutzeranfrage eine semantisch passende Playlist mit verfügbaren Videos.
- **Inputs:** `query` (string), `available_videos` (Liste mit Metadaten), optionale `time_budget`, `level`.
- **Outputs:** JSON `{ "playlist": [ video_id, ... ] }`.
- **Verbindliche Dossiers:** `docs/ranking_heuristic.md` (Score-Gewichtung), `docs/product/safety_scope.md`.
- **Fehlerverhalten:** Bei unklaren/leeren Suchbegriffen neutrale Playlist ausspielen; wenn keine Treffer gefunden werden, leere Liste + Hinweis, dass neue Inhalte folgen.

### `luvi.coach_recommender`
- **Purpose:** Empfiehlt Coach-Programme / Deep-Dive-Serien entsprechend Nutzerzielen, Präferenzen und ggf. Zyklusphase.
- **Inputs:** `goals`, `phase`, `completed_programs` (IDs), optionale `time_commitment`.
- **Outputs:** JSON `{ "programs": [ { "program_id": string, "reason": string } ] }`.
- **Verbindliche Dossiers:** Programmdaten (Supabase), `docs/phase_definitions.md`, `docs/product/safety_scope.md`, aktueller MVP-Scope (nur verfügbare Programme empfehlen).
- **Fehlerverhalten:** Wenn keine Phase/Goals vorhanden sind → generische Einsteigerprogramme nennen; keine Empfehlungen außerhalb des MVP-Scopes oder gegen Safety & Scope.

## Wie KI dieses Dokument nutzen soll
- Dieses File ist die maßgebliche Spezifikation für interne Archon-Agents; es definiert ihre Schnittstellen und verweist auf die relevanten Dossiers.
- Agents dürfen nur innerhalb ihres Purpose operieren und keine zusätzlichen Datenfelder anfordern oder erzeugen.
- Bei Konflikten zwischen Anforderungen verschiedener Dossiers gilt die Priorität aus `docs/bmad/global.md` (BMAD → SSOT → Roadmap).
- Safety-&-Scope-Regeln sind strikt einzuhalten; Inhalte, die dort verboten sind, dürfen nicht zurückgegeben werden.
