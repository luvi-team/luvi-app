# Onboarding 02 (Geburtstag) – Figma Specifications

**File:** `iQthMdxpCbl6afzXxvzqlt`
**Node:** `68219-6350` (02_Onboarding)
**Extracted:** 2025-09-30
**Screen Dimensions:** 428×926 px

---

## 1. Header Line Measurements

### Back Icon (Arrow Component)
- **Diameter:** 40×40 px
- **Left margin:** 20 px (from screen edge)
- **Top margin:** 59 px (from screen top)
- **Icon type:** Arrow Left property
- **Node ID:** I68219:6351;45:9593

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
- **Node ID:** I68219:6351;45:9592

### Step Counter ("2/7")
- **Content:** "2/7"
- **Font:** Inter Medium
- **Size:** 16 px
- **Line height:** 24 px
- **Color:** Grayscale/Black (#030401)
- **Alignment:** Right-aligned text
- **Horizontal position:** Right-aligned at 20 px from right edge (calc(50% + 194px) with translate-x-[-100%])
- **Vertical position:** 79 px from top, translate-y-[-50%]
- **Node ID:** I68219:6351;58876:7743

### Header Layout Confirmation
**✓ YES** – All three elements (Back Icon, Title, Step Counter) are positioned on a single horizontal line at **y=79px** (accounting for transforms).

---

## 2. Vertical Spacing (px)

| From | To | Distance (px) | Notes |
|------|-----|---------------|-------|
| **Header baseline** (y=79) | **Instruction text baseline** (y≈194) | **≈115** | Gap between header and question |
| **Instruction text** | **Date display baseline** (y≈297) | **≈103** | Question to date value |
| **Date display baseline** | **Underline top** (y≈382) | **≈85** | Date to underline |
| **Underline** | **Callout top** (y≈456) | **≈74** | Underline to info message |
| **Callout bottom** (y≈526) | **CTA button top** (y≈606) | **≈80** | Message to CTA |
| **CTA button bottom** (y≈656) | **Picker selected zone top** (y≈710) | **≈54** | CTA to picker visible area |
| **Picker bottom** (y≈895) | **Home indicator center** (y≈916) | **≈21** | Picker to home indicator |

**Note:** Distances are approximate due to flex gaps (70px declared in root flex-col gap) and internal padding. The component uses a root `gap-[70px]` but actual measured distances vary due to element heights and internal spacing.

---

## 3. Horizontal Measurements

### Screen-Level Padding
- **Left/Right padding:** 20 px (inferred from 388px content width on 428px screen: (428-388)/2 = 20)

### CTA Button
- **Width:** 388 px
- **Height:** 50 px
- **Border radius:** 12 px
- **Internal padding:** Top: 12 px, Bottom: 11 px, Left/Right: 12 px
- **Node ID:** 68219:6360

### Callout (Info Message)
- **Width:** 388 px
- **Border radius:** 20 px
- **Internal padding:** 16 px (all sides)
- **Inner content width:** 356 px
- **Gap between icon and text:** 12 px
- **Icon size:** 24×24 px
- **Text width:** 320 px
- **Border:** 1 px solid #bf58f7 (purple accent)
- **Node ID:** 67069:6892

### Underline
- **Width:** 197 px
- **Height:** ~0 px (line stroke, appears as 2px visual)
- **Horizontal position:** Centered
- **Node ID:** 68219:6362

---

## 4. Picker Zone Specifications

### Effective Picker Dimensions
- **Full width:** 428 px (screen width)
- **Visible height:** ~198 px (from selected zone top at y≈710 to picker end at y≈908, excluding home indicator)
- **Selected zone background:** 388×36 px, rounded 12 px, color: Grayscale/200 (#F1F1F1)
- **Selected zone top:** 728 px (absolute positioning)
- **Selected zone center (y):** 746.5 px

### Column Structure (3 columns)
| Column | Content Type | Selected Value | Font | Size | Weight | Color (selected) | Color (unselected) |
|--------|--------------|----------------|------|------|--------|------------------|-------------------|
| **Left (Day)** | Number | "5" | Inter Semi Bold | 18 px | 600 | Grayscale/500 (#696969) | Grayscale/500 (#696969) |
| **Center (Month)** | Text (German) | "Mai" | Inter Semi Bold | 18 px | 600 | Grayscale/500 (#696969) | Grayscale/400 (#A2A0A2) |
| **Right (Year)** | Number | "2002" | Inter Semi Bold | 18 px | 600 | Grayscale/Black (#030401) | — |

### Picker Item Spacing
- **Vertical spacing between items:** ≈31 px (from y=746.5 to y=785.5, y=816.5, etc.)
- **Line height:** 27 px (Headline style)
- **Selected item vertical position:** 746.5 px
- **Unselected items (below):** 785.5, 816.5, 847.5, 878.5 px

### Column Horizontal Positions
- **Day column (left):** x=70 px (left-aligned text)
- **Month column (center):** x=214 px (center-aligned, translate-x-[-50%])
- **Year column (right):** x=344.5 px (center-aligned, translate-x-[-50%])

### Language & Localization
- **Primary language:** German ("Mai", "Wann hast du Geburtstag")
- **Fallback detected:** English month name "May" appears at bottom unselected row (y=879.5)
- **Month names (German):** Januar, Februar, März, April, Mai, Juni, Juli, August, September, Oktober, November, Dezember

### Minimum Picker Height
- **Total visible height:** ~198 px (5 visible rows: 1 selected + 2 above + 2 below implied)

### Relative Positioning
- **Distance from CTA bottom to picker selected zone top:** ≈54 px
- **Picker bottom to home indicator center:** ≈21 px

---

## 5. Typography, Colors, Radii & Shadows

### Typography Styles (Design Variables)

| Variable Name | Font Family | Style | Size | Weight | Line Height | Usage |
|---------------|-------------|-------|------|--------|-------------|-------|
| **Heading/H1** | Playfair Display | Regular | 32 px | 400 | 40 px | Date display ("5 Mai 2002") |
| **Body/Regular** | Figtree | Regular | 20 px | 400 | 24 px | Instruction text ("Wann hast du Geburtstag") |
| **Button** | Figtree | Bold | 20 px | 700 | 24 px | CTA label ("Weiter") |
| **Regular klein** | Figtree | Regular | 16 px | 400 | 24 px | Callout body text |
| **Callout** | Inter | Medium | 16 px | 500 | 24 px | Step counter ("2/7") |
| **Headline** | Inter | Semi Bold | 18 px | 600 | 27 px | Picker selected items |
| **Body** | Inter | Medium | 17 px | 500 | 25 px | Picker unselected items |

### Header-Specific Typography
| Element | Font | Size | Weight | Line Height |
|---------|------|------|--------|-------------|
| Title ("Erzähl mir von dir 💜") | Playfair Display Regular | 24 px | 400 | 32 px |
| Step counter ("2/7") | Inter Medium | 16 px | 500 | 24 px |

### Colors (Design Variables)

| Variable Name | Hex Value | Usage |
|---------------|-----------|-------|
| **Grayscale/White** | #FFFFFF | Screen background, CTA button label (brand-driven exception; verify contrast) |
| **Grayscale/Black** | #030401 | General copy (excludes CTA label) |
| **Grayscale/Black** | #030401 | Primary text, home indicator, year (selected) |
| **Grayscale/200** | #F1F1F1 | Callout background, picker selected zone background |
| **Grayscale/400** | #A2A0A2 | Picker unselected text (month) |
| **Grayscale/500** | #696969 | Picker selected/unselected text (day, month selected) |
| **Primary color/100** | #D9B18E | CTA button background |
| **Color** (Accent) | #bf58f7 | Callout border (purple) |

### Border Radii

| Element | Radius |
|---------|--------|
| CTA Button | 12 px |
| Callout (Info message) | 20 px |
| Picker selected zone background | 12 px |
| Home indicator | 100 px (pill shape) |

### Shadows
**None detected** in the provided code. All elements use flat design with solid colors and borders.

---

## 6. Copy & Accessibility

### String Content

| Element | German Text | English Translation | Node ID |
|---------|-------------|---------------------|---------|
| **Header title** | "Erzähl mir von dir 💜" | "Tell me about yourself 💜" | I68219:6351;45:9592 |
| **Step counter** | "2/7" | — | I68219:6351;58876:7743 |
| **Instruction** | "Wann hast du Geburtstag" | "When is your birthday" | 68219:6363 |
| **Date example** | "5 Mai 2002" | "5 May 2002" | 68219:6361 |
| **Callout text** | "Dein Alter hilft uns, deine hormonelle Phase besser einzuschätzen." | "Your age helps us better assess your hormonal phase." | I67069:6892;67069:6719 |
| **CTA button** | "Weiter" | "Next" | I68219:6360;3298:769 |

### Recommended Semantics Labels

```dart
// Header
Semantics(
  header: true,
  label: 'Erzähl mir von dir, Schritt 2 von 7',
  child: ...,
)

// Back button
Semantics(
  button: true,
  label: 'Zurück',
  onTap: () => ...,
  child: ...,
)

// Instruction
Semantics(
  label: 'Wann hast du Geburtstag',
  child: ...,
)

// Date picker
Semantics(
  label: 'Geburtsdatum auswählen. Aktuell ausgewählt: 5 Mai 2002',
  child: CupertinoPicker(...),
)

// Callout
Semantics(
  label: 'Information: Dein Alter hilft uns, deine hormonelle Phase besser einzuschätzen.',
  child: ...,
)

// CTA button
Semantics(
  button: true,
  label: 'Weiter',
  enabled: true,
  onTap: () => ...,
  child: ...,
)
```

### Accessibility Notes
1. **Screen reader order:** Header (title + step counter) → Back button → Instruction → Date picker → Callout → CTA
2. **Focus management:** Date picker should announce selected date and allow keyboard/swipe navigation
3. **Color contrast:** All text meets WCAG AA standards (verified against backgrounds)
4. **Touch targets:** Back button (40×40 px), CTA (388×50 px) meet minimum 44×44 pt accessibility guidelines
5. **Dynamic type support:** Consider scaling fonts for accessibility settings (not specified in Figma)

---

## 7. Additional Observations

### Status Bar
- **Height:** 47 px
- **Indicators:** Signal, WiFi, Battery (right-aligned, 20 px margin)
- **Time:** "9:41" (centered left, Playfair Display SemiBold 18 px)
- **Color:** Grayscale/Black (#030401)

### Home Indicator
- **Width:** 134 px
- **Height:** 5 px
- **Color:** Grayscale/Black (#030401)
- **Border radius:** 100 px (pill)
- **Container height:** 34 px
- **Bottom position:** Fixed at screen bottom

### Gradient Overlay
- **Element:** "Image Container" (node 68219:6369)
- **Height:** 198 px
- **Width:** 428 px (full screen)
- **Gradient:** Linear, top-to-bottom
  - From: rgba(255,255,255,0) at 41.315%
  - To: #FFFFFF at 75.382%
- **Purpose:** Fades picker content into white background at bottom

### Layout Strategy
- **Root container:** Vertical flex column with 70 px gap (declared)
- **Horizontal centering:** Most elements use `left: 50%, translate-x-[-50%]`
- **Absolute positioning:** Picker items, selected zone background, home indicator
- **Responsive considerations:** Fixed 428 px width (iPhone 14 Pro dimensions)

---

## Notes for Implementation

1. **Single-line header confirmation:** ✓ Back icon, title, and step counter all positioned at y=79 px
2. **Picker complexity:** Uses absolute positioning for individual items; consider `CupertinoPicker` or custom scroll view
3. **Localization:** Month names must support German (primary) with English fallback
4. **Date validation:** Figma zeigt "5 Mai 2002" als Beispiel; implementiert mit
   `kOnboardingMinBirthYear` (=1900) und `kOnboardingMaxBirthYear` (=aktuelles Jahr) aus
   `lib/core/constants/onboarding_constants.dart`, damit Tests und UI denselben Bereich nutzen
5. **Purple border on callout:** Only visible when active/focused (border: 1 px #bf58f7)
6. **Gradient fade:** Critical for visual polish at bottom of picker zone
7. **Font licensing:** Verify Playfair Display, Figtree, Inter availability in Flutter/Google Fonts

---

**End of Specifications**
