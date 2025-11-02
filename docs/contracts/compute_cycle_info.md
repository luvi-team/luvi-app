# Compute Cycle Info — Contract v1 (MVP)

Status: Draft (awaiting approval)
Applies to: S1 and subsequent sprints until revision

## Purpose
Deterministische Berechnung der aktuellen Zyklusphase und Ableitungen für UI/Ranking. Testbar, ohne PII-Overreach.

- Performance (P95 ≤ 50 ms): compute_cycle_info() from function entry to return, computation‑only (keine Network/DB‑I/O). Warm‑start Messung (JIT/caches warm). Baseline: Mid‑range Mobile/CPU (z. B. Apple M1/A14‑äquiv. oder Snapdragon 7xx), 1 Thread, keine konkurrierende Last. Methode: 10 000 Aufrufe über repräsentativen Input‑Satz, erste 100 als Warm‑up verwerfen; P95 via StopWatch/Harness berechnet und mit Sample‑Anzahl dokumentiert.

## Inputs
- lmp_date (string, ISO 8601 `YYYY-MM-DD`, lokal): Erster Tag der letzten Periode. Pflicht.
- cycle_length_days (int): Standard 28; erlaubt 21..35 (Clamp). Pflicht.
- period_length_days (int): Standard 5; erlaubt 2..8 (Clamp). Pflicht.
- timezone (string, IANA, optional): Standard Geräte‑TZ.
- now (timestamp, optional): Standard `DateTime.now()`; Test‑Injection erlaubt.
- luteal_length_days (int, optional): Standard 14; erlaubt 10..16 (Clamp).

## Outputs
- phase (enum): `menstrual` | `follicular` | `ovulatory` | `luteal`.
- day_in_phase (int ≥ 1).
- day_in_cycle (int 1..cycle_length_days, clamp applied).
- phase_window_start (date, local) · phase_window_end (date, local).
- next_phase (enum) · next_phase_start (date).
- phase_confidence (float 0..1): v1 immer 1.0 (deterministisch).
- clamps_applied (bool) · notes (string[] optional).

## Algorithm (v1, deterministisch)
1. Day 1 = `lmp_date` (lokal). `d = daysBetween(lmp_date, now)`; wenn `d < 0` → clamp auf 0.
2. Zyklustag: `day_in_cycle = (d % cycle_length_days) + 1` (1‑basiert).
3. Phasegrenzen:
   - Menstruation: Tage `1 .. period_length_days`.
   - Luteal: Letzte `luteal_length_days` Tage des Zyklus.
   - Ovulatorisch: Ovulationstag `ov_day = cycle_length_days - luteal_length_days`; danach clampen: `ov_day ∈ [1, cycle_length_days]`. Das 2‑Tage‑Fenster ist `[ov_day, min(ov_day+1, cycle_length_days)]`. Ob `day_in_cycle` in diesem Fenster liegt, bestimmt die Phase `ovulatory` (ansonsten nicht).
     Beispiele: (a) `ov_day < 1` → Clamp auf 1 ⇒ Fenster `[1, 2]`; (b) `ov_day = cycle_length_days` ⇒ Fenster `[cycle_length_days, cycle_length_days]` (ein Tag).
   - Follikulär: Rest zwischen Menstruation und Ovulation.
4. `phase_window_start/end` aus Phase + Grenzen ableiten; `next_phase` und `next_phase_start` deterministisch berechnen.
5. Clamps: Eingaben außerhalb erlaubter Bereiche auf Grenzen setzen; `clamps_applied = true` und `notes` füllen.

## Offsets/Clamps
- cycle_length_days: min 21, max 35 (Default 28).
- period_length_days: min 2, max 8 (Default 5).
- luteal_length_days: min 10, max 16 (Default 14).
- Ovulationstag‑Berechnung: Vor der Berechnung werden alle Eingaben auf erlaubte Bereiche geclamped. Danach gilt: `ov_day = max(1, min(cycle_length_days, cycle_length_days - luteal_length_days))`.

  Fachlicher Kontext: Ovulation tritt typischerweise ~`luteal_length_days` Tage vor der nächsten Menstruation auf (klinischer Standard; vgl. ACOG Patient Education; Wilcox AJ et al., BMJ 2000). Grenzen: Wenn `luteal_length_days ≥ cycle_length_days` in den Roh‑Eingaben, sind die Eingaben biologisch inkonsistent; durch Clamps (min/max) wird auf einen sicheren Bereich normalisiert und als Hinweis in `notes` vermerkt.

  Beispiele:
  - Normal: `cycle_length_days=28`, `luteal_length_days=14` ⇒ `ov_day=14` ⇒ Fenster `[14,15]`.
  - Kurzzyklus: `cycle_length_days=21`, `luteal_length_days=16` ⇒ `ov_day=5` ⇒ Fenster `[5,6]` (ungewöhnliche Kombination; klinisch einordnen, ggf. Hinweis anzeigen).
  - Pathologischer Input (luteal ≥ cycle): z. B. `cycle_length_days=16`, `luteal_length_days=16` ⇒ nach Clamps `cycle_length_days→21`, `luteal_length_days→16`, `ov_day=5`, `notes += ["cycle_length_clamped"]`.

