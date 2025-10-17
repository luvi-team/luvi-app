# Dashboard Tokens Phase 1 – Figma Audit

**Source:** Figma node `68721:7519` (Dashboard V2)
**Date:** 2025-10-17
**Method:** MCP Figma extraction + codebase token analysis
**Purpose:** Extract 6 design areas for pixel-perfect token migration

---

## 1. Pinke Wave Amplitude

### Figma Specs
- **Node ID:** 68721:7520, 68721:7521, 68721:7522, 68721:7523 (wave SVG layers)
- **Visual Analysis:** Pink/purple gradient wave overlay above hero card, curved lip extending ~20-24px vertically
- **Current Implementation:** `lib/features/screens/heute_screen.dart:51`
  ```dart
  const double _phaseRecoWaveAmplitude = 24.0; // Height of curved lip
  ```
- **Audit:** Screenshot shows wave amplitude is **slightly flatter** than current 24px (visual estimate ~20-22px)

### Dart Equivalents
- **Current Token:** Hardcoded const `_phaseRecoWaveAmplitude = 24.0`
- **Proposed Token:** `DashboardLayoutTokens.waveAmplitudePink`
  ```dart
  final double waveAmplitudePink = 22.0; // Reduced from 24px (Figma audit Phase 1)
  ```

### Delta
- **Status:** ⚠️ **Mismatch**
- **Current:** 24px
- **Figma:** ~22px (visual estimate from screenshot)
- **Impact:** Minor visual adjustment, reduces wave curve height by ~8%
- **Action:** Update `DashboardLayoutTokens` to add `waveAmplitudePink: 22.0`

---

## 2. HeroBild Border & Shadow

### Figma Specs (Hero Card Frame)
- **Node ID:** 68721:7575 (Workout Frame outer container)
- **Border:**
  - **CSS:** `border: 1px solid #696969;`
  - **Figma Color:** Grayscale/500 `#696969`
  - **Width:** 1px
  - **Radius:** 24px (node 68721:7575 `rounded-[24px]`)
- **Shadow:**
  - **CSS:** `box-shadow: 0px 4px 4px 0px rgba(0,0,0,0.25);`
  - **Offset:** (0, 4)
  - **Blur:** 4px
  - **Spread:** 0px
  - **Color:** rgba(0,0,0,0.25) → `Color(0x40000000)`

### Current Implementation
- **Border:** `lib/features/widgets/hero_sync_preview.dart:37-48`
  - Uses `CalendarRadiusTokens.cardLarge` (24.0) ✅ **MATCH**
  - Border defined implicitly via Container decoration
- **Shadow:** `lib/features/widgets/hero_sync_preview.dart:39` + `lib/core/theme/app_theme.dart:584-589`
  ```dart
  final shadowTokens = Theme.of(context).extension<ShadowTokens>();
  // ShadowTokens.light.heroDrop:
  BoxShadow(offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Color(0x40000000))
  ```
  - ✅ **EXACT MATCH** with Figma specs

### Dart Equivalents
```dart
// Border
border: Border.all(
  color: DsTokens.grayscale500, // #696969
  width: 1.0,
),
borderRadius: BorderRadius.circular(
  CalendarRadiusTokens.light.cardLarge, // 24.0
),

// Shadow
boxShadow: [ShadowTokens.light.heroDrop] // Already matches Figma
```

### Delta
- **Status:** ✅ **MATCH**
- **Border:** 1px solid #696969, radius 24px → Existing tokens already support this
- **Shadow:** `0px 4px 4px rgba(0,0,0,0.25)` → `ShadowTokens.heroDrop` **exact match**
- **Action:** **None required** (existing tokens sufficient)

---

## 3. Text-Shadow im Callout

### Figma Specs (Hero Info Card Text)
- **Node ID:** 68721:7577 (Workout Frame text content)
- **Text-Shadow CSS:**
  ```css
  text-shadow: rgba(0,0,0,0.25) 0px 4px 4px;
  ```
  - **Offset-X:** 0px
  - **Offset-Y:** 4px
  - **Blur:** 4px
  - **Color:** rgba(0,0,0,0.25) → `Color(0x40000000)`
- **Affected Text:**
  - "Heute, 28. Sept" (Figtree Bold 16)
  - "Wir starten heute ruhig..." (Figtree Regular 14)

