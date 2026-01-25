# Ranking-Heuristik v1.5 (SSOT)

> Version: v1.5 · Datum: 2026-01-25

## Ziel
Dieses Dokument definiert eine klare Score-Formel zur Priorisierung von Stream-Inhalten im LUVI-Feed und beschreibt die Komponenten, Fallbacks und Sicherheitsregeln. Die Heuristik unterstützt eine zyklusbewusste, zielorientierte und dennoch vielfältige Mischung aus Videos und Artikeln. Sie ist einfach gehalten (MVP) und lässt sich später anpassen.

## Score-Formel (v1.5)


| Gewicht | Wert | Begründung |
|---------|------|------------|
| `w_phase` | 0.30 | Kernfeature: Zyklusphase-Matching |
| `w_goal` | 0.20 | Personalisierung nach Nutzerzielen |
| `w_recency` | 0.15 | Aktualität bevorzugen |
| `w_editorial` | 0.10 | Redaktionelle Qualitätskontrolle |
| `w_pop` | 0.10 | Beliebte Inhalte berücksichtigen |
| `w_affinity` | 0.10 | Persönliche Präferenzen |
| `w_div` | 0.05 | Vielfalt durch Redundanz-Strafe |

**Summe positiver Gewichte:** 0.95 (diversity wird subtrahiert)

## Komponenten (Zweck, Formel, Normalisierung, Defaults)

### phase_score
- **Zweck:** Misst, wie gut das Video zur aktuellen Zyklusphase passt.
- **Rohwert:** Skalare Ähnlichkeit zwischen `video_phase` und `user.current_phase`.
- **Formel:** `phase_score = video_phase[current_phase]` (bereits in [0,1]).
- **Datenstruktur:** `video_phase` ist ein Dictionary/Map mit Phasen-Keys:
  ```json
  {
    "menstruation": 0.8,
    "follikel": 0.6,
    "ovulation": 0.4,
    "luteal": 0.9
  }
  ```
  Zugriff: `video_phase["luteal"]` → `0.9` (phase_score für Lutealphase).
- **Normalisierung:** Identität; Clamp auf [0,1].
- **Default:** 0.5 (neutral), wenn `phase = unknown` oder `none`.
- **Bereich:** [0,1].

### goal_match
- **Zweck:** Bewertung des Matchings zwischen Video und aktuellen Zielen der Nutzerin (z. B. „besser schlafen", „mehr Energie").
- **Rohwert:** Kosinus-Ähnlichkeit oder Tag-Overlap zwischen Video-Tags und User-Goals.
- **Formel:** `goal_match = similarity(video.tags, user.goals)`.
- **Normalisierung:** Auf [0,1] skalieren.
- **Default:** 0.5 (neutral), wenn keine Ziele angegeben.
- **Bereich:** [0,1].

### recency
- **Zweck:** Neuheit gegenüber Upload-/Erstellzeit bevorzugen.
- **Rohwert:** `age_days = (now - created_at) / 1d`.
- **Formel:** Exponentialer Zerfall mit Halbwertszeit `H = 14` Tage:
  ```
  recency = exp(-ln(2) * age_days / H)
  ```
- **Normalisierung:** Resultat liegt in (0,1]; Clamp auf [0,1]. Optionales Floor `min_recency = 0.05`.
- **Default:** 0.5, wenn `created_at` fehlt.
- **Bereich:** [0,1].

