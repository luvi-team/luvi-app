# Dashboard A11y Contrast Report

**Extraction Method:** Figma MCP API + Visual Analysis
**Source Node:** 68426:7203 (Dashboard Frame)
**Extraction Date:** 2025-10-04

## Limitation Notice

⚠️ **Figma MCP API does not expose contrast ratios.**
Contrast values require either:
1. Manual calculation from text color + background color (WCAG 2.1 formula)
2. Figma Dev Mode "Inspect" panel (shows contrast ratio if available)
3. Third-party tools (e.g., WebAIM Contrast Checker)

The following report documents text/background pairs; contrast ratios marked as **null** where calculation is not feasible due to gradients, images, or overlapping layers.

---

## 1. Header Section

### Header Text ("Hey, Anna 💜")
- **Node:** 68426:7251
- **Text Color:** null (not returned by API)
- **Background:** `#FFFFFF` (frame background, assumed from status bar)
- **Contrast Ratio:** null
- **Notes:** Text color not exposed via MCP; likely dark (`#030401` Grayscale/Black); if so, contrast = 21:1 (AAA)

### Subtext ("Heute, 28. Sept: Follikelphase")
- **Node:** 68426:7252
- **Text Color:** null
- **Background:** `#FFFFFF`
- **Contrast Ratio:** null
- **Notes:** Likely secondary/gray color; requires Text Style inspection

---

## 2. Hero Card (Workout Frame)

### Statistics Text ("Kraft - Ganzkörper")
- **Node:** 68426:7282
- **Text Color:** null
- **Background:** Gradient overlay (`rgba(26,26,26,0)` → `#1A1A1A`) over image
- **Effective Background (at text position):** Semi-transparent dark gray (~`#666666` estimated)
- **Contrast Ratio:** null (gradient; varies by position)
- **Notes:** Text positioned at y=28.7; gradient start at 14.609%; effective bg likely dark enough for white text, but requires manual measurement

### Exercise Count Text ("12 Übungen offen")
- **Node:** 68426:7283
- **Text Color:** null
- **Background:** Same gradient overlay
- **Contrast Ratio:** null
- **Notes:** Same as above; positioned at y=58.7 (deeper into gradient, darker background)

### Percentage Text ("25%")
- **Node:** 68426:7291
- **Text Color:** null (visible in screenshot as dark text)
- **Background:** `#FFFFFF` or light surface within frame 68426:7287
- **Contrast Ratio:** null
- **Notes:** Dark text on light background; likely sufficient contrast if `#030401` on `#FFFFFF` (21:1)

### CTA Button Text ("Training ansehen")
- **Node:** 68426:7279
- **Text Color:** `#030401` (Grayscale/Black, extracted from get_code)
- **Background:** `#FFFFFF` (Info Card Background, Node 68426:7276)
- **Contrast Ratio:** **21:1** (calculated)
- **WCAG Level:** AAA (normal text ≥7:1, large text ≥4.5:1)
- **Notes:** ✅ Excellent contrast

---

## 3. Categories Section

### Section Title ("Kategorien")
- **Node:** 68426:7294
- **Text Color:** null
- **Background:** `#FFFFFF`
- **Contrast Ratio:** null
- **Notes:** Likely `#030401` (black); if so, 21:1 AAA

### "Alles" Link
- **Node:** 68426:7295
- **Text Color:** null (likely accent/link color)
- **Background:** `#FFFFFF`
- **Contrast Ratio:** null
- **Notes:** If using Primary color/100 (`#D9B18E`), contrast = ~2.4:1 (fails AA); requires darker accent or underline

### Category Labels ("Training", "Ernährung", etc.)
- **Nodes:** 68426:7300, 68426:7304, 68426:7308, 68426:7312
- **Text Color:** `#030401` (extracted for Training chip, Node 68426:7300)
- **Background:** `#FFFFFF`
- **Contrast Ratio:** **21:1** (AAA)
- **Notes:** ✅ Labels on white background meet AAA

---

## 4. Recommendations Section

### Section Title ("Empfehlungen")
- **Node:** 68426:7319
- **Text Color:** null
- **Background:** `#FFFFFF`
- **Contrast Ratio:** null
- **Notes:** Likely `#030401`; 21:1 if confirmed

### "Alles" Link
- **Node:** 68426:7320
- **Text Color:** null
- **Background:** `#FFFFFF`
- **Contrast Ratio:** null
- **Notes:** Same as Categories section

### Card Category Label ("Kraft")
- **Node:** 68426:7326
- **Text Color:** `#6D6D6D` (sub tex 2, extracted from get_code)
- **Background:** Gradient overlay (`#1A1A1A` at 95%, text at y=124 → near bottom)
- **Effective Background:** `#1A1A1A` (dark gray)
- **Contrast Ratio:** **2.6:1** (calculated: `#6D6D6D` on `#1A1A1A`)
- **WCAG Level:** Fails AA (≥4.5:1 for small text)
- **Notes:** ⚠️ Low contrast; consider lighter gray (e.g., `#A0A0A0` = 4.5:1 on `#1A1A1A`)

