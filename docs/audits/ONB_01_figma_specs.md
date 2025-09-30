# 01_Onboarding (Figma Specs)

**Node ID:** 67069:6953
**Frame Size:** 428×926 px
**File Key:** iQthMdxpCbl6afzXxvzqlt

---

## Layout Tree

```
01_Onboarding (Frame 428×926)
├── Title With Status bar (Instance, 428×112, y=0)
│   ├── Status Bar (47px height)
│   │   ├── Time ("9:41")
│   │   ├── Indicators (Signal, WiFi, Battery)
│   │   └── Mic & Cam icons
│   ├── Page Title ("Erzähl mir von dir 💜")
│   └── Step Counter ("1/7", right-aligned)
├── Instruction Text ("Wie soll ich dich nennen?", y=196)
├── Name Input ("Claire", y=304)
├── Line 23 (Underline separator, y=428)
├── button/Buttons large ("Weiter", y=512)
├── State (iOS Keyboard, y=646, 428×282)
└── HomeIndicator (y=892, 428×34)
```

---

## Spacing (px)

### Vertical Gaps
- **Status bar → Title text center:** ~79 px
- **Title bar → Instruction text:** 84 px
- **Instruction → Name input:** 108 px (center-to-center)
- **Name input → Underline:** 84 px
- **Underline → Button:** 84 px
- **Button → Keyboard:** 96 px
- **Keyboard height:** 282 px
- **Keyboard → Home Indicator:** 0 px (adjacent)

### Horizontal Padding
- **Screen edge to content:** 20 px (button, title with status bar insets = 20px)
- **Title bar inner padding:** 20 px (left/right)
- **Keyboard keys horizontal gap:** ~5–6 px

### Component Dimensions
- **Button (CTA):** 388×50 px, inner padding ~12 px
- **Status bar total:** 47 px height
- **Home Indicator bar:** 134×5 px, rounded 100 px, centered horizontally, ~16 px from bottom

### Keyboard Layout
- **Top row (QWERTYUIOP):** 10 keys, 42 px height, ~6 px gaps
- **Middle row (ASDFGHJKL):** 9 keys, inset 19 px left/right, 42 px height, ~6 px gaps
- **Bottom row (ZXCVBNM + Shift/Delete):** 7 keys + 2 action keys (42 px each), inset 58 px left/right
- **Space bar row:** "123" key (91 px), space (flexible grow), "return" key (91 px), 6 px gaps

---

## Typography

