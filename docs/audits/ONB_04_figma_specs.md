# ONB_04 Figma Specifications
**Screen:** 04_Onboarding (Last Period Start Date)
**Figma Node:** 68186:8204
**Screen Dimensions:** 428×932px (iPhone 14 Pro Max)

---

## 1. Header (Title with Status Bar)

### Status Bar
- **Height:** 47px (node: 68186:8205;45:9596)
- **Background:** `Grayscale/White` (#FFFFFF)
- **Time:** "9:41" (Playfair Display SemiBold 18px)
- **Indicators:** Right-aligned (signal, WiFi, battery) at x=340px

### Back Button
- **Container Size:** 40×40px (node: 68186:8205;45:9594)
- **Visual Icon:** 20×20px (centered, arrow-left)
- **Position:** absolute, left=20px, top=59px
- **⚠️ A11y Issue:** Current 40×40px < 44pt minimum hit area
- **Recommendation:** Increase hit area to 44×44px via padding/transparent border
- **Semantic Label:** "Zurück" or "Zurück zur vorherigen Seite"

### Title
- **Text:** "Erzähl mir von dir 💜"
- **Font:** Playfair Display Regular 24px / line-height 32px (node: 68186:8205;45:9592)
- **Color:** `Grayscale/Black` (#030401)
- **Width:** 388px
- **Position:** centered horizontally, baseline y=79px

### Step Indicator
- **Text:** "4/7"
- **Font:** Inter Medium 16px / line-height 24px (node: 68186:8205;58876:7743)
- **Color:** `Grayscale/Black` (#030401)
- **Position:** absolute right-aligned, baseline y=79px (same as title), x=calc(50% + 194px)
- **Semantic Label:** "Schritt 4 von 7"

### Layout Note
Title and Step Indicator share the **same baseline (y=79px)**, confirming single-line alignment.

---

## 2. Vertical Spacing Measurements

**Primary vertical rhythm:** 59px gap between major sections (flex layout with `gap-[59px]`)

| From | To | Spacing | Notes |
|------|----|---------|-----------------------|
| Header (112px tall) | Question | 59px | First gap after header container |
| Question | Date Display | 59px | Implicit from flex gap |
| Date Display | Underline | 59px | Implicit from flex gap |
| Underline | Callout | 59px | Implicit from flex gap |
| Callout | CTA Button | 59px | Implicit from flex gap |
| CTA Button | Picker (gradient overlay) | 59px | Implicit from flex gap |
| Picker | Home Indicator (34px tall) | — | Picker extends to bottom, home indicator overlays |

**Total Header Height:** 112px (includes 47px status bar)

---

## 3. Date Picker Specifications

### Overall Dimensions
- **Visible Height:** 198px (gradient overlay, node: 68186:8224)
- **Full Width:** 428px (screen width)
- **Selected Row Background:** 388×36px, rounded-12px, `Grayscale/200` (#F1F1F1, node: 68186:8206)
- **Selected Row Position:** top=728px

### Column Layout (3 columns)

#### Day Column (Left)
- **X-Position:** left=70px for labels (nodes: 68186:8219-8223)
- **Font:** Inter Semi Bold 18px / line-height 27px (`Headline` token)
- **Color:** dimgrey (#696969 = `Grayscale/500`)
- **Values (visible):** 5, 6, 7, 8, 9
- **Semantic Label:** "Tag auswählen"

#### Month Column (Center)
- **X-Position (selected):** left=214px (node: 68186:8207)
- **X-Position (unselected):** left=50% centered (nodes: 68186:8209-8212)
- **Font (selected):** Inter Semi Bold 18px / line-height 27px (`Headline` token), color: dimgrey (#696969)
- **Font (unselected):** Inter Medium 17px / line-height 25px (`Body` token), color: `Grayscale/400` (#A2A0A2)
- **Locale:** **German (DE)** — "Mai" (not "May")
- **Edge Case:** Bottom row shows "May" (English) as design artifact
- **Semantic Label:** "Monat auswählen"

#### Year Column (Right)
- **X-Position:** left=344.5px (node: 68186:8208)
- **Font:** Inter Semi Bold 18px / line-height 27px (`Headline` token)
- **Color:** `Grayscale/Black` (#030401)
- **Value (selected):** 2002
- **Semantic Label:** "Jahr auswählen"

### Row Spacing (Y-Positions)
- **Center row (selected):** top=746.5px
- **Rows below:** top=785.5px, 816.5px, 847.5px, 878.5px
- **Increments:** ~31-39px between rows (non-uniform, likely for deceleration effect)

### Full-Width Confirmation
Picker spans full screen width (428px) with gradient overlay from transparent (41.315%) to white (75.382%).

### Picker A11y
- **Selected Value Announcement:** "Ausgewählt: 5 Mai 2002"
- **Interaction:** Swipe/scroll for value changes, VoiceOver should announce column name + new value

---

## 4. CTA Button

### Dimensions & Layout
- **Size:** 388×50px (node: 68186:8214)
- **Border Radius:** 12px (rounded-[12px])
- **Padding:** top=12px, bottom=11px, left/right=12px
- **Gap:** 8px between internal flex items

### Colors
- **Background:** `Primary color/100` (#D9B18E, tan/beige)
- **Text:** `Grayscale/White` (#FFFFFF)

### Typography
- **Font:** `Button` token → Figtree Bold 20px / line-height 24px
- **Text:** "Weiter"
- **Alignment:** center

### Disabled Logic
- **⚠️ Not specified in Figma** (only enabled state shown)
- **Recommendation:** Implement disabled state until user interacts with date picker
  - **Disabled Style Options:**
    1. Opacity: 0.5-0.6 on current background
    2. Alternative Background: `Grayscale/200` (#F1F1F1) with `Grayscale/500` (#696969) text
- **Trigger:** Enable when user selects a date different from default (e.g., any scroll/tap on picker)

### A11y
- **Tap Target:** 388×50px ≈ 50×63pt → ✅ **Meets 44pt minimum**
- **Semantic Label:** "Weiter" (inherent from text)
- **Contrast:** White on #D9B18E → **Needs verification** (tan background may have lower contrast; test against WCAG AA 4.5:1 for 20px text)

---

## 5. Callout (Info Box)

### Dimensions & Layout
- **Size:** 356×124px (node: 68219:6483)
- **Padding:** 16px all sides (p-[16px])
- **Gap (icon → text):** 12px (gap-[12px])
- **Gap (internal):** 10px vertical between text elements (though text flows as paragraph)

### Border & Background
- **Border Radius:** 20px (rounded-[20px])
- **Border:** 1px solid `Color` (#BF58F7, purple accent)
- **Background:** `Grayscale/200` (#F1F1F1)

### Content Structure
- **Icon (node: 67069:6715):** 24×24px info icon (decorative or labeled "Hinweis" if interactive)
- **Text Container (node: 67069:6719):** flex-grow, 12px gap from icon

### Typography
- **Base Text:** `Regular klein` / `Callout` token → Figtree Regular 16px / line-height 24px
- **Bold Inline:** Figtree Bold (for "exakten Tag nicht mehr weißt")
- **Color:** `Grayscale/Black` (#030401)

### Content (German)
> Mach dir keine Sorgen, wenn du den **exakten Tag nicht mehr weißt**. Eine ungefähre Schätzung reicht für den Start völlig aus.

### A11y
- **Role:** `role="alert"` or `role="note"` for screen readers
- **Contrast:** #030401 on #F1F1F1 → **Needs verification** (likely passes, but test against WCAG AA 4.5:1)
- **Icon Label:** If interactive, needs "Hinweis"; if decorative, aria-hidden="true"

---

## 6. Question & Date Display

### Question Text (node: 68186:8218)
- **Text:** "Wann hat deine letzte Periode angefangen?"
- **Font:** `Body/Regular` token → Figtree Regular 20px / line-height 24px
- **Color:** `Grayscale/Black` (#030401)
- **Alignment:** center
- **Semantic:** Inherently labeled (question text)

### Date Display (node: 68186:8216)
- **Text:** "5 Mai 2002"
- **Font:** `Heading/H1` token → Playfair Display Regular 32px / line-height 40px
- **Color:** `Grayscale/Black` (#030401)
- **Alignment:** center
- **Semantic Role:** Heading or "Ausgewähltes Datum: 5 Mai 2002"

### Underline (node: 68186:8217)
- **Size:** 197×0px (height 0, visual line at top=-2px via SVG)
- **Width:** 197px (centered under date)
- **Purpose:** Visual separator between date and picker

---

## 7. Design Tokens Summary

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `Grayscale/White` | #FFFFFF | Backgrounds, CTA text |
| `Grayscale/Black` | #030401 | Primary text, picker selected year |
| `Grayscale/200` | #F1F1F1 | Callout background, picker selected row |
| `Grayscale/400` | #A2A0A2 | Picker unselected text |
| `Grayscale/500` | #696969 | Picker selected day/month |
| `Primary color/100` | #D9B18E | CTA button background |
| `Color` | #BF58F7 | Callout border (purple accent) |

### Typography Tokens
| Token | Specification | Usage |
|-------|---------------|-------|
| `Heading/H1` | Playfair Display Regular 32/40 | Date display |
| `Body/Regular` | Figtree Regular 20/24 | Question text |
| `Button` | Figtree Bold 20/24 | CTA button |
| `Callout` / `Regular klein` | Figtree Regular 16/24 | Callout body |
| `Headline` | Inter Semi Bold 18/27 | Picker selected row |
| `Body` | Inter Medium 17/25 | Picker unselected row |
| (Header Title) | Playfair Display Regular 24/32 | Header title |
| (Step Indicator) | Inter Medium 16/24 | Step "4/7" |

### Border Radius
| Element | Radius | Token/Note |
|---------|--------|------------|
| Callout | 20px | rounded-[20px] |
| CTA Button | 12px | rounded-[12px] |
| Picker Selected Row | 12px | rounded-[12px] |
| Home Indicator | 100px | Pill shape |

### Spacing
| Type | Value | Usage |
|------|-------|-------|
| Vertical Rhythm | 59px | Gap between major sections (flex layout) |
| Callout Padding | 16px | All sides |
| Callout Icon Gap | 12px | Icon to text |
| CTA Padding | 12px | Vertical and horizontal |

---

## 8. Accessibility Audit

### Semantic Labels Required
- ✅ **Back Button:** "Zurück" or "Zurück zur vorherigen Seite"
- ✅ **Step Indicator:** "Schritt 4 von 7"
- ✅ **Question:** Inherently labeled by text
- ✅ **Date Display:** Heading or "Ausgewähltes Datum: 5 Mai 2002"
- ✅ **Callout:** `role="alert"` or `role="note"`
- ⚠️ **Info Icon:** Decorative (`aria-hidden="true"`) or labeled "Hinweis"
- ✅ **CTA Button:** "Weiter" (inherent)
- ✅ **Picker Columns:**
  - Day: "Tag auswählen"
  - Month: "Monat auswählen"
  - Year: "Jahr auswählen"
- ✅ **Picker Selection:** "Ausgewählt: 5 Mai 2002"

### Tap Target Sizes (WCAG 2.5.5 / iOS HIG: ≥44pt)
| Element | Size (px) | Size (pt) | Status |
|---------|-----------|-----------|--------|
| Back Button | 40×40 | ~40×40 | ⚠️ **Below 44pt** → Increase hit area to 44×44px |
| CTA Button | 388×50 | ~50×63 | ✅ **Meets requirement** |
| Picker Rows | Full-width × 36 tall | Adequate | ✅ For swipe/scroll |

**Fix for Back Button:** Implement 44×44px hit area while keeping visual at 40×40px (use padding or transparent border).

### Color Contrast (WCAG AA: 4.5:1 normal, 3:1 large ≥18pt)
| Element | Foreground | Background | Size | Status |
|---------|------------|------------|------|--------|
| Title | #030401 | #FFFFFF | 24px | ✅ High contrast |
| Question | #030401 | #FFFFFF | 20px | ✅ High contrast |
| Date Display | #030401 | #FFFFFF | 32px (large) | ✅ High contrast |
| Callout Text | #030401 | #F1F1F1 | 16px | ⚠️ **Needs verification** |
| CTA Button | #FFFFFF | #D9B18E | 20px | ⚠️ **Needs verification** (tan background) |
| Picker Selected | #696969 / #030401 | #F1F1F1 | 18px | ⚠️ **Needs verification** |
| Picker Unselected | #A2A0A2 | white gradient | 17px | ⚠️ **Needs verification** |

**Action Items:**
1. Test callout text (#030401 on #F1F1F1) against WCAG AA 4.5:1
2. Test CTA button (white on #D9B18E) — tan may fail, consider darker shade or higher text weight
3. Test picker colors (#696969 and #A2A0A2 on light backgrounds)

### Focus Indicators
- **Required for:** Back button, CTA button, picker interaction
- **Recommendation:** 2px solid `Color` (#BF58F7) outline with 2px offset for all interactive elements

---

## 9. Implementation Notes

### Disabled State Logic (CTA Button)
- **Current Spec:** Only enabled state shown in Figma
- **Recommended Logic:**
  1. **Default:** Button enabled (user may proceed with pre-filled date)
  2. **Alternative (if validation required):** Disabled until user interacts with picker (any scroll/tap)
- **Disabled Styling:**
  - Option A: Opacity 0.5-0.6 on `Primary color/100`
  - Option B: Background `Grayscale/200` (#F1F1F1), text `Grayscale/500` (#696969)

### Date Picker Locale
- **Primary:** German (DE) — "Mai" for May
- **Edge Case in Figma:** Bottom row shows "May" (English) — likely design artifact, **do not implement**
- **Implementation:** Use `Intl.DateFormat('de-DE')` or equivalent for month names

### Underline Width
- **Figma Spec:** 197px (node: 68186:8217)
- **Implementation:** Consider dynamic width based on date text length, or keep fixed at 197px centered under date

### Home Indicator
- **Height:** 34px container, 5px rounded bar (134px wide)
- **Position:** Fixed bottom, centered
- **Color:** `Grayscale/Black` (#030401)
- **Notes:** iOS system element, automatically handled by SafeArea in Flutter

---

## 10. QA Checklist

- [ ] Back button hit area increased to 44×44px
- [ ] Title and step indicator aligned on same baseline (y=79px)
- [ ] Vertical spacing uses 59px gaps between sections
- [ ] Date picker displays German month names ("Mai" not "May")
- [ ] Picker selected row background: 388×36px, rounded-12px, #F1F1F1
- [ ] Picker column widths and x-positions match spec (70px, 214px, 344.5px)
- [ ] CTA button: 388×50px, rounded-12px, #D9B18E background, white text
- [ ] Callout: 356×124px, rounded-20px, #BF58F7 border, #F1F1F1 background, 16px padding
- [ ] All design tokens used (no hardcoded hex values in UI code)
- [ ] Semantic labels for screen readers implemented
- [ ] Color contrast tested and passes WCAG AA
- [ ] Focus indicators visible on all interactive elements
- [ ] Disabled state logic implemented for CTA button (if required)
- [ ] VoiceOver announces picker column names and selected values
- [ ] Underline centered under date display (197px width)

---

## 11. References

**Figma:**
- File Key: iQthMdxpCbl6afzXxvzqlt
- Node ID: 68186:8204 (04_Onboarding)

**Related Screens:**
- ONB_01 (docs/audits/ONB_01_figma_specs.md)
- ONB_02 (docs/audits/ONB_02_figma_specs.md)
- ONB_03 (docs/audits/ONB_03_figma_specs.md)

**Design System:**
- Token definitions: Figma variables (see JSON output)
- Typography scale: Playfair Display (headings), Figtree (body/buttons), Inter (UI elements)
- Color palette: Grayscale (5 values) + Primary color/100 + Color (purple accent)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-01
**Auditor:** ui-frontend agent (Claude Code)