### editorial
- **Zweck:** Redaktionelles Urteil/Boost oder Malus (Qualität, Kuration, Compliance).
- **Rohwert:** Redaktionsscore `e` (-1 bis +1).
- **Formel:** `editorial = e`.
- **Normalisierung:** Lineare Skalierung, Eingabebereich [-1,1]. 0 = neutral, positiv = Boost, negativ = Malus.
- **Tatsächlicher Impact:** `editorial × w_editorial`. Mit `w_editorial = 0.10` ist der maximale Einfluss auf den Endscore **±0.10** (nicht ±1.0).
- **Default:** 0.0 (kein Einfluss).
- **Bereich:** [-1,1].
- **Hinweis:** Kann für Safety-Blacklist verwendet werden (stark negativer Wert für problematische Inhalte).
- **Operational Note (Spezifikation für Implementierung):** Der `editorial`-Score SOLL wie folgt gesetzt werden:
  - **Input:** Admin-UI "Editorial Score" Feld oder CMS-Metadaten
  - **Speicherung:** DB-Spalte `content_item.editorial_score` (DECIMAL, Constraint: CHECK(editorial_score >= -1 AND editorial_score <= 1))
  - **Berechtigungen:** Nur Redakteure (role: `editor`) und Admins dürfen den Wert setzen
  - **Validierung:** API/DB-Constraint erzwingt Bereich [-1, 1]
  - **Status:** Noch nicht implementiert — wird in S5 (Brain Content) umgesetzt

> **⚠️ IMPLEMENTATION STATUS: NOT YET IMPLEMENTED**
>
> - **Target Sprint:** S5 (Brain Content)
> - **Fallback Behavior:** Systems MUST treat `editorial = 0.0` until implementation
> - **DB Schema:** `content_item.editorial_score` (DECIMAL, CHECK >= -1 AND <= 1)
> - **Permissions:** Role `editor` and `admin` only
> - **Migration:** Will be created in S5; no current migration exists
> - **Feature Flag:** `FEATURE_EDITORIAL_SCORES` (to be added)

### popularity
- **Zweck:** Popularität (Views/Engagement) berücksichtigen ohne Dominanz.
- **Rohwert:** `views`, optional CTR/Like-Rate.
- **Formel:**
  ```
  EPSILON = 1e-9  // Floating-point Toleranz
  pop_raw = ln(views + 1)

  if abs(p_p95 - p_p05) < EPSILON:
      p_norm = 0.5  // Neutral bei fehlender Varianz
  else:
      p_norm = (pop_raw - p_p05) / (p_p95 - p_p05)

  popularity = clamp01(p_norm)
  ```
- **Normalisierung:** Quantil-basiert (5.–95. Perzentil); täglich Refit der Quantile.
- **Edge-Case:** Falls `abs(p_p95 - p_p05) < EPSILON` (alle Items haben nahezu identische Views), wird `p_norm = 0.5` (neutral) gesetzt, um Division durch Null zu vermeiden. EPSILON = 1e-9 für Floating-Point-Sicherheit.
- **Default:** 0.2 (konservativ) bei fehlenden Metriken.
- **Bereich:** [0,1].

### affinity
- **Zweck:** Persönliche Affinität aus Nutzerinteraktionen (Save/Like/Watchtime/Creator-Präferenz).
- **Rohwert:** Gewichteter Mix aus vier Signal-Typen mit folgenden Gewichten:
  - `w_save = 1.0` (Save-Signal)
  - `w_like = 0.8` (Like-Signal)
  - `w_watch = 1.0` (Watch-Signal; implizit angewandt da Identität — `f_watch` ist bereits auf [0,1] normiert; Weight bleibt für zukünftiges Tuning konfigurierbar)
  - `w_creator_pref = 0.3` (Creator-Preference-Signal)
