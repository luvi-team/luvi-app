# Onboarding 03 (Ziele) – Figma Specifications

**File:** `iQthMdxpCbl6afzXxvzqlt`
**Node:** `68186-7924` (03_Onboarding)
**Extracted:** 2025-10-01
**Screen Dimensions:** 428×926 px

---

## 1. Header Line Measurements

### Back Icon (Arrow Component)
- **Diameter:** 40×40 px
- **Left margin:** 20 px (from screen edge)
- **Top margin:** 59 px (from screen top)
- **Icon type:** Arrow Left property
- **Node ID:** I68186:7927;45:9593

### Title Text
- **Content:** "Erzähl mir von dir 💜"
- **Font:** Playfair Display Regular
- **Size:** 24 px
- **Line height:** 32 px
- **Color:** Grayscale/Black (#030401)
- **Width:** 388 px
- **Horizontal position:** Centered (translate-x-[-50%], left: 50%)
- **Vertical position (top):** 79 px from screen top
- **Vertical centering:** translate-y-[-50%] (baseline at 79px)
- **Node ID:** I68186:7927;45:9592

### Step Counter ("3/7")
- **Content:** "3/7"
- **Font:** Inter Medium
- **Size:** 16 px
- **Line height:** 24 px
- **Color:** Grayscale/Black (#030401)
- **Alignment:** Right-aligned text
- **Horizontal position:** Right-aligned at 20 px from right edge (calc(50% + 194px) with translate-x-[-100%])
- **Vertical position:** 79 px from top, translate-y-[-50%]
- **Node ID:** I68186:7927;58876:7743

### Header Layout Confirmation
**✓ YES** – All three elements (Back Icon, Title, Step Counter) are positioned on a single horizontal line at **y=79px** (accounting for transforms).

---

## 2. Vertical Spacing (px)

| From | To | Distance (px) | Notes |
|------|-----|---------------|-------|
| **Header baseline** (y=79) | **Question text top** (y≈159) | **≈80** | Gap 47px declared (Header container=112px) |
| **Question text bottom** (y≈183) | **First card top** (y≈206) | **≈23** | Gap 47px minus question height (24px) |
| **First card bottom** (y≈295) | **Second card top** (y≈319) | **24** | Card gap (declared in Goal List flex-col gap-[24px]) |
| **Second card bottom** (y≈385) | **Third card top** (y≈409) | **24** | Card gap |
| **Third card bottom** (y≈498) | **Fourth card top** (y≈522) | **24** | Card gap |
| **Fourth card bottom** (y≈611) | **Fifth card top** (y≈635) | **24** | Card gap |
| **Fifth card bottom** (y≈724) | **CTA button top** (y≈771) | **≈47** | Gap between Goal List and CTA |
| **CTA button bottom** (y≈821) | **Home indicator container top** (y≈868) | **≈47** | Gap before home indicator |
| **Home indicator container top** | **Screen bottom** (y=926) | **58** | Home indicator container height (34px) + bottom margin (24px) |

**Note:** Root flex container uses `gap-[47px]` between major sections (Header, Question, Goal List, CTA, Home Indicator).

---

## 3. List Elements/Cards Specifications

### Card Container Dimensions
- **Width:** 388 px (full content width)
- **Height (variable by content):**
  - Single-line goals (e.g., Card 2 "Training"): **66 px**
  - Two-line goals (e.g., Card 1 "Meinen Zyklus & Körper besser verstehen"): **89 px**
- **Border radius:** 20 px
- **Background color:** Grayscale/100 (#F7F7F8)
- **Padding:** 20 px (vertical) × 16 px (horizontal)
- **Inner content height:** 26 px (single-line) or 49 px (two-line)
- **Node IDs:**
  - Card 1 (selected, two-line): I68186:7930;67067:6792
  - Card 2 (unselected, single-line): I68186:7931;67067:7056

### Card Border (Selected State)
- **Border:** 1 px solid Grayscale/Black (#1C1411)
- **Applied only to selected cards** (via `aria-hidden` pseudo-element in code)
- **Visual thickness:** 1 px (browser-rendered)

### Icon Area
- **Size:** 24×24 px (consistent across all cards)
- **Gap between icon and text:** 20 px
- **Icon types:**
  - Card 1: `ic / explore` (node 67067:6761)
  - Card 2: `ic / Weight` (node 67067:6984)
  - Card 3: `ic / dish` (node 58894:2928)
  - Card 4: `ic / Weight loss` (custom SVG, node 68219:6426)
  - Card 5: `ic / emoji` (node 61000:6910)

### Card States

#### Default (Unselected)
- **Background:** Grayscale/100 (#F7F7F8)
- **Border:** None (0 px)
- **Radio button:**
  - Outer circle: 24×24 px, 2 px stroke, color Grayscale/300 (inferred from Ellipse9 asset)
  - Inner fill: None
  - Node ID: 1115:3916

#### Selected
- **Background:** Grayscale/100 (#F7F7F8) (same as default)
- **Border:** 1 px solid Grayscale/Black (#1C1411)
- **Radio button:**
  - Outer circle: 24×24 px, 2 px stroke, color Grayscale/Black (inferred from Ellipse10 asset)
  - Inner fill: 14×14 px circle, color Primary color/100 (#D9B18E)
  - Positioning: Centered within 24×24 px container (inset 20.833%)
  - Node ID: 1115:3919

### Typography (Card Content)

| Element | Font | Size | Weight | Line Height | Color | Width |
|---------|------|------|--------|-------------|-------|-------|
| **Card title (single-line)** | Figtree Regular | 16 px | 400 | 24 px | Grayscale/Black (#030401) | 268 px |
| **Card title (two-line)** | Figtree Regular | 16 px | 400 | 24 px | Grayscale/Black (#030401) | 268 px |

**Wrap behavior:** Text wraps naturally at 268 px width (no hyphenation in Figma code).

---

## 4. CTA Button Specifications

### Dimensions & Layout
- **Width:** 388 px
- **Height:** 50 px
- **Border radius:** 12 px
- **Padding:** Top 12 px, Bottom 11 px, Left/Right 12 px (pb-[11px] pt-[12px] px-[12px])
- **Inner content:** Vertically centered, horizontally centered
- **Node ID:** 68186:7926

### Typography
- **Font:** Figtree Bold
- **Size:** 20 px
- **Weight:** 700
- **Line height:** 24 px
- **Color:** Grayscale/Black (#030401)
- **Text alignment:** Center

### Colors
- **Background:** Primary color/100 (#D9B18E)
- **Text:** Grayscale/Black (#030401)

### Interactive States (Inferred)
- **Default:** Background #D9B18E
- **Pressed:** (Not specified in Figma; recommend darker shade ~#C89A78)
- **Disabled:** (Not specified; recommend opacity 0.5 or greyed background)

---

## 5. Colors, Typography, Radii & Shadows

### Design Token Variables

#### Colors
| Variable Name | Hex Value | Usage |
|---------------|-----------|-------|
| **Grayscale/White** | #FFFFFF | Screen background, status bar background |
| **Grayscale/Black** | #030401 | Primary text, button text, selected card border, home indicator, radio button (selected) |
| **Grayscale/100** | #F7F7F8 | Card background (default & selected) |
| **Primary color/100** | #D9B18E | CTA button background, radio button inner fill (selected) |

#### Typography Styles
| Variable Name | Font Family | Style | Size | Weight | Line Height | Usage |
|---------------|-------------|-------|------|--------|-------------|-------|
| **Body/Regular** | Figtree | Regular | 20 px | 400 | 24 px | Question text ("Was sind deine Ziele?") |
| **Regular klein** | Figtree | Regular | 16 px | 400 | 24 px | Card titles |
| **Button** | Figtree | Bold | 20 px | 700 | 24 px | CTA label ("Weiter") |
| **Callout** | Inter | Medium | 16 px | 500 | 24 px | Step counter ("3/7") |
| (Header Title) | Playfair Display | Regular | 24 px | 400 | 32 px | Header title ("Erzähl mir von dir 💜") |

#### Border Radii
| Element | Radius |
|---------|--------|
| **Goal Cards** | 20 px |
| **CTA Button** | 12 px |
| **Radio Button (outer)** | 24 px (circle) |
| **Radio Button (inner fill)** | 14 px (circle) |
| **Home Indicator** | 100 px (pill) |

#### Shadows
**None detected** in the provided code. All elements use flat design with solid colors and borders.

---

## 6. Copy & Accessibility

### String Content

| Element | German Text | English Translation | Node ID |
|---------|-------------|---------------------|---------|
| **Header title** | "Erzähl mir von dir 💜" | "Tell me about yourself 💜" | I68186:7927;45:9592 |
| **Step counter** | "3/7" | — | I68186:7927;58876:7743 |
| **Question** | "Was sind deine Ziele?" | "What are your goals?" | 68186:7928 |
| **Goal 1 (selected)** | "Meinen Zyklus & Körper besser verstehen" | "Better understand my cycle & body" | I68186:7930;67067:6779 |
| **Goal 2** | "Training an meinen Zyklus anpassen" | "Adapt training to my cycle" | I68186:7931;67067:7061 |
| **Goal 3** | "Ernährung optimieren & neue Rezepte entdecken" | "Optimize nutrition & discover new recipes" | I68186:7932;67067:7061 |
| **Goal 4** | "Gewicht managen (Abnehmen/Halten)" | "Manage weight (Lose/Maintain)" | 68219:6428 |
| **Goal 5 (selected)** | "Stress reduzieren & Achtsamkeit stärken" | "Reduce stress & strengthen mindfulness" | 68219:6440 |
| **CTA button** | "Weiter" | "Next" | I68186:7926;3298:769 |

### Multi-Selection Detection
**YES – Multiple goals can be selected.** Evidence:
- **Card 1** (node 68186:7930): Selected state (border visible, radio button filled)
- **Card 5** (node 68219:6435): Selected state (border visible, radio button filled)
- **Cards 2, 3, 4**: Unselected state (no border, radio button empty)

**Interaction:** Despite visual "radio button" component, behavior is **checkbox-like** (multi-select). Implementation should use checkboxes with custom radio-style visuals.

### Tap Targets & Touch Areas

| Element | Minimum Size | Actual Size | Status |
|---------|--------------|-------------|--------|
| **Back button** | 44×44 pt | 40×40 px | ⚠️ Below minimum (recommend 44×44 px with hit-test padding) |
| **Goal card (single-line)** | 44×44 pt | 388×66 px | ✅ Meets minimum |
| **Goal card (two-line)** | 44×44 pt | 388×89 px | ✅ Meets minimum |
| **CTA button** | 44×44 pt | 388×50 px | ✅ Meets minimum |

**Recommendation:** Add `hit-test-size: 44×44 px` to back button via semantic wrapper or increased touch area.

### Recommended Semantic Labels

```dart
// Header
Semantics(
  header: true,
  label: 'Erzähl mir von dir, Schritt 3 von 7',
  child: ...,
)

// Back button
Semantics(
  button: true,
  label: 'Zurück',
  onTap: () => Navigator.pop(context),
  increasedTapTarget: true, // 44×44 pt minimum
  child: ...,
)

// Question
Semantics(
  label: 'Was sind deine Ziele?',
  child: ...,
)

// Goal card (multi-select checkbox)
Semantics(
  label: 'Meinen Zyklus & Körper besser verstehen',
  checked: true, // if selected
  onTap: () => toggleGoal(1),
  child: ...,
)

// CTA button
Semantics(
  button: true,
  label: 'Weiter',
  enabled: true, // enable only if ≥1 goal selected
  onTap: () => proceedToNextStep(),
  child: ...,
)
```

### Accessibility Notes
1. **Screen reader order:** Header (title + step counter) → Back button → Question → Goal cards (1–5) → CTA
2. **Focus management:** Each goal card should receive independent focus; announce current selection state on tap
3. **Multi-selection announcement:** "2 von 5 Zielen ausgewählt" (dynamic hint)
4. **Color contrast:**
   - Text on card background (#030401 on #F7F7F8): **17.9:1** ✅ WCAG AAA
  - Button text (#030401 on #D9B18E): **≈10.4:1** ✅ WCAG AAA (Stark Figma Plugin)
5. **Dynamic type support:** Consider scaling fonts for accessibility settings (not specified in Figma)

---

## 7. Additional Observations

### Status Bar
- **Height:** 47 px
- **Indicators:** Signal, WiFi, Battery (right-aligned, 20 px margin)
- **Time:** "9:41" (centered left, Playfair Display SemiBold 18 px)
- **Color:** Grayscale/Black (#030401)
- **Mic & Cam indicator:** 6×6 px dot (top-right)
- **Node ID:** I68186:7927;45:9596

### Home Indicator
- **Width:** 134 px
- **Height:** 5 px
- **Color:** Grayscale/Black (#030401) (property1="dark")
- **Border radius:** 100 px (pill)
- **Container height:** 34 px
- **Bottom position:** Fixed at screen bottom
- **Vertical centering:** calc(50% - 0.5px)
- **Node ID:** 68186:7925

### Layout Strategy
- **Root container:** Vertical flex column with 47 px gap (gap-[47px])
- **Goal List:** Vertical flex column with 24 px gap (gap-[24px])
- **Horizontal centering:** Content width 388 px, screen width 428 px → 20 px left/right margins
- **Absolute positioning:** Minimal (only header internal elements)
- **Responsive considerations:** Fixed 428 px width (iPhone 14 Pro dimensions)

### Goal List Container
- **Node ID:** 68186:7929
- **Flex direction:** Column
- **Gap:** 24 px
- **Items alignment:** Start (left-aligned)
- **Content stretch:** Full width (388 px)

---

## Notes for Implementation

1. **Single-line header confirmation:** ✓ Back icon, title, and step counter all positioned at y=79 px
2. **Multi-select interaction:** Use checkboxes with custom radio-button visuals (not true radio buttons)
3. **Card height variation:** Single-line cards (66 px) vs. two-line cards (89 px); implement auto-height based on text wrap
4. **Selected state border:** Apply 1 px #1C1411 border only when card is selected (toggle on tap)
5. **Radio button custom widget:** Create reusable component with `selected: bool` parameter (outer circle + inner fill)
6. **Back button hit-test:** Increase touch area to 44×44 px minimum (WCAG 2.1 Level AA)
7. **CTA button state:** Disable if no goals selected; enable when ≥1 goal selected
8. **Font licensing:** Verify Playfair Display, Figtree, Inter availability in Flutter/Google Fonts
9. **Localization:** All strings must support German (primary) with English fallback
10. **Icon assets:** Export SVG icons from Figma (explore, weight, dish, weight-loss, emoji) at 24×24 px

---

**End of Specifications**