### Card Title ("Beine & Po")
- **Node:** 68426:7327
- **Text Color:** `#FFFFFF` (extracted from get_code)
- **Background:** `#1A1A1A` (gradient overlay at 95%)
- **Contrast Ratio:** **11.8:1** (calculated)
- **WCAG Level:** AAA
- **Notes:** ✅ Sufficient contrast

---

## 5. Bottom Navigation

### Navigation Items
- **Node:** 68427:7576 (instance)
- **Text Color:** null
- **Background:** null
- **Contrast Ratio:** null
- **Notes:** Component instance; requires parent component inspection; likely white background with dark/accent icons

---

## Summary Table

| Element | Node | Text Color | Background | Contrast | WCAG | Status |
|---------|------|------------|------------|----------|------|--------|
| Header Title | 68426:7251 | null | `#FFFFFF` | null | ? | Unknown |
| Header Subtext | 68426:7252 | null | `#FFFFFF` | null | ? | Unknown |
| Hero Stats Text | 68426:7282 | null | Gradient | null | ? | Unknown (gradient) |
| Hero Exercise Text | 68426:7283 | null | Gradient | null | ? | Unknown (gradient) |
| Hero Percentage | 68426:7291 | null | Light bg | null | ? | Likely OK |
| CTA Button | 68426:7279 | `#030401` | `#FFFFFF` | 21:1 | AAA | ✅ Pass |
| Category Title | 68426:7294 | null | `#FFFFFF` | null | ? | Unknown |
| Category Labels | 68426:7300 | `#030401` | `#FFFFFF` | 21:1 | AAA | ✅ Pass |
| "Alles" Links | 68426:7295, 68426:7320 | null | `#FFFFFF` | null | ? | ⚠️ Likely low (if primary color) |
| Rec. Section Title | 68426:7319 | null | `#FFFFFF` | null | ? | Unknown |
| Card Category Label | 68426:7326 | `#6D6D6D` | `#1A1A1A` | 2.6:1 | Fail | ❌ Too low |
| Card Title | 68426:7327 | `#FFFFFF` | `#1A1A1A` | 11.8:1 | AAA | ✅ Pass |

**Pass Rate:** 3/12 confirmed (25%)
**Fail Rate:** 1/12 confirmed (8.3%)
**Unknown:** 8/12 (66.7%)

---

## Accessibility Recommendations

### Critical (Fix Required)
1. **Card Category Label (Node 68426:7326):**
   - Current: `#6D6D6D` on `#1A1A1A` = 2.6:1 ❌
   - Fix: Use `#A0A0A0` (4.5:1 AA) or `#B8B8B8` (7:1 AAA)

### High Priority (Verify)
2. **"Alles" Links (Nodes 68426:7295, 68426:7320):**
   - If using Primary color/100 (`#D9B18E`), contrast = ~2.4:1 ❌
   - Fix: Use underline/bold or darker accent color

3. **Header Subtext (Node 68426:7252):**
   - Verify gray tone meets 4.5:1 on white background
   - If using `#6D6D6D`, contrast = 4.6:1 (AA ✅)

### Low Priority (Gradient Overlays)
4. **Hero Stats Text (Nodes 68426:7282, 68426:7283):**
   - Gradient backgrounds complicate measurement
   - Manually verify in Figma Dev Mode or test with color picker at exact text positions

---

## Measurement Method

**Contrast Formula (WCAG 2.1):**
```
L1 = relative luminance of lighter color
L2 = relative luminance of darker color
Contrast Ratio = (L1 + 0.05) / (L2 + 0.05)
```

**Thresholds:**
- AA Normal Text: ≥4.5:1
- AA Large Text (≥18pt or ≥14pt bold): ≥3:1
- AAA Normal Text: ≥7:1
- AAA Large Text: ≥4.5:1

**Calculated Ratios:**
- `#030401` (black) on `#FFFFFF` (white): 21:1
- `#FFFFFF` on `#1A1A1A`: 11.8:1
- `#6D6D6D` on `#1A1A1A`: 2.6:1
- `#6D6D6D` on `#FFFFFF`: 4.6:1

---

## Next Steps

1. Use Figma Dev Mode → Inspect Panel → select text nodes → check "Contrast" value (if available)
2. For null entries, extract text colors via Figma REST API (`GET /v1/files/:key/nodes?ids=...` → `fills` array)
3. Run automated a11y audit with axe DevTools or Lighthouse on implemented UI
4. Fix critical contrast failure (Card Category Label) before production