- **Formel:**
  ```
  affinity = clamp01(1 - ∏(1 - f_i))
  ```
  Wobei `f_i` die Einzelbeiträge (normiert [0,1]) sind.

  **Signal-to-Component Transformation:**

  Vor Anwendung der Noisy-OR Aggregation werden rohe Nutzerinteraktions-Signale in normierte Komponenten `f_i ∈ [0,1]` transformiert:

  1. **Save-Signal (binär):**
     - Formel: `f_save = w_save × (1 if user saved else 0)`
     - Ausgabebereich: `{0.0, 1.0}` (diskret: entweder 0.0 oder 1.0)
     - Beispiel: User saved → `f_save = 1.0 × 1 = 1.0` | Nicht saved → `f_save = 1.0 × 0 = 0.0`

  2. **Like-Signal (binär):**
     - Formel: `f_like = w_like × (1 if user liked else 0)`
     - Ausgabebereich: `{0.0, 0.8}` (diskret: entweder 0.0 oder 0.8)
     - Beispiel: User liked → `f_like = 0.8 × 1 = 0.8` | Nicht liked → `f_like = 0.8 × 0 = 0.0`

  3. **Watch-Signal (kontinuierlich):**
     - Formel:
       ```
       if video_duration <= 0:
           f_watch = 0.0
       else:
           f_watch = min(1.0, watch_time / video_duration)
       ```
     - Ausgabebereich: `[0.0, 1.0]` (kontinuierlich, geclampt)
     - Beispiel: 45s von 60s Video geschaut → `f_watch = min(1.0, 45/60) = 0.75`

  4. **Creator-Preference-Signal (kontinuierlich):**
     - Formel: `f_creator_pref = w_creator_pref × user_creator_affinity_score`
     - Wobei `user_creator_affinity_score ∈ [0,1]` (abgeleitet aus historischen Interaktionen mit Creator)
     - Ausgabebereich: `[0.0, 0.3]` (kontinuierlich, skaliert durch Weight)
     - Beispiel: Hohe Creator-Affinität (0.9) → `f_creator_pref = 0.3 × 0.9 = 0.27`

  Alle `f_i`-Werte sind explizit auf `[0,1]` beschränkt, bevor sie in der Noisy-OR-Formel verwendet werden.

  **Privacy & Consent Requirements:**

  - **Consent:** Affinity-Tracking (Save/Like/Watch) erfordert Nutzereinwilligung unter dem `analytics`-Scope (siehe `docs/privacy/consent_scopes.md`). Implementierungen MÜSSEN vor Tracking-Start die Consent-Prüfung durchführen.
  - **RLS-Anforderung (Implementation Note):** Falls Affinity-Daten persistiert werden (z. B. `user_saves`, `user_likes`, `user_watch_history`), MÜSSEN Tabellen RLS-geschützt sein mit Owner-based Policy: `user_id = auth.uid()` (ADR-0002).
  - **Datenminimierung:** Affinity-Scores sind aggregiert; rohe Interaktions-Logs folgen 90-Tage-Retention gemäß ADR-0006 Patterns.
  - **Push Privacy:** Affinity-Daten werden NIEMALS in Push-Payloads inkludiert (ADR-0005).

  **Erklärung:** Die Produkt-Notation (∏) bedeutet, dass alle `(1 - f_i)` Terme
  miteinander multipliziert werden ("Noisy-OR" Aggregation):

  - `f_i` = einzelne Affinitäts-Komponente (normiert auf [0,1])
  - `∏(1 - f_i)` = Wahrscheinlichkeit, dass *keines* der Signale zutrifft
  - `1 - ∏(...)` = Wahrscheinlichkeit, dass *mindestens ein* Signal zutrifft

  **Rechenbeispiel 1 (Hohe Affinität):**
  Gegeben: f_save = 1.0 (saved), f_like = 0.8 (liked), f_watch = 0.6 (60% geschaut), f_creator_pref = 0.15 (affinity 0.5)

  Schritt 1 – (1 - f_i) berechnen:
    (1 - 1.0) = 0.0 | (1 - 0.8) = 0.2 | (1 - 0.6) = 0.4 | (1 - 0.15) = 0.85

  Schritt 2 – Produkt (∏):
    0.0 × 0.2 × 0.4 × 0.85 = 0.0

  Schritt 3 – Komplement:
    affinity = 1 - 0.0 = **1.0** (maximale Affinität: saved + liked + hohe Watch-Time)

  **Rechenbeispiel 2 (Moderate Affinität):**
  Gegeben: f_save = 0.0 (nicht saved), f_like = 0.0 (nicht liked), f_watch = 0.5, f_creator_pref = 0.21 (affinity 0.7)

  Schritt 1 – (1 - f_i) berechnen:
    (1 - 0.0) = 1.0 | (1 - 0.0) = 1.0 | (1 - 0.5) = 0.5 | (1 - 0.21) = 0.79

  Schritt 2 – Produkt (∏):
    1.0 × 1.0 × 0.5 × 0.79 = 0.395

  Schritt 3 – Komplement:
    affinity = 1 - 0.395 = **0.605** (moderate Affinität trotz fehlender Save/Like, durch Watch + Creator-Preference)

  **Mathematischer Hintergrund (Noisy-OR):**
  Diese Formel basiert auf der "Noisy-OR" Aggregation aus der Wahrscheinlichkeitstheorie.
  Sie nimmt probabilistische Unabhängigkeit der Signale an: Jedes Signal (`save`, `like`, `watch`)
  trägt unabhängig zur Gesamtaffinität bei.

  > **Referenz:** Pearl, J. (1988). *Probabilistic Reasoning in Intelligent Systems*, Kap. 4.3 (Noisy-OR gates in Bayesian networks).

