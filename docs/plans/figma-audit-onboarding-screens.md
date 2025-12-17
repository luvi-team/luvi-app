# Figma Audit: LUVI Onboarding Screens

**Generated:** 2025-12-16
**Figma File:** Nova-Health-UI-Working-Copy
**Agent:** Claude Code

---

## Design System Variables

### Colors

| Variable Name | Figma Hex | Code Token | Status |
|--------------|-----------|------------|--------|
| signature | `#9F2B68` | `DsColors.signature` | ✅ Match |
| Grayscale/Black | `#030401` | `DsColors.grayscaleBlack` | ✅ Match |
| Grayscale/White | `#FFFFFF` | `DsColors.grayscaleWhite` | ✅ Match |
| Secondary color/100 | `#1C1411` | `DsColors.secondaryDark` | ✅ Match |
| Gold Medium | `#D4B896` | `DsColors.goldMedium` / `authGradientBase` | ✅ Match |
| Gold Light | `#EDE1D3` | `DsColors.goldLight` / `authGradientLight` | ✅ Match |
| Button Primary | `#A8406F` | `DsColors.buttonPrimary` | ⚠️ Figma shows `#9F2B68` for button |
| Gray weekday header | `#99A1AF` | [NOT_FOUND] | ❌ Missing Token |
| Today label | `#6A7282` | [NOT_FOUND] | ❌ Missing Token |
| Period glow (radial) | `rgba(255,100,130,0.6)` | [NOT_FOUND] | ❌ Missing Token |

### Typography Styles

| Style Name | Font Family | Size | Weight | Line Height | Code Match |
|------------|-------------|------|--------|-------------|------------|
| Heading/H1 | Playfair Display | 32px | 400 | 40px | ✅ `TypographyTokens.size32`, `lineHeightRatio40on32` |
| Heading 2 | Playfair Display | 24px | 400 | 32px | ✅ `TypographyTokens.size24`, `lineHeightRatio32on24` |
| Button | Figtree | 20px | 700 | 24px | ✅ `TypographyTokens.size20`, `lineHeightRatio24on20` |
| Body/Regular | Figtree | 20px | 400 | 24px | ✅ Partial match |
| Regular klein | Figtree | 16px | 400 | 24px | ✅ `TypographyTokens.size16` |
| Regular 12 | Figtree | 12px | 400 | 15px | ✅ `TypographyTokens.size12` |
| Calendar Day | Inter | 15px | 400 | 22.5px | ⚠️ No exact token |
| Calendar Weekday | Inter | 11px | 400 | 16.5px | ❌ Missing size token |
| Calendar Month | Figtree | 16px | 400 | 24px | ✅ Match |

### Spacing Scale

| Token | Figma Value | Code Token | Status |
|-------|-------------|------------|--------|
| Screen Padding | 20px | `OnboardingSpacing.horizontalPadding` (20) | ✅ Match |
| Card Gap | 24px | `OnboardingSpacing.cardGap` (24) | ✅ Match |
| Option Gap | 24px | `OnboardingSpacing.optionGap05/06/07` (24) | ✅ Match |
| Pills Gap | 9px | `OnboardingSpacing.pillsGap03` (16) | ❌ Mismatch |
| Button Padding H | 40px | [NOT_FOUND] | ❌ Missing |
| Button Padding V | 16px | [NOT_FOUND] | ❌ Missing |
| Progress Bar Height | 18px | [NOT_FOUND] | ❌ Missing |
| Input Field Height | 88px | [NOT_FOUND] | ❌ Missing |

---

## Screen O1: Name Input

**Node-ID:** `68919:8593`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68919-8593&m=dev

### Frame

```yaml
frame:
  name: "Container"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    angle: 180
    stops:
      - position: 0.18369
        color: "#D4B896"
      - position: 0.50332
        color: "#EDE1D3"
      - position: 0.74466
        color: "#D4B896"
```

### Component Tree

#### 1. Status Bar
```yaml
status_bar:
  position:
    x: 32
    y: 0
  height: 40
  time:
    text: "9:41"
    font: Inter Regular 16px
    color: "#0A0A0A"
```

