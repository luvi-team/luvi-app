# ONB_07 Figma Specs – Zyklusregelmäßigkeit

**Node:** `68479:6935` | **Screen:** `07_Onboarding` | **File:** `iQthMdxpCbl6afzXxvzqlt`

---

## 1. Header (Title With Status bar)

### Layout
- **Back-Button**
  - **Visuell:** 40×40 px
  - **Hit-Area:** 44×44 pt (iOS/A11y-Standard erfüllt)
  - **Position:** x=20, y=59
  - **Border-Radius:** 20 px (circle)
  - **BG:** `#D9B18E` (Primary color/100)
  - **Icon:** Arrow left (20×20 px inner, centered)

- **Titel:** „Erzähl mir von dir 💜"
  - **Typo:** Playfair Display / Regular / 24 px / line-height 32 px
  - **Color:** `#030401` (Grayscale/Black)
  - **y-Baseline:** 79 px (gemeinsam mit Step)

- **Step:** „7/7"
  - **Typo:** Inter / Medium / 16 px / line-height 24 px
  - **Color:** `#030401` (Grayscale/Black)
  - **Position:** x=194 rechts von Center, y=79
  - **Alignment:** right, y-baseline shared mit Titel

**Spacing:**
- Status Bar → Header-Baseline: 79 px (absolut von top=0 bei Status-Bar-Höhe=47 px → +32 px gap)

---

## 2. Vertikaler Rhythmus (y-px)