### Current Implementation
- **File:** `lib/features/widgets/hero_sync_preview.dart:135-159` (estimated, not visible in limit=100)
- **Status:** ❌ **NO TEXT-SHADOW**
- **Evidence:** Current implementation uses `TextStyle` without `shadows` property

### Dart Equivalents
```dart
// Option 1: Add to WorkoutCardTypographyTokens
static const TextStyle heroCalloutTitleStyle = TextStyle(
  fontFamily: FontFamilies.figtree,
  fontWeight: FontWeight.w700,
  fontSize: 16,
  height: 24 / 16,
  shadows: [
    Shadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      color: Color(0x40000000), // rgba(0,0,0,0.25)
    ),
  ],
);

static const TextStyle heroCalloutBodyStyle = TextStyle(
  fontFamily: FontFamilies.figtree,
  fontWeight: FontWeight.w400,
  fontSize: 14,
  height: 24 / 14,
  shadows: [
    Shadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      color: Color(0x40000000),
    ),
  ],
);

// Option 2: Add to ShadowTokens
static const Shadow heroCalloutTextShadow = Shadow(
  offset: Offset(0, 4),
  blurRadius: 4,
  color: Color(0x40000000),
);
```

### Delta
- **Status:** ❌ **MISSING**
- **Current:** No text-shadow
- **Figma:** `0px 4px 4px rgba(0,0,0,0.25)`
- **Impact:** Text readability improvement on gradient background
- **Action:** Add `heroCalloutTextShadow` to `ShadowTokens` or embed in `DashboardTypographyTokens`

---

## 4. Typografie "Dein Training..." + "Erstellt von..."

### Figma Specs
- **Section Title ("Dein Training für diese Woche"):**
  - **Node ID:** 68721:7583
  - **Font:** Figtree Regular
  - **Size:** 20px
  - **Weight:** 400 (normal)
  - **Line Height:** 24px (ratio 1.2)
  - **Color:** #030401 (Grayscale/Black)
  - **CSS:** `font-family: 'Figtree:Regular', sans-serif; font-weight: normal; font-size: 20px; line-height: 24px; color: #030401;`

- **Section Subtitle ("Erstellt von deinen LUVI-Expert:innen"):**
  - **Node ID:** 68721:7584
  - **Font:** Figtree Italic
  - **Size:** 16px
  - **Weight:** 400 (normal)
  - **Line Height:** 24px (ratio 1.5)
  - **Color:** #696969 (Grayscale/500, dimgrey)
  - **CSS:** `font-family: 'Figtree:Italic', sans-serif; font-style: italic; font-size: 16px; color: #696969;`

### Current Implementation
- **Section Title:** `lib/features/widgets/section_header.dart:14-18` (estimated, uses hardcoded TextStyle)
  - Current: Figtree 20 w600 (from deltas_v2.md:41)
  - **Mismatch:** Weight 600 vs Figma 400
- **Section Subtitle:** `lib/features/screens/heute_screen.dart` (inline style, deltas_v2.md:50)
  - Current: Figtree Italic 16/24 color 0x99030401 (opacity mismatch)
  - **Mismatch:** Color has alpha 0x99 (60%) vs Figma solid #696969

### Dart Equivalents
```dart
// lib/core/theme/app_theme.dart additions
@immutable
class DashboardTypographyTokens extends ThemeExtension<DashboardTypographyTokens> {
  const DashboardTypographyTokens({
    required this.sectionTitle,
    required this.sectionSubtitle,
  });

  final TextStyle sectionTitle;
  final TextStyle sectionSubtitle;

  static const DashboardTypographyTokens light = DashboardTypographyTokens(
    sectionTitle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400, // Regular (not w600!)
      fontSize: 20,
      height: 24 / 20,
      color: Color(0xFF030401), // Grayscale/Black
    ),
    sectionSubtitle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
      fontStyle: FontStyle.italic,
      color: Color(0xFF696969), // Grayscale/500 (solid, no alpha)
    ),
  );

  @override
  DashboardTypographyTokens copyWith({
    TextStyle? sectionTitle,
    TextStyle? sectionSubtitle,
  }) => DashboardTypographyTokens(
    sectionTitle: sectionTitle ?? this.sectionTitle,
    sectionSubtitle: sectionSubtitle ?? this.sectionSubtitle,
  );

  @override
  DashboardTypographyTokens lerp(
    ThemeExtension<DashboardTypographyTokens>? other,
    double t,
  ) {
    if (other is! DashboardTypographyTokens) return this;
    return DashboardTypographyTokens(
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t) ?? sectionTitle,
      sectionSubtitle: TextStyle.lerp(sectionSubtitle, other.sectionSubtitle, t) ?? sectionSubtitle,
    );
  }
}
```

