# Dashboard Tokens Mapping (Figma → Neutral Tokens)

**Date:** 2025-10-04
**Figma Node:** 68426:7203 (Dashboard)
**Source:** Nova Health UI – Working Copy
**Method:** Mechanical extraction (no interpretation)
**Scope:** Figma-only mapping to neutral token names. Repo reuse mapping is handled separately.

---

## Colors

| Figma Value | Figma Variable Name | Proposed Neutral Token Name | Notes |
|-------------|---------------------|----------------------------|-------|
| `#030401` | Grayscale/Black | `color.text.primary` | Primary text color |
| `#FFFFFF` | Additional Colors/White | `color.surface.primary` | Primary surface/background |
| `#6d6d6d` | sub tex 2 | `color.text.secondary` | Secondary/subtitle text |
| `#D9B18E` | Primary color/100 | `color.brand.primary` | Primary brand color (buttons, highlights) |
| `#CCB2F4` | Accent/300 | `color.brand.accent` | Accent color (hero card background) |
| `#F7F7F8` | Grayscale/100 | `color.surface.secondary` | Secondary surface (chip backgrounds) |
| `#E53935` | Alerts/Error | `color.status.error` | Error/alert color (defined in variables but not used in Dashboard) |
| `#696969` | (unknown) | `color.border.primary` | Border color (hero card stroke) |
| `#1A1A1A` | (gradient overlay) | `color.overlay.dark` | Dark gradient overlay (recommendation cards) |
| `#1E1F24` | (gradient overlay alt) | `color.overlay.dark.alt` | Alternative dark overlay (Cardio card) |

---

## Gradients

| Gradient Definition | Context | Proposed Neutral Token Name | Notes |
|---------------------|---------|----------------------------|-------|
| `linear-gradient(to-bottom, rgba(26,26,26,0) 14.609%, #1A1A1A 95%)` | Recommendation card overlay | `gradient.overlay.dark.default` | Standard image overlay |
| `linear-gradient(to-bottom, rgba(30,31,36,0) 14.609%, #1E1F24 95%)` | Recommendation card overlay (Cardio) | `gradient.overlay.dark.alt` | Alternative overlay for specific card types |

---

## Spacing

| Value (px) | Context / Source | Proposed Neutral Token Name | Notes |
|------------|------------------|----------------------------|-------|
| 0 | List padding | `spacing.none` | Zero spacing |
| 2 | Title-subtitle gap (68426:7248) | `spacing.2xs` | Extra extra small |
| 4 | Header title emoji gap (68426:7249) | `spacing.xs` | Extra small |
| 6 | Bottom nav padding/gap (68427:7576) | `spacing.s` | Small |
| 8 | Header actions gap (68426:7253), chip label gap | `spacing.m` | Medium |
| 10 | Icon container padding (68426:7254), chip padding | `spacing.l` | Large |
| 14 | Card content left padding | `spacing.xl` | Extra large |
| 15 | Recommendations list gap (68426:7321) | `spacing.2xl` | 2x extra large |
| 16 | Categories section gap (68426:7292) | `spacing.3xl` | 3x extra large |
| 18 | Bottom nav button padding vertical | `spacing.4xl` | 4x extra large |
| 20 | Bottom nav button padding horizontal | `spacing.5xl` | 5x extra large |
| 21 | Main frame padding, hero card padding | `spacing.6xl` | 6x extra large |
| 24 | Main frame section gaps | `spacing.7xl` | 7x extra large |
| 41 | Categories grid gap (68426:7296) | `spacing.8xl` | 8x extra large |
| 42 | Main frame vertical gap (68426:7234) | `spacing.9xl` | 9x extra large |

---

## Radii

| Value (px) | Context / Source | Proposed Neutral Token Name | Notes |
|------------|------------------|----------------------------|-------|
| 5 | Progress icon container (68426:7286) | `radius.2xs` | Extra extra small |
| 16 | Category chips (68426:7297-7309) | `radius.m` | Medium |
| 17.12 | Hero CTA button (68426:7276) | `radius.l` | Large |
| 20 | Recommendation cards | `radius.xl` | Extra large |
| 24 | Hero card (68426:7268) | `radius.2xl` | 2x extra large |
| 26.667 | Header icon containers (68426:7254) | `radius.3xl` | 3x extra large |
| 36.5 | Bottom nav container/items (68427:7576) | `radius.4xl` | 4x extra large |
| 100 | Home indicator (68427:7573) | `radius.full` | Fully rounded (pill shape) |

**Corner Smoothing:** Not extractable from Dev Mode export; requires manual Figma inspection.
**Independent Radii:** Not extractable from Dev Mode export; requires manual Figma inspection.

---

## Shadows

| Definition | Context / Source | Proposed Neutral Token Name | Notes |
|------------|------------------|----------------------------|-------|
| `0px 0px 24px 0px rgba(0,0,0,0.12)` | Bottom navigation bar (68427:7576) | `shadow.elevation.low` | Low elevation shadow |

---

## Typography

### Brand Typography Styles

