# Dashboard Components Inventory

**Date:** 2025-10-04
**Figma Node:** 68426:7203 (Dashboard)
**Source:** Nova Health UI – Working Copy
**Method:** Mechanical extraction (no interpretation)
**Limitations:** Interaction variants (pressed/hover states) not available in Dev Mode export

---

## 1. StatusBar

**Type:** System component (non-interactive)
**Figma Node:** 68426:7204

### Layout
- **Position:** `x=0, y=0`
- **Size:** `w=423, h=44`

### Props Schema
```dart
{
  "time": String,          // e.g., "19:27"
  // System-managed properties (signal, wifi, battery) not exposed in Figma
}
```

### States
- **normal:** Default system state

### Typography
- **Time:**
  - Family: `DM Sans` (System/OS mock font; excluded from brand typography)
  - Weight: `600` (SemiBold)
  - Size: `15px`
  - Line Height: `normal`
  - Letter Spacing: `-0.165px`
  - Color: `#030401`

### Notes
- Figma shows placeholder symbols; actual implementation uses Flutter platform widgets.
- No custom styling beyond default iOS/Android status bar.
- Typography is system font, not part of brand design system.

---

## 2. HeaderSection

**Type:** Composite layout (static + interactive)
**Figma Node:** 68426:7235

### Layout
- **Position:** `x=21, y=62`
- **Size:** `w=385, h=66`
- **Auto Layout:**
  - Direction: `horizontal`
  - Gap: `8px`
  - Padding: `0`
  - Alignment: `null` (not extractable from Tailwind code)
  - Constraints: `null` (not extractable from Tailwind code)

### Props Schema
```dart
{
  "userName": String,           // e.g., "Anna"
  "date": String,               // e.g., "28. Sept"
  "cyclePhase": String,         // e.g., "Follikelphase"
  "onSearchTap": VoidCallback,
  "onNotificationsTap": VoidCallback,
  "hasUnreadNotifications": bool
}
```

### States
- **normal:** Default
- **searchPressed:** `null` (no Figma variant found)
- **notificationsPressed:** `null` (no Figma variant found)

### Sub-components

#### 2.1 HeaderTitle
**Figma Node:** 68426:7251
- **Text:** `"Hey, {userName} 💜"`
- **Typography:**
  - Family: `Playfair Display`
  - Weight: `400`
  - Size: `32px`
  - Line Height: `40px`
  - Figma Style: `Heading/H1`
  - Color: `#030401`

#### 2.2 HeaderSubtitle
**Figma Node:** 68426:7252
- **Text:** `"Heute, {date}: {cyclePhase}"`
- **Typography:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `16px`
  - Line Height: `24px`
  - Figma Style: `Regular klein`
  - Color: `#6d6d6d`

#### 2.3 IconButton (Search)
**Figma Node:** 68426:7254
- **Icon Node:** 68426:7255
- **Icon Size:** `20x20px`
- **Container:**
  - Size: `40x40px`
  - Border: `0.769px solid rgba(255,255,255,0.08)`
  - Radius: `26.667px`
  - Background: `transparent`
  - Padding: `10px`
- **States:**
  - normal: As above
  - pressed: `null` (no Figma variant found)

#### 2.4 IconButton (Notifications)
**Figma Node:** 68426:7260
- **Icon Node:** 68426:7261
- **Icon Size:** `20x20px`
- **Notification Dot:**
  - Figma Node: `68426:7265`
  - Size: `null` (not specified in code)
  - Color: `null` (not specified in code)
  - Position: `top-right` (inferred from node bounds)
- **Container:**
  - Size: `40x40px`
  - Border: `0.769px solid rgba(255,255,255,0.08)`
  - Radius: `26.667px`
  - Background: `transparent`
  - Padding: `10px`
- **States:**
  - normal: As above
  - pressed: `null` (no Figma variant found)
  - hasUnread: Show notification dot (visual delta not specified)

---

## 3. HeroCard