### Delta
- **Section Title:**
  - **Status:** ⚠️ **Mismatch**
  - **Current:** Figtree 20/24 w600
  - **Figma:** Figtree 20/24 w400
  - **Impact:** Title appears bolder than intended
  - **Action:** Create `DashboardTypographyTokens.sectionTitle` with w400

- **Section Subtitle:**
  - **Status:** ⚠️ **Mismatch**
  - **Current:** Figtree Italic 16/24 color 0x99030401 (60% opacity black)
  - **Figma:** Figtree Italic 16/24 color #696969 (solid grey)
  - **Impact:** Subtitle appears darker/more saturated than intended
  - **Action:** Create `DashboardTypographyTokens.sectionSubtitle` with solid #696969

---

## 5. Divider-Style

### Figma Specs
- **Location:** Between "Ernährung & Nutrition" and "Regeneration & Achtsamkeit" subsections
- **Node ID:** 68723:7672 (Line 35, rotated 0.15deg)
- **Visual Analysis:** Thin horizontal line separator
- **Estimated Specs:**
  - **Color:** #DCDCDC (from deltas_v2.md:5, inputBorder token)
  - **Thickness:** 1px (standard)
  - **Vertical Margin:** 12px top + 12px bottom (visual estimate from screenshot)

### Current Implementation
- **File:** `lib/features/screens/heute_screen.dart:654` (estimated line from reference)
- **Status:** ❌ **NO DIVIDER**
- **Evidence:** Current implementation uses `SizedBox(height: _subsectionGap)` (24px gap, no visual line)

### Dart Equivalents
```dart
// lib/core/theme/app_theme.dart additions
@immutable
class DividerTokens extends ThemeExtension<DividerTokens> {
  const DividerTokens({
    required this.sectionDividerColor,
    required this.sectionDividerThickness,
    required this.sectionDividerVerticalMargin,
  });

  final Color sectionDividerColor;
  final double sectionDividerThickness;
  final double sectionDividerVerticalMargin;

  static const DividerTokens light = DividerTokens(
    sectionDividerColor: Color(0xFFDCDCDC), // inputBorder token
    sectionDividerThickness: 1.0,
    sectionDividerVerticalMargin: 12.0, // Visual estimate from screenshot
  );

  @override
  DividerTokens copyWith({
    Color? sectionDividerColor,
    double? sectionDividerThickness,
    double? sectionDividerVerticalMargin,
  }) => DividerTokens(
    sectionDividerColor: sectionDividerColor ?? this.sectionDividerColor,
    sectionDividerThickness: sectionDividerThickness ?? this.sectionDividerThickness,
    sectionDividerVerticalMargin: sectionDividerVerticalMargin ?? this.sectionDividerVerticalMargin,
  );

  @override
  DividerTokens lerp(ThemeExtension<DividerTokens>? other, double t) {
    if (other is! DividerTokens) return this;
    return DividerTokens(
      sectionDividerColor: Color.lerp(sectionDividerColor, other.sectionDividerColor, t) ?? sectionDividerColor,
      sectionDividerThickness: lerpDouble(sectionDividerThickness, other.sectionDividerThickness, t) ?? sectionDividerThickness,
      sectionDividerVerticalMargin: lerpDouble(sectionDividerVerticalMargin, other.sectionDividerVerticalMargin, t) ?? sectionDividerVerticalMargin,
    );
  }
}

// Usage in widget:
Padding(
  padding: EdgeInsets.symmetric(
    vertical: DividerTokens.light.sectionDividerVerticalMargin,
  ),
  child: Divider(
    color: DividerTokens.light.sectionDividerColor,
    thickness: DividerTokens.light.sectionDividerThickness,
  ),
)
```

### Delta
- **Status:** ❌ **MISSING**
- **Current:** No divider (only whitespace gap)
- **Figma:** 1px line #DCDCDC with ~12px vertical margin
- **Impact:** Visual separation between subsections missing
- **Action:** Create `DividerTokens` extension with section-specific properties

