# LUVI Dossiers v1.0

> Legacy/Archive: This file is not an active SSOT. Use `docs/phase_definitions.md`,
> `docs/consent_texts.md`, and `docs/ranking_heuristic.md` instead.

> Zusammengeführt aus drei Dossiers · Datum: 2025-11-08

## Inhaltsübersicht
- 1. [Phase-Definitionen v1.0](#phase-definitionen-v10)
- 2. [Consent-Texte v1.0](#consent-texte-v10)
- 3. [Ranking-Heuristik v1.0](#ranking-heuristik-v10)

---

# Phase-Definitionen v1.0

> Version: v1.0 · Datum: 2025-11-08

## Ziel/Scope
<!-- TODO: Beschreibe Zielsetzung, Abgrenzung und Anwendungsfälle der Phasenlogik. -->
- Ziel: Konsistente Bestimmung von Zyklusphasen für UI/Logik.
- Scope: Definitionen, Wechselregeln, Unsicherheiten, UI-Hinweise.

## Medizinische und regulatorische Freigabe (Pflicht)
- Medizinische Validierung: Vor Finalisierung Fachreview durch Gynäkologie/Endokrinologie (Phasen-Definitionen, typische Dauern, Übergangsmarker wie z. B. LH‑Peak für Ovulation). Prognosen beeinflussen Gesundheitsentscheidungen von Nutzerinnen.
- Regulatorische Einordnung: Zweckbestimmung prüfen. Bei Aussagen wie Verhütungsunterstützung, Kinderwunsch, Ovulationsdiagnose oder klinischen Empfehlungen ist die App voraussichtlich SaMD (Software as a Medical Device) – bestimmt die nachgelagerten Compliance‑Pflichten.
- EU/US‑Compliance: Falls SaMD, EU MDR (CE‑Kennzeichnung, Risikoklasse, Technische Doku, QMS z. B. ISO 13485) und US FDA‑Pfad (510(k)/De Novo/PMA je Risiko) adressieren.
- Datenschutz: Gesundheitsdaten = besondere Kategorien (DSGVO Art. 9) → explizite Einwilligung, starke Schutzmaßnahmen, ggf. DPIA bei hohem Risiko. In den USA: FTC‑Durchsetzung und State Privacy Laws beachten (Fälle gegen Fertility‑Apps wegen unzulässiger Datenteilung).
- Datenpriorisierung & Unsicherheit/UX: Eingabereihenfolge (Selbstberichte, Sensoren, Historie) definieren, Confidence‑Scores bei Ambiguitäten, UI‑Regeln zur Darstellung inkl. Warn-/Hinweistexte („keine medizinische Beratung“).

Wichtig: Phase‑Definitionen und zugehörige UI‑Logik werden erst nach medizinischem Review und geklärtem regulatorischem Pfad finalisiert.

## Begriffe
<!-- TODO: Präzise Definitionen inkl. Quellen/Verweise. -->
- Menstruation: <!-- TODO: Definition und Abgrenzung, Start-/Endkriterien. -->
- Follikelphase: <!-- TODO: Definition, typische Dauer, Marker. -->
- Ovulation: <!-- TODO: Definition, Identifikatoren (z. B. LH-Peak), Fenster. -->
- Lutealphase: <!-- TODO: Definition, typische Dauer, Marker. -->

## Wechselkriterien
<!-- TODO: Formalisierte Regeln, Offsets, Prioritäten und Konfliktauflösung beschreiben. -->
- Formeln/Offsets: <!-- TODO: z. B. Nutzung von Durchschnittswerten, gleitenden Fenstern, heuristischen Offsets. -->
- Unsicherheiten: <!-- TODO: Umgang mit fehlenden/uneindeutigen Daten, Confidence-Scores, Fallbacks. -->
- Priorisierung: <!-- TODO: Welche Datenquellen haben Vorrang (Selbstberichte, Sensorik, Vorperioden)? -->
- Validierung: <!-- TODO: Plausibilitätschecks, minimale/maximale Phasendauern. -->

## Anwendungslogik im UI
<!-- TODO: Regeln für Darstellung, Badges, Hinweise und Edge-Cases. -->
- Badges: <!-- TODO: Wann welche Badge? Farben/Symbole. -->
- Hinweise: <!-- TODO: Kontextabhängige Tipps/Warnungen im UI. -->
- Leer-/Unsicherheitszustände: <!-- TODO: UX bei niedriger Sicherheit oder fehlenden Daten. -->

## Versionsinfo
- Version: v1.0
- Datum: 2025-11-08
- Änderungsverlauf: <!-- TODO: Changelog-Einträge. -->

---

# Consent-Texte v1.0

> Version: v1.0 · Datum: 2025-11-08

## Long DE (finaler Wortlaut)
<!-- TODO: Finalen deutschen Wortlaut einfügen. -->

## Long EN (final wording)
<!-- TODO: Insert final English wording. -->

## Short DE (finaler Wortlaut)
<!-- TODO: Finalen deutschen Kurztext einfügen. -->

## Short EN (final wording)
<!-- TODO: Insert final short English wording. -->

## Widerruf/Transparenz-Hinweis
- DE: <!-- TODO: Ein Satz zur Widerrufsmöglichkeit und Transparenz. -->
- EN: <!-- TODO: One sentence about withdrawal option and transparency. -->

## Hinweis
⚠️ TODO: Texte juristisch prüfen.

---

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