**Type:** Interactive card (navigation)
**Figma Node:** 68426:7268

### Layout
- **Position:** `x=21, y=170`
- **Size:** `w=385, h=190`
- **Auto Layout:**
  - Direction: `null` (not visible in Tailwind output)
  - Gap: `null`
  - Padding: `21px` (all sides)
  - Alignment: `null`
  - Constraints: `null`

### Props Schema
```dart
{
  "title": String,              // e.g., "Kraft - Ganzkörper"
  "subtitle": String,           // e.g., "12 Übungen offen"
  "progress": double,           // 0.0 - 1.0
  "ctaLabel": String,           // e.g., "Training ansehen"
  "onCtaTap": VoidCallback,
  "backgroundColor": Color      // e.g., #CCB2F4
}
```

### States
- **normal:** Default
- **ctaPressed:** `null` (no Figma variant found)
- **disabled:** `null` (no Figma variant found)

### Container
**Background:** `#CCB2F4` (solid; verified from code `className='bg-[#ccb2f4]'`)
**Radius:** `24px`
**Border:** `1px solid #696969`
**Shadow:** None

### Sub-components

#### 3.1 CardTitle
**Figma Node:** 68426:7282
- **Typography:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `20px`
  - Line Height: `24px`
  - Figma Style: `Body/Regular`
  - Color: `#FFFFFF`

#### 3.2 CardSubtitle
**Figma Node:** 68426:7283
- **Typography:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `16px`
  - Line Height: `24px`
  - Figma Style: `Regular klein`
  - Color: `#6d6d6d`
- **Accessibility Note:** Color `#6d6d6d` on `#CCB2F4` background creates low contrast (~2.8:1, fails WCAG AA). This is a design issue from Figma.

#### 3.3 ProgressIndicator
**Figma Node:** 68426:7285
- **Type:** Circular
- **Outer Size:** `59.92px`
- **Inner Size:** `22.256px x 35.953px`
- **Stroke Width:** `null` (SVG asset; not extractable from code)
- **Track Color:** `null` (SVG asset; not extractable from code)
- **Cap:** `null` (SVG asset; not extractable from code)
- **Arc Start Angle:** `null` (SVG asset; not extractable from code)
- **Color:** `#FFFFFF`
- **Value:** `0.25` (25%)
- **Notes:** SVG delivered via localhost URL; stroke properties require manual Figma inspection.

#### 3.4 ProgressPercentageLabel
**Figma Node:** 68426:7291
- **Text:** `"25%"`
- **Typography:**
  - Family: `Urbanist` (non-brand font; not in Figma variables)
  - Weight: `500`
  - Size: `17.12px`
  - Line Height: `1.2`
  - Figma Style: `null` (custom style)
  - Color: `#FFFFFF`

#### 3.5 CtaButton
**Figma Node:** 68426:7276
- **Size:** `w=291.05px, h=50.51px`
- **Background:** `#FFFFFF`
- **Radius:** `17.12px`
- **Padding:** `null` (not specified in code)
- **Text:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `16px`
  - Line Height: `24px`
  - Figma Style: `Regular klein`
  - Color: `#030401`
- **Icon:**
  - Node: `68426:7278`
  - Name: `Play Button Vector`
  - Size: `20.58px x 22.88px`
- **States:**
  - normal: As above
  - pressed: `null` (no Figma variant found)

---

## 4. SectionHeader

**Type:** Composite layout (static + navigation)
**Figma Nodes:** 68426:7293 (Kategorien), 68426:7318 (Empfehlungen)

### Layout
- **Size:** `w=372, h=23-24`
- **Auto Layout:**
  - Direction: `horizontal`
  - Gap: `null`
  - Padding: `null`
  - Alignment: `space-between` (from `className='justify-between'`)
  - Constraints: `null`

### Props Schema
```dart
{
  "title": String,              // e.g., "Kategorien"
  "moreLabel": String,          // e.g., "Alles"
  "onMoreTap": VoidCallback
}
```

