# Onboarding Flow Refactor Plan - FINAL

> **Agent:** Claude Code
> **Basiert auf:** `misty-hatching-pond.md` (ursprünglicher Plan)
> **Status:** READY FOR IMPLEMENTATION
> **Review Score:** 9.5/10 ⭐

---

## Übersicht

**Ziel:** Refactor der Onboarding-Screens entsprechend dem neuen Figma-Design.

**Scope:** 9 Screens (O1-O9)

**Kritische Entscheidungen:**
- ❌ **KEIN "Lieber später"** bei O2 und O3
- ✅ **Age Policy 16-120** mit Validation
- ✅ **Server-SSOT** für Gate-State
- ✅ **Custom BirthdatePicker** (ListWheelScrollView)
- ✅ **Period Duration Default: 7 Tage**

---

## Korrigierte Route-Struktur (Best Practice)

**Pattern:** Dateinamen NICHT ändern, neue Datei für O6 (Cycle Intro)

| Figma | Datei | GoRoute name | Path |
|-------|-------|--------------|------|
| O1 | `onboarding_01.dart` | `onboarding_01` | `/onboarding/intro` |
| O2 | `onboarding_02.dart` | `onboarding_02` | `/onboarding/birthday` |
| O3 | `onboarding_03_fitness.dart` | `onboarding_03_fitness` | `/onboarding/fitness` |
| O4 | `onboarding_04_goals.dart` | `onboarding_04_goals` | `/onboarding/goals` |
| O5 | `onboarding_05_interests.dart` | `onboarding_05_interests` | `/onboarding/interests` |
| **O6** | **`onboarding_06_cycle_intro.dart`** (NEU) | `onboarding_06_cycle_intro` | `/onboarding/cycle-intro` |
| O7 | `onboarding_06_period.dart` (behalten) | `onboarding_06_period` | `/onboarding/period-start` |
| O8 | `onboarding_07_duration.dart` (behalten) | `onboarding_07_duration` | `/onboarding/period-duration` |
| O9 | `onboarding_success_screen.dart` | `onboarding_success` | `/onboarding/success` |

---

## Figma-Maße Quick Reference

| Element | Maße | Details |
|---------|------|---------|
| Progress Bar | 227 × 18px | radius: 40, border: 1px black |
| Weiter Button | padding 16/40px | radius: 40, shadow: 0,25,50,-12 |
| Input Container (O1) | 340 × 88px | radius: 16, glass 10% |
| BirthdatePicker (O2) | 333 × 280px | selection: 313×56px, radius: 14 |
| Fitness Pills (O3) | 114 × 58px | radius: 29, gap: 9px |
| Goal Cards (O4) | padding 5/18/5/16 | radius: 16, icon: 24px |
| Interest Pills (O5) | padding 5/18/5/16 | radius: 999 (full pill) |
| CalendarMini (O6) | radius: 24 | glow: 120px RadialGradient |
| PeriodCalendar (O7/O8) | radius: 40 | opacity: 0.3, HEUTE: **12px** |
| Progress Ring (O9) | 200 × 200px | strokeWidth: 8 |

---

## Phase 1: Design Tokens ✅ ABGESCHLOSSEN

### 1.1 Neue Farben
**Datei:** `lib/core/design_tokens/colors.dart`

```dart
// Onboarding Tokens
static const Color bgCream = Color(0xFFFAEEE0);
static const Color goldLight = Color(0xFFEDE1D3);
static const Color goldMedium = Color(0xFFD4B896);
static const Color signature = Color(0xFF9F2B68);
static const Color buttonPrimary = Color(0xFFA8406F);

// Calendar Tokens
static const Color calendarWeekdayGray = Color(0xFF99A1AF);
static const Color todayLabelGray = Color(0xFF6A7282);
static const Color periodGlowPink = Color(0x99FF6482);
static const Color periodGlowPinkLight = Color(0x19FF6482);
static const Color datePickerSelectionBg = Color(0xFFF5F5F5);
```

### 1.2 Gradients
**Datei:** `lib/core/design_tokens/gradients.dart`