- **Normalisierung:** Einzelkomponenten auf [0,1]; Endwert clamp [0,1].
- **Default:** 0.5 für neue Nutzer*innen (cold_start).
- **Bereich:** [0,1].

### diversity_penalty
- **Zweck:** Redundanz dämpfen (gleiche Kategorie/Creator in kurzer Zeit; fördert Vielfalt).
- **Rohwert:** Redundanzmaß `r` basierend auf Pillar-Überlappung der letzten K angezeigten Items.
- **Formel:**
  ```
  last_K_items = get_last_displayed_items(user, K)  // K = 10
  same_pillar_count = count(i in last_K_items where i.pillar == current_item.pillar)
  r = same_pillar_count / K
  diversity_penalty = clamp01(r)
  ```
- **Definitionen:**
  - `current_item.pillar`: Content-Pillar des zu bewertenden Items (z.B. "Sleep", "Nutrition", "Movement")
  - `get_last_displayed_items(user, K)`: Die letzten K dem User angezeigten Items
  - `same_pillar_count`: Anzahl Items mit gleichem Pillar wie das aktuelle Item
- **Parameter:** `K = 10` (Anzahl der letzten angezeigten Items für Redundanzberechnung; MVP-Default).
- **Normalisierung:** Anteil bereits [0,1] durch Division durch K.
- **Default:** 0.0 (keine Strafe ohne Historie).
- **Bereich:** [0,1].

**Rechenbeispiel:**
- Letzte 10 Items: 4× "Sleep", 3× "Nutrition", 2× "Movement", 1× "Mindfulness"
- Aktuelles Item: Pillar = "Sleep"
- `same_pillar_count = 4`
- `r = 4 / 10 = 0.4`
- `diversity_penalty = clamp01(0.4) = 0.4`

> **MVP-Hinweis:** Für Multi-Dimensionen (Pillar + Creator) kann später eine gewichtete Kombination verwendet werden:
> `r = w_pillar × (same_pillar_count/K) + w_creator × (same_creator_count/K)` mit `w_pillar + w_creator = 1`.

## Fallbacks

**Default-Policy (Regel):** Fehlende nutzerspezifische Daten erhalten neutrale Defaults (0.5).

| Situation | Aktion |
|-----------|--------|
| Fehlender `phase_score` | `phase_score = 0.5` (neutral) |
| Kein `goal_match` | `goal_match = 0.5` (keine Ziele angegeben) |
| Neue Nutzer*innen | `affinity = 0.5` (cold_start) |

**Alternative Policy (Ausnahme):** Term entfernen und Gewichte renormieren — NUR wenn ein Feature für ALLE Kandidaten im Batch strukturell nicht verfügbar ist (z.B. `popularity` bei komplett neuen Inhalten ohne Views-Daten für den gesamten Batch).

## Invarianten & Sicherheitsregeln