#### 2. Back Arrow
```yaml
back_arrow:
  position:
    x: 0
    y: 30
  size:
    width: 64
    height: 52
  touch_target: 64x52
  icon_color: "#030401"
```

#### 3. Progress Bar
```yaml
progress_bar:
  position:
    y: 54
    x_center: true
  container:
    width: 307
    height: 18
    background: "#FFFFFF"
    border:
      color: "#000000"
      width: 1
    corner_radius: 40
  fill:
    width: 104  # ~33% for step 1/6
    color: "#9F2B68" (signature)
    corner_radius: 40
  label:
    text: "Frage 1 von 6"
    position_below: true
    margin_top: 23
    font: Inter Regular 16px
    color: "#000000"
```

#### 4. Headline
```yaml
headline:
  position:
    y: 193
    x_center: true
  text:
    line1: "Willkommen!"
    line2: "Wie dürfen wir dich nennen?"
  font:
    family: "Playfair Display"
    style: Regular
    size: 24
    line_height: 32
  color: "#000000"
  alignment: center
```

#### 5. Input Field
```yaml
input_field:
  position:
    y: 361  # calc from top
    x_center: true
  container:
    width: 340
    height: 88
    background: "rgba(255,255,255,0.1)"
    corner_radius: 16
  text_input:
    placeholder_text: "Anna"  # shown as example
    font:
      family: "Playfair Display"
      style: Regular
      size: 32
      line_height: 40
    color: "#030401"
    alignment: center
  cursor:
    visible: true
    position: after_text
```

#### 6. Primary Button
```yaml
primary_button:
  position:
    y: 469
    x_center: true
  container:
    width: auto (hug)
    height: 56
    background: "#9F2B68" (signature)
    corner_radius: 40
    padding:
      horizontal: 40
      vertical: 16
  text:
    content: "Weiter"
    font:
      family: "Figtree"
      style: Bold
      size: 20
      line_height: 24
    color: "#FFFFFF"
```

#### 7. Keyboard (iOS Default)
```yaml
keyboard:
  position:
    y: 582
    x: -6
  size:
    width: 403
    height: 270
  background: "#D1D3D9"
  backdrop_blur: 54.366
  key_background: "#FFFFFF"
  key_corner_radius: 4.6
  key_font:
    family: "Playfair Display"
    size: 22
    line_height: 28
```

---

## Screen O2: Geburtsdatum

**Node-ID:** `68915:9213`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68915-9213&m=dev

### Frame

```yaml
frame:
  name: "02_Onboarding"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    angle: 179.725
    stops:
      - position: 0.24962
        color: "#EDE1D3"
      - position: 0.70226
        color: "#D4B896"
```

### Component Tree

#### 1. Progress Bar
```yaml
progress_bar:
  fill_width: 133  # ~43% for step 2/6
  label: "Frage 2 von 6"
```

#### 2. Headline
```yaml
headline:
  text:
    line1: "Hey Anna,"
    line2: "wann hast du Geburtstag?"
  font: Playfair Display Regular 24px/32px
  color: "#010100"
```

#### 3. Subtitle
```yaml
subtitle:
  text:
    line1: "Dein Alter hilft uns, deine hormonelle"
    line2: "Phase besser einzuschätzen."
  font: Figtree Regular 16px/24px
  color: "#030401"
  position:
    y: 272
    x_center: true
```

#### 4. Date Picker
```yaml
date_picker:
  position:
    y: 398  # center vertically
    x_center: true
  container:
    width: 333
    height: 280
    background: "rgba(0,0,0,0)"  # transparent
    corner_radius: 16
  selected_row:
    background: "#F5F5F5"
    height: 56
    corner_radius: 14
    position_y: 112
  columns:
    - type: month
      width: 104.328
      items: ["Februar", "März", "April", "Mai", "Juni"]
    - type: day
      width: 104.328
      items: ["7", "8", "9", "10", "11"]
    - type: year
      width: 104.344
      items: ["2021", "2022", "2023", "2024", "2025"]
  text_styles:
    unselected:
      font: Arimo Regular 16px/24px
      color: "#171515"
    selected:
      font: Arimo Regular 16px/24px
      color: "#000000"
  row_height: 44  # 32px text + 12px gap
  visible_rows: 5
```

