# Dashboard Interaction Variants (States)

**Extraction Method:** Figma MCP Tool (get_code, get_metadata)
**Source Node:** 68426:7203 (Dashboard Frame)
**Extraction Date:** 2025-10-04

## Limitation Notice

⚠️ **Figma MCP API does not expose Component Variants/Interactive States.**
The following data is derived from single-state snapshots. Interactive states (hover/pressed/focus/disabled) require manual Figma Dev Mode inspection or Variants API (not available via MCP).

---

## 1. Header Section Actions (Search + Bell)

### Search Icon Container (Node: 68426:7254)
- **Base State:** normal
  - Container: 40×40px
  - Background: transparent
  - Icon: 20×20px (centered, 10px padding)
  - Border: none visible
- **States Available:** null (not exposed via API)
- **Visual Deltas:** null
- **Notes:** No variant/state metadata returned; requires manual Dev Mode inspection

### Bell Icon Container (Node: 68426:7260)
- **Base State:** normal
  - Container: 40×40px
  - Background: transparent
  - Icon Group: 20×20px (Node: 68426:7261)
  - Notification Dot: present (Node: 68426:7265)
    - Position: inset 8.33% top, 54.16% left, 58.33% bottom, 12.5% right (relative to container)
    - Color: `#E53935` (Alerts/Error variable)
    - Size: ~6.7×6.7px (calculated from insets: 33.33% width × 20px, 33.33% height × 20px)
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** No variant/state metadata; notification dot likely controlled by boolean prop

---

## 2. Hero Card CTA Button (Training ansehen)

### Info Button Group (Node: 68426:7277)
- **Base State:** normal
  - Container: 150.24×24px
  - Background: `#FFFFFF` (from parent card 68426:7276: rounded-rectangle 291×50.5px)
  - Text: "Training ansehen"
    - Font: `Figtree Regular 16px` (leading 24px)
    - Color: `#030401` (Grayscale/Black)
  - Icon: Play button vector (23.11×20.84px, rotated 89.346°)
  - Padding: 14.86px vertical (calculated from parent card height 50.5px - text height 24px / 2)
  - Border Radius: null (parent card has radius, not explicitly stated)
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Parent card (68426:7276) provides background; no press/hover states exposed

---

## 3. Section Header "Alles" Links

### Kategorien "Alles" (Node: 68426:7295)
- **Base State:** normal
  - Text: "Alles"
  - Font: null (not specified in API response)
  - Color: likely accent/link color (not returned by API)
  - Position: x=324, y=0 (relative to Category Title frame 68426:7293)
  - Size: 48×24px
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Text node styling not fully exposed; requires Text Styles API

### Empfehlungen "Alles" (Node: 68426:7320)
- **Base State:** normal
  - Text: "Alles"
  - Size: 35×24px
  - Position: x=337, y=-1 (relative to header frame 68426:7318)
  - Color/Font: null
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Similar to Kategorien; no style metadata returned

---

## 4. Category Chips

### Exercise Category Chip (Node: 68426:7297)
- **Base State:** normal (likely selected, based on fill)
  - Container: 60×92px (vertical layout)
  - Icon Container: 60×60px, `border-radius: 16px`
  - Background: `#D9B18E` (Primary color/100)
  - Icon: 19.8×19.8px (Martial Arts Category vector, Node: 68430:6936)
  - Label: "Training"
    - Font: `Figtree Regular 14px` (leading 24px)
    - Color: `#030401`
  - Gap: 8px (between icon container and label)
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Selected state likely = filled background; unselected = outline/transparent (not accessible via API)

### Other Chips (Ernährung, Regeneration, Achtsamkeit)
- **Nodes:** 68426:7301, 68426:7305, 68426:7309
- **Base State:** normal (likely unselected, based on layout similarity)
  - Background: null (not returned; likely transparent or outlined)
  - Icons: 24×24px instances (dish, enhance, explore)
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Unselected state styling not extractable; requires component variant inspection

---

## 5. Recommendation Cards

### Workout Article Card (Node: 68426:7322)
- **Base State:** normal
  - Container: 155×180px
  - Border Radius: `20px`
  - Image: 155×180px (placeholder Node: 68426:7323)
    - Object-fit: cover
    - Object-position: 50% 50%
  - Overlay: Gradient
    - Direction: to-b (top-to-bottom)
    - From: `rgba(26, 26, 26, 0)` at 14.609%
    - To: `#1A1A1A` at 95%
  - Text Container (Node: 68426:7325):
    - Position: x=14px, y=124px (absolute)
    - Category Label: "Kraft"
      - Font: `Figtree Regular 12px` (leading 18px, tracking 0.12px)
      - Color: `#6D6D6D` (sub tex 2)
    - Title: "Beine & Po"
      - Font: `Figtree Regular 16px` (leading 24px)
      - Color: `#FFFFFF`
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Pressed/hover states (e.g., scale, shadow) not exposed; likely interactive but no variant data

---

## 6. Bottom Action Pills

### Bottom Navigation Bar (Node: 68427:7576)
- **Base State:** normal
  - Container: 388×72px
  - Position: x=24px, y=820px
  - Items: null (instance node, children not expanded)
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Instance of component; requires Component Set inspection in Figma

### AI Pill Icon (Node: 68430:7508)
- **Base State:** normal
  - Icon: 24×24px
  - Position: x=160px, y=844px
  - Color/Style: null
- **States Available:** null
- **Visual Deltas:** null
- **Notes:** Instance node; no properties returned

---

## Summary

| Component | Node ID | States Extracted | Missing Data |
|-----------|---------|------------------|--------------|
| Search Icon | 68426:7254 | 0 | All states (hover/pressed/focus) |
| Bell Icon | 68426:7260 | 0 | All states |
| CTA Button | 68426:7277 | 0 | All states |
| "Alles" Links | 68426:7295, 68426:7320 | 0 | All states + text styles |
| Category Chips | 68426:7297, etc. | 0 | Unselected state, all interactive states |
| Recommendation Cards | 68426:7322 | 0 | Hover/pressed states |
| Bottom Pills | 68427:7576 | 0 | All states (component instance) |

**Total Components Analyzed:** 7
**Total States Documented:** 7 (base only)
**Total Interactive States Missing:** ~35 (5 states × 7 components)

**Reason:** Figma MCP API does not expose:
- Component Variants/Properties
- Interactive State definitions (hover, pressed, focus, disabled)
- Text Styles (full metadata)
- Component Set structures

**Recommendation:** Use Figma Desktop Dev Mode → Inspect Panel → manually document Variants for each component, or use Figma REST API with Variants endpoints.
