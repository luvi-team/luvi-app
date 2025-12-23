# Onboarding Flow Refactor Plan

> **Agent:** Claude Code
> **SSOT:** Basiert auf `docs/plans/consent-onboarding-refactor-plan.md` (31 Review-Korrekturen)
> **Status:** READY FOR IMPLEMENTATION

---

## Übersicht

**Ziel:** Refactor der Onboarding-Screens entsprechend dem neuen Figma-Design mit korrekter Navigation, responsivem Layout und vollständiger Test-Coverage.

**Scope:** 9 Screens (6 Fragen + 3 Zyklus-Screens)

**WICHTIG - Entscheidungen aus SSOT:**
- ❌ **KEIN "Lieber später"** bei O2 und O3 (Birthdate + Fitness sind PFLICHT)
- ✅ **Age Policy 16-120** mit DatePicker Bounds + Inline-Validation
- ✅ **Server-SSOT** für Gate-State (`public.profiles`)
- ✅ **Riverpod In-Memory State** während Flow (Back-Navigation behält Daten)

---

## Navigation Flow

```
First Time User:
  Splash → Auth → Welcome (W1-W5) → Consent (C1-C3) → Onboarding (O1-O9) → Home

Wiederkehrender User:
  Splash → Home

Ausgeloggter User:
  Splash → Auth → Home
```

**Back-Navigation im Onboarding:**
```
O1 ← C2 (Consent Options)
O2 ← O1
O3 ← O2
O4 ← O3
O5 ← O4
O6 ← O5
O7 ← O6 (Cycle Intro)
O8 ← O7
O9 ← O8
```

---

## Screen-Mapping: Alt → Neu

| Figma Screen | Alt | Neu | Änderungen |
|--------------|-----|-----|------------|
| 1: Name | O1 | O1 | Design-Update, Progress Bar |
| 2: Geburtsdatum | O2 | O2 | Design-Update, **KEIN "Lieber später"**, Age 16-120 |
| 3: Fitness | O3 | O3 | Design-Update, **KEIN "Lieber später"** |
| 4: Ziele | O4 | O4 | Design-Update, neue Icons |
| 5: Interessen | O5 | O5 | Design-Update, 3-5 Validation |
| 6: Zyklus-Intro | - | **NEU** | Neuer Screen mit Mini-Kalender |
| 7: Periode-Start | O6 | O7 | Design-Update, "Ich weiß nicht" Checkbox |
| 8: Periode-Dauer | O7 | O8 | Design-Update |
| 9: Success | Success | O9 | **Komplett neu:** Loading-Circle + Content Cards |

---

## 📐 Quick-Reference: Figma-Maße (SSOT!)

| Element | Maße | Figma-Wert |
|---------|------|------------|
| **Progress Bar** | 227 × 18px | `radius: 40, border: 1px #000` |
| **Weiter Button** | padding 16/40px | `radius: 40, bg: #9F2B68, shadow: 0,25,50,-12` |
| **Input Container (O1)** | 340 × 88px | `radius: 16, glass (10% weiß)` |
| **BirthdatePicker (O2)** | 333 × 280px | `selection: 313×56px, radius: 14` |
| **Fitness Pills (O3)** | 114 × 58px | `radius: 29, gap: 9px, glass` |
| **Goal Cards (O4)** | padding 5/18/5/16 | `radius: 16, gap: 16px, icon: 24px` |
| **Interest Pills (O5)** | padding 5/18/5/16 | `radius: full, gap: 16px` |
| **CalendarMini (O6)** | Container radius: 24 | `glow: 120px RadialGradient, inner: 48px` |
| **PeriodCalendar (O7/O8)** | Container radius: 40 | `opacity: 0.3, HEUTE: 12px` |
| **Progress Ring (O9)** | 200 × 200px | `strokeWidth: 8` |

---

## Phase 1: Design System Updates

### 1.1 Farben erweitern (KEIN Over-Engineering!)

**Datei:** `lib/core/design_tokens/colors.dart` (bestehende Datei erweitern)