```dart
static LinearGradient get onboardingStandard => LinearGradient(
  colors: [DsColors.goldMedium, DsColors.goldLight, DsColors.goldMedium],
  stops: const [0.18, 0.50, 0.75],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

static LinearGradient get onboardingSuccess => LinearGradient(
  colors: [DsColors.signature, DsColors.goldMedium, DsColors.goldLight],
  stops: const [0.04, 0.52, 0.98],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
```

### 1.3 Effects (Glass)
**Datei:** `lib/core/design_tokens/effects.dart` (NEU)

```dart
class DsEffects {
  static BoxDecoration get glassCard => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
  );

  static BoxDecoration get glassPill => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(999),
  );
}
```

---

## Phase 2: Shared Widgets ✅ ABGESCHLOSSEN

### 2.1 OnboardingProgressBar (NEU)
**Datei:** `lib/features/onboarding/widgets/onboarding_progress_bar.dart`

- 227 × 18px, radius 40, border 1px black
- Fill: `DsColors.signature`
- Semantics Label

### 2.2 OnboardingButton (NEU)
**Datei:** `lib/features/onboarding/widgets/onboarding_button.dart`

- Padding: 16px vertical, 40px horizontal
- Radius: 40, Shadow: 0,25,50,-12
- Disabled State: `DsColors.gray300`

### 2.3 BirthdatePicker (NEU) - Custom Widget
**Datei:** `lib/features/onboarding/widgets/birthdate_picker.dart`

```dart
class BirthdatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
}

class _BirthdatePickerState extends State<BirthdatePicker> {
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  // Age Policy Bounds
  int get _minimumYear => DateTime.now().year - kMaxAge;  // 120 zurück
  int get _maximumYear => DateTime.now().year - kMinAge;  // 16 zurück

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
```

### 2.4 CalendarMiniWidget (NEU)
**Datei:** `lib/features/onboarding/widgets/calendar_mini_widget.dart`

- Container: 10% white opacity, radius 24
- RadialGradient Glow für highlighted day

### 2.5 CircularProgressRing (NEU)
**Datei:** `lib/features/onboarding/widgets/circular_progress_ring.dart`

```dart
class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 2.6 PeriodCalendar Updates
**Datei:** `lib/features/onboarding/widgets/period_calendar.dart` (EXISTIERT)

Änderungen:
- Container: opacity 0.3, radius 40
- Weekday Header: `DsColors.calendarWeekdayGray`
- HEUTE Label: **fontSize: 12** (KORRIGIERT von 8!)
- Period Border: `DsColors.signature`

---

## Phase 3: State Management ✅ ABGESCHLOSSEN

### 3.1 Riverpod OnboardingState
**Datei:** `lib/features/onboarding/state/onboarding_state.dart`

```dart
@riverpod
class OnboardingState extends _$OnboardingState {
  @override
  OnboardingData build() => OnboardingData.empty();

  void setName(String name) => state = state.copyWith(name: name);
  void setBirthDate(DateTime date) => state = state.copyWith(birthDate: date);
  void setFitnessLevel(FitnessLevel level) => state = state.copyWith(fitnessLevel: level);
  void toggleGoal(Goal goal) { /* ... */ }
  void toggleInterest(Interest interest) { /* ... */ }
  void setPeriodStart(DateTime date) => state = state.copyWith(periodStart: date);
  void setPeriodDuration(int days) => state = state.copyWith(periodDuration: days);
}

@freezed
class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    String? name,
    DateTime? birthDate,
    FitnessLevel? fitnessLevel,
    @Default([]) List<Goal> selectedGoals,
    @Default([]) List<Interest> selectedInterests,
    DateTime? periodStart,
    @Default(7) int periodDuration,  // KORRIGIERT: Default 7 Tage
    @Default(28) int cycleLength,
  }) = _OnboardingData;
}
```

---

## Phase 4: Model Enums ✅ ABGESCHLOSSEN

### 4.1 FitnessLevel (existiert)
**Getter:** `String get dbKey => name;`

### 4.2 Interest (existiert)
**Getter:** `String get key => switch {...}` (KORREKT - bleibt `key`)

### 4.3 Goal
**Datei:** `lib/features/onboarding/model/goal.dart`

```dart
enum Goal { fitter, energy, sleep, cycle, longevity, wellbeing }

