# Ranking-Heuristik v1.2 (SSOT)

> Version: v1.2 · Datum: 2025-12-03

## Ziel
Dieses Dokument definiert eine klare Score-Formel zur Priorisierung von Stream-Inhalten im LUVI-Feed und beschreibt die Komponenten, Fallbacks und Sicherheitsregeln. Die Heuristik unterstützt eine zyklusbewusste, zielorientierte und dennoch vielfältige Mischung aus Videos und Artikeln. Sie ist einfach gehalten (MVP) und lässt sich später anpassen.

## Score-Formel (v1.2)

```
score = w_phase * phase_score
      + w_goal * goal_match
      + w_recency * recency
      + w_editorial * editorial
      + w_pop * popularity
      + w_affinity * affinity
      - w_div * diversity_penalty
```

### Standardgewichte (v1.2)

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
- **Normalisierung:** Lineare Skalierung, Bereich [-1,1]. 0 = neutral, positiv = Boost, negativ = Malus.
- **Default:** 0.0 (kein Einfluss).
- **Bereich:** [-1,1].
- **Hinweis:** Kann für Safety-Blacklist verwendet werden (stark negativer Wert für problematische Inhalte).

### popularity
- **Zweck:** Popularität (Views/Engagement) berücksichtigen ohne Dominanz.
- **Rohwert:** `views`, optional CTR/Like-Rate.
- **Formel:**
  ```
  pop_raw = ln(views + 1)
  p_norm = (pop_raw - p_p05) / (p_p95 - p_p05)
  popularity = clamp01(p_norm)
  ```
- **Normalisierung:** Quantil-basiert (5.–95. Perzentil); täglich Refit der Quantile.
- **Default:** 0.2 (konservativ) bei fehlenden Metriken.
- **Bereich:** [0,1].

### affinity
- **Zweck:** Persönliche Affinität aus Nutzerinteraktionen (Save/Like/Watchtime/Creator-Präferenz).
- **Rohwert:** Gewichteter Mix:
  - `w_save = 1.0`
  - `w_like = 0.8`
  - `w_watch = 0..1` (normiert nach Duration)
  - `w_creator_pref = 0.3`
- **Formel:**
  ```
  affinity = clamp01(1 - ∏(1 - f_i))
  ```
  Wobei `f_i` die Einzelbeiträge (normiert [0,1]) sind.

  **Erklärung:** Die Produkt-Notation (∏) bedeutet, dass alle `(1 - f_i)` Terme
  miteinander multipliziert werden ("Noisy-OR" Aggregation):

  - `f_i` = einzelne Affinitäts-Komponente (normiert auf [0,1])
  - `∏(1 - f_i)` = Wahrscheinlichkeit, dass *keines* der Signale zutrifft
  - `1 - ∏(...)` = Wahrscheinlichkeit, dass *mindestens ein* Signal zutrifft

  **Rechenbeispiel:**
  Gegeben: f_save = 0.5, f_like = 0.3, f_watch = 0.2

  Schritt 1 – (1 - f_i) berechnen:
    (1 - 0.5) = 0.5 | (1 - 0.3) = 0.7 | (1 - 0.2) = 0.8

  Schritt 2 – Produkt (∏):
    0.5 × 0.7 × 0.8 = 0.28

  Schritt 3 – Komplement:
    affinity = 1 - 0.28 = **0.72** (moderat hohe Affinität)

- **Normalisierung:** Einzelkomponenten auf [0,1]; Endwert clamp [0,1].
- **Default:** 0.5 für neue Nutzer*innen (cold_start).
- **Bereich:** [0,1].

### diversity_penalty
- **Zweck:** Redundanz dämpfen (gleiche Kategorie/Creator in kurzer Zeit; fördert Vielfalt).
- **Rohwert:** Redundanzmaß `r` aus letzten N Interaktionen.
- **Formel:** `diversity_penalty = clamp01(r)` (Anteil gleicher Kategorie in letzten K Items).
- **Normalisierung:** Anteil/Score bereits [0,1].
- **Default:** 0.0 (keine Strafe ohne Historie).
- **Bereich:** [0,1].

