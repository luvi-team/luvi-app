# Phase-Definitionen v1.3 (SSOT)

> Version: v1.3 · Datum: 2026-01-25

## Zweck & Scope
Dieses Dokument definiert die Berechnungslogik für die vier Zyklusphasen (Menstruation, Follikel, Ovulation, Luteal) und legt Fallback-Regeln fest. Ziel ist es, eine konsistente, nachvollziehbare und nicht-medizinische Phasenbestimmung für die UI, das Feed-Ranking und KI-Agents bereitzustellen. Die Phasen dienen ausschließlich der Lifestyle-Steuerung (Workouts, Schlaf, Mind, Ernährung) und dürfen nicht für Diagnosen oder medizinische Empfehlungen verwendet werden.

## Medizinische und regulatorische Freigabe (Pflicht)

> **Wichtig:** Phase-Definitionen und zugehörige UI-Logik werden erst nach medizinischem Review und geklärtem regulatorischem Pfad finalisiert.

- **Medizinische Validierung:** Vor Finalisierung Fachreview durch Gynäkologie/Endokrinologie (Phasen-Definitionen, typische Dauern, Übergangsmarker wie z. B. LH-Peak für Ovulation). Prognosen beeinflussen Gesundheitsentscheidungen von Nutzerinnen.
- **Regulatorische Einordnung:** Zweckbestimmung prüfen. Bei Aussagen wie Verhütungsunterstützung, Kinderwunsch, Ovulationsdiagnose oder klinischen Empfehlungen ist die App voraussichtlich SaMD (Software as a Medical Device) – bestimmt die nachgelagerten Compliance-Pflichten.
- **EU/US-Compliance:** Falls SaMD, EU MDR (CE-Kennzeichnung, Risikoklasse, Technische Doku, QMS z. B. ISO 13485) und US FDA-Pfad (510(k)/De Novo/PMA je Risiko) adressieren.
- **Datenschutz:** Gesundheitsdaten = besondere Kategorien (DSGVO Art. 9) → explizite Einwilligung, starke Schutzmaßnahmen, ggf. DPIA bei hohem Risiko. In den USA: FTC-Durchsetzung und State Privacy Laws beachten (Fälle gegen Fertility-Apps wegen unzulässiger Datenteilung).
- **Datenpriorisierung & Unsicherheit/UX:** Eingabereihenfolge (Selbstberichte, Sensoren, Historie) definieren, Confidence-Scores bei Ambiguitäten, UI-Regeln zur Darstellung inkl. Warn-/Hinweistexte („keine medizinische Beratung").

## Datenmodell
Die Phasenberechnung basiert auf dem Objekt `cycle_data` mit folgenden Feldern:

| Feld | Typ | Required | Beschreibung |
|------|-----|----------|--------------|
| `last_period_start` | Date | required | Datum des Beginns der letzten Periode |
| `cycle_length` | Integer | optional | Durchschnittliche Länge des Zyklus in Tagen; default: 28 |
| `period_length` | Integer | optional | Durchschnittliche Dauer der Menstruation in Tagen; default: 5 |
| `menopause` | Boolean | optional | `true`, wenn die Nutzerin in der Menopause ist |
| `on_hormonal_contraception` | Boolean | optional | `true`, wenn hormonelle Verhütung aktiv ist |
| `irregular_cycle` | Boolean | optional | `true`, wenn der Zyklus unregelmäßig ist |

### Validierungsregeln

| Feld | Erlaubter Bereich | Default | Fehlerbehandlung |
|------|-------------------|---------|------------------|
| `cycle_length` | 21–60 Tage | 28 | `< 21`: `phase = unknown` + Oligomenorrhoe-Warnung; `> 60`: ArgumentError |
| `period_length` | 1–10 Tage | 5 | `< 1` oder `> 10`: ArgumentError |
| `last_period_start` | Vergangenheit oder heute | required | Zukunft: Abgelehnt; `> 90 Tage alt`: Stale-Data-Warnung |

> **ACOG-Referenz vs. App-Bereich:**
> - ACOG definiert Normalbereich: 21–45 Tage
> - App erlaubt erweiterten Bereich: 21–60 Tage (für Perimenopause, lange Zyklen)
> - Zyklen 46–60 Tage: Berechnet mit `low_confidence` + UI-Warnung
>
> **Warum 1–10 Tage für Periodendauer?**
> - Medizinischer Durchschnitt: 2–7 Tage
> - App erlaubt 1–10 zur Abdeckung von Extremfällen
> - Werte außerhalb 2–7: Keine automatische Warnung (individuell variabel)

## Algorithmus zur Phasenberechnung

### 1. Vorabprüfung
- Wenn `menopause = true` oder `on_hormonal_contraception = true`, setze `phase = none` und flagge den Zyklus als neutral (keine Phasenlogik).
- Wenn `last_period_start` nicht gesetzt: `phase = unknown`.

### 2. Parameter bestimmen
```
cycle_len = cycle_length oder 28 (default)
period_len = period_length oder 5 (default)
luteal_length = 13 (evidenzbasiert, typischer Bereich 12–14 Tage)
ovulation_day = cycle_len - luteal_length
ovulation_window = 2 (±2 Tage um ovulation_day)
```

> **Evidenzbasierter Ansatz:** Die Lutealphase (Zeitraum von Ovulation bis
> Menstruation) ist biologisch relativ konstant bei 12–14 Tagen. Die Berechnung
> `ovulation_day = cycle_len - 13` nutzt diese Konstanz für eine genauere
> Ovulationsschätzung als die frühere 50%-Heuristik, insbesondere bei kurzen
> oder langen Zyklen.
>
> **Beispiele:**
> - 28-Tage-Zyklus: `ovulation_day` = 28 - 13 = Tag 15
> - 21-Tage-Zyklus: `ovulation_day` = 21 - 13 = Tag 8
> - 35-Tage-Zyklus: `ovulation_day` = 35 - 13 = Tag 22
>
> **Klinische Validierung:** Für medizinisch genaue Ovulationserkennung sind
> LH-Surge-Tests oder Basaltemperaturmessung (BBT) notwendig. Diese App-Schätzung
> dient ausschließlich der Lifestyle-Personalisierung, nicht der Fruchtbarkeits-
> oder Verhütungsplanung.

> **Minimum Cycle Length Guard:** Zykluslängen unter 21 Tagen gelten medizinisch
> als Oligomenorrhoe (ACOG-Richtlinien: Normalbereich 21–45 Tage; Quelle: ACOG
> Committee Opinion No. 651, 2015). Falls `cycle_len < 21`, wird `phase = unknown`
> gesetzt und im UI ein Hinweis angezeigt: „Zykluslänge ungewöhnlich kurz — bitte
> Zyklusdaten prüfen oder ärztlichen Rat einholen." Die Warnung wird im
> Observability-Layer geloggt (Event: `cycle_length_below_minimum`).

> **Roadmap:** Integration von Wearable-Daten, LH/BBT-Eingaben und User-Feedback
> zur Verbesserung der Phasengenauigkeit.
> - [ ] Follow-up: Phase-Confidence-Score bei Phasengrenzen (Archon Task: eef75718-27f8-4493-80d9-82c9dcff4f49)

> **Edge Case Guard:** Falls `period_len >= ovulation_day` (anatomisch ungültig:
> Ovulation während Menstruation), wird `phase = unknown` gesetzt. **Keine
> Autokorrektur** – die Nutzerin soll die Daten korrigieren. Die ungültigen
> Eingaben werden im Observability-Layer geloggt (Event: `invalid_cycle_parameters`)
> und im UI erscheint ein Hinweis: „Zyklusdaten scheinen ungültig. Bitte
> Periodendauer und Zykluslänge prüfen."

### 3. cycle_day berechnen
```
cycle_day = ((heutiges_datum - last_period_start) mod cycle_len) + 1
```

> **Datum-Normalisierung:** `heutiges_datum` und `last_period_start` werden als
> date-only UTC-Werte normalisiert (Jahr, Monat, Tag). Dies gewährleistet
> konsistente Berechnungen unabhängig von der Zeitzone des Clients.

> **Eingabe-Validierung:**
> - **Future Date Check:** Falls `last_period_start > heute`, setze `phase = unknown`
>   mit UI-Hinweis: „Periodenbeginn kann nicht in der Zukunft liegen."
> - **Stale Data Detection:** Falls `last_period_start + 90 Tage < heute`, zeige
>   UI-Hinweis: „Zyklusdaten möglicherweise veraltet. Bitte letzten Periodenbeginn
>   aktualisieren." Phase wird mit `low_confidence` markiert.

### 4. Phase zuweisen (Evidenzbasiert)

> **Formel:** Verwendet `ovulation_day = cycle_len - luteal_length` mit `luteal_length = 13`.
> Ovulationsfenster umfasst `ovulation_day ± ovulation_window` (±2 Tage, 5 Tage total).

| Phase | Bedingung |
|-------|-----------|
| **Menstruation** | `cycle_day <= period_len` |
| **Ovulationsfenster** | `|cycle_day - ovulation_day| <= ovulation_window` (±2 Tage) |
| **Follikel** | `period_len < cycle_day < ovulation_day - ovulation_window` |
| **Luteal** | `cycle_day > ovulation_day + ovulation_window` |

### 5. Confidence Score Model

Die Phasenberechnung enthält einen `confidence_score` (0.0–1.0), der die Zuverlässigkeit der Phasenvorhersage angibt:

| Score-Bereich | Label | UI-Verhalten |
|---------------|-------|--------------|
| 0.8–1.0 | `high` | Phase wird ohne Hinweis angezeigt |
| 0.5–0.79 | `medium` | Phase + dezenter Hinweis: „Schätzung basiert auf Durchschnittswerten" |
| 0.0–0.49 | `low` | Phase als „unsicher" markiert: „Bitte Zyklusdaten vervollständigen" |

**Penalties (subtrahiert vom Base-Score 1.0):**

| Bedingung | Penalty | Rationale |
|-----------|---------|-----------|
| `cycle_length` = default (28) | -0.20 | Geschätzt, nicht eingegeben |
| `period_length` = default (5) | -0.15 | Geschätzt, nicht eingegeben |
| `cycle_len > 45` | -0.15 | Außerhalb ACOG-Normalbereich |
| `cycle_len < 21` | Score = 0.0 | Oligomenorrhoe, `phase = unknown` |
| `irregular_cycle = true` | -0.30 | Hohe Variabilität erwartet |
| `last_period_start > 60 Tage alt` | -0.10 | Möglicherweise veraltet |
| `cycle_day` nahe Übergang (±1 Tag) | -0.05 | Grenzfall zwischen Phasen |

**Formel:**
```
confidence_score = max(0.0, min(1.0, 1.0 - sum(applicable_penalties)))
```

**Runtime-Verhalten:**
- Bei `low` Confidence: KI-Agents nutzen nur allgemeine, nicht-phasenspezifische Inhalte
- Bei `medium` Confidence: Volle Phasen-Personalisierung mit Disclaimer
- Bei `high` Confidence: Volle Phasen-Personalisierung ohne Disclaimer
- Confidence-Score wird in Diagnostics/Observability geloggt

## Edge Cases & Fallbacks

| Situation | Aktion |
|-----------|--------|
| Keine Angaben | Nutze Defaults, informiere Nutzerin (UI: „Bitte Zyklusdaten hinzufügen") |
| Unregelmäßiger Zyklus | Wenn `irregular_cycle = true`: `phase = unknown`, neutrale Inhalte |
| Menopause/Hormonelle Verhütung | `phase = none`, KI und Ranking ignorieren Phasensignale |
| Datenwiderspruch | Wenn `cycle_len < period_len` oder absurde Werte: `phase = unknown` |
| `cycle_len < 21` | Medizinisch ungewöhnlich kurz (Oligomenorrhoe): `phase = unknown`, UI-Hinweis zur Datenprüfung, Observability-Log: `cycle_length_below_minimum` |
| `cycle_len > 45` | Über ACOG-Normalbereich: Phase wird mit `low_confidence` berechnet, UI-Warnung: „Zykluslänge über 45 Tagen ist ungewöhnlich lang — bitte Zyklusdaten prüfen oder ärztlichen Rat einholen." Observability-Log: `cycle_length_above_acog_range` |
| `period_len >= ovulation_day` | Anatomisch ungültig: `phase = unknown`, **keine Autokorrektur**. UI-Hinweis: „Zyklusdaten scheinen ungültig. Bitte Periodendauer und Zykluslänge prüfen." Observability-Log: `invalid_cycle_parameters` |
| `last_period_start` in Zukunft | Ungültig: `phase = unknown`, UI-Hinweis: „Periodenbeginn kann nicht in der Zukunft liegen." |
| `last_period_start > 90 Tage alt` | Möglicherweise veraltet: Phase mit `low_confidence`, UI-Hinweis: „Zyklusdaten möglicherweise veraltet." |

## Scope & Grenzen
- Die Phasenlogik dient **nur** der Priorisierung und Personalisierung von Lifestyle-Inhalten.
- Sie ist **kein diagnostisches Tool** und darf nicht zur Bestimmung von Fruchtbarkeit, Schwangerschaft oder gesundheitlichen Zuständen verwendet werden.
- Beim Auftreten von starken Schmerzen, ungewöhnlichen Blutungen oder anderen gesundheitlichen Problemen ist immer ein ärztlicher Rat einzuholen (siehe Safety-&-Scope-Dossier).

## Beispiele

### Beispiel A: Standard-Zyklus
**Input:**
- `last_period_start` = 2025-11-01
- `cycle_length` = 28
- `period_length` = 5
- Heutiges Datum = 2025-11-15

**Berechnung:**
- `cycle_day` = 15
- `ovulation_day` = 28 - 13 = 15
- `|cycle_day - ovulation_day|` = |15 - 15| = 0 ≤ 2
- **Phase = Ovulationsfenster** (innerhalb ±2 Tage um `ovulation_day`)

### Beispiel B: Fehlende Zykluslänge
**Input:**
- `last_period_start` = 2025-11-20
- `cycle_length` fehlt
- `period_length` = 6
- Heutiges Datum = 2025-11-23

**Berechnung:**
- Default: `cycle_len` = 28, `period_len` = 6
- `cycle_day` = 4
- **Phase = Menstruation** (`cycle_day <= period_len`)
- **Confidence:** `medium` (Penalty: -0.20 für default cycle_length)
- **UI-Hinweis:** „Zykluslänge unbekannt, bitte angeben"

### Beispiel C: Unregelmäßiger Zyklus
**Input:**
- Stark schwankende Zykluslängen (24, 35, 31)

**Regel:**
- Markiere Phase als `unknown`
- Nutze neutrale Inhalte
- UI bittet um genauere Daten

## Wie KI dieses Dokument nutzen soll
- `luvi.cycle_explainer` verwendet dieses Dossier, um dem/der Nutzer*in die aktuelle Phase und passende, nicht-medizinische Tipps zu erklären.
- `luvi.feed_ranker` nutzt das Phasensignal nur, um Inhalte zu priorisieren (siehe Ranking-Heuristik); wenn `phase = unknown` oder `none`, muss es neutral ranken.
- Andere Agents dürfen **keine Diagnosen oder Empfehlungen außerhalb des Lifestyle-Scopes** aus diesem Dokument ableiten.
- Bei Widersprüchen zwischen diesem Dokument und anderen Quellen hat dieses SSOT Vorrang; im Zweifel `phase = unknown` setzen und auf Safety-&-Scope-Dossier verweisen.

## Versionsinfo
- **Version:** v1.3
- **Datum:** 2026-01-25
- **Änderungsverlauf:**
  - v1.3: Algorithmus auf evidenzbasierte Formel (`cycle_len - 13`) aktualisiert (Sync mit Implementation); Validierungsregeln dokumentiert; Confidence-Score-Modell hinzugefügt; Edge Cases erweitert (>45 Tage, Future Date, Stale Data); Auto-Korrektur entfernt; UTC-Timezone-Dokumentation.
  - v1.2: Medizinische/regulatorische Compliance-Anforderungen aus v1.0 integriert; Sync mit Archon v1.1.
  - v1.1: Algorithmus definiert, Fallbacks und Beispiele hinzugefügt; „Wie KI dieses Dokument nutzen soll" ergänzt.
  - v1.0: Erste Skizze mit TODOs.