| Regel | Beschreibung |
|-------|--------------|
| **Blacklist Pre-Filter** | **Primary defense:** Items mit `editorial == -1.0` werden **VOR dem Scoring** aus dem Kandidaten-Pool entfernt. Diese Items erhalten keinen Score und erscheinen nie im Feed. |
| **Blacklists (Top-20 Garantie)** | **Secondary defense (defense-in-depth):** Runtime-Sicherheitsnetz das prüft, ob trotz Pre-Filter ein geblacklistetes Item in Top-20 erscheint. Fängt Edge-Cases ab (Race Conditions, Cache-Stale, Pipeline-Bugs). Verwende `editorial = -1.0` für geblacklistete Inhalte. Bei Auslösung → siehe Blacklist-Monitoring. |
| **Editorial Boost** | Redaktionelle Aufwertungen dürfen das Ranking nur um **max +0.10** erhöhen (`w_editorial × max_editorial = 0.10 × 1.0`); Editor*innen müssen Begründung dokumentieren. |
| **Content-Diversität** | In den **Top 10** sollen mindestens **3 verschiedene Pillars** vertreten sein; falls nicht, erhöhe `diversity_penalty` entsprechend. |
| **Score-Clamp** | Endscore wird auf **[0,1]** begrenzt. |
| **Blacklist-Monitoring** | Runtime-Hook prüft Top-20 auf `editorial == -1.0` als **Sicherheitsnetz**. Jeder Fund ist ein **operationaler Incident** (nicht normales Rauschen): Structured Alert `{item_id, final_score, editorial, pipeline_run_id, timestamp}` + Metric `blacklist_breach_total`. Sofortige Eskalation bei jedem Breach. |

### Content-Diversität Enforcement (MVP-Vorschlag)

**Mechanismus:** Post-Score Swap-Strategie

1. Score alle Kandidaten mit der Formel oben
2. Wähle Top 10 nach Score
3. Prüfe Pillar-Diversität: Zähle unique Pillars
4. Falls <3 Pillars: Tausche das niedrigst-bewertete Item eines überrepräsentierten Pillars mit dem höchst-bewerteten Item eines fehlenden Pillars aus Rang 11+
5. Wiederhole bis Constraint erfüllt oder keine eligiblen Swaps

> **Hinweis:** Dies ist ein MVP-Vorschlag. Die finale Implementierung sollte im Team abgestimmt werden.

> **Hinweis zu Editorial-Werten:** Beispiele B und C verwenden nicht-null `editorial`-Werte zur Illustration zukünftigen Verhaltens. Bis `FEATURE_EDITORIAL_SCORES` in S5 implementiert ist, behandelt das System `editorial = 0.0` (siehe Abschnitt "Implementation Status" oben).

## Beispiele

### Beispiel A: Optimaler Match (Luteal-Phase)
**Input:**
- Phase: Luteal (`phase_score = 0.9`)
- Ziel: „besser schlafen" (`goal_match = 0.8`)
- Video vor 3 Tagen (`recency ≈ 0.86`)
- Editorial: neutral (`editorial = 0.0`)
- Popularity: mittel (`popularity = 0.5`)
- Affinity: hoch (`affinity = 0.7`)
- Diversity: niedrig (`diversity_penalty = 0.1`)

**Berechnung:**
```
score = 0.30*0.9 + 0.20*0.8 + 0.15*0.86 + 0.10*0.0 + 0.10*0.5 + 0.10*0.7 - 0.05*0.1
      = 0.27    + 0.16     + 0.129      + 0.0       + 0.05      + 0.07      - 0.005
      = 0.674
```
**Interpretation:** Sehr gut geeignet; sollte in Top-Sektion angezeigt werden.

### Beispiel B: Cold Start (neue Nutzerin)
**Input:**
- Phase: unknown (`phase_score = 0.5`)
- Ziel: fehlt (`goal_match = 0.5`)
- Video 2 Jahre alt (`recency ≈ 0.05`)
- Editorial: leichter Boost (`editorial = 0.3`)
- Popularity: hoch (`popularity = 0.9`)
- Affinity: neutral (`affinity = 0.5`)
- Diversity: mittel (`diversity_penalty = 0.3`)