## Fallbacks

| Situation | Aktion |
|-----------|--------|
| Fehlender `phase_score` | `phase_score = 0.5` (neutral) |
| Kein `goal_match` | `goal_match = 0.5` (keine Ziele angegeben) |
| Neue Nutzer*innen | `affinity = 0.5` (cold_start) |
| Fehlende Daten für Term | Term aus Score entfernen, restliche Gewichte proportional normieren |

## Invarianten & Sicherheitsregeln

| Regel | Beschreibung |
|-------|--------------|
| **Blacklists** | Inhalte aus Safety-&-Scope-Dossier (extreme Diäten, medizinische Versprechen) dürfen **nie in Top 20** erscheinen, unabhängig vom Score. Verwende `editorial = -1.0` für geblacklistete Inhalte. |
| **Editorial Boost** | Redaktionelle Aufwertungen dürfen das Ranking nur um **max +0.2** erhöhen; Editor*innen müssen Begründung dokumentieren. |
| **Content-Diversität** | In den **Top 10** sollen mindestens **3 verschiedene Pillars** vertreten sein; falls nicht, erhöhe `diversity_penalty` entsprechend. |
| **Score-Clamp** | Endscore wird auf **[0,1]** begrenzt. |
| **Blacklist-Monitoring** | Nach Score-Clamp und Diversity-Penalty: Runtime-Hook prüft Top-N auf `editorial == -1.0`. Bei Fund: Structured Alert `{item_id, final_score, editorial, pipeline_run_id, timestamp}` + Metric-Inkrement `blacklist_breach_total`. Alert triggert On-Call bei ≥1 Breach/Stunde. |

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
- `editorial = -1.0` (Blacklist-Malus)

**Berechnung:**
```
score = ... + 0.10*(-1.0) + ... = stark negativ
```
**Interpretation:** Erscheint nicht in Top 20 (Invariante greift zusätzlich).

## Wie KI dieses Dokument nutzen soll
- `luvi.feed_ranker` **muss** diese Formel als Default-Score verwenden. Anpassungen der Gewichte sind nur im Rahmen expliziter Experimente erlaubt und müssen dokumentiert werden.
- Bei fehlenden Termen sind die **Fallbacks zu verwenden**; KI darf keine eigenen heuristischen Faktoren einführen.
- Andere Agents (z. B. `search_playlist_builder`) können diese Heuristik als Basis nutzen, sollten aber ihre eigenen Parameter definieren, falls sinnvoll.
- Im **Konfliktfall** (Safety-&-Scope-Dossier, Phase-Definitionen) haben die jeweiligen Dossiers Vorrang (z. B. keine verbotenen Inhalte trotz hohem Score).
- Diese Heuristik dient als MVP-Basis; Weiterentwicklungen müssen versioniert und als neue SSOT-Version dokumentiert werden.

## Monitoring & Iteration
- **Parameter:** `H=14` (Recency Halbwertszeit) und Popularitätsquantile regelmäßig neu schätzen (täglich) und überwachen.
- **Cold-Start:** Für neue Nutzerinnen dominieren `phase_score`, `goal_match` und `recency`; `affinity` steigt mit Interaktionen.
- **Monitoring:** Gewichte und Schlagworte überwachen (Impact/Drift, A/B), Fairness/Vielfaltsmetriken reporten.
- **A/B Testing:** Gewichtsänderungen vor Rollout in kontrolliertem Experiment validieren.

## Versionsinfo
- **Version:** v1.2
- **Datum:** 2025-12-03
- **Änderungsverlauf:**
  - v1.2: `goal_match` (Archon v1.1) und `editorial` (Lokal v1.0) kombiniert; detaillierte Formeln aus v1.0 übernommen; Invarianten & Sicherheitsregeln aus Archon integriert; Gewichte neu balanciert.
  - v1.1: Vollständige Score-Formel mit Gewichten, Komponenten, Fallbacks, Invarianten und Beispielen.
  - v1.0: Erste Formel mit TODO-Platzhaltern.