---

## Screen O3: Fitness Level

**Node-ID:** `69020:1429`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=69020-1429&m=dev

### Frame

```yaml
frame:
  name: "Container"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    angle: 180
    stops:
      - position: 0.18369
        color: "#D4B896"
      - position: 0.40569
        color: "#EDE1D3"
      - position: 0.74466
        color: "#D4B896"
```

### Component Tree

#### 1. Progress Bar
```yaml
progress_bar:
  fill_width: 137  # ~45% for step 3/6
  label: "Frage 3 von 6"
```

#### 2. Headline
```yaml
headline:
  text: "Anna, wie fit fühlst du dich?"
  font: Playfair Display Regular 24px/32px
  color: "#000000"
  position:
    y: 202.5
    x_center: true
  width: 276
```

#### 3. Subtitle
```yaml
subtitle:
  text: "Damit wir die Intensität passend wählen."
  font: Figtree Regular 16px/24px
  color: "#000000"
  position:
    y: 262
    x_center: true
  width: 288
```

#### 4. Fitness Pills
```yaml
fitness_pills:
  layout:
    direction: horizontal
    gap: 9
  position:
    y: 326  # center: 50% - 88px
    x_center: true
  pill:
    width: 114
    height: 58
    corner_radius: 16
    normal_state:
      background: "rgba(0,0,0,0)"  # transparent
      border: none
      text:
        font: Figtree Regular 20px/24px
        color: "#000000"
    selected_state:
      background: [NOT_IN_FIGMA_CONTEXT]
      border: [NEEDS_VERIFICATION]
  items:
    - text: "Nicht fit"
      db_key: "beginner"
    - text: "Fit"
      db_key: "occasional"
    - text: "Sehr fit"
      db_key: "fit"
```

---

## Screen O4: Ziele

**Node-ID:** `69023:9463`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=69023-9463&m=dev

### Frame

```yaml
frame:
  name: "Container"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    stops:
      - position: 0.13073
        color: "#D4B896"
      - position: 0.34508
        color: "#EDE1D3"
      - position: 0.66118
        color: "#EDE1D3"
      - position: 0.79683
        color: "#D4B896"
```

### Component Tree

#### 1. Progress Bar
```yaml
progress_bar:
  fill_width: 162  # ~53% for step 4/6
  label: "Frage 4 von 6"
```

#### 2. Headline
```yaml
headline:
  text: "Was sind deine Ziele?"
  font: Playfair Display Regular 24px/32px
  color: "#1E2939"
  position:
    y: 188.5
    x_center: true
```

#### 3. Subtitle
```yaml
subtitle:
  text: "Du kannst mehrere auswählen."
  font: Figtree Regular 16px/24px
  color: "#000000"
  position:
    y: 234.5
    x_center: true
```

#### 4. Goal Cards
```yaml
goal_cards:
  layout:
    direction: vertical
    gap: 24
  position:
    y: 360  # center: 50% + 17.5px
    x_center: true
  width: 346
  card:
    height: auto (hug)
    corner_radius: 33554400  # pill shape
    padding:
      left: 16
      right: 18
      vertical: 5
    normal_state:
      background: "rgba(0,0,0,0)"
    selected_state:
      background: [NEEDS_VERIFICATION]
    icon:
      size: 24
      color: "#0A0A0A"
      position:
        left: 16
    text:
      font: Inter Medium 16px/24px
      color: "#0A0A0A"
      letter_spacing: -0.3125
      margin_left: 16  # gap from icon
  items:
    - text: "Fitter & stärker werden"
      icon: "ic/Muscel"
      db_key: "fitter"
    - text: "Mehr Energie im Alltag"
      icon: "ic/Kcal"
      db_key: "energy"
    - text: "Besser schlafen und Stress reduzieren"
      icon: "ic/explore"
      db_key: "sleep_stress"
    - text: "Zyklus & Hormone verstehen"
      icon: "ic/Calander"
      db_key: "cycle_hormones"
    - text: "Langfristige Gesundheit und Longevity"
      icon: "ic/Run"
      db_key: "longevity"
    - text: "Mich einfach wohlfühlen"
      icon: "ic/emoji"
      db_key: "wellbeing"
```