### States
- **normal:** Default
- **morePressed:** `null` (no Figma interaction variant found)

### Sub-components

#### 4.1 Title
**Figma Node:** 68426:7294 / 68426:7319
- **Typography:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `20px`
  - Line Height: `24px`
  - Figma Style: `Body/Regular`
  - Color: `#030401`

#### 4.2 MoreLabel
**Figma Node:** 68426:7295 / 68426:7320
- **Typography:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `14px`
  - Line Height: `24px`
  - Figma Style: `Regular klein 14`
  - Color: `#D9B18E`
- **States:**
  - normal: As above
  - pressed: `null` (no Figma interaction variant found)

---

## 5. CategoryChip

**Type:** Interactive chip (navigation)
**Figma Nodes:** 68426:7297, 68426:7301, 68426:7305, 68426:7309

### Layout
- **Size:** `w=60-76px, h=92px` (including label)
- **Icon Container:** `w=60-76px, h=60px`
- **Auto Layout:**
  - Direction: `vertical`
  - Gap: `8px`
  - Padding: `10px` (icon container)
  - Alignment: `center`
  - Constraints: `null`

### Props Schema
```dart
{
  "icon": Widget,               // Icon widget
  "label": String,              // e.g., "Training"
  "isSelected": bool,
  "onTap": VoidCallback
}
```

### States
- **normal:** Default (grey bg)
- **selected:** Highlighted (primary color bg)
- **pressed:** `null` (no Figma variant found)

### Container
- **Background (normal):** `#F7F7F8`
- **Background (selected):** `#D9B18E`
- **Radius:** `16px`
- **Shadow:** None
- **Padding:** `10px`

### Label
- **Typography:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `14px`
  - Line Height: `24px`
  - Figma Style: `Regular klein 14`
  - Color: `#030401`

### Icon Sizes (by chip)
- **Training (68430:6936):** `19.8x19.8px`
- **Ernährung (68430:7446):** `24x24px`
- **Regeneration (68430:7479):** `24x24px`
- **Achtsamkeit (68430:7501):** `24x24px`

---

## 6. RecommendationCard

**Type:** Interactive card (navigation)
**Figma Nodes:** 68426:7322, 68426:7328, 68426:7334

### Layout
- **Size:** `w=155px, h=180px`
- **Auto Layout:** `null`

### Props Schema
```dart
{
  "imageUrl": String,
  "tag": String,                // e.g., "Kraft"
  "title": String,              // e.g., "Beine & Po"
  "onTap": VoidCallback
}
```

### States
- **normal:** Default
- **pressed:** `null` (no Figma variant found)

### Container
- **Radius:** `20px`
- **Shadow:** None
- **Image Overlay:** Linear gradient
  - Type: `gradient`
  - Direction: `to-bottom`
  - Stops:
    - `14.609%`: `rgba(26,26,26,0)`
    - `95%`: `#1A1A1A`
  - **Alt Gradient (Cardio card):**
    - `14.609%`: `rgba(30,31,36,0)`
    - `95%`: `#1E1F24`

### Sub-components

#### 6.1 Tag
**Typography:**
- Family: `Figtree`
- Weight: `400`
- Size: `12px`
- Line Height: `18px`
- Letter Spacing: `0.12px`
- Figma Style: `null` (not found in variables; custom style)
- Color: `#6d6d6d`

**Position:** `(14, 124)` relative to card

#### 6.2 Title
**Typography:**
- Family: `Figtree`
- Weight: `400`
- Size: `16px`
- Line Height: `24px`
- Figma Style: `Regular klein`
- Color: `#FFFFFF`

**Position:** `(14, 142)` relative to card (below tag)

---

## 7. BottomActionPills

**Type:** Navigation bar (interactive)
**Figma Node:** 68427:7576

### Layout
- **Position:** `x=24, y=820`
- **Size:** `w=388, h=72`
- **Auto Layout:**
  - Direction: `horizontal`
  - Gap: `6px`
  - Padding: `6px` (all sides)
  - Alignment: `null`
  - Constraints: `null`
