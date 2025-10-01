# ONB_06 Figma Specs
**Screen:** 06_Onboarding ("Wie lange dauert dein Zyklus normalerweise?")
**Figma Node:** 68256:6510
**Date:** 2025-10-01

---

## 1) Header

### Layout
- **Back button**
  - Position: x=20, y=59
  - Visual size: 40×40px
  - Hit-area requirement: **44×44pt minimum** (Material minInteractiveDimension)
  - Icon: Arrow left (black)

- **Title**
  - Text: "Erzähl mir von dir 💜"
  - Position: y=79 (center baseline)
  - Typography: Playfair Display Regular 24/32
  - Color: Grayscale/Black (#030401)
  - Alignment: Center

- **Step indicator**
  - Text: "6/7"
  - Position: y=79 (same baseline as title)
  - Typography: Inter Medium 16/24
  - Color: Grayscale/Black (#030401)
  - Alignment: Right (x=194 from center)

- **Common baseline:** y=79 for title and step indicator

---

## 2) Vertical Spacing (px)

| From                  | To                     | Distance |
|-----------------------|------------------------|----------|
| Header bottom         | Question top           | **48**   |
| Question bottom       | Option list top        | **48**   |
| Option gap            | Between cards          | **24**   |
| Option list bottom    | Callout top            | **48**   |
| Callout bottom        | CTA top                | **48**   |
| CTA bottom            | HomeIndicator top      | **48**   |

**Note:** Consistent 48px rhythm for major sections; 24px gap between option cards.

---

## 3) Options-Karten (Single-Select)

### Dimensions
- Width: 340px
- Height: 63–64px (slight variance due to text wrapping)

### Border & Styling
- **Corner radius:** 20px
- **Default state:**
  - Background: Grayscale/100 (#F7F7F8)
  - Border: None
- **Selected state:**
  - Background: Grayscale/100 (#F7F7F8)
  - Border: 1px solid #1C1411

### Inner Layout
- **Padding:** 16px horizontal, 20px vertical
- **Content:** Text (left-aligned) + Radio button (right-aligned, 24×24px)

### Typography
- Font: Regular klein (Figtree Regular 16/24)
- Color: Grayscale/Black (#030401)
- Max lines: Single line expected; text wraps naturally if needed

### Radio Visual (24×24px)
- **Unselected:** Empty circle (gray outline)
- **Selected:** Gold filled circle (Primary color/100 #D9B18E inner dot visible)
- **Note:** No additional black outer ring in selected state

### Single-Select Confirmation
- **Confirmed:** Only one option can be selected at a time (radio behavior)

---

## 4) Callout/Footnote

- **Text:** "Jeder Zyklus ist einzigartig - wie du auch!"
- **Style:** Regular klein kursiv (Figtree Italic 16/24), color=#000000
- **Box:** None (no background, no border)
- **Dimensions:** x=62, y=718, w=304, h=30
- **Spacing:** 48px below option list, 48px above CTA

---

## 5) CTA (Call-to-Action)

- **Dimensions:** 388×50px
- **Corner radius:** 12px
- **Label:** "Weiter"
- **Typography:** Button (Figtree Bold 20/24), color=white
- **Background:** Primary color/100 (#D9B18E)
- **Disabled state:** Not specified in Figma; only enabled state visible

**Note:** Disabled state styling should be defined in code (e.g., opacity or alternate color).

---

## 6) Tokens (Figma Variables)

### Colors
| Token                | Hex       |
|----------------------|-----------|
| Grayscale/White      | #FFFFFF   |
| Grayscale/Black      | #030401   |
| Grayscale/100        | #F7F7F8   |
| Primary color/100    | #D9B18E   |

### Typography
| Token                | Spec                                |
|----------------------|-------------------------------------|
| Button               | Figtree Bold 20/24                  |
| Body/Regular         | Figtree Regular 20/24               |
| Regular klein        | Figtree Regular 16/24               |
| Regular klein kursiv | Figtree Italic 16/24                |
| Callout              | Inter Medium 16/24                  |

### Radii
| Element              | Radius |
|----------------------|--------|
| Option cards         | 20px   |
| CTA button           | 12px   |

---

## 7) A11y (Accessibility)

### Semantics
- **Header:**
  - Back button: IconButton (Semantics hint: "Navigate back")
  - Title: Text (Semantics label: "Tell me about yourself")
  - Step: Text (Semantics label: "Step 6 of 7")

- **Question:**
  - Heading (Semantics label: "How long does your cycle normally last?")

- **RadioGroup:**
  - Single-select group (5 options)
  - Each option: RadioListTile (label + radio state)

- **Callout:**
  - ExcludeSemantics or decorative Text (non-interactive)

- **CTA:**
  - ElevatedButton (Semantics label: "Next", enabled state)

### Tap-Targets (≥44pt)
| Element              | Size     | Status    |
|----------------------|----------|-----------|
| Back button          | 40×40    | ⚠️ Needs 44×44 hit-area (Material minInteractiveDimension) |
| Radio cards          | 340×63–64 | ✅ OK      |
| CTA button           | 388×50   | ✅ OK      |

**Note:** Back button visual is 40×40, but Flutter Material requires 44pt minimum interactive area. Use `visualDensity: VisualDensity.compact` + padding to expand hit-area without altering visual size.

---

## Implementation Notes

1. **Back button hit-area:** Wrap in `SizedBox(width: 44, height: 44)` or use Material's `IconButton.visualDensity`.
2. **Radio states:** Implement custom radio indicator with gold fill for selected state (no default Material radio style).
3. **Disabled CTA:** Define disabled state in code (e.g., 50% opacity or gray background).
4. **Single-select logic:** Use `RadioListTile` or custom `GestureDetector` with state management.
5. **Callout:** Use `Text` with `ExcludeSemantics(excluding: true)` to hide from screen readers.

---

**Audit completed:** 2025-10-01
**Auditor:** Claude Code (qa-dsgvo)