| Element                      | Y-Start | Height | Spacing-To-Next |
|------------------------------|---------|--------|------------------|
| Header (Title Baseline)      | 79      | 32 (lh)| 90 px (to Question) |
| Frage („Wie ist dein Zyklus so?") | 202 | 24     | 90 px (to Card 1) |
| Option 1 (Ziemlich regelmäßig) | 316 | 63     | 24 px (Option-Gap) |
| Option 2 (Eher unberechenbar)  | 403 | 64     | 24 px (Option-Gap) |
| Option 3 (Keine Ahnung)        | 491 | 63     | 90 px (to Footnote) |
| Footnote (Ob Uhrwerk…)         | 645 | 19     | 90 px (to CTA)    |
| CTA („Weiter")                 | 754 | 50     | 90 px (to Home Indicator) |
| Home Indicator                 | 894 | 34     | —               |

**Token-Kandidaten:**
- `rhythm/90` (Header→Frage, Frage→Cards, Footnote→CTA, CTA→Home)
- `rhythm/24` (Option-Gap)

---

## 3. Options-Karten (Single-Select, 3 Stück)

### Gemeinsame Eigenschaften
- **Width:** 261 px (x=83.5 centered in 428 px viewport)
- **Height:** 63–64 px (variiert mit Text-Zeilen)
- **Border-Radius:** 20 px
- **BG-Color:** `#F7F7F8` (Grayscale/100)
- **Padding:** 20 px vertikal, 16 px horizontal
- **Gap (Icon→Text):** 20 px
- **Gap (Text→Radio):** 16 px

### States
**Default (unselected):**
- Border: none (nur BG)
- Radio: Grayscale-Ring (outer), leer (inner)

**Selected:**
- Border: 1 px solid `#1C1411` (token: Grayscale/Black oder custom)
- Radio: Grayscale-Ring (outer), gold fill `#D9B18E` (inner)
  - **Kein** extra schwarzer Ring außen (visuelle Bestätigung: Screenshot zeigt nur 1 px Border am Card-Edge + gold-fill im Radio)

### Karte 1: „Ziemlich regelmäßig"
- **Icon:** clock (24×24 px, node `67067:6761`)
- **Text:** Figtree / Regular / 16 px / lh 24 px
  - Zeilenumbruch: nein (single-line)
- **Radio:** 24×24 px (selected state gold-fill)

### Karte 2: „Eher unberechenbar"
- **Icon:** energy (24×24 px, node `67067:7059`)
- **Text:** Figtree / Regular / 16 px / lh 24 px
  - Zeilenumbruch: nein (single-line)
- **Radio:** 24×24 px (unselected)

### Karte 3: „Keine Ahnung"
- **Icon:** Help (24×24 px, node `67067:7060`)
- **Text:** Figtree / Regular / 16 px / lh 24 px
  - Zeilenumbruch: nein, aber Figma-Data zeigt whitespace padding (nicht relevant für echten Text)
- **Radio:** 24×24 px (unselected)

---

## 4. Footnote/Callout

**Text:** „Ob Uhrwerk oder Chaos - ich verstehe beides!"
- **Typo:** Figtree / Italic / 16 px / lh 24 px
  - **Token:** `Regular klein kursiv` (Custom-Name)
- **Color:** `#000000` (black, abweichend von Grayscale/Black #030401 – likely Figma-Default)
- **Width:** 363 px
- **Height:** 19 px (single-line)
- **Box:** nein (nur Text, kein BG/Border)
- **Position:** x=32.5, y=645 (centered horizontal)

---

## 5. CTA („Weiter")

- **Maße:** 388×50 px
- **Border-Radius:** 12 px
- **BG-Color:** `#D9B18E` (Primary color/100)
- **Label:** „Weiter"
  - **Typo:** Figtree / Bold / 20 px / lh 24 px
  - **Token:** `Button`
  - **Color:** `#FFFFFF` (white)
- **Padding:** 12 px horizontal, 11 px top, 12 px bottom
- **Position:** x=20, y=754

**Disabled-Zustand:**
- Figma zeigt nur Default-State (gold BG, white Text)
- **Spec-Annahme:** Disabled = BG blasser (z.B. `#F7F7F8` oder 50% opacity) + Text `#999` – **Keine Figma-Spec vorhanden → UI-Implementation muss definieren**

---

## 6. Tokens (Farben/Typo/Radii)

### Farben
| Token                  | Hex       | Usage                                      |
|------------------------|-----------|--------------------------------------------|
| `Grayscale/White`      | #FFFFFF   | BG (Screen), CTA-Label                     |
| `Grayscale/Black`      | #030401   | Titel, Step, Frage, Option-Text, Card-Border (selected) |
| `Grayscale/100`        | #F7F7F8   | Option-Cards BG                            |
| `Primary color/100`    | #D9B18E   | Back-Button BG, CTA BG, Radio-fill (selected) |

### Typografie
| Token                 | Family       | Style   | Size | Weight | Line-Height |
|-----------------------|--------------|---------|------|--------|-------------|
| `Playfair Display`    | Playfair Display | Regular | 24   | 400    | 32          |
| `Body/Regular`        | Figtree      | Regular | 20   | 400    | 24          |
| `Regular klein`       | Figtree      | Regular | 16   | 400    | 24          |
| `Regular klein kursiv`| Figtree      | Italic  | 16   | 400    | 24          |
| `Button`              | Figtree      | Bold    | 20   | 700    | 24          |
| `Callout` (Step)      | Inter        | Medium  | 16   | 500    | 24          |

### Radii
| Token           | Value | Usage                          |
|-----------------|-------|--------------------------------|
| `radius/20`     | 20 px | Option-Cards, Back-Button      |
| `radius/12`     | 12 px | CTA                            |

---

## 7. A11y (Accessibility)

### Semantics
- **Header:**
  - Back-Button: `Button` (Tap-Target 44×44 pt ✅)
  - Titel: `Heading` (level 1)
  - Step: `Text` (decorative, could be `Accessibility.ignored`)

- **Frage:**
  - `Heading` (level 2) or `Text` (Screen-Question context)

- **Options:**
  - **RadioGroup** (semantics parent)
    - **Radio 1:** „Ziemlich regelmäßig" (value: `regular`)
    - **Radio 2:** „Eher unberechenbar" (value: `unpredictable`)
    - **Radio 3:** „Keine Ahnung" (value: `unknown`)
  - Each: `Radio` (focusable, activatable)

- **Footnote:**
  - `Text` (non-interactive)

- **CTA:**
  - `Button` (label: „Weiter", disabled until selection)
  - Tap-Target: 388×50 px ≈ 97×50 pt @ 4x → **50 pt height ✅ exceeds 44 pt**

### Contrast & Focus
- Text-on-BG: `#030401` on `#FFFFFF` → **21:1 (AAA)**
- Text-on-Card: `#030401` on `#F7F7F8` → **~20:1 (AAA)**
- CTA: `#FFFFFF` on `#D9B18E` → **~3.5:1 (AA Large)**
- Focus-Indicators: Native platform (iOS: blue ring, Android: teal)

---

## Notes

1. **Card-Border Selected:** Only 1 px solid `#1C1411` at card-edge (no extra black ring on radio – gold-fill inner is sufficient).
2. **Footnote Color Discrepancy:** Figma shows `#000000` (black) vs. token `Grayscale/Black` (#030401) – likely Figma default, should use token in code.
3. **Disabled CTA State:** Not specified in Figma → implementation must define (suggested: 50% opacity or `Grayscale/100` BG + `#999` text).
4. **Spacing Tokens:** `rhythm/90` (4× usage), `rhythm/24` (Option-Gap) should be codified in `lib/core/tokens/spacing.dart`.

---

**Generated:** 2025-10-01
**Auditor:** Claude Code (ui-frontend)
**Status:** ✅ Specs Complete (No Code Changes)