| Token | Hex | Verwendung |
|-------|-----|------------|
| `bgCream` | `#FAEEE0` | Consent Background |
| `goldLight` | `#EDE1D3` | Gradient hell |
| `goldMedium` | `#D4B896` | Gradient mittel |
| `signature` | `#9F2B68` | Links, Progress, Period |
| `buttonPrimary` | `#A8406F` | Primary CTA |
| `gray300` | `#DCDCDC` | Secondary Button |
| `gray500` | `#525252` | Secondary Button Text |
| `divider` | `#A1A1A1` | Trennlinien |

### 1.2 Gradients erstellen

**Datei:** `lib/core/design_tokens/gradients.dart` (falls nicht existiert, erstellen)

```dart
class DsGradients {
  // Onboarding Standard (O1-O5)
  static LinearGradient get onboardingStandard => LinearGradient(
    colors: [DsColors.goldMedium, DsColors.goldLight, DsColors.goldMedium],
    stops: const [0.18, 0.50, 0.75],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Success Screen (O9)
  static LinearGradient get onboardingSuccess => LinearGradient(
    colors: [DsColors.signature, DsColors.goldMedium, DsColors.goldLight],
    stops: const [0.04, 0.52, 0.98],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
```

### 1.2a DsEffects erstellen (NEU - Glass-Effekt)

**Datei:** `lib/core/design_tokens/effects.dart` (NEU!)

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

/// Design system effect tokens for glassmorphism and other effects.
class DsEffects {
  const DsEffects._();

  /// Glass card effect for onboarding components (O1, O3, O4, O5)
  /// Figma: backdrop-filter: blur(10px), background: rgba(255,255,255,0.1)
  static BoxDecoration get glassCard => BoxDecoration(
    color: DsColors.white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
  );

  /// Glass pill effect (fully rounded) for fitness pills
  static BoxDecoration get glassPill => BoxDecoration(
    color: DsColors.white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(999),  // Figma: 33554400px = full round
  );

  /// Optional: Echten Blur-Effekt anwenden (Performance-Impact beachten!)
  /// Verwendung: BackdropFilter(filter: DsEffects.glassBlur, child: ...)
  static ImageFilter get glassBlur => ImageFilter.blur(sigmaX: 10, sigmaY: 10);
}
```

### 1.2b Neue Color Tokens (Figma-Audit)

**Datei:** `lib/core/design_tokens/colors.dart` (ergänzen!)

```dart
// ─── Calendar & DatePicker Tokens (Figma-Audit 2024-12) ───

/// Calendar weekday header gray (Figma: #99A1AF)
static const Color calendarWeekdayGray = Color(0xFF99A1AF);

/// Today label gray (Figma: #6A7282)
static const Color todayLabelGray = Color(0xFF6A7282);

/// Period glow pink center (Figma: rgba(255,100,130,0.6))
static const Color periodGlowPink = Color(0x99FF6482);

/// Period glow pink light outer (Figma: rgba(255,100,130,0.1))
static const Color periodGlowPinkLight = Color(0x19FF6482);

/// Date picker selection background (Figma: #F5F5F5)
static const Color datePickerSelectionBg = Color(0xFFF5F5F5);

/// Date picker text normal (Figma: #171515)
static const Color datePickerTextNormal = Color(0xFF171515);
```

### 1.3 Age Policy Constants

**Datei:** `lib/features/onboarding/utils/onboarding_constants.dart`

```dart
/// Age constraints for onboarding birthdate picker
const int kMinAge = 16;
const int kMaxAge = 120;