---

## Screen O5: Interessen

**Node-ID:** `68919:8474`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68919-8474&m=dev

### Frame

```yaml
frame:
  name: "02_Onboarding"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    stops:
      - position: 0.21906
        color: "#D4B896"
      - position: 0.27673
        color: "#DFCBB2"
      - position: 0.34721
        color: "#EDE1D3"
      - position: 0.65691
        color: "#EDE1D3"
      - position: 0.71671
        color: "#E1CDB5"
      - position: 0.79043
        color: "#D4B896"
```

### Component Tree

#### 1. Progress Bar
```yaml
progress_bar:
  fill_width: 195  # ~64% for step 5/6
  label: "Frage 5 von 6"
```

#### 2. Headline
```yaml
headline:
  text: "Was interessiert dich?"
  font: Playfair Display Regular 24px/32px
  color: "#000000"
  position:
    y: 190
    x_center: true
```

#### 3. Subtitle
```yaml
subtitle:
  text: "Wähle 3–5, damit dein Feed direkt passt."
  font: Figtree Regular 16px/24px
  color: "#000000"
  position:
    y: 236
    x_center: true
```

#### 4. Interest Pills
```yaml
interest_pills:
  layout:
    direction: vertical
    gap: 24
  position:
    y: 426  # center: 50% + 18px
    x_center: true
  width: 309
  pill:
    width: fill
    height: 34
    corner_radius: 33554400  # pill shape
    padding:
      horizontal: 19
      vertical: 8
    normal_state:
      background: "rgba(0,0,0,0)"
      text:
        font: Inter Medium 16px/24px
        color: "#0A0A0A"
        letter_spacing: -0.3125
  items:
    - text: "Krafttraining & Muskelaufbau"
      db_key: "strength_training"
    - text: "Cardio & Ausdauer"
      db_key: "cardio"
    - text: "Beweglichkeit und Mobilität"
      db_key: "mobility"
    - text: "Ernährung & Supplements"
      db_key: "nutrition"
    - text: "Achtsamkeit & Regeneration"
      db_key: "mindfulness"
    - text: "Horrmone & Zyklus"  # Note: typo in Figma "Horrmone"
      db_key: "hormones_cycle"
```

---

## Screen O6: Zyklus Intro

**Node-ID:** `68920:9390`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68920-9390&m=dev

### Frame

```yaml
frame:
  name: "Container"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    stops:
      - position: 0.21479
        color: "#D4B896"
      - position: 0.37285
        color: "#EDE1D3"
      - position: 0.54288
        color: "#EDE1D3"
      - position: 0.81449
        color: "#D4B896"
```

### Component Tree

#### 1. Progress Bar
```yaml
progress_bar:
  fill_width: 227  # ~74% for step 6/6
  label: "Frage 6 von 6"
  # Note: uses --color variable instead of --signature
```

#### 2. Headline
```yaml
headline:
  text: "Damit LUVI für dich passt, brauchen wir noch deinen Zyklusstart."
  font: Playfair Display Regular 24px/32px
  color: "#0A0A0A"
  position:
    y: 174
    x_center: true
  width: 297
  line_count: 3
```