extension GoalExtension on Goal {
  String get dbKey => name;  // Konsistent mit FitnessLevel
  String label(AppLocalizations l10n) => switch (this) { /* ... */ };
  String get iconPath => switch (this) { /* ... */ };
}
```

---

## Phase 5: Screen Implementation

### O1: Name Input
- Progress Bar Step 1/6
- Input Container: 340×88px, glass effect
- State: `onboardingStateProvider.notifier.setName()`

### O2: Geburtsdatum
- Progress Bar Step 2/6
- Custom BirthdatePicker (333×280px)
- Age Validation: 16-120
- ❌ KEIN "Lieber später"

### O3: Fitness Level
- Progress Bar Step 3/6
- 3 Pills: 114×58px, gap 9px
- ❌ KEIN "Lieber später"

### O4: Ziele
- Progress Bar Step 4/6
- 6 Goal Cards mit Icons
- Multi-Select, min 1

### O5: Interessen
- Progress Bar Step 5/6
- 6 Interest Pills
- Validation: 3-5 required

### O6: Zyklus-Intro (NEU)
**Neue Datei:** `lib/features/onboarding/screens/onboarding_06_cycle_intro.dart`
- Progress Bar Step 6/6
- CalendarMiniWidget mit Glow
- "Okay, los" Button

### O7: Period Start
- KEIN Progress Bar
- Vollbild PeriodCalendar
- "Ich weiß es nicht mehr" Checkbox
- Auto-Navigation nach Selection

### O8: Period Duration
- KEIN Progress Bar
- PeriodCalendar mit Adjustment Mode
- Default: **7 Tage**
- "Weiter" Button

### O9: Success Screen
- Pink-to-Beige Gradient (`DsGradients.onboardingSuccess`)
- 3 Content Preview Cards (L10n!)
- CircularProgressRing (Animation 0%→100%)
- Save → Navigate to Home

#### O9 Animation State Machine (KRITISCH!)

```dart
enum O9AnimationState {
  animating,   // 0-100% Progress läuft
  saving,      // Save-Operation aktiv
  error,       // Save fehlgeschlagen, Retry möglich
  success,     // Fertig, Navigation startet
}

class O9SuccessController {
  final ValueNotifier<O9AnimationState> state =
      ValueNotifier(O9AnimationState.animating);

  void onAnimationComplete() {
    state.value = O9AnimationState.saving;
    _performSave();
  }

  Future<void> _performSave() async {
    try {
      await _saveToSupabase();
      state.value = O9AnimationState.success;
      // Navigation erfolgt im Listener nach 500ms
    } catch (e) {
      state.value = O9AnimationState.error;
    }
  }