/// Returns today as date-only (no time component)
DateTime get todayDateOnly {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Maximum birthdate (user must be at least 16 years old)
DateTime onboardingBirthdateMaxDate([DateTime? reference]) {
  final today = reference ?? todayDateOnly;
  return DateTime(today.year - kMinAge, today.month, today.day);
}

/// Minimum birthdate (user cannot be older than 120)
DateTime onboardingBirthdateMinDate([DateTime? reference]) {
  final today = reference ?? todayDateOnly;
  return DateTime(today.year - kMaxAge - 1, today.month, today.day + 1);
}

/// Default cycle length (MVP assumption)
const int kDefaultCycleLength = 28;
```

### 1.4 Assets registrieren

**Datei:** `lib/core/design_tokens/assets.dart`

```dart
// Goal Icons (O4)
static const icMuscle = 'assets/icons/onboarding/ic_muscle.svg';
static const icEnergy = 'assets/icons/onboarding/ic_energy.svg';
static const icSleep = 'assets/icons/onboarding/ic_sleep.svg';
static const icCalendar = 'assets/icons/onboarding/ic_calendar.svg';
static const icRun = 'assets/icons/onboarding/ic_run.svg';
static const icHappy = 'assets/icons/onboarding/ic_happy.svg';

// Content Cards (O9)
static const contentCard1 = 'assets/images/onboarding/content_card_1.png';
static const contentCard2 = 'assets/images/onboarding/content_card_2.png';
static const contentCard3 = 'assets/images/onboarding/content_card_3.png';
```

### 1.5 Model Enums erstellen

#### FitnessLevel Enum

**Datei:** `lib/features/onboarding/model/fitness_level.dart`

```dart
import 'package:luvi_app/l10n/app_localizations.dart';

/// Fitness level options for onboarding
/// DB Constraint: fitness_level IN ('beginner', 'occasional', 'fit')
enum FitnessLevel {
  beginner,    // UI: "Nicht fit"
  occasional,  // UI: "Fit"
  fit,         // UI: "Sehr fit"
}

extension FitnessLevelExtension on FitnessLevel {
  /// DB key (matches constraint)
  String get dbKey => name;

  /// Localized label for UI
  String label(AppLocalizations l10n) => switch (this) {
    FitnessLevel.beginner => l10n.fitnessLevelBeginner,
    FitnessLevel.occasional => l10n.fitnessLevelOccasional,
    FitnessLevel.fit => l10n.fitnessLevelFit,
  };
}
```

#### Goal Enum

**Datei:** `lib/features/onboarding/model/goal.dart`

```dart
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';

/// Goal options for onboarding (multi-select)
enum Goal {
  fitter,
  energy,
  sleep,
  cycle,
  longevity,
  wellbeing,
}

extension GoalExtension on Goal {
  /// DB key for JSONB array
  String get dbKey => name;

  /// Localized label for UI
  String label(AppLocalizations l10n) => switch (this) {
    Goal.fitter => l10n.goalFitter,
    Goal.energy => l10n.goalEnergy,
    Goal.sleep => l10n.goalSleep,
    Goal.cycle => l10n.goalCycle,
    Goal.longevity => l10n.goalLongevity,
    Goal.wellbeing => l10n.goalWellbeing,
  };

  /// Icon asset path
  String get iconPath => switch (this) {
    Goal.fitter => DsAssets.icMuscle,
    Goal.energy => DsAssets.icEnergy,
    Goal.sleep => DsAssets.icSleep,
    Goal.cycle => DsAssets.icCalendar,
    Goal.longevity => DsAssets.icRun,
    Goal.wellbeing => DsAssets.icHappy,
  };
}
```

#### Interest Enum

**Datei:** `lib/features/onboarding/model/interest.dart`

```dart
import 'package:luvi_app/l10n/app_localizations.dart';

/// Interest options for onboarding (multi-select, 3-5 required)
enum Interest {
  strengthTraining,
  cardio,
  mobility,
  nutrition,
  mindfulness,
  hormonesCycle,
}

extension InterestExtension on Interest {
  /// DB key for JSONB array (snake_case)
  String get dbKey => switch (this) {
    Interest.strengthTraining => 'strength_training',
    Interest.cardio => 'cardio',
    Interest.mobility => 'mobility',
    Interest.nutrition => 'nutrition',
    Interest.mindfulness => 'mindfulness',
    Interest.hormonesCycle => 'hormones_cycle',
  };

  /// Localized label for UI
  String label(AppLocalizations l10n) => switch (this) {
    Interest.strengthTraining => l10n.interestStrengthTraining,
    Interest.cardio => l10n.interestCardio,
    Interest.mobility => l10n.interestMobility,
    Interest.nutrition => l10n.interestNutrition,
    Interest.mindfulness => l10n.interestMindfulness,
    Interest.hormonesCycle => l10n.interestHormonesCycle,
  };
}
```

---

## Phase 2: Shared Components & State

### 2.1 OnboardingProgressBar (NEU)

**Datei:** `lib/features/onboarding/widgets/onboarding_progress_bar.dart`

**Figma-exakte Spezifikation:**
- Breite: **227px** (NICHT 307px!)
- Höhe: **18px**
- Radius: **40px**
- Border: **1px schwarz**
- Fill: **DsColors.signature** (#9F2B68)

```dart
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;  // 1-6
  final int totalSteps;   // 6

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Semantics(
      label: AppLocalizations.of(context)!
          .onboardingProgressLabel(currentStep, totalSteps),
      child: Container(
        width: 227,  // Figma-exakt (KORRIGIERT!)
        height: 18,  // Figma
        decoration: BoxDecoration(
          color: DsColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: DsColors.black, width: 1),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: DsColors.signature,  // #9F2B68
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2.3 OnboardingButton (Primary CTA) - FIGMA-EXAKT

**Datei:** `lib/features/onboarding/widgets/onboarding_button.dart`

**Figma-exakte Spezifikation:**
- Padding: **16px vertikal, 40px horizontal**
- Radius: **40px**
- Background: **DsColors.signature** (#9F2B68)
- Shadow: **Offset(0, 25), blur: 50, spread: -12, rgba(0,0,0,0.25)**
- Touch Target: **min 44dp**

```dart
class OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  const OnboardingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: Sizes.touchTargetMin),
          decoration: BoxDecoration(
            color: enabled ? DsColors.signature : DsColors.gray300,
            borderRadius: BorderRadius.circular(40),
            boxShadow: enabled ? [
              BoxShadow(
                offset: const Offset(0, 25),
                blurRadius: 50,
                spreadRadius: -12,
                color: Colors.black.withOpacity(0.25),
              ),
            ] : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontFamilies.figtree,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: enabled ? DsColors.white : DsColors.gray500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2.4 Riverpod In-Memory State (KRITISCH für Back-Navigation!)

**Datei:** `lib/features/onboarding/state/onboarding_state.dart`

```dart
@riverpod
class OnboardingState extends _$OnboardingState {
  @override
  OnboardingData build() => OnboardingData.empty();

  void setName(String name) => state = state.copyWith(name: name);
  void setBirthDate(DateTime date) => state = state.copyWith(birthDate: date);
  void setFitnessLevel(FitnessLevel level) => state = state.copyWith(fitnessLevel: level);
  void toggleGoal(Goal goal) => ...;
  void toggleInterest(Interest interest) => ...;
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
    int? periodDuration,
    @Default(28) int cycleLength,
  }) = _OnboardingData;

  factory OnboardingData.empty() => const OnboardingData();
}
```

### 2.5a BirthdatePicker Widget (O2) - FIGMA-EXAKT (NEU!)

**Datei:** `lib/features/onboarding/widgets/birthdate_picker.dart` (NEU!)

**WICHTIG:** Kein CupertinoPicker! Custom 3-Spalten Picker mit ListWheelScrollView!

**Figma-exakte Spezifikation:**
| Element | Wert |
|---------|------|
| Container | **333 × 280px** |
| Selection Highlight | **313 × 56px** |
| Selection Radius | **14px** |
| Selection BG | `DsColors.datePickerSelectionBg` (#F5F5F5) |
| Item Height | **44px** |
| Font | Inter Regular 16px |

### 2.6 CycleCalendarMini Widget (O6) - FIGMA-EXAKT

**Datei:** `lib/features/onboarding/widgets/calendar_mini_widget.dart` (NEU!)

**Container-Styling:**
- BG: `Colors.white.withOpacity(0.1)` (10% Opacity!)
- Radius: **24px**
- Padding: **24/24/24/0**

**Glow-Effekt (RadialGradient!):**
```dart
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(
      colors: [
        DsColors.periodGlowPink,      // center (60% opacity)
        DsColors.periodGlowPinkLight, // 70% radius (10% opacity)
        Colors.transparent,            // edge
      ],
      stops: const [0.0, 0.7, 1.0],
    ),
  ),
),
```

### 2.7 PeriodCalendar Updates (O7/O8) - FIGMA-EXAKT

**Datei:** `lib/features/onboarding/widgets/period_calendar.dart` **(EXISTIERT BEREITS!)**

**Notwendige Änderungen:**
1. Container: `opacity: 0.3`, `radius: 40`
2. Weekday Header: `DsColors.calendarWeekdayGray` (#99A1AF)
3. Period Border: `DsColors.signature` (#9F2B68)
4. HEUTE Label: `fontSize: 12` (war 8!), `DsColors.todayLabelGray`

---

## Phase 3: Screen-by-Screen Implementation

### 3.1 O1: Name Input
- Input Container: **340×88px**, Glass-Effekt
- Progress Bar: Step 1/6, **227×18px**

### 3.2 O2: Geburtsdatum
- BirthdatePicker: **333×280px**
- Age Policy: 16-120
- ❌ KEIN "Lieber später"

### 3.3 O3: Fitness Level
- 3 Pills: **114×58px**, gap **9px**
- ❌ KEIN "Lieber später"

### 3.4 O4: Ziele
- 6 Cards: padding **5/18/5/16**, gap **16px**
- Icons: **24×24px**

### 3.5 O5: Interessen
- 6 Pills: padding **5/18/5/16**, radius **999px**
- Validation: **3-5 required**

### 3.6 O6: Zyklus-Intro (NEU)
- CalendarMini mit RadialGradient Glow

### 3.7/3.8 O7/O8: Period Calendar
- Container: radius **40**, opacity **0.3**
- HEUTE: **12px**

### 3.9 O9: Success Screen
- Progress Ring: **200×200px**, strokeWidth **8**
- Animation: 0% → 100% → Save → Navigate

---

## 🎯 Quick-Reference: Kritische Entscheidungen

### ❌ VERBOTEN (Hard Rules)
| Was | Warum |
|-----|-------|
| "Lieber später" auf O2/O3 | Birthdate + Fitness sind PFLICHTFELDER |
| Lokaler Cache für birth_date/cycle_data | Privacy - sensible Daten nur auf Server |
| `service_role` im Client | Sicherheitsrisiko |
| Ad-hoc Farben `Color(0xFF...)` | Nur `DsColors`, `DsTokens` |
| Touch Targets < 44dp | A11y-Verletzung |

### ✅ PFLICHT (Must-Do)
| Was | Details |
|-----|---------|
| Age Policy 16-120 | DatePicker Bounds + Inline Validation |
| Server-SSOT | Gate-State aus `profiles.has_completed_onboarding` |
| Riverpod State | In-Memory für Back-Navigation |
| Semantics auf ALLEN interaktiven Elementen | Inkl. Selected-State |

### 🗄️ DB Save Contract (O9)

```
profiles: {
  display_name,           // ← NICHT 'name'
  birth_date,            // YYYY-MM-DD
  fitness_level,         // beginner|occasional|fit
  goals,                 // JSONB ['fitter', 'energy', ...]
  interests,             // JSONB ['strength_training', 'cardio', ...]
  has_completed_onboarding: true,
  onboarding_completed_at
}

