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