  void retry() {
    state.value = O9AnimationState.saving;
    _performSave();
  }
}
```

**UI-Zustände:**
| State | UI |
|-------|-----|
| `animating` | Ring animiert, "Wir stellen deine Pläne zusammen..." |
| `saving` | Ring bei 100%, "Wird gespeichert..." |
| `error` | Ring rot, Error-Text, Retry Button |
| `success` | Ring grün, "Fertig!" → Auto-Navigate nach 500ms |

---

## Phase 6: L10n Keys

### 6.1 Deutsche Keys (`lib/l10n/app_de.arb`)

```json
{
  "onboardingProgressLabel": "Frage {current} von {total}",

  "onboardingNameTitle": "Willkommen!\nWie dürfen wir dich nennen?",
  "onboardingNameHint": "Dein Name",

  "onboardingBirthdayTitle": "Hey {name},\nwann hast du Geburtstag?",
  "onboardingBirthdaySubtitle": "Dein Alter hilft uns, deine hormonelle Phase besser einzuschätzen.",

  "onboardingFitnessTitle": "{name}, wie fit fühlst du dich?",
  "onboardingFitnessSubtitle": "Damit wir die Intensität passend wählen.",

  "onboardingGoalsTitle": "Was sind deine Ziele?",
  "onboardingGoalsSubtitle": "Du kannst mehrere auswählen.",

  "onboardingInterestsTitle": "Was interessiert dich?",
  "onboardingInterestsSubtitle": "Wähle 3–5, damit dein Feed direkt passt.",

  "onboardingCycleIntroTitle": "Damit LUVI für dich passt, brauchen wir noch deinen Zyklusstart.",
  "onboardingCycleIntroButton": "Okay, los",

  "onboardingPeriodStartTitle": "Tippe auf den Tag, an dem deine letzte Periode begann.",
  "onboardingPeriodUnknown": "Ich weiß es nicht mehr",

  "onboardingPeriodDurationTitle": "Wir haben die Dauer geschätzt. Tippe auf den Tag, um anzupassen.",

  "onboardingSuccessLoading": "Wir stellen deine Pläne zusammen...",
  "onboardingSuccessSaving": "Wird gespeichert...",
  "onboardingSuccessComplete": "Fertig!",
  "onboardingSaveError": "Speichern fehlgeschlagen. Bitte erneut versuchen.",
  "onboardingRetryButton": "Erneut versuchen",

  "onboardingContentCard1": "Brauche ich mehr Eisen während meiner Blutung?",
  "onboardingContentCard2": "Wie trainiere ich während meiner Ovulation?",
  "onboardingContentCard3": "Wie kann ich meinen Stress reduzieren?"
}
```

### 6.2 Englische Keys (`lib/l10n/app_en.arb`)

```json
{
  "onboardingProgressLabel": "Question {current} of {total}",

  "onboardingNameTitle": "Welcome!\nWhat should we call you?",
  "onboardingNameHint": "Your name",

  "onboardingBirthdayTitle": "Hey {name},\nwhen is your birthday?",
  "onboardingBirthdaySubtitle": "Your age helps us better assess your hormonal phase.",

  "onboardingFitnessTitle": "{name}, how fit do you feel?",
  "onboardingFitnessSubtitle": "So we can choose the right intensity.",

  "onboardingGoalsTitle": "What are your goals?",
  "onboardingGoalsSubtitle": "You can select multiple.",

  "onboardingInterestsTitle": "What interests you?",
  "onboardingInterestsSubtitle": "Choose 3–5 so your feed fits perfectly.",

  "onboardingCycleIntroTitle": "To personalize LUVI for you, we need your cycle start.",
  "onboardingCycleIntroButton": "Okay, let's go",

  "onboardingPeriodStartTitle": "Tap the day your last period started.",
  "onboardingPeriodUnknown": "I don't remember",

  "onboardingPeriodDurationTitle": "We've estimated the duration. Tap a day to adjust.",

  "onboardingSuccessLoading": "We're putting together your plans...",
  "onboardingSuccessSaving": "Saving...",
  "onboardingSuccessComplete": "Done!",
  "onboardingSaveError": "Save failed. Please try again.",
  "onboardingRetryButton": "Try again",

  "onboardingContentCard1": "Do I need more iron during my period?",
  "onboardingContentCard2": "How do I train during ovulation?",
  "onboardingContentCard3": "How can I reduce my stress?"
}
```

---

## Phase 7: Tests

### Neue Tests erstellen

| Screen | Test-Datei |
|--------|------------|
| **O1** | `onboarding_01_widget_test.dart` (NEU!) |
| O2 | `onboarding_02_age_validation_test.dart` |
| O3 | `onboarding_03_fitness_test.dart` |
| O6 | `onboarding_06_cycle_intro_test.dart` |
| O9 | `onboarding_success_test.dart` |

### Widget Tests

- `onboarding_progress_bar_test.dart`
- `onboarding_button_test.dart`
- `birthdate_picker_test.dart`
- `circular_progress_ring_test.dart`

---

## Phase 8: DB Save Contract (O9)

```dart
// profiles upsert
await supabase.from('profiles').upsert({
  'display_name': state.name,
  'birth_date': state.birthDate.toIso8601String().substring(0, 10),
  'fitness_level': state.fitnessLevel.dbKey,
  'goals': state.selectedGoals.map((g) => g.dbKey).toList(),
  'interests': state.selectedInterests.map((i) => i.key).toList(),  // KORRIGIERT: .key
  'has_completed_onboarding': true,
  'onboarding_completed_at': DateTime.now().toIso8601String(),
}, onConflict: 'user_id');