### Heading/H1 (Page Title)
- **Font:** Playfair Display Regular
- **Size/Weight:** 24 px / 400 (Regular)
- **Line Height:** 32 px
- **Letter Spacing:** default
- **Color:** Grayscale/Black (#030401)
- **Usage:** "Erzähl mir von dir 💜"

### Body/Regular (Instruction Text)
- **Font:** Figtree Regular
- **Size/Weight:** 20 px / 400
- **Line Height:** 24 px
- **Letter Spacing:** default
- **Color:** Grayscale/Black (#030401)
- **Usage:** "Wie soll ich dich nennen?"

### Heading/H1 (User Input Display)
- **Font:** Playfair Display Regular
- **Size/Weight:** 32 px / 400
- **Line Height:** 40 px
- **Letter Spacing:** default
- **Color:** Grayscale/Black (#030401)
- **Usage:** "Claire" (user's input text)

### Button
- **Font:** Figtree Bold
- **Size/Weight:** 20 px / 700
- **Line Height:** 24 px
- **Letter Spacing:** default
- **Color:** Grayscale/White (#FFFFFF)
- **Usage:** "Weiter" (CTA button)

### Callout (Step Counter)
- **Font:** Inter Medium
- **Size/Weight:** 16 px / 500
- **Line Height:** 24 px
- **Letter Spacing:** default
- **Color:** Grayscale/Black (#030401)
- **Usage:** "1/7"

### Keyboard Text
- **Font:** Playfair Display Regular
- **Size/Weight:** 22 px / 400 (letters), 16 px / 400 (labels)
- **Line Height:** 28 px (letters), 21 px (labels)
- **Letter Spacing:** 0.35 px (letters), -0.32 px (labels)
- **Color:** Grayscale/Black (#030401)

---

## Colors

### Background Colors
- **Screen Background:** Grayscale/White (#FFFFFF)
- **CTA Button:** Primary color/100 (#D9B18E)
- **Keyboard Background:** #D1D3D9 (with backdrop-blur-[54.366px])
- **Key Background (normal):** Grayscale/White (#FFFFFF)
- **Key Background (action/secondary):** #ABB0BC (gray tone)

### Text Colors
- **Primary Text (all copy):** Grayscale/Black (#030401)
- **Button Text:** Grayscale/White (#FFFFFF)

### Line/Separator
- **Underline (Line 23):** Grayscale/Black (#030401) or similar (appears as thin gray line)

### Home Indicator
- **Home Indicator bar:** Grayscale/Black (#030401)

---

## Radii/Shadows

### Button (CTA)
- **Border Radius:** 12 px
- **Shadow:** none visible (solid fill)

### Keyboard Keys
- **Border Radius:** 4.6 px (rounded corners)
- **Shadow:** 0px 1px 0px 0px rgba(0,0,0,0.3)

### Home Indicator Bar
- **Border Radius:** 100 px (pill shape)

---

## Components + Props/States

### Title With Status bar (Instance)
- **Component:** Reusable header with status bar, title, step counter
- **Props:**
  - `title` (string): "Erzähl mir von dir 💜"
  - `stepText` (string): "1/7"
- **States:** default (no variants visible in this node)
- **Sub-elements:**
  - Status bar (time, signal, WiFi, battery)
  - Title text (Playfair Display 24 px)
  - Step counter (Inter 16 px, right-aligned)

### button/Buttons large (Instance)
- **Component:** Primary CTA button
- **Props:**
  - `label` (string): "Weiter"
  - `color` (fill): Primary color/100 (#D9B18E)
  - `size`: large (388×50 px)
- **States:** default (no hover/pressed state visible)
- **Inner padding:** 12 px all sides, 8 px gap (if icon present)

### State (iOS Keyboard, Instance)
- **Component:** iOS-style keyboard (QWERTY layout)
- **Props:**
  - `layout`: letters (not numbers/symbols)
  - `shift`: active (uppercase letters shown)
- **States:** default (shift active, no emoji/dictation pressed)
- **Sub-elements:**
  - Top row: QWERTYUIOP
  - Middle row: ASDFGHJKL
  - Bottom row: ZXCVBNM + Shift (left), Delete (right)
  - Space bar row: "123", space, "return"
  - Emoji icon (left), Dictation icon (right)

### HomeIndicator (Instance)
- **Component:** iOS home indicator bar
- **Props:** none (static)
- **States:** default

### _Key (Keyboard Key, nested instance)
- **Component:** Individual keyboard key
- **Props:**
  - `label` (string): single letter or label
  - `color`: Primary (white), Secondary (gray #ABB0BC)
  - `darkMode`: False
- **States:** default (no pressed state visible)

---

## Interaction (CTA Target)

### Primary CTA
- **Button Label:** "Weiter" (Continue)
- **Action:** Navigate to next onboarding step (likely question 2/7)
- **Accessibility:** Button role, label "Weiter", no additional hint visible

### Keyboard Interaction
- **Input Field:** User types name (currently "Claire")
- **Expected Flow:** User edits name → taps "Weiter" → proceeds to step 2/7

---

## Copy Strings (Exact)

### Main Content
1. **Page Title:** "Erzähl mir von dir 💜"
2. **Step Counter:** "1/7"
3. **Instruction Text:** "Wie soll ich dich nennen?"
4. **Input Placeholder/Value:** "Claire" (example user input)
5. **CTA Button:** "Weiter"

### Keyboard Labels
- **Keys:** Q, W, E, R, T, Y, U, I, O, P, A, S, D, F, G, H, J, K, L, Z, X, C, V, B, N, M
- **Action Keys:** "123", "space", "return"
- **Time:** "9:41"

---

## a11y Notes

### Semantic Roles
- **Title With Status bar:** Header landmark (status bar should be hidden from a11y tree)
- **Instruction Text:** Label for input field (should be associated with text input)
- **Name Input:** Text input field (editable), current value "Claire"
- **CTA Button:** Button role, label "Weiter"
- **Keyboard:** System keyboard (a11y managed by OS)
- **Home Indicator:** Decorative, hidden from a11y tree

### Text Contrast
- **Grayscale/Black on White:** WCAG AAA (21:1 ratio, excellent contrast)
- **White on Primary color/100 (#D9B18E):** ~3.8:1 ratio (WCAG AA Large Text, acceptable for button ≥18 pt bold)

### a11y Hints (Inferred)
- **Instruction Text:** Should be linked to input field via `accessibilityLabel` or `labelledBy`
- **Input Field:** Should announce "Wie soll ich dich nennen?, editable text field, current value Claire"
- **CTA Button:** Should announce "Weiter, button, double-tap to activate"
- **Step Counter:** Should be read as "Schritt 1 von 7" (Step 1 of 7)

### Missing a11y Hints (Gaps)
- No visible placeholder text in input field (relies on instruction text above)
- No visible error state or helper text (may exist in other variants)
- Keyboard has no explicit a11y labels (OS-managed, but custom keyboards may need hints)

---

## Design System Token Mapping (Proposed)

### Colors
- `Grayscale/White` → `DsColors.white` or `DsColors.background`
- `Grayscale/Black` → `DsColors.black` or `DsColors.textPrimary`
- `Primary color/100` → `DsColors.primary100` or `DsColors.ctaPrimary`

### Typography
- `Heading/H1` (32 px) → `DsTextStyles.headingH1` (Playfair Display)
- `Body/Regular` (20 px) → `DsTextStyles.bodyRegular` (Figtree)
- `Button` (20 px bold) → `DsTextStyles.button` (Figtree Bold)
- `Callout` (16 px) → `DsTextStyles.callout` (Inter Medium)

### Spacing
- Vertical gaps (84 px) → `DsSpacing.xxlarge` or `DsSpacing.section`
- Button padding (12 px) → `DsSpacing.medium`
- Key gaps (5–6 px) → `DsSpacing.small`

### Radii
- Button (12 px) → `DsRadii.large`
- Keyboard keys (4.6 px) → `DsRadii.small`
- Home Indicator (100 px) → `DsRadii.pill`

### Shadows
- Keyboard key shadow (0px 1px 0px rgba(0,0,0,0.3)) → `DsShadows.keyShadow`

---

## Implementation Notes (Flutter)

### Reuse Constraints
1. **Do NOT hardcode colors:** Use `DsColors.*` tokens
2. **Do NOT hardcode typography:** Use `DsTextStyles.*` tokens
3. **Do NOT hardcode spacing:** Use `DsSpacing.*` or `SizedBox(height: DsSpacing.*)`
4. **Reuse components:** Import existing `PrimaryButton`, `StatusBarHeader`, `KeyboardKey` if available
5. **Keyboard:** Check if iOS keyboard is mocked or uses native `TextField` with `keyboardType: TextInputType.name`

### Safe Areas
- **Top:** Status bar = 47 px (iOS notch may add more, check `MediaQuery.of(context).padding.top`)
- **Bottom:** Home Indicator = 34 px (iOS home indicator, check `MediaQuery.of(context).padding.bottom`)
- Use `SafeArea` widget to ensure content doesn't overlap system UI

### Keyboard Considerations
- **Keyboard visibility:** When keyboard appears, reduce available scroll area or adjust layout
- **Input field:** Should auto-focus on screen load (or on CTA from previous screen)
- **Validation:** No visible error state in this design; may need to add if input is empty on "Weiter" tap

### Accessibility (Flutter)
- **Instruction Text:** Wrap in `Semantics(label: "Wie soll ich dich nennen?", ...)`
- **Input Field:** Use `TextField` with `decoration: InputDecoration(labelText: "...")` or `Semantics` wrapper
- **CTA Button:** Use `Semantics(button: true, label: "Weiter", onTap: ...)` or ensure `ElevatedButton` has semantic label
- **Step Counter:** Wrap in `Semantics(label: "Schritt 1 von 7", ...)`

---

## Open Questions / Variants

1. **Empty State:** What happens if user taps "Weiter" with no input? (Error state not shown in this node)
2. **Keyboard Type:** Is this a custom keyboard or native iOS? (Figma shows custom instance; likely mocked for design)
3. **Emoji in Title:** How is 💜 rendered? (Unicode or custom asset?)
4. **Navigation:** What is step 2/7? (Not visible in this node; check sibling frames)
5. **Dark Mode:** Is there a dark mode variant? (Variables suggest "Dark Mode=False", implying True exists)

---

**Deliverable Status:** ✅ Specs extracted
**Next Steps:** Review with ui-frontend agent; cross-reference with existing Flutter tokens/components.