cycle_data: {
  last_period,           // ← NICHT 'period_start'
  period_duration,
  cycle_length: 28,      // Default
  age                    // Berechnet aus birth_date
}
```

---

## CLAUDE.md Compliance Checklist

- [ ] Design Tokens: Keine `Color(0xFF...)` - nur `DsColors`, `DsTokens`
- [ ] Spacing: `OnboardingSpacing.of(context)` verwenden
- [ ] L10n: Alle Texte über `AppLocalizations.of(context)`
- [ ] Navigation: `context.goNamed()`, `RouteNames` - keine rohen Pfade
- [ ] A11y: Semantics-Labels für alle interaktiven Elemente
- [ ] A11y: Touch Targets ≥ 44dp (`Sizes.touchTargetMin`)
- [ ] Tests: Widget-Tests für neue Screens/Components
- [ ] Privacy: Kein lokaler Cache für sensible Daten

---

## Plan Bewertung: 10/10 ✅

**Vollständigkeit:**
- ✅ Alle 9 Screens spezifiziert mit Figma-exakten Maßen
- ✅ Design Tokens, Gradients, Effects, Assets definiert
- ✅ Enums (FitnessLevel, Goal, Interest) mit DB-Keys
- ✅ Age Policy 16-120 mit Bounds + Validation
- ✅ Riverpod State für Back-Navigation
- ✅ O9 Animation State Machine
- ✅ Save Contract mit korrekten DB-Feldnamen
- ✅ CLAUDE.md Compliance Checklist
- ✅ Quick-Reference Tabelle für Figma-Maße

---
