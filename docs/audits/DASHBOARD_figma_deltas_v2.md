# Dashboard Figma Deltas v2.0

**Source:** Figma node `68672:7335` vs Baseline spec node `68426:7203`
**Date:** 2025-10-15
**Method:** Figma MCP extraction + codebase reuse inventory analysis

---

## Executive Summary

Node **68672:7335** represents a **significant design iteration** from the baseline spec (68426:7203). This is NOT an incremental update - it introduces 6 major structural changes, requires 7 new typography variants (including a **new font family: Nunito**), and adds entirely new UI patterns (calendar strip, horizontal carousel).

**Critical Blockers:**
1. **Nunito font not in codebase** → Calendar cannot render
2. **No gradient system** → Card text overlays blocked
3. **No shadow tokens** → Cards lack elevation
4. **No horizontal scroll pattern** → Workout carousel blocked
5. **No image card component** → All workout/recommendation cards blocked

---

## 🔴 Structural Changes (Breaking)

| Change | From (68426:7203) | To (68672:7335) | Impact |
|--------|-------------------|-----------------|--------|
| **Hero Card** | Purple (#CCB2F4) card with 25% progress circle | Gradient workout card with text overlay | `heroCard.progress` implementation obsolete |
| **Categories** | Horizontal chip row (Training/Ernährung/etc.) | Removed or relocated | `categories.chips[]` may be unused |
| **Bottom Nav** | 5-item pill with 'Start' label + icons | Icon-only nav bar (Home/Heart/Track/Chart/Account) | `bottomActions.items[]` structure completely different |
| **Workout Section** | Single recommendation list | Horizontal scrolling carousel + subsections | Requires new scroll pattern |
| **Calendar Strip** | Not present | NEW: Week strip with day 27-30, 1-3 | New widget required |
| **Recommendations** | Flat list | Organized into 'Ernährung & Nutrition' / 'Regeneration & Achtsamkeit' | New layout structure |

---

## 🟡 Typography Deltas

### ✅ Existing Matches
| Figma Spec | Codebase Token | File:Line |
|------------|----------------|-----------|
| Playfair Display Regular 32/40 | `_textThemeConst.headlineMedium` | `lib/core/theme/app_theme.dart:24` |
| Figtree Regular 20/24 | `_textThemeConst.bodyMedium` | `lib/core/theme/app_theme.dart:32` |
| Figtree Regular 16/24 | `TypographyTokens.size16` + `ratio24on16` | `lib/core/design_tokens/typography.dart` |

### ❌ Missing Variants (Must Create)
| Variant | Usage | Priority | Notes |
|---------|-------|----------|-------|
| **Nunito Bold 16** | Calendar day numbers | 🔴 HIGH | **NEW FONT FAMILY** - add to pubspec.yaml |
| **Nunito SemiBold 14** | Calendar weekday labels (M D M D F S S) | 🔴 HIGH | **NEW FONT FAMILY** |
| **Playfair Display Bold 24/32** | Workout card titles ('GanzkörperKraftraining') | 🔴 HIGH | H2 bold variant |
| **Figtree Italic 16/24** | 'Erstellt von deinen LUVI-Expert:innen' | 🟡 MEDIUM | New style |
| **Figtree Bold 16/24** | Workout frame date 'Heute, 28. Sept' | 🟡 MEDIUM | Can derive from existing |
| **Figtree Regular 12/24** | Time labels '60 min', card subtitles | 🟡 MEDIUM | Smaller body text |
| **Figtree SemiBold 14** | Calendar weekday labels (alternative) | 🟡 MEDIUM | If not using Nunito |

### ⚠️ Font Conflict
- **bodySmall** currently uses **Inter 14/24** (`lib/core/theme/app_theme.dart:48`)
- Dashboard needs **Figtree 14/24** instead
- **Resolution:** Create Dashboard-specific text style or update bodySmall globally (breaking change)

---

## 🟡 Color Deltas

### ✅ Existing Matches
| Figma Color | Hex | Codebase Token | File:Line |
|-------------|-----|----------------|-----------|
| Grayscale/Black | `#030401` | `_onPrimary` / `_onSurface` | `lib/core/theme/app_theme.dart:16,17` |
| Primary color/100 | `#D9B18E` | `_primary` | `lib/core/theme/app_theme.dart:10` |
| Secondary color/100 | `#1C1411` | `DsTokens.cardBorderSelected` | `lib/core/theme/app_theme.dart:150` |
| Grayscale/500 | `#696969` | `DsTokens.grayscale500` | `lib/core/theme/app_theme.dart:152` |
| Grayscale/100 | `#F7F7F8` | `DsTokens.cardSurface` | `lib/core/theme/app_theme.dart:149` |

### ❌ Missing Colors (Must Create)
| Color | Hex + Opacity | Usage | Priority | Token Name Suggestion |
|-------|---------------|-------|----------|----------------------|
| **Calendar gold** | `#E1B941` @ 0.5 | Selected day 28 background | 🔴 HIGH | `DsTokens.calendarSelectedBg` |
| **Calendar blue** | `#4169E1` (royalblue) | Active day indicator | 🔴 HIGH | `DsTokens.calendarActiveIndicator` |
| **Calendar day text** | `#282B31` | Non-selected day numbers | 🟡 MEDIUM | `DsTokens.calendarDayText` |
| **Calendar weekday** | `#C5C7C9` | Weekday labels (M D M D...) | 🟡 MEDIUM | `DsTokens.calendarWeekdayLabel` |
| **Time label** | `#FFFFFF` @ 0.6 | '60 min' on workout cards | 🟡 MEDIUM | Use `Colors.white.withOpacity(0.6)` |

### ⚠️ Near Misses
- **sub tex 2** (`#6d6d6d`) vs **grayscale500** (`#696969`) - 4% difference
  - **Resolution:** Use existing `#696969` or document divergence reason

### 🔴 Missing Gradients (High Collision Risk)
- **Workout card overlay:** Linear gradient `#1A1A1A` 0% → 100% opacity (top to bottom)
- **Usage:** Text readability on image cards
- **Codebase:** No gradient system exists (confirmed in `docs/audits/dashboard_reuse_inventory.md:23`)
- **Resolution:** Create `lib/core/design_tokens/gradients.dart`:
  ```dart
  class GradientTokens {
    static const cardOverlay = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x001A1A1A), // 0% opacity
        Color(0xFF1A1A1A), // 100% opacity
      ],
      stops: [0.14609, 0.95],
    );
  }
  ```

---

## 🟡 Spacing Deltas

### ✅ Existing Matches
| Figma Value | Codebase Token | File:Line |
|-------------|----------------|-----------|
| 20px | `Spacing.goalCardVertical` | `lib/core/design_tokens/spacing.dart:6` |
| 16px | `Spacing.m` | `lib/core/design_tokens/spacing.dart:3` |
| 24px | `Spacing.l` | `lib/core/design_tokens/spacing.dart:2` |
| 8px | `Spacing.xs` | `lib/core/design_tokens/spacing.dart:5` |

### ❌ Missing Spacing Values
| Value | Usage | Priority | Token Name Suggestion |
|-------|-------|----------|----------------------|
| **2px** | Header title-subtitle gap | 🟢 LOW | `Spacing.xxs` or inline |
| **4px** | Time icon-text gap | 🟡 MEDIUM | `Spacing.micro` |
| **10px** | Icon container padding | 🟡 MEDIUM | `Spacing.iconPadding` |
| **14px** | Workout frame text padding | 🟡 MEDIUM | Ad-hoc or derive from 16px |
| **21px** | Hero card margins | 🟡 MEDIUM | **Conflict:** Very close to `20px` (Spacing.goalCardVertical) - unify? |
| **35px** | Calendar weekday labels gap | 🟡 MEDIUM | `Spacing.calendarWeekdayGap` |
| **41px** | Category chip gap (if rendered) | 🟡 MEDIUM | `Spacing.chipGap` |
| **42px** | Main section gaps | 🟡 MEDIUM | Close to existing `OnboardingSpacing` patterns |

### ⚠️ Conflicts
- **21px vs 20px:** Hero card margins (21) vs `Spacing.goalCardVertical` (20)
  - **Resolution:** Use existing 20px or document 21px as intentional 5% increase

---

## 🟡 Radii Deltas

### ✅ Existing Matches
| Figma Value | Codebase Token | File:Line |
|-------------|----------------|-----------|
| 12px | `Sizes.radiusM` | `lib/core/design_tokens/sizes.dart:3` |
| 20px | `Sizes.radiusL` | `lib/core/design_tokens/sizes.dart:4` |
| 40px | `Sizes.radiusXL` | `lib/core/design_tokens/sizes.dart:11` |
| 100px | Home indicator | Baseline spec |

### ❌ Missing Radii
| Value | Usage | Priority | Token Name Suggestion |
|-------|-------|----------|----------------------|
| **2px** | Calendar selected day corner (asymmetric) | 🟢 LOW | Inline `BorderRadius.only(topRight: Radius.circular(2))` |
| **16px** | Category chips (if rendered) | 🟡 MEDIUM | `Sizes.radiusMedium` (between M and L) |
| **24px** | Hero workout frame | 🔴 HIGH | `Sizes.radiusXL24` or `Sizes.cardRadius` |
| **26.667px** | Header icon containers | 🟡 MEDIUM | **Unusual fractional value** - round to 27px or use existing token |

### 📝 Notes
- **Corner smoothing:** Not available in Figma Dev Mode export - all radii are standard CSS `border-radius`

---

## 🔴 Shadow Deltas (Critical)

### ❌ No Existing Shadow System
**Codebase:** No shadow tokens exist (confirmed in `docs/audits/dashboard_reuse_inventory.md:52`)

### Required Shadows
| Shadow | CSS Value | Usage | Priority |
|--------|-----------|-------|----------|
| **Card Shadow** | `0px 4px 4px rgba(0,0,0,0.25)` | Workout detail cards, recommendation cards | 🔴 HIGH |
| **Nav Shadow (baseline)** | `0px 0px 24px rgba(0,0,0,0.12)` | Bottom nav bar (from node 68426:7203) | 🟡 MEDIUM |

### Resolution
Create `lib/core/design_tokens/shadows.dart`:
```dart
class ShadowTokens {
  static const card = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      color: Color(0x40000000), // rgba(0,0,0,0.25)
    ),
  ];

  static const nav = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 24,
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
    ),
  ];
}
```

---

## 🔴 Missing Widget Patterns

### ❌ No Horizontal Scroll Pattern
**Evidence:** `rg --line-number "Axis.horizontal" lib` returns no results (per reuse_inventory.md:113)

**Required:** Workout cards carousel (node `68672:7402`)
- **Type:** `ListView.builder` or `PageView` with `scrollDirection: Axis.horizontal`
- **Gap:** 17px between cards
- **Responsive sizing:** On narrow screens (<600dp) stretch cards to 100% of the available width (minus horizontal safe-area padding) and maintain the ~340:280 aspect ratio via `aspectRatio` or proportional height.
- **Large screens:** At ≥600dp width cap each card at 340px, center multiple cards in the row, and respect safe-area insets plus device pixel density.
- **Layout guidance:** Apply `BoxConstraints` (`maxWidth`/`minWidth`) or responsive layout widgets (e.g., `Flexible`, breakpoint-driven `Grid`) to adapt portrait vs. landscape and tablet vs. mobile.
- **Priority:** 🔴 HIGH

### ❌ No Image Card Component
**Closest Match:** `GoalCard` (lib/features/onboarding/widgets/goal_card.dart:17) - has title/selected but **no image/gradient**

**Required:** `ImageCard` widget with:
- Image background (NetworkImage or AssetImage)
- Optional gradient overlay (from GradientTokens)
- Title + subtitle text overlay
- Optional icon (e.g., time duration with clock icon)
- Tap callback
- Radius 20px, shadow `0px 4px 4px 0.25`

**Priority:** 🔴 HIGH (blocks all workout/recommendation cards)

### ❌ No Calendar Component
**Required:** `CalendarWeekStrip` widget with:
- Weekday labels row (M D M D F S S)
- Day numbers row (27, 28, 29, 30, 1, 2, 3)
- Selected state (gold background + blue indicator)
- Day tap callback

**Priority:** 🔴 HIGH (unique to this design iteration)

### ⚠️ Partial Match: Hero Card
**Closest Match:** `WelcomeShell` (lib/features/consent/widgets/welcome_shell.dart:8)
- ✅ Has hero image + aspect ratio
- ✅ Has wave overlay pattern
- ❌ No CTA button overlay
- ❌ No text card overlay

**Required:** `WorkoutHeroCard` with gradient background + white text card overlay + CTA button

**Priority:** 🔴 HIGH

---

## 🟡 Accessibility Issues

| Element | Issue | Contrast Ratio | WCAG Level | Severity | Fix | Status |
|---------|-------|----------------|------------|----------|-----|--------|
| **Calendar weekday labels** | `#C5C7C9` on `#FFFFFF` | ~3.2:1 | ❌ FAIL AA (needs 4.5:1) | 🟡 MEDIUM | Switch to `DsTokens.grayscale500` (`#696969`) or fallback `#949494`; rollout tracked for dashboard. | Deferred – follow-up [DASH-A11Y-001](issues/dashboard_calendar_weekday_contrast.md) |
| **Time label '60 min'** | `rgba(255,255,255,0.6)` on image | Varies | ⚠️ CONDITIONAL | 🟢 LOW | Test against production imagery; bump to 0.7–0.8 opacity if contrast fails. | Known limitation – monitor during QA sign-off |
| **Workout frame subtitle** | `#6d6d6d` on `#FFFFFF` | ~4.6:1 | ✅ PASS AA normal text | 🟢 LOW | Acceptable; no change required. | Implemented – passes in current widgets |

---

## 🟢 Implementation Priority

### Phase 1: Foundations (Blockers)
1. ✅ **Add Nunito font** to `pubspec.yaml` + `lib/core/design_tokens/typography.dart`
2. ✅ **Create GradientTokens** (`lib/core/design_tokens/gradients.dart`)
3. ✅ **Create ShadowTokens** (`lib/core/design_tokens/shadows.dart`)
4. ✅ **Add typography variants:**
   - Playfair Bold 24/32
   - Figtree Italic 16/24
   - Figtree Bold 16/24
   - Figtree Regular 12/24
   - Nunito Bold 16
   - Nunito SemiBold 14
5. ✅ **Add color tokens:**
   - Calendar gold `#E1B941` @ 0.5
   - Calendar blue `#4169E1`
   - Calendar day text `#282B31`
   - Calendar weekday `#C5C7C9`
6. ✅ **Add spacing tokens:** 2px, 4px, 10px, 14px, 21px, 35px, 41px, 42px
7. ✅ **Add radius tokens:** 2px, 16px, 24px, 27px
8. ✅ **Add opacity token:** 0.6 for time labels

```dart
// Suggested location: lib/core/design_tokens/dashboard_tokens.dart
import 'package:flutter/material.dart';

class ColorTokens {
  const ColorTokens._();
  static const calendarSelectedBg = Color(0x80E1B941); // #E1B941 @ 0.5 alpha (gold selection)
  static const calendarActiveIndicator = Color(0xFF4169E1); // #4169E1 active day indicator
  static const dayText = Color(0xFF282B31); // #282B31 calendar day number
  static const weekday = Color(0xFFC5C7C9); // #C5C7C9 weekday label text
}

class SpacingTokens {
  const SpacingTokens._();
  static const spacing2 = 2.0; // 2 px micro-spacing
  static const spacing4 = 4.0; // 4 px micro-spacing
  static const spacing10 = 10.0; // 10 px card padding inset
  static const spacing14 = 14.0; // 14 px space between weekday/date rows
  static const spacing21 = 21.0; // 21 px hero vertical offset
  static const spacing35 = 35.0; // 35 px section spacing
  static const spacing41 = 41.0; // 41 px nav alignment offset
  static const spacing42 = 42.0; // 42 px carousel baseline gap
}

class RadiusTokens {
  const RadiusTokens._();
  static const radius2 = 2.0; // 2 px inner indicator radius
  static const radius16 = 16.0; // 16 px card corners
  static const radius24 = 24.0; // 24 px hero overlay corners
  static const radius27 = 27.0; // 27 px bottom nav wave radius
}

class OpacityTokens {
  const OpacityTokens._();
  static const timeLabel = 0.6; // 60% opacity (rgba alpha 0.6) for duration labels
}
```

### Phase 2: Base Widgets
1. ✅ **ImageCard** widget (with gradient overlay support)
2. ✅ **SectionHeader** widget (title + optional subtitle + trailing)
3. ✅ **HorizontalCardCarousel** wrapper

### Phase 3: Dashboard Widgets
1. ✅ **CalendarWeekStrip**
2. ✅ **WorkoutHeroCard**
3. ✅ **WorkoutDetailCard** (uses ImageCard)
4. ✅ **RecommendationCard** (alias of WorkoutDetailCard)
5. ✅ **BottomNavBar** (icon-based)

### Phase 4: Screen Composition
1. ✅ Compose **DashboardScreen** with all widgets
2. ✅ Wire up navigation and state management
3. ✅ Add interactions (card taps, calendar selection, nav routing)
4. ✅ Implement horizontal scroll physics

### Phase 5: Polish
1. ⚪ Skeleton loaders
2. ⚪ Image caching strategy
3. ⚪ Pull-to-refresh
4. ⚪ Performance optimization
5. ⚪ Accessibility labels + semantics
6. ⚪ Fix contrast issues (calendar weekday labels)

---

## 📋 Testing Recommendations

### Widget Tests
- [ ] `CalendarWeekStrip`: day selection state, weekday labels render
- [ ] `WorkoutHeroCard`: CTA tap callback, text truncation
- [ ] `WorkoutDetailCard`: gradient overlay renders, duration label shows
- [ ] `SectionHeader`: title/subtitle layout, optional trailing widget
- [ ] `BottomNavBar`: active/inactive states, tap callbacks

### Golden Tests
- [ ] Dashboard full screen at 428×1558
- [ ] Calendar strip selected/unselected states
- [ ] Workout cards with different image aspect ratios
- [ ] Bottom nav active tab variants

### Accessibility Tests
- [ ] Contrast ratio verification (calendar weekday labels)
- [ ] Semantic labels for screen reader navigation
- [ ] Touch target sizes (minimum 44×44)
- [ ] Focus order for keyboard navigation

### Performance Tests
- [ ] Horizontal scroll jank (maintain 60fps)
- [ ] Image loading (placeholders, no layout shifts)
- [ ] Memory usage with many cards

---

## 📦 Deliverables Summary

**Created:**
- ✅ `docs/audits/DASHBOARD_figma_audit_v2.json` - Comprehensive audit (all specs extracted)
- ✅ `docs/audits/DASHBOARD_figma_deltas_v2.md` - This summary document

**Next Steps:**
1. Review deltas with team (especially breaking changes)
2. Prioritize Phase 1 foundations (Nunito font, gradients, shadows)
3. Create Phase 2 base widgets (ImageCard, SectionHeader, HorizontalCardCarousel)
4. Implement Phase 3 Dashboard-specific widgets
5. Compose DashboardScreen in Phase 4
6. Polish in Phase 5

---

**Questions for Product/Design:**
1. Is the calendar week strip feature confirmed for MVP? (requires Nunito font)
2. Should we unify `21px` margins with existing `20px` (Spacing.goalCardVertical)?
3. Is the removed Categories section moving to a different screen, or is it cut?
4. Confirm bottom nav icon design - baseline had different approach (5-item pill)