#### 3. Calendar Mini Widget
```yaml
calendar_mini:
  position:
    y: 380  # center: 50% + 26.25px
    x_center: true
  container:
    width: 321
    height: 312.5
    background: "rgba(255,255,255,0.1)"
    corner_radius: 24
    padding:
      top: 24
      horizontal: 24
  weekday_header:
    labels: ["M", "D", "M", "D", "F", "S", "S"]
    font: Inter Regular 11px/16.5px
    color: "#99A1AF"
    letter_spacing: 0.0645
    cell_width: 32.141
  day_grid:
    cell_size: 32
    gap: 8  # implicit from layout
    rows: 5
    columns: 7
  day_cell:
    normal:
      font: Inter Regular 15px/22.5px
      color: "#0A0A0A"
      letter_spacing: -0.2344
    weekend:
      font: Inter Regular 15px/22.5px
      color: "#9F2B68" (signature)  # Sa/So in magenta
  period_indicator:
    position:
      day: 25
    outer_glow:
      diameter: 120
      gradient:
        type: radial
        stops:
          - position: 0
            color: "rgba(255,100,130,0.6)"
          - position: 0.7
            color: "rgba(255,100,130,0.1)"
          - position: 1
            color: "rgba(0,0,0,0)"
    inner_circle:
      diameter: 48
      background: "#FFFFFF"
      shadow:
        - offset_x: 0
          offset_y: 10
          blur: 15
          spread: -3
          color: "rgba(0,0,0,0.1)"
        - offset_x: 0
          offset_y: 4
          blur: 6
          spread: -4
          color: "rgba(0,0,0,0.1)"
      text:
        content: "25"
        font: Inter Regular 20px/30px
        color: "#9F2B68" (signature)
        letter_spacing: -0.4492
```

#### 4. Primary Button
```yaml
primary_button:
  text: "Okay, los"
  # otherwise same as O1
```

---

## Screen O7: Periode Start

**Node-ID:** `68920:9976`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68920-9976&m=dev

### Frame

```yaml
frame:
  name: "Container"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    stops:
      - position: 0.1743
        color: "#D4B896"
      - position: 0.27582
        color: "#EDE1D3"
      - position: 0.59254
        color: "#D4B896"
      - position: 0.74448
        color: "#EDE1D3"
      - position: 0.85387
        color: "#D4B896"
```

### Component Tree

#### 1. Header Text
```yaml
header:
  text: "Tippe auf den Tag, an dem deine letzte Periode begann."
  font: Figtree Regular 20px/24px
  color: "#1C1411"
  position:
    y: 54
    x_center: true
  width: 282
```

#### 2. Period Calendar Full
```yaml
period_calendar:
  position:
    y: 147
    x_center: true
  container:
    width: 353
    height: 612
    background: "rgba(255,255,255,0.3)"
    corner_radius: 40
    padding:
      top: 16
      horizontal: 8
  months:
    - name: "November"
      font: Figtree Regular 16px/24px
      color: "#0A0A0A"
    - name: "Dezember"
      font: Figtree Regular 16px/24px
      color: "#0A0A0A"
  weekday_header:
    labels: ["M", "D", "M", "D", "F", "S", "S"]
    font: Inter Regular 14px/20px
    color: "#99A1AF"
    letter_spacing: -0.1504
  day_cell:
    size: 39  # grid cell
    normal:
      font: Inter Medium 16px/24px
      color: "#0A0A0A" or "#000000"
      letter_spacing: -0.3125
    period_day:
      border:
        color: "#9F2B68" (signature)
        width: 2
        style: solid
        radius: 33554400  # full circle
      text_color: "#9F2B68" (signature)
    today:
      label:
        text: "HEUTE"
        font: Inter Regular 12px/16px
        color: "#6A7282"
        position: below_date
        margin_top: 3
  grid_gap: 8
```

#### 3. Checkbox Option
```yaml
checkbox:
  position:
    y: 759
    x_center: true
  container:
    height: 77
    width: 369
    corner_radius: 10
    padding:
      horizontal: 0
      vertical: 12
  checkbox_circle:
    size: 24
    border:
      color: "#9F2B68" (signature)
      width: 2
    unchecked_fill: transparent
    checked_fill: "#9F2B68"
  label:
    text: "Ich weiß es nicht mehr"
    font: Figtree Regular 16px/24px
    color: "#000000"
    margin_left: 12
```

---

## Screen O8: Periode Dauer

**Node-ID:** `68920:10544`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68920-10544&m=dev

### Frame

```yaml
frame:
  # Same gradient as O7
```

