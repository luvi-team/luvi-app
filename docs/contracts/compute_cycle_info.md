# Compute Cycle Info — Contract v1 (MVP)

Status: Draft/SSOT. Gilt für S1 und Folge-Sprints bis Revision.

## Purpose
Deterministische Berechnung der aktuellen Zyklusphase und Ableitungen für UI/Ranking. Schnell (P95 ≤ 50 ms), testbar, ohne PII-Overreach.

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
   - Ovulatorisch: Fenster um Ovulationstag `ov_day = cycle_length_days - luteal_length_days` → Tage `ov_day .. ov_day+1` (2‑Tage‑Fenster; clamp in [1..cycle_length_days]).
   - Follikulär: Rest zwischen Menstruation und Ovulation.
4. `phase_window_start/end` aus Phase + Grenzen ableiten; `next_phase` und `next_phase_start` deterministisch berechnen.
5. Clamps: Eingaben außerhalb erlaubter Bereiche auf Grenzen setzen; `clamps_applied = true` und `notes` füllen.

## Offsets/Clamps
- cycle_length_days: min 21, max 35 (Default 28).
- period_length_days: min 2, max 8 (Default 5).
- luteal_length_days: min 10, max 16 (Default 14).
- Ovulation: `ov_day = max(1, min(cycle_length_days, cycle_length_days - luteal_length_days))`.

## Edge Cases
- Missing LMP: return `{ phase: null, phase_confidence: 0, requires_onboarding: true }`.
- Future LMP (`lmp_date > now`): clamp `d = 0`, Phase = `menstrual`, `notes += ["future_lmp_clamped"]`.
- Very long/short cycles: clamps trigger; `notes += ["cycle_length_clamped"]`.
- TZ/Leap: Berechnung in lokaler TZ; Datumsteil für Fenstergrenzen verwenden.
- Legacy Migration: Falls alte Felder (z. B. `avg_cycle_length`) vorhanden, Priorität: explizite Eingaben > Historie.

## Test Cases (Mindestens)
- T00 Defaults: 28/5/14, `now = lmp+0d` → menstrual, day 1.
- T01 Menstruation Ende: `now = lmp+4d` → menstrual, day 5; `now = lmp+5d` → follikulär, day 6.
- T02 Ovulation: `now = lmp+13d` (ov_day=14) → ovulatory.
- T03 Luteal: `now = lmp+20d` → luteal.
- T04 Clamps: cycle_length=19 → clamp 21; luteal=20 → clamp 16.
- T05 Missing LMP → requires_onboarding.
- T06 Future LMP → clamp to day 1 menstrual.

## Versioning
- v1.0 (MVP): deterministisch, keine Wearables/AI.
- v1.x: Optionale Nutzer‑Offets/Personalisation (nicht in v1).

---

Implementierungs‑Verweis (empfohlen): `lib/features/cycle/compute_cycle_info.dart:1` (API‑Surface) + Widget‑Binding in `lib/features/screens/heute_screen.dart:1`.