// cycle_data upsert
await supabase.from('cycle_data').upsert({
  'last_period': state.periodStart.toIso8601String().substring(0, 10),
  'period_duration': state.periodDuration,  // Default: 7
  'cycle_length': state.cycleLength,        // Default: 28
  'age': calculateAge(state.birthDate),
}, onConflict: 'user_id');
```

---

## Kritische Dateien

### Zu erstellen (NEU):
- `lib/core/design_tokens/effects.dart`
- `lib/features/onboarding/widgets/onboarding_progress_bar.dart`
- `lib/features/onboarding/widgets/onboarding_button.dart`
- `lib/features/onboarding/widgets/birthdate_picker.dart`
- `lib/features/onboarding/widgets/calendar_mini_widget.dart`
- `lib/features/onboarding/widgets/circular_progress_ring.dart`
- `lib/features/onboarding/screens/onboarding_06_cycle_intro.dart`
- `lib/features/onboarding/state/onboarding_state.dart`
- `lib/features/onboarding/model/goal.dart`

### Assets (zu verifizieren/erstellen):
```
assets/icons/onboarding/
├── ic_muscle.svg      # Goal: Fitter
├── ic_energy.svg      # Goal: Energy
├── ic_sleep.svg       # Goal: Sleep
├── ic_calendar.svg    # Goal: Cycle
├── ic_run.svg         # Goal: Longevity
└── ic_happy.svg       # Goal: Wellbeing

assets/images/onboarding/
├── content_card_1.png  # O9: Eisen-Frage
├── content_card_2.png  # O9: Training-Frage
├── content_card_3.png  # O9: Stress-Frage
├── 2.0x/
│   └── content_card_*.png
└── 3.0x/
    └── content_card_*.png
```

### Zu modifizieren:
- `lib/core/design_tokens/colors.dart`
- `lib/core/design_tokens/gradients.dart`
- `lib/core/navigation/routes.dart`
- `lib/features/onboarding/widgets/period_calendar.dart`
- `lib/features/onboarding/screens/onboarding_01.dart`
- `lib/features/onboarding/screens/onboarding_02.dart`
- `lib/features/onboarding/screens/onboarding_03_fitness.dart`
- `lib/features/onboarding/screens/onboarding_04_goals.dart`
- `lib/features/onboarding/screens/onboarding_05_interests.dart`
- `lib/features/onboarding/screens/onboarding_06_period.dart`
- `lib/features/onboarding/screens/onboarding_07_duration.dart`
- `lib/features/onboarding/screens/onboarding_success_screen.dart`
- `lib/l10n/app_de.arb`
- `lib/l10n/app_en.arb`

---

## Implementierungs-Reihenfolge

1. **Phase 1:** Design Tokens (colors, gradients, effects)
2. **Phase 2:** Shared Widgets (progress bar, button, pickers)
3. **Phase 3:** State Management (Riverpod)
4. **Phase 4:** Model Enums (Goal)
5. **Phase 5:** Screens (O1 → O2 → O3 → O4 → O5 → O6 → O7 → O8 → O9)
6. **Phase 6:** L10n
7. **Phase 7:** Tests
8. **Phase 8:** Final Integration

---

## Korrekturen angewendet

| # | Issue | Lösung |
|---|-------|--------|
| 1 | Route Naming | Neue Datei für O6, bestehende Dateien behalten |
| 2 | Typography (HEUTE) | **12px** (korrigiert von 8px) |
| 3 | BirthdatePicker | Custom ListWheelScrollView |
| 4 | Interest Getter | `.key` (bestehendes Pattern beibehalten) |
| 5 | O1 Test | Hinzugefügt |
| 6 | Content Cards | L10n Keys hinzugefügt |
| 7 | Period Duration | **7 Tage** Default |
| 8 | Controller Disposal | Best Practice Pattern dokumentiert |
| 9 | L10n Subtitles | Alle Subtitles für DE + EN hinzugefügt |
| 10 | O9 State Machine | Vollständige Animation State Machine |
| 11 | EN L10n Keys | Komplette englische Übersetzungen |
| 12 | Assets Liste | Goal Icons + Content Card Images dokumentiert |

---

## CLAUDE.md Compliance

- [x] Design Tokens: `DsColors`, `DsTokens` - keine `Color(0xFF...)`
- [x] Spacing: `OnboardingSpacing.of(context)`
- [x] L10n: Alle Texte über `AppLocalizations`
- [x] Navigation: `context.goNamed()`, Route Constants
- [x] A11y: Semantics, Touch Targets ≥ 44dp
- [x] Tests: Widget-Tests für alle neuen Screens
- [x] Privacy: Kein lokaler Cache für sensible Daten