### Component Tree

#### 1. Header Text
```yaml
header:
  text: "Wir haben die Dauer geschätzt. Tippe auf den Tag, um anzupassen."
  font: Figtree Regular 20px/24px
  color: "#1C1411"
  position:
    y: 57
    x_center: true
  width: 316
```

#### 2. Period Calendar
```yaml
# Same as O7 but with pre-selected period days (1-7)
```

#### 3. Primary Button
```yaml
primary_button:
  position:
    y: 757
  text: "Weiter"
```

---

## Screen O9: Success

**Node-ID:** `68921:11072`
**Figma URL:** https://www.figma.com/design/iQthMdxpCbl6afzXxvzqlt/Nova-Health-UI-Working-Copy?node-id=68921-11072&m=dev

### Frame

```yaml
frame:
  name: "Container"
  width: 393
  height: 852
  background:
    type: gradient
    gradient_type: linear
    angle: 179.379
    stops:
      - position: 0.043161
        color: "#A8406F"  # signature variant
      - position: 0.23097
        color: "#A8406F"
      - position: 0.51784
        color: "#D4B896"
      - position: 0.63356
        color: "#DAC2A5"
      - position: 0.86138
        color: "#E7D7C4"
      - position: 0.97571
        color: "#EDE1D3"
```

### Component Tree

#### 1. Content Cards
```yaml
content_cards:
  card_1:  # Large, top left
    position:
      x: 66
      y: 81
    size:
      width: 150
      height: 183
    corner_radius: 16
    background: "rgba(233,213,255,0.2)"
    image:
      position:
        x: 29
        y: 4
      size:
        width: 92
        height: 127
      corner_radius: 16
    text:
      content: "Brauche ich mehr Eisen während meiner Blutung?"
      position:
        y: 134
        x_center: true
      font: Figtree Regular 12px/16px
      color: "#0A0A0A"
      alignment: center
      width: 136
  card_2:  # Small, top right
    position:
      x: 227
      y: 210
    size:
      width: 140
      height: 120
    corner_radius: 16
    background: "rgba(207,250,254,0.2)"
    image:
      size:
        width: 46
        height: 90
    text:
      content: "Wie trainiere ich während meiner Ovulation?"
      font: Figtree Regular 12px/15px
      color: "#0A0A0A"
  card_3:  # Small, bottom left
    position:
      x: 79
      y: 282
    size:
      width: 133
      height: 114
    corner_radius: 16
    background: "rgba(252,231,243,0.2)"
    text:
      content: "Wie kann ich meinen Stress reduzieren?"
      font: Figtree Regular 12px/16px
      color: "#0A0A0A"
      alignment: right
```

#### 2. Progress Ring
```yaml
progress_ring:
  position:
    x: 94  # 39 + 55
    y: 455  # 363 + 92
    x_center: true
  outer_diameter: 200
  stroke_width: 6.67  # derived from 3.33% inset
  background_ring:
    color: "rgba(237,225,211,0.5)"  # approximate from vector
  progress_ring:
    color: "#9F2B68" (signature)
    progress: 25%
  center_text:
    content: "25%"
    font: Figtree Regular 30px/36px
    color: "#0A0A0A"
    letter_spacing: 0.3955
```

#### 3. Loading Text
```yaml
loading_text:
  text: "Wir stellen deine Pläne zusammen…"
  font: Inter Regular 16px/24px
  color: "#0A0A0A"
  letter_spacing: -0.3125
  position:
    y: 683  # bottom of container
    x_center: true
```

---

## Token Mapping: Figma ↔ Code

### Colors Mapping