| Font Spec | Figma Variable Name | Proposed Neutral Token Name | Notes |
|-----------|---------------------|----------------------------|-------|
| Playfair Display, 400, 32px, 40px line-height | Heading/H1 | `typography.heading.h1` | Primary heading |
| Figtree, 400, 20px, 24px line-height | Body/Regular | `typography.body.large` | Large body text, section headers |
| Figtree, 400, 16px, 24px line-height | Regular klein | `typography.body.medium` | Medium body text |
| Figtree, 400, 14px, 24px line-height | Regular klein 14 | `typography.body.small` | Small body text, labels |
| Figtree, 400, 12px, 18px line-height, 0.12px letter-spacing | (custom style) | `typography.body.2xs` | Extra small body text (card tags) |

### Non-Brand Typography (Excluded)

| Font Spec | Context | Notes |
|-----------|---------|-------|
| DM Sans, 600, 15px, -0.165px letter-spacing | Status bar time (68426:7223) | System/OS mock font; excluded from brand typography |
| Urbanist, 500, 17.12px, 1.2 line-height | Progress percentage (68426:7291) | Non-brand font; not in Figma variables; possibly custom style |

**Figma Style IDs:** Not extractable from Dev Mode export.

---

## Icons / Assets

| Icon Name | Figma Node | Context | Proposed Neutral Asset Name | Notes |
|-----------|------------|---------|----------------------------|-------|
| Magnifying Glass Shape | 68426:7257 | Search icon | `icon.search` | Export settings require manual Figma inspection |
| Bell Icon Group | 68426:7262 | Notifications icon | `icon.notifications` | Export settings require manual Figma inspection |
| Notification Dot | 68426:7265 | Notification indicator | `icon.notification-dot` | Export settings require manual Figma inspection |
| Play Button Vector | 68426:7278 | Hero CTA icon | `icon.play` | Export settings require manual Figma inspection |
| Inner Progress Circle | 68426:7285 | Progress indicator | `icon.progress-circle` | SVG asset; export settings require manual inspection |
| Martial Arts Category | 68430:6936 | Training icon | `icon.category.training` | Export settings require manual Figma inspection |
| ic / dish | 68430:7446 | Ernährung icon | `icon.category.nutrition` | Figma component instance |
| ic / enhance | 68430:7479 | Regeneration icon | `icon.category.regeneration` | Figma component instance |
| ic / explore | 68430:7501 | Achtsamkeit icon | `icon.category.mindfulness` | Figma component instance |
| ic / ai | 68430:7508 | Bottom nav AI icon | `icon.nav.ai` | Figma component instance |
| ic / heart | I68427:7576;67074:8646 | Bottom nav icon | `icon.nav.heart` | Icon container only; no SVG in code |
| Social media | I68427:7576;67074:8648 | Bottom nav icon | `icon.nav.social` | Export settings require manual Figma inspection |
| ic / Chart | I68427:7576;67074:8650 | Bottom nav icon | `icon.nav.chart` | Export settings require manual Figma inspection |
| ic / Account | I68427:7576;67074:8652 | Bottom nav icon | `icon.nav.account` | Export settings require manual Figma inspection |

**Export Size, Stroke Scaling:** Not extractable from Dev Mode export; requires manual Figma asset panel inspection.

---

## Token Naming Convention

**Pattern:** `{category}.{subcategory}.{variant}`

**Categories:**
- `color`: Color values
- `gradient`: Gradient definitions
- `spacing`: Spacing/gap/padding values
- `radius`: Border radius values
- `shadow`: Shadow definitions
- `typography`: Text styles
- `icon`: Icon assets

**Scale Naming:**
- Spacing/Radius: `2xs, xs, s, m, l, xl, 2xl, 3xl, 4xl, 5xl, 6xl, 7xl, 8xl, 9xl, full`
- Colors: `primary, secondary, tertiary, accent, brand, status`
- Shadows: `elevation.{low, medium, high}`

---

## Limitations & Notes

1. **Dev Mode Export Constraints:**
   - Corner smoothing settings not visible
   - Independent corner radii not extractable
   - Figma style IDs not included in code export
   - Icon export settings (size, stroke scaling) not in code
   - Interaction variants (pressed/hover states) not in code

2. **Manual Inspection Required For:**
   - Corner smoothing values
   - Per-corner radius values (if different)
   - Icon asset export settings (SVG/PNG, dimensions, stroke behavior)
   - Interaction state visual deltas
   - Figma text style IDs

3. **Token Strategy:**
   - All tokens are Figma-source-of-truth mappings
   - Repo implementation reuse is handled separately (not in this document)
   - Tokens follow semantic naming (not pixel values)
   - Scale is consistent across categories where applicable

---

## Deduplication & Unique Values

**Total Unique Colors:** 10
**Total Unique Gradients:** 2
**Total Unique Spacing Values:** 15
**Total Unique Radii:** 8
**Total Unique Shadows:** 1
**Total Unique Typography Styles:** 5 (brand) + 2 (excluded non-brand)
**Total Icons:** 14
