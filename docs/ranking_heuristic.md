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

## Faktoren (Erläuterung, Standardwerte, Grenzen)
- phase_match: <!-- TODO: Definition (0..1), Standardberechnung, Mindest-/Maximalwerte. -->
- recency: <!-- TODO: Zeitzerfall/Decay-Funktion, Normalisierung 0..1. -->
- editorial: <!-- TODO: Redaktionsboost, Default=0.0, Bereich -1..+1. -->
- popularity: <!-- TODO: Views/CTR normalisieren (Log/Quantiles), 0..1. -->
- affinity: <!-- TODO: Personalisierung/Ähnlichkeit, 0..1, Cold-Start-Default. -->
- diversity: <!-- TODO: Redundanzpenalität/Serienähnlichkeit, 0..1. -->

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
- Normalisierung: <!-- TODO: Sicherstellen, dass alle Faktoren kompatibel skaliert sind. -->
- Grenzen: <!-- TODO: Score auf [0,1] clampen oder z-score verwenden? -->
- Monitoring: <!-- TODO: Drift/Impact der Gewichte regelmäßig evaluieren. -->