| Figma Token | Figma Value | Code Token | Code Value | Match |
|-------------|-------------|------------|------------|-------|
| --signature | `#9F2B68` | `DsColors.signature` | `0xFF9F2B68` | ✅ |
| --color | `#9F2B68` | `DsColors.signature` | `0xFF9F2B68` | ✅ |
| Grayscale/Black | `#030401` | `DsColors.grayscaleBlack` | `0xFF030401` | ✅ |
| Gold Medium | `#D4B896` | `DsColors.goldMedium` | `0xFFD4B896` | ✅ |
| Gold Light | `#EDE1D3` | `DsColors.goldLight` | `0xFFEDE1D3` | ✅ |
| Secondary/100 | `#1C1411` | `DsColors.secondaryDark` | `0xFF1C1411` | ✅ |
| Button BG | `#9F2B68` | `DsColors.buttonPrimary` | `0xFFA8406F` | ⚠️ Mismatch |
| Gray 99A1AF | `#99A1AF` | - | - | ❌ Missing |
| Gray 6A7282 | `#6A7282` | - | - | ❌ Missing |

### Typography Mapping

| Figma Style | Code Token | Match |
|-------------|------------|-------|
| H1 32/40 Playfair | `AuthTypography.headlineFontSize` | ✅ |
| H2 24/32 Playfair | `AuthTypography.titleFontSize` | ✅ |
| Button 20/24 Figtree Bold | `TypographyTokens.size20` | ✅ |
| Body 16/24 Figtree | `TypographyTokens.size16` | ✅ |
| Small 12/15 Figtree | `TypographyTokens.size12` | ✅ |

### Gradient Mapping

| Figma Gradient | Code Token | Match |
|----------------|------------|-------|
| Onboarding Standard | `DsGradients.onboardingStandard` | ⚠️ Stops differ |
| Success Screen | `DsGradients.successScreen` | ⚠️ Colors differ |

---

## Identified Gaps

### Missing Color Tokens

1. `#99A1AF` - Calendar weekday header gray
2. `#6A7282` - Today label gray
3. `rgba(255,100,130,0.6)` - Period glow pink
4. `#F5F5F5` - Date picker selected row

### Missing Typography Tokens

1. Inter 11px/16.5px - Calendar mini weekday
2. Inter 14px/20px - Calendar full weekday
3. Inter 15px/22.5px - Calendar day
4. Arimo 16px/24px - Date picker (need font import?)

### Missing Spacing Tokens

1. Button padding horizontal: 40px
2. Button padding vertical: 16px
3. Progress bar height: 18px
4. Input field height: 88px
5. Fitness pills gap: 9px (code has 16px)

### Gradient Discrepancies

1. O1/O3: Code has 3 stops, Figma shows same pattern but may differ slightly
2. O9: Figma has 6 stops, code `successScreen` has 3 stops

---

## Recommendations

### High Priority

1. **Add missing gray tokens:**
   ```dart
   static const Color calendarWeekdayGray = Color(0xFF99A1AF);
   static const Color todayLabelGray = Color(0xFF6A7282);
   ```

2. **Fix button background color discrepancy:**
   - Figma uses `#9F2B68` for primary buttons
   - Code uses `#A8406F` for `buttonPrimary`
   - Recommend aligning to `signature` color

3. **Add period glow color:**
   ```dart
   static const Color periodGlowPink = Color(0x99FF6482); // 60% opacity
   ```

### Medium Priority

4. **Add calendar typography tokens:**
   ```dart
   static const double calendarWeekdaySize = 11.0;
   static const double calendarDaySize = 15.0;
   ```

5. **Fix fitness pills gap:**
   - Change `_pillsGap03` from 16.0 to 9.0

6. **Add button padding tokens:**
   ```dart
   static const double buttonPaddingH = 40.0;
   static const double buttonPaddingV = 16.0;
   ```

### Low Priority

7. Review gradient stop positions for exact match
8. Consider adding Arimo font or using Inter as substitute

---

## Appendix: Screenshots Reference

All 9 screens have been visually verified via `mcp__figma__get_screenshot`:

- O1: Name Input - ✅ Captured
- O2: Geburtsdatum - ✅ Captured
- O3: Fitness Level - ✅ Captured
- O4: Ziele - ✅ Captured
- O5: Interessen - ✅ Captured
- O6: Zyklus Intro - ✅ Captured
- O7: Periode Start - ✅ Captured
- O8: Periode Dauer - ✅ Captured
- O9: Success - ✅ Captured
