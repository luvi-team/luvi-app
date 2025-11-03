# Compute Cycle Info — Contract v1 (MVP)

Status: Draft (awaiting approval)
Applies to: S1 and subsequent sprints until revision

## Purpose
Deterministic computation of the current cycle phase and derived values for UI/ranking. Testable without PII overreach.

- Performance (target P95 ≤ 50 ms): compute_cycle_info() from function entry to return, computation‑only (no network/DB I/O). Warm‑start measurement (JIT/caches warm). Baseline: mid‑range mobile/CPU (e.g., Apple M1/A14‑equivalent or Snapdragon 7xx), single thread, no concurrent load. Method: 10,000 invocations over a representative input set; discard the first 100 as warm‑up; compute P95 via `Stopwatch`/harness and document the sample count.
  - Baseline cadence: run baseline measurement (a) before merge of relevant changes, (b) after any performance‑affecting change to compute_cycle_info or its dependencies, and (c) on a scheduled nightly/weekly CI job on a stable runner.
  - Baseline (reference; record and update here): example device "Apple M1 (8‑core, 16 GB), macOS 14, Flutter 3.35.4 release"; sample size `n=9,900` (after `warmup=100`); measured P95: **TBD** ms (pending initial measurement). If the measurement device/build differs from the reference, record the deviation in the artifact (see below).
  - Instrumentation/Harness: Dart `Stopwatch` around compute only; script `tools/perf/compute_cycle_info_bench.dart`; warm‑up `100`, samples `10,000`; P95 computed from sorted durations at index `ceil(0.95*n)-1`. Reproduce locally: `dart run tools/perf/compute_cycle_info_bench.dart --samples 10000 --warmup 100 --json docs/perf/compute_cycle_info/<DATE>.json`.
  - Artifacts (commit required): commit the produced JSON under `docs/perf/compute_cycle_info/`.
    - Required fields: `timestamp`, `device` (model, OS, CPU, memory), `build` (Flutter/Dart versions, build mode), `warmup`, `samples`, `p50`, `p95`, `p99`, and `deviations` (from the reference device/build, if any).
    - Naming: `compute_cycle_info_<YYYY-MM-DD>_<device|runner>.json` (or CI‑provided run ID). One canonical latest artifact should live in this folder per runner/device profile.
  - CI regression rule: job name "Performance CI / compute_cycle_info". Fail the job if measured `P95 > 60 ms` (slightly above the 50 ms target to avoid flakiness). The job uploads its raw JSON artifact and links to the committed baseline for traceability.

## Inputs
- lmp_date (string, ISO 8601 `YYYY-MM-DD`, local): First day of the last period. Required.
- cycle_length_days (int): Default 28; allowed 21..35 (clamp). Required.
- period_length_days (int): Default 5; allowed 2..8 (clamp). Required.
- timezone (string, IANA, optional): Defaults to the device time zone.
- now (timestamp, optional): Defaults to `DateTime.now()`; injectable for tests.
- luteal_length_days (int, optional): Default 14; allowed 10..16 (clamp).

## Outputs
- phase (enum): `menstrual` | `follicular` | `ovulatory` | `luteal`.
- day_in_phase (int ≥ 1).
- day_in_cycle (int 1..cycle_length_days, clamp applied).
- phase_window_start (date, local) · phase_window_end (date, local).
- next_phase (enum) · next_phase_start (date).
- phase_confidence (float 0..1): v1 always 1.0 (deterministic).
- requires_onboarding (bool): whether the user must complete onboarding before predictions.
- clamps_applied (bool) · notes (string[] optional).

## Algorithm (v1, deterministic)
1. Day 1 = `lmp_date` in the target timezone. All day arithmetic uses calendar days in the user's local timezone (or the timezone attached to the inputs), not raw UTC timestamps:
   - Determine `tz`: (1) use the `timezone` param (IANA) if present and valid; else (2) derive from `now` if it carries an offset/zone; else (3) use the device/environment timezone; if none is determinable (server context), fall back to `UTC`.
   - Normalize `lmp_date` and `now` into `tz` and convert to date-only (midnight→midnight in `tz`).
   - Compute `d = daysBetween(lmp_date_localDate, now_localDate)`; if `d < 0` → clamp to 0.