References: ACOG Patient Education (Ovulation/Menstrual Cycle); Wilcox AJ et al., BMJ 2000 (Timing of the fertile window)

## Edge Cases
- Missing LMP: return `{ phase: null, phase_confidence: 0, requires_onboarding: true }`.
- Future LMP (`lmp_date > now`): clamp `d = 0`, Phase = `menstrual`, `notes += ["future_lmp_clamped"]`.
- Very long/short cycles: clamps trigger; `notes += ["cycle_length_clamped"]`.
- TZ/Leap: Berechnung in lokaler TZ; Datumsteil für Fenstergrenzen verwenden.
- Legacy Migration: Falls alte Felder (z. B. `avg_cycle_length`) vorhanden, Priorität: explizite Eingaben > Historie.

Input‑Validierung (nach Clamps, deterministisch):
- Invarianten: `1 ≤ period_length_days ≤ cycle_length_days`, `1 ≤ luteal_length_days < cycle_length_days`.
- Falls eine Invariante nach Clamps nicht erfüllt ist, weitere Korrektur auf nächstzulässigen Wert und `notes` ergänzen (z. B. `"invariant_adjustment"`). In v1 sind die Clamp‑Grenzen so gewählt, dass diese Invariante regulär erfüllt ist.

## Test Cases (mindestens)
Hinweis: Referenzen auf Algorithmus‑Schritte in Klammern (z. B. [Step 2]). Alle Outputs vollständig spezifiziert.

- T00 Defaults (Basisfall):
  Input: `lmp=2025-01-01`, `now=2025-01-01`, `cycle_length=28`, `period_length=5`, `luteal_length=14`.
  Normalisiert: keine Clamps.
  Erwartet: `{ phase: menstrual, day_in_cycle: 1, day_in_phase: 1, phase_window_start: 2025-01-01, phase_window_end: 2025-01-05, next_phase: follicular, next_phase_start: 2025-01-06, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Steps 1–5].

- T01 Menstruation‑Grenze (Übergang):
  a) `now = lmp+4d` ⇒ `{ phase: menstrual, day_in_cycle: 5, day_in_phase: 5, next_phase: follicular, next_phase_start: lmp+5d, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Steps 2–4].
  b) `now = lmp+5d` ⇒ `{ phase: follicular, day_in_cycle: 6, day_in_phase: 1, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Steps 2–4].

- T02 Ovulation‑Fenster (Mitgliedschaft entscheidet):
  `now = lmp+13d` (bei 28/14) ⇒ `ov_day=14`, Fenster `[14,15]` ⇒ `{ phase: ovulatory, day_in_cycle: 14, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Step 3].

- T03 Luteal‑Phase:
  `now = lmp+20d` (28/14) ⇒ `{ phase: luteal, day_in_cycle: 21, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Step 3].

- T04 Multiple Clamps (Cross‑Clamp‑Szenario):
  Input: `cycle_length=19`, `luteal_length=20`, `period_length=9`.
  Erwartete Normalisierung: `cycle_length→21`, `luteal_length→16`, `period_length→8` [Step 5].
  Erwarteter Output‑Teil: `{ phase_confidence: 1.0, clamps_applied: true, notes: ["cycle_length_clamped", "luteal_length_clamped", "period_length_clamped"] }`.

- T05 Input‑Inkonsistenz vor Clamps (luteal ≥ cycle):
  Input: `cycle_length=16`, `luteal_length=16`, `period_length=5`.
  Erwartete Normalisierung: `cycle_length→21`, `luteal_length→16` ⇒ `ov_day=5`; `notes` enthält mindestens `"cycle_length_clamped"`; `{ phase_confidence: 1.0, clamps_applied: true }` [Steps 3,5].

- T06 Missing LMP:
  Input: `lmp=null` ⇒ `{ phase: null, phase_confidence: 0, requires_onboarding: true, clamps_applied: false, notes: [] }` [Edge Case].

- T07 Future LMP:
  Input: `lmp = tomorrow`, `now = today` ⇒ `d=0` Clamp, `{ phase: menstrual, day_in_cycle: 1, phase_confidence: 1.0, clamps_applied: true, notes: ["future_lmp_clamped"] }` [Steps 1–2, Edge Case].

## Versioning
- v1.0 (MVP): deterministisch, keine Wearables/AI.
- v1.x: Optionale Nutzer‑Offets/Personalisation (nicht in v1).

---

Implementierungs‑Verweis (empfohlen): `lib/features/cycle/compute_cycle_info.dart:1` (API‑Surface) + Widget‑Binding in `lib/features/screens/heute_screen.dart:1`.