**Berechnung:**
```
score = 0.30*0.5 + 0.20*0.5 + 0.15*0.05 + 0.10*0.3 + 0.10*0.9 + 0.10*0.5 - 0.05*0.3
      = 0.15    + 0.10     + 0.0075     + 0.03      + 0.09      + 0.05      - 0.015
      = 0.4125
```
**Interpretation:** Mittleres Ranking; erscheint weiter unten im Feed.

### Beispiel C: Blacklisted Content
**Input:**
- Inhalt verstößt gegen Safety-Policy
- Phase: Follikel (`phase_score = 0.7`)
- Ziel: neutral (`goal_match = 0.5`)
- Video vor 5 Tagen (`recency ≈ 0.78`)
- Editorial: **Blacklist** (`editorial = -1.0`)
- Popularity: mittel (`popularity = 0.5`)
- Affinity: neutral (`affinity = 0.5`)
- Diversity: niedrig (`diversity_penalty = 0.1`)

**Berechnung:**
```
score = 0.30*0.7 + 0.20*0.5 + 0.15*0.78 + 0.10*(-1.0) + 0.10*0.5 + 0.10*0.5 - 0.05*0.1
      = 0.21    + 0.10     + 0.117      - 0.10        + 0.05      + 0.05      - 0.005
      = 0.422
```
**Interpretation:** Dieser Inhalt wird durch den **Blacklist Pre-Filter** bereits VOR dem Scoring aus dem Kandidaten-Pool entfernt. Die Berechnung oben dient nur zur Illustration des Score-Impacts von `editorial = -1.0`. In der Produktion erscheint dieser Inhalt nie im Feed.

## Wie KI dieses Dokument nutzen soll
- `luvi.feed_ranker` **muss** diese Formel als Default-Score verwenden. Anpassungen der Gewichte sind nur im Rahmen expliziter Experimente erlaubt und müssen dokumentiert werden.
- Bei fehlenden Termen sind die **Fallbacks zu verwenden**; KI darf keine eigenen heuristischen Faktoren einführen.
- Andere Agents (z. B. `search_playlist_builder`) können diese Heuristik als Basis nutzen, sollten aber ihre eigenen Parameter definieren, falls sinnvoll.
- Im **Konfliktfall** (Safety-&-Scope-Dossier, Phase-Definitionen) haben die jeweiligen Dossiers Vorrang (z. B. keine verbotenen Inhalte trotz hohem Score).
- Diese Heuristik dient als MVP-Basis; Weiterentwicklungen müssen versioniert und als neue SSOT-Version dokumentiert werden.

## Monitoring & Iteration

### Parameters
- `H = 14` — Recency half-life in days (fix für MVP). Recency-Scores werden täglich neu berechnet mit H=14.
- `K = 10` — Window size of last displayed items for diversity/redundancy penalty.
- `min_recency = 0.05` — Floor für Recency-Normalisierung (verhindert dass sehr alte Inhalte auf 0 fallen). Typ: float, Bereich: [0,1].

### Feed-Impact Validation (Pre-Swap)

**Procedure:**
1. Sample ~100 zufällige User-Feeds
2. Berechne Top-50 Items mit alten und neuen Quantilen
3. Spearman Rank-Korrelation berechnen
4. **Logging:** `quantile_swap_spearman {sample_size, median_correlation, p10, p90}`
5. **Alert:** `quantile_correlation_alert` wenn `median_correlation < 0.90`
6. **Gate:** Swap nur bei `median_correlation >= 0.90`; sonst Alert + manuelle Review

### Popularity Quantiles Refit
- **Schedule:** Daily at **UTC 02:00** (low-traffic window)
- **Procedure:** Compute new p05/p95 from last 30 days of data while serving current quantiles
- **Swap:** Atomic replacement of quantile values after computation completes
- **Transition:** None for MVP — instant swap is acceptable because quantile drift is gradual (day-to-day changes are typically <5%, so ranking churn is minimal)
- **Logging:** Log `quantile_refit_completed {p05_old, p05_new, p95_old, p95_new, duration_ms}`
- **Rollback:** On failure, retain previous quantiles and alert `quantile_refit_failed`