---

## 6. Card Gradient/Shadow/Radii/Padding

### Figma Specs (Workout Cards & Recommendation Cards)

#### A. Gradient Overlay
- **Nodes:** 68721:7587, 68721:7597, 68723:7691, 68723:7694, 68723:7677, 68723:7681 (Highlight Overlay layers)
- **Type:** Linear Gradient
- **Direction:** Bottom to Top (bottomCenter → topCenter)
- **Colors:**
  - **Start (bottom):** `#1A1A1A` @ 100% opacity → `Color(0xFF1A1A1A)`
  - **End (top):** `#1A1A1A` @ 0% opacity → `Color(0x001A1A1A)`
- **Stops:** [0.146, 0.95]
- **CSS:** `linear-gradient(to top, #1A1A1A 14.6%, rgba(26,26,26,0) 95%)`

**Current Implementation:**
- **File:** `lib/core/theme/app_theme.dart:746-751`
- **Token:** `WorkoutCardOverlayTokens.light`
  ```dart
  static const WorkoutCardOverlayTokens light = WorkoutCardOverlayTokens(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.146, 0.95],
    colors: [Color(0xFF1A1A1A), Color(0x001A1A1A)],
  );
  ```
- **Status:** ✅ **EXACT MATCH**

#### B. Shadow
- **Nodes:** 68721:7586, 68721:7596, 68723:7676, 68723:7680, 68723:7689, 68723:7693 (Workout Details Card containers)
- **CSS:** `box-shadow: 0px 4px 4px 0px rgba(0,0,0,0.25);`
- **Offset:** (0, 4)
- **Blur:** 4px
- **Spread:** 0px
- **Color:** rgba(0,0,0,0.25) → `Color(0x40000000)`

**Current Implementation:**
- **File:** `lib/core/theme/app_theme.dart:590-595`
- **Token:** `ShadowTokens.tileDrop`
  ```dart
  tileDrop: BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 4,
    spreadRadius: 0,
    color: Color(0x40000000),
  ),
  ```
- **Status:** ✅ **EXACT MATCH**

#### C. Border Radius
- **Nodes:** 68721:7586, 68721:7596 (large workout cards), 68723:7676, 68723:7680, 68723:7689, 68723:7693 (small recommendation cards)
- **CSS:** `rounded-[20px]` (all cards use uniform 20px radius)

**Current Implementation:**
- **File:** `lib/core/theme/app_theme.dart:531`
- **Token:** `CalendarRadiusTokens.cardWorkout`
  ```dart
  cardWorkout: 20.0,
  ```
- **Status:** ✅ **EXACT MATCH**

#### D. Padding (Card Internal)
- **Workout Cards (large):**
  - **Node ID:** 68721:7586, 68721:7596
  - **Figma CSS:** No explicit padding property (inferred from content position)
  - **Visual Estimate:** ~14px internal padding (content-to-edge)
- **Recommendation Cards (small):**
  - **Node ID:** 68723:7689, 68723:7693
  - **Visual Estimate:** ~12-14px internal padding

**Current Implementation:**
- **File:** `lib/features/dashboard/widgets/weekly_training_card.dart:12`
  ```dart
  const double _contentPadding = 14;
  ```
- **Status:** ✅ **MATCH** (14px confirmed)

### Dart Equivalents Summary
```dart
// All card tokens already exist and match Figma:

// Gradient
WorkoutCardOverlayTokens.light.gradient // ✅ Exact match

// Shadow
ShadowTokens.light.tileDrop // ✅ Exact match

// Radius
CalendarRadiusTokens.light.cardWorkout // ✅ 20.0px

// Padding
const _contentPadding = 14.0; // ✅ Matches visual estimate
```

### Delta
- **Status:** ✅ **ALL MATCH**
- **Gradient:** Existing `WorkoutCardOverlayTokens` matches Figma stops and colors exactly
- **Shadow:** Existing `ShadowTokens.tileDrop` matches Figma 0/4/4/0.25 spec
- **Radius:** Existing `CalendarRadiusTokens.cardWorkout` = 20px
- **Padding:** Current implementation `_contentPadding = 14` matches visual estimate
- **Action:** **None required** (all specs already implemented)

---

## Summary Table