2. Cycle day: `day_in_cycle = (d % cycle_length_days) + 1` (1‑based).
3. Phase boundaries:
   - Menstrual: days `1 .. period_length_days`.
   - Luteal: last `luteal_length_days` days of the cycle.
   - Ovulatory: ovulation day `ov_day = cycle_length_days - luteal_length_days`; then clamp: `ov_day ∈ [1, cycle_length_days]`. The 2‑day window is `[ov_day, min(ov_day+1, cycle_length_days)]`. Whether `day_in_cycle` falls into this window determines phase `ovulatory` (otherwise not).
     Examples: (a) `ov_day < 1` → clamp to 1 ⇒ window `[1, 2]`; (b) `ov_day = cycle_length_days` ⇒ window `[cycle_length_days, cycle_length_days]` (one day).
   - Follicular: remainder between menstrual and ovulation windows.
4. Derive `phase_window_start/end` from the phase and boundaries; both are calendar dates in `tz` and represent whole-day boundaries (inclusive start and inclusive end), independent of time-of-day. Compute `next_phase` and `next_phase_start` deterministically.
5. Clamps: set inputs outside allowed ranges to their bounds; set `clamps_applied = true` and populate `notes`.

## Timezone & Date Boundaries
- Principle: perform day arithmetic in the local user timezone `tz` (or the zone attached to inputs), never on raw UTC instants.
- Normalization: convert inputs to `tz` and treat them as date-only values (use local midnight as the day boundary), then compute differences/offsets.
- Window semantics: `phase_window_start` and `phase_window_end` are calendar dates in `tz` and represent whole days (inclusive start and end).
- Fallbacks (timezone-less inputs):
  - If `timezone` is missing and `now` carries no offset, use device/environment `tz`; if that cannot be determined (server contexts), use `UTC` and add `notes += ["timezone_defaulted:UTC"]`.
  - For date-only strings (e.g., `YYYY-MM-DD`), interpret them as dates in `tz`.
- DST/cross-midnight: daylight saving time transitions affect the number of hours in a day, not calendar day differences.
- Example (DST forward): `tz=Europe/Berlin`, `lmp_date=2025-03-29`, `now=2025-03-30T23:00+02:00` (DST started on 2025‑03‑30; 23‑hour day). After normalization, `daysBetween(2025-03-29, 2025-03-30) = 1`, so `day_in_cycle = 2`. `phase_window_start=2025-03-29`, `phase_window_end=…` per phase. Add `notes += ["timezone_used:Europe/Berlin", "dst_transition"]`.
 - Leap seconds: ignore for v1. Use calendar (date‑only) arithmetic rather than timestamp arithmetic to avoid leap‑second and DST artifacts. Implementation note: compute `daysBetween` from date components via UTC‑normalized dates (e.g., `DateTime.utc(y, m, d)` for both operands) so that midnight‑to‑midnight across DST yields exactly 1 day.

## Offsets/Clamps
- cycle_length_days: min 21, max 35 (default 28).
- period_length_days: min 2, max 8 (default 5).
- luteal_length_days: min 10, max 16 (default 14).
- Ovulation day computation: clamp all inputs to allowed ranges before computing. Then: `ov_day = max(1, min(cycle_length_days, cycle_length_days - luteal_length_days))`.

  Domain context: Ovulation typically occurs ~`luteal_length_days` days before the next menstruation (clinical standard; see ACOG Patient Education; Wilcox AJ et al., BMJ 2000). Bounds: If raw inputs have `luteal_length_days ≥ cycle_length_days`, inputs are biologically inconsistent; clamps (min/max) normalize to a safe range and add a note to `notes`.

  Examples:
  - Normal: `cycle_length_days=28`, `luteal_length_days=14` ⇒ `ov_day=14` ⇒ window `[14,15]`.
  - Short cycle: `cycle_length_days=21`, `luteal_length_days=16` ⇒ `ov_day=5` ⇒ window `[5,6]` (unusual combination; assess clinically, optionally show a hint).
  - Pathological input (luteal ≥ cycle): e.g., `cycle_length_days=16`, `luteal_length_days=16` ⇒ after clamps `cycle_length_days→21`, `luteal_length_days→16`, `ov_day=5`, `notes += ["cycle_length_clamped"]`.

References: ACOG Patient Education (Ovulation/Menstrual Cycle); Wilcox AJ et al., BMJ 2000 (Timing of the fertile window)