- **Spacing to Home Indicator:** `0px` (bottom edge at y=892px, home indicator starts at y=892px)

### Props Schema
```dart
{
  "selectedIndex": int,         // 0-4
  "onItemTap": Function(int)
}
```

### States
- **normal:** Default
- **itemPressed:** `null` (no Figma variant found)

### Container
- **Background:** `#FFFFFF`
- **Radius:** `36.5px`
- **Shadow:** `0px 0px 24px 0px rgba(0,0,0,0.12)`

### Items

#### 7.1 Start Button (index 0)
- **Type:** Label + background
- **Size:** `w=104.75px, h=60px`
- **Background (selected):** `#D9B18E`
- **Background (normal):** `#F7F7F8`
- **Radius:** `36.5px`
- **Padding:** `20px (horizontal), 18px (vertical)`
- **Text:**
  - Family: `Figtree`
  - Weight: `400`
  - Size: `16px`
  - Line Height: `24px`
  - Figma Style: `Regular klein`
  - Color (selected): `#FFFFFF`
  - Color (normal): `#030401`

#### 7.2 Icon Buttons (index 1-4)
- **Type:** Icon + background
- **Background (selected):** `#D9B18E`
- **Background (normal):** `#F7F7F8`
- **Radius:** `36.5px`
- **Padding:** `20px (horizontal), 18px (vertical)`
- **Icon Size:** `24px`
- **Icons:**
  - index 1: Heart (node: I68427:7576;67074:8646)
  - index 2: Social media (node: I68427:7576;67074:8648)
  - index 3: Chart (node: I68427:7576;67074:8650)
  - index 4: Account (node: I68427:7576;67074:8652)

---

## 8. HomeIndicator

**Type:** System component (non-interactive)
**Figma Node:** 68427:7573

### Layout
- **Position:** `x=0, y=892`
- **Size:** `w=428, h=34`

### Props Schema
```dart
{} // No props, system-managed
```

### States
- **normal:** Default

### Indicator
- **Size:** `w=134px, h=5px`
- **Background:** `#030401`
- **Radius:** `100px`

### Notes
- Actual implementation uses Flutter platform widgets.
- No custom styling required.

---

## Summary

| Component | Interactive | States (Documented) | States (null/missing) | Props Count | Reuse Potential |
|-----------|-------------|---------------------|----------------------|-------------|-----------------|
| StatusBar | No | 1 | 0 | 1 | Low (system) |
| HeaderSection | Yes | 1 | 2 (pressed states) | 6 | High |
| HeroCard | Yes | 1 | 2 (pressed/disabled) | 6 | High |
| SectionHeader | Yes | 1 | 1 (pressed) | 3 | High |
| CategoryChip | Yes | 2 | 1 (pressed) | 4 | High |
| RecommendationCard | Yes | 1 | 1 (pressed) | 4 | High |
| BottomActionPills | Yes | 1 | 1 (itemPressed) | 2 | Medium |
| HomeIndicator | No | 1 | 0 | 0 | Low (system) |

**Total Components:** 8
**Total Interactive:** 6
**Total States Documented:** 9
**Total States Missing (null):** 7
**Total Props:** 26

---

## Notes on Limitations

1. **Interaction States:** All pressed/hover/focus/disabled states are marked as `null` because no Figma interaction variants were found in the Dev Mode export.

2. **Auto Layout Properties:** Alignment and constraints are frequently `null` because they are not extractable from Tailwind CSS classes in the code export.

3. **Icon Properties:** Export settings (size, stroke scaling) require manual Figma asset panel inspection.

4. **Accessibility:** Hero card subtitle color (`#6d6d6d` on `#CCB2F4`) fails WCAG AA contrast requirements (~2.8:1). This is a design issue originating from Figma.

5. **Typography:** Two non-brand fonts identified:
   - `DM Sans` (status bar): System/OS mock
   - `Urbanist` (progress %): Custom style, not in Figma variables
