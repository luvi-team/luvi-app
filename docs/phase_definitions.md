# Phase-Definitionen v1.2 (SSOT)

> Version: v1.2 · Datum: 2025-12-03

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

## Algorithmus zur Phasenberechnung

### 1. Vorabprüfung
- Wenn `menopause = true` oder `on_hormonal_contraception = true`, setze `phase = none` und flagge den Zyklus als neutral (keine Phasenlogik).
- Wenn `last_period_start` nicht gesetzt: `phase = unknown`.

### 2. Parameter bestimmen
```
cycle_len = cycle_length oder 28 (default)
period_len = period_length oder 5 (default)
ovulation_day = round(cycle_len * 0.5) (MVP-Schätzwert)
ovulation_day_alt = cycle_len - 14 (Alternative bei variabler Zykluslänge)
```

> **Minimum Cycle Length Guard:** Zykluslängen unter 21 Tagen gelten medizinisch
> als Oligomenorrhoe (ACOG-Richtlinien: Normalbereich 21–35 Tage; Quelle: ACOG
> Committee Opinion No. 651, 2015, verfügbar unter https://www.acog.org/clinical/clinical-guidance/committee-opinion/articles/2015/12/menstruation-in-girls-and-adolescents-using-the-menstrual-cycle-as-a-vital-sign). Falls
> `cycle_len < 21`, wird `phase = unknown` gesetzt und im UI ein Hinweis
> angezeigt: „Zykluslänge ungewöhnlich kurz — bitte Zyklusdaten prüfen oder
> ärztlichen Rat einholen." Die Warnung wird im Observability-Layer geloggt.

> **MVP-Vereinfachung:** Die 50%-Heuristik ist ein einfacher Startwert und
> passt am ehesten zu ~28‑Tage-Zyklen. Biologische Ovulation variiert typischerweise
> ±2–3 Tage und hängt von individuellen Faktoren ab. Klinisch wird der Eisprung
> per LH-Surge-Test oder Basaltemperatur (BBT) bestätigt.
> **Alternative (biologisch näher):** `cycle_len - 14` modelliert eine relativ
> konstante Lutealphase und ist oft robuster für kurze oder lange Zyklen,
> bleibt aber eine grobe Schätzung.
> **Accuracy‑Trade-offs:** 50% kann bei kurzen Zyklen zu spät und bei langen
> Zyklen zu früh liegen; `cycle_len - 14` kann bei stark variabler Lutealphase
> ebenfalls abweichen. Für bessere Genauigkeit sollten `cycle_len - 14` oder
> hybride/Confidence‑Score‑Ansätze bevorzugt werden.
> **Roadmap:** Integration von Wearable-Daten, LH/BBT-Eingaben und
> User-Feedback zur Verbesserung der Phasengenauigkeit.
> - [ ] Follow-up: Phase‑Confidence‑Score bei Phasengrenzen (Archon Task: eef75718-27f8-4493-80d9-82c9dcff4f49)

> **Edge Case Guard:** Falls `period_len >= ovulation_day` (möglich bei kurzen
> Zyklen oder ungenauen Eingaben), wird `ovulation_day` auf `period_len + 1`
> korrigiert, damit die Follikelphase (`period_len < cycle_day < ovulation_day`)
> definiert bleibt. Diese Korrektur wird geloggt und im UI als Datenwarnung angezeigt.

### 3. cycle_day berechnen
```
cycle_day = ((heutiges_datum - last_period_start) mod cycle_len) + 1
```
Wobei `heutiges_datum` der aktuelle Tag (Europe/Vienna) ist.

### 4. Phase zuweisen (MVP-Heuristik)
| Phase | Bedingung |
|-------|-----------|
| **Menstruation** | `cycle_day <= period_len` |
| **Follikel** | `period_len < cycle_day < ovulation_day` |
| **Ovulation** | `cycle_day == ovulation_day` oder `cycle_day == ovulation_day + 1` (Fenster von 2 Tagen) |
| **Luteal** | `cycle_day > ovulation_day + 1` |

### 5. Confidence & Hinweise
- Wenn `cycle_length` oder `period_length` geschätzt werden, markiere die Phase intern als `low_confidence`.
- Bei `cycle_day` nahe den Übergängen (±1 Tag) können Hinweise im UI erscheinen („Phase möglicherweise wechselnd").

## Edge Cases & Fallbacks

| Situation | Aktion |
|-----------|--------|
| Keine Angaben | Nutze Defaults, informiere Nutzerin (UI: „Bitte Zyklusdaten hinzufügen") |
| Unregelmäßiger Zyklus | Wenn `irregular_cycle = true`: `phase = unknown`, neutrale Inhalte |
| Menopause/Hormonelle Verhütung | `phase = none`, KI und Ranking ignorieren Phasensignale |
| Datenwiderspruch | Wenn `cycle_len < period_len` oder absurde Werte: `phase = unknown` |
| `cycle_len < 21` | Medizinisch ungewöhnlich kurz (Oligomenorrhoe): `phase = unknown`, UI-Hinweis zur Datenprüfung, Observability-Log |
| `period_len >= ovulation_day` | Anatomisch ungültig: Ovulation während Menstruation. Setze `ovulation_day = period_len + 1` als Safe-Fallback, logge Warnung im Observability-Layer. UI-Hinweis: „Bitte Zyklusdaten prüfen" |

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
- `ovulation_day` = 14
- **Phase = Ovulation** (da `cycle_day == ovulation_day + 1`)

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
- **Version:** v1.2
- **Datum:** 2025-12-03
- **Änderungsverlauf:**
  - v1.2: Medizinische/regulatorische Compliance-Anforderungen aus v1.0 integriert; Sync mit Archon v1.1.
  - v1.1: Algorithmus definiert, Fallbacks und Beispiele hinzugefügt; „Wie KI dieses Dokument nutzen soll" ergänzt.
  - v1.0: Erste Skizze mit TODOs.