## Edge Cases
- Missing LMP: return `{ phase: null, phase_confidence: 0, requires_onboarding: true }`.
- Future LMP (`lmp_date > now`): clamp `d = 0`, phase = `menstrual`, `notes += ["future_lmp_clamped"]`.
- Very long/short cycles: clamps trigger; `notes += ["cycle_length_clamped"]`.
- TZ/Leap: compute in local time zone using date‑only arithmetic; ignore leap seconds; window boundaries are calendar dates.
- Legacy migration: if legacy fields (e.g., `avg_cycle_length`) exist, precedence is explicit inputs > history.

Input validation (after clamps, deterministic):
- Invariants: `1 ≤ period_length_days ≤ cycle_length_days`, `1 ≤ luteal_length_days < cycle_length_days`.
- If an invariant is not met after clamps, further correct to the nearest admissible value and add to `notes` (e.g., `"invariant_adjustment"`). In v1, clamp bounds are chosen such that these invariants are normally satisfied.

## Test Cases (at minimum)
Note: References to algorithm steps in brackets (e.g., [Step 2]). All outputs fully specified.

- T00 Defaults (baseline):
  Input: `lmp=2025-01-01`, `now=2025-01-01`, `cycle_length=28`, `period_length=5`, `luteal_length=14`.
  Normalized: no clamps.
  Expected: `{ phase: menstrual, day_in_cycle: 1, day_in_phase: 1, phase_window_start: 2025-01-01, phase_window_end: 2025-01-05, next_phase: follicular, next_phase_start: 2025-01-06, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Steps 1–5].

- T01 Menstrual boundary (transition):
  a) `now = lmp+4d` ⇒ `{ phase: menstrual, day_in_cycle: 5, day_in_phase: 5, next_phase: follicular, next_phase_start: lmp+5d, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Steps 2–4].
  b) `now = lmp+5d` ⇒ `{ phase: follicular, day_in_cycle: 6, day_in_phase: 1, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Steps 2–4].

- T02 Ovulation window (membership determines phase):
  `now = lmp+13d` (with 28/14) ⇒ `ov_day=14`, window `[14,15]` ⇒ `{ phase: ovulatory, day_in_cycle: 14, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Step 3].

- T03 Luteal phase:
  `now = lmp+20d` (28/14) ⇒ `{ phase: luteal, day_in_cycle: 21, phase_confidence: 1.0, clamps_applied: false, notes: [] }` [Step 3].

- T04 Multiple clamps (cross‑clamp scenario):
  Input: `cycle_length=19`, `luteal_length=20`, `period_length=9`.
  Expected normalization: `cycle_length→21`, `luteal_length→16`, `period_length→8` [Step 5].
  Expected output subset: `{ phase_confidence: 1.0, clamps_applied: true, notes: ["cycle_length_clamped", "luteal_length_clamped", "period_length_clamped"] }`.

- T05 Input inconsistency before clamps (luteal ≥ cycle):
  Input: `cycle_length=16`, `luteal_length=16`, `period_length=5`.
  Expected normalization: `cycle_length→21`, `luteal_length→16` ⇒ `ov_day=5`; `notes` contains at least `"cycle_length_clamped"`; `{ phase_confidence: 1.0, clamps_applied: true }` [Steps 3,5].

- T06 Missing LMP:
  Input: `lmp=null` ⇒ `{ phase: null, phase_confidence: 0, requires_onboarding: true, clamps_applied: false, notes: [] }` [Edge Case].

- T07 Future LMP:
  Input: `lmp = tomorrow`, `now = today` ⇒ `d=0` clamp, `{ phase: menstrual, day_in_cycle: 1, phase_confidence: 1.0, requires_onboarding: false, clamps_applied: true, notes: ["future_lmp_clamped"] }` [Steps 1–2, Edge Case].