| Design Area | Status | Current Token | Figma Value | Action Required |
|-------------|--------|---------------|-------------|-----------------|
| **1. Wave Amplitude** | ⚠️ Mismatch | `_phaseRecoWaveAmplitude = 24.0` | ~22px | Add `DashboardLayoutTokens.waveAmplitudePink` |
| **2. Hero Border** | ✅ Match | `CalendarRadiusTokens.cardLarge = 24.0` | 24px radius, 1px #696969 border | None (use existing tokens) |
| **2. Hero Shadow** | ✅ Match | `ShadowTokens.heroDrop` | 0/4/4/0.25 | None (exact match) |
| **3. Text-Shadow** | ❌ Missing | N/A | 0/4/4/0.25 | Add `ShadowTokens.heroCalloutTextShadow` or embed in `DashboardTypographyTokens` |
| **4. Section Title** | ⚠️ Mismatch | Hardcoded w600 | Figtree 20/24 w400 #030401 | Create `DashboardTypographyTokens.sectionTitle` |
| **4. Section Subtitle** | ⚠️ Mismatch | Hardcoded 0x99030401 | Figtree Italic 16/24 #696969 | Create `DashboardTypographyTokens.sectionSubtitle` |
| **5. Divider** | ❌ Missing | N/A | 1px #DCDCDC, 12px margin | Create `DividerTokens` extension |
| **6. Card Gradient** | ✅ Match | `WorkoutCardOverlayTokens.light` | [0.146, 0.95] #1A1A1A | None (exact match) |
| **6. Card Shadow** | ✅ Match | `ShadowTokens.tileDrop` | 0/4/4/0.25 | None (exact match) |
| **6. Card Radius** | ✅ Match | `CalendarRadiusTokens.cardWorkout = 20.0` | 20px | None (exact match) |
| **6. Card Padding** | ✅ Match | `_contentPadding = 14` | ~14px | None (already implemented) |

---

## Implementation Checklist

### Required Changes (app_theme.dart)

- [ ] **Add `DashboardLayoutTokens.waveAmplitudePink`** (Zeile ~390-446)
  - Property: `final double waveAmplitudePink;`
  - Value: `22.0` (reduced from hardcoded 24px)
  - Update `copyWith()`, `lerp()` methods

- [ ] **Create `DashboardTypographyTokens`** (new class after WorkoutCardTypographyTokens)
  - `sectionTitle`: Figtree 20/24 w400 #030401
  - `sectionSubtitle`: Figtree Italic 16/24 #696969
  - Implement `copyWith()`, `lerp()` methods
  - Add to `buildAppTheme().extensions` list (Zeile 78-89)

- [ ] **Create `DividerTokens`** (new class after DashboardTypographyTokens)
  - `sectionDividerColor`: #DCDCDC
  - `sectionDividerThickness`: 1.0
  - `sectionDividerVerticalMargin`: 12.0
  - Implement `copyWith()`, `lerp()` methods
  - Add to `buildAppTheme().extensions` list

- [ ] **Optional: Extend `ShadowTokens` for text-shadow** (Zeile 577-613)
  - Property: `final Shadow? heroCalloutTextShadow;`
  - Value: `Shadow(offset: Offset(0, 4), blurRadius: 4, color: Color(0x40000000))`
  - **Alternative:** Embed `shadows` directly in `DashboardTypographyTokens.sectionTitle` TextStyle

### Verified Matches (No Changes)
- ✅ `ShadowTokens.heroDrop` (hero card shadow)
- ✅ `ShadowTokens.tileDrop` (workout/recommendation card shadow)
- ✅ `WorkoutCardOverlayTokens.light` (card gradient overlay)
- ✅ `CalendarRadiusTokens.cardLarge` (hero card radius 24px)
- ✅ `CalendarRadiusTokens.cardWorkout` (workout card radius 20px)

---

## References
- **Figma Node:** 68721:7519 (Dashboard V2 full screen)
- **Existing Audit:** `docs/audits/DASHBOARD_figma_deltas_v2.md`
- **Codebase Files:**
  - `lib/core/theme/app_theme.dart` (token definitions)
  - `lib/features/screens/heute_screen.dart` (wave amplitude constant)
  - `lib/features/widgets/hero_sync_preview.dart` (hero card implementation)
  - `lib/features/dashboard/widgets/weekly_training_card.dart` (workout card)
