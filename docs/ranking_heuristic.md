# Ranking-Heuristik v1.0

> Version: v1.0 · Datum: 2025-11-08

## Formel
```
score = 0.40 * phase_match
      + 0.20 * recency
      + 0.15 * editorial
      + 0.10 * popularity
      + 0.10 * affinity
      - 0.05 * diversity
```
<!-- TODO: Bei Bedarf Gewichte/Begriffe anpassen. -->

## Faktoren (Zweck, Formel, Normalisierung, Defaults, Grenzen)

- phase_match
  - Zweck: inhaltliche Passung zur aktuellen Phase der Nutzerin.
  - Rohwert: skalare Ähnlichkeit zwischen `video_phase` und `user.current_phase`.
  - Formel: `phase_match = video_phase[current_phase]` (bereits in [0,1]).
  - Normalisierung: Identität; Clamp auf [0,1].
  - Default (Cold‑Start): 0.5 (neutral), falls Phase unbekannt.
  - Bereich: [0,1].

- recency
  - Zweck: Neuheit gegenüber Upload‑/Erstellzeit bevorzugen.
  - Rohwert: `age_days = (now - created_at) / 1d`.
  - Formel: Exponentialer Zerfall mit Halbwertszeit `H = 14` Tage: `recency = exp(-ln(2) * age_days / H)`.
  - Normalisierung: Resultat liegt in (0,1]; Clamp auf [0,1]. Optionales Floor `min_recency = 0.05`.
  - Default (Cold‑Start): 0.5, wenn `created_at` fehlt.
  - Bereich: (0,1], auf [0,1] geklemmt.

- editorial
  - Zweck: redaktionelles Urteil/Boost oder Malus (Qualität, Kuration, Compliance).
  - Rohwert: Redaktionsscore `e`.
  - Formel: `editorial = e`.
  - Normalisierung: lineare Skalierung, erwarteter Bereich [-1,1]. 0 = neutral, positiv = Boost, negativ = Malus.
  - Default (Cold‑Start): 0.0.
  - Bereich: [-1,1].

- popularity
  - Zweck: Popularität (Views/Engagement) berücksichtigen ohne Dominanz.
  - Rohwert: `views`, optional CTR/Like‑Rate.
  - Formel: `pop_raw = ln(views + 1)`; anschließend Min‑Max auf [0,1] per quantilenstabiler Skala (z. B. 5.–95. Perzentil), dann Clamp.
    - Pseudocode:
      - `p = ln(views + 1)`
      - `p_norm = (p - p_p05) / (p_p95 - p_p05)`
      - `popularity = clamp01(p_norm)`
  - Normalisierung: Quantil‑basiert; Periodisch (täglich) Refit der Quantile.
  - Default (Cold‑Start): 0.2 (konservativ) bei fehlenden Metriken.
  - Bereich: [0,1].

- affinity
  - Zweck: persönliche Affinität aus Nutzerinteraktionen (Save/Like/Watchtime/Creator‑Präferenz).
  - Rohwert: gewichteter Mix, z. B. `w_save=1.0`, `w_like=0.8`, `w_watch=0..1 (normiert)`, `w_creator_pref=0.3`.
  - Formel (Beispiel): `affinity = clamp01(1 - ∏(1 - f_i))`, wobei `f_i` Einzelbeiträge (normiert [0,1]) sind.
  - Normalisierung: Einzelkomponenten jeweils auf [0,1] normieren (z. B. Watchtime/Duration capped bei 0.95); Endwert clamp [0,1].
  - Default (Cold‑Start): 0.0 (keine personalen Signale).
  - Bereich: [0,1].

- diversity
  - Zweck: Redundanz dämpfen (gleiche Kategorie/Creator in kurzer Zeit; fördert Vielfalt).
  - Rohwert: Redundanzmaß `r` aus letzten N Interaktionen (z. B. Anteil gleicher Kategorie in letzten K Items).
  - Formel: `diversity = clamp01(r)`; wird als Strafe subtrahiert.
  - Normalisierung: Anteil/Score bereits [0,1].
  - Default (Cold‑Start): 0.0 (keine Strafe ohne Historie).
  - Bereich: [0,1].

## Beispielrechnung
<!-- TODO: Werte, Normierung und Rundung finalisieren. -->
Gegeben (Platzhalterwerte):
- phase_match = 0.8
- recency = 0.6
- editorial = 0.2
- popularity = 0.5
- affinity = 0.7
- diversity = 0.3

Berechnung:
```
score = 0.40*0.8 + 0.20*0.6 + 0.15*0.2 + 0.10*0.5 + 0.10*0.7 - 0.05*0.3
      = 0.32     + 0.12     + 0.03      + 0.05      + 0.07      - 0.015
      = 0.575
```

## Notizen
- Normalisierung: Alle Faktoren liefern auf [0,1] (bzw. editorial [-1,1]). Endscore kann optional auf [0,1] geklemmt werden, ist aber nicht zwingend.
- Parameter: `H=14` (Recency Halbwertszeit) und Popularitätsquantile regelmäßig neu schätzen (täglich) und überwachen.
- Cold‑Start: Für neue Nutzerinnen dominieren `phase_match`, `recency` und `editorial`; `affinity` steigt mit Interaktionen.
- Monitoring: Gewichte und Schlagworte überwachen (Impact/Drift, A/B), Fairness/Vielfaltsmetriken reporten.