- T08 Short cycle (21/10) — ovulatory day 1:
  Input: `lmp=2025-01-01`, `now=2025-01-11`, `cycle_length=21`, `period_length=5`, `luteal_length=10`.
  Normalized: no clamps (21/5/10).
  Derived: `ov_day=11`, window `[11,12]`, luteal starts day `12` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 11, day_in_phase: 1, phase_window_start: 2025-01-11, phase_window_end: 2025-01-12, next_phase: luteal, next_phase_start: 2025-01-12, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T09 Short cycle (21/14) — ovulatory day 1:
  Input: `lmp=2025-01-01`, `now=2025-01-07`, `cycle_length=21`, `period_length=5`, `luteal_length=14`.
  Normalized: no clamps (21/5/14).
  Derived: `ov_day=7`, window `[7,8]`, luteal starts day `8` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 7, day_in_phase: 1, phase_window_start: 2025-01-07, phase_window_end: 2025-01-08, next_phase: luteal, next_phase_start: 2025-01-08, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T10 Short cycle (21/16) — ovulatory overlaps menstrual boundary:
  Input: `lmp=2025-01-01`, `now=2025-01-05`, `cycle_length=21`, `period_length=5`, `luteal_length=16`.
  Normalized: no clamps (21/5/16).
  Derived: `ov_day=5`, window `[5,6]` (unusual, overlaps menstrual day 5); luteal starts day `6` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 5, day_in_phase: 1, phase_window_start: 2025-01-05, phase_window_end: 2025-01-06, next_phase: luteal, next_phase_start: 2025-01-06, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T11 Long cycle (35/10) — ovulatory day 1:
  Input: `lmp=2025-01-01`, `now=2025-01-25`, `cycle_length=35`, `period_length=5`, `luteal_length=10`.
  Normalized: no clamps (35/5/10).
  Derived: `ov_day=25`, window `[25,26]`, luteal starts day `26` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 25, day_in_phase: 1, phase_window_start: 2025-01-25, phase_window_end: 2025-01-26, next_phase: luteal, next_phase_start: 2025-01-26, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T12 Long cycle (35/14) — ovulatory day 1:
  Input: `lmp=2025-01-01`, `now=2025-01-21`, `cycle_length=35`, `period_length=5`, `luteal_length=14`.
  Normalized: no clamps (35/5/14).
  Derived: `ov_day=21`, window `[21,22]`, luteal starts day `22` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 21, day_in_phase: 1, phase_window_start: 2025-01-21, phase_window_end: 2025-01-22, next_phase: luteal, next_phase_start: 2025-01-22, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T13 Long cycle (35/16) — ovulatory day 1:
  Input: `lmp=2025-01-01`, `now=2025-01-19`, `cycle_length=35`, `period_length=5`, `luteal_length=16`.
  Normalized: no clamps (35/5/16).
  Derived: `ov_day=19`, window `[19,20]`, luteal starts day `20` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 19, day_in_phase: 1, phase_window_start: 2025-01-19, phase_window_end: 2025-01-20, next_phase: luteal, next_phase_start: 2025-01-20, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T14 Boundary — cycle end (no wrap-around of window end):
  Input: `lmp=2025-01-01`, `now=2025-02-04`, `cycle_length=35`, `period_length=5`, `luteal_length=10`.
  Normalized: no clamps (35/5/10).
  Derived: `day_in_cycle=35`, luteal window `[26,35]` (dates 2025-01-26..2025-02-04) [Steps 2–4].
  Expected: `{ phase: luteal, day_in_cycle: 35, day_in_phase: 10, phase_window_start: 2025-01-26, phase_window_end: 2025-02-04, next_phase: menstrual, next_phase_start: 2025-02-05, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

- T15 Boundary — ovulatory day 2 equals luteal day 1 (no cross-cycle wrap):
  Input: `lmp=2025-01-01`, `now=2025-01-22`, `cycle_length=35`, `period_length=5`, `luteal_length=14`.
  Normalized: no clamps (35/5/14).
  Derived: `ov_day=21`, window `[21,22]` and luteal begins day `22` [Steps 2–4].
  Expected: `{ phase: ovulatory, day_in_cycle: 22, day_in_phase: 2, phase_window_start: 2025-01-21, phase_window_end: 2025-01-22, next_phase: luteal, next_phase_start: 2025-01-22, phase_confidence: 1.0, clamps_applied: false, notes: [] }`.

## Versioning
- v1.0 (MVP): deterministic, no wearables/AI.
- v1.x: optional user offsets/personalization (not in v1).

---

Implementation reference (recommended):
- API: `lib/features/cycle/domain/cycle.dart:CycleInfo.phaseOn` (string phase) and `lib/features/cycle/domain/phase.dart:CycleInfoPhaseAdapter.phaseFor` (Phase enum adapter).
- UI binding: `lib/features/screens/heute_screen.dart:HeuteScreen` (uses `weekViewFor` and `cycleInfo.phaseFor(...)`).