### Post-Swap Monitoring (Churn Detection)

Nach dem atomaren Swap:
1. **Churn-Sampling:** Erste Stunde nach Swap
2. **Metriken:**
   - Kendall Tau Korrelation (Pre vs Post Top-50)
   - `pct_gt_5_positions`: % Items mit >5 Rang-Verschiebung
3. **Logging:** `churn_summary {kendall_tau, pct_gt_5_positions, sample_window_ms}`
4. **Alert:** `quantile_churn_alert` wenn `pct_gt_5_positions > 20%`
5. **Auto-Rollback:** Bei Threshold-Breach → `quantile_refit_failed` + Revert zu vorherigen Quantilen

### Cold-Start
Für neue Nutzerinnen dominieren `phase_score`, `goal_match` und `recency`; `affinity` steigt mit Interaktionen.

### Monitoring (MVP-Schwellenwerte)
- **Drift:** Alert wenn Score-Verteilung >15% vom 7-Tage-Durchschnitt abweicht (Kolmogorov-Smirnov Test)
- **Diversität:** Alert wenn <3 Pillars in Top-10 bei >5% der generierten Feeds
- **Cadence:** Wöchentliche Review der Metriken
- **Eskalation:** Bei 2+ konsekutiven Alerts → Investigation innerhalb 48h

### A/B Testing (MVP-Regeln)
- Min. 1000 Users pro Variante vor Entscheidung
- 95% Konfidenzintervall für statistische Signifikanz
- Max. 2 Wochen Laufzeit pro Experiment
- Gewichtsänderungen vor Rollout in kontrolliertem Experiment validieren

## Versionsinfo
- **Version:** v1.5
- **Datum:** 2026-01-25
- **Änderungsverlauf:**
  - v1.5: CodeRabbit Review Fixes (Batch 3)
    - Clarify: `diversity_penalty` Formel mit expliziter Pillar-basierter Berechnung
    - Add: `diversity_penalty` Rechenbeispiel und Definitionen
    - Add: MVP-Hinweis für Multi-Dimensionen (Pillar + Creator)
    - Fix: `popularity` Division-by-Zero Guard mit EPSILON = 1e-9
    - Add: `popularity` Edge-Case Dokumentation für identische Views
  - v1.4: CodeRabbit Review Fixes (Batch 2)
    - Add: Hinweis zu Editorial-Werten in Beispielen (S5 Feature Flag)
    - Fix: `f_watch` Formel mit explizitem Edge-Case für `video_duration ≤ 0`
    - Clarify: `w_watch` Weight-Anwendung (implizit da Identität)
  - v1.3: CodeRabbit Review Fixes
    - Fix: Editorial Boost max +0.10 (war fälschlich +0.2)
    - Add: Blacklist Pre-Filter vor Scoring
    - Add: `min_recency` Parameter dokumentiert
    - Clarify: Fallback-Policy (Default vs Alternative)
    - Clarify: H=14 ist fix für MVP
    - Clarify: Editorial Impact-Skalierung (`editorial × w_editorial`)
    - Add: Konkrete Monitoring-Schwellenwerte (Drift 15%, Diversität 5%, A/B 1000 Users)
    - Add: Quantile-Refit operationelle Details (UTC 02:00, atomic swap, logging)
  - v1.2: `goal_match` (Archon v1.1) und `editorial` (Lokal v1.0) kombiniert; detaillierte Formeln aus v1.0 übernommen; Invarianten & Sicherheitsregeln aus Archon integriert; Gewichte neu balanciert.
  - v1.1: Vollständige Score-Formel mit Gewichten, Komponenten, Fallbacks, Invarianten und Beispielen.
  - v1.0: Erste Formel mit TODO-Platzhaltern.
