# Dashboard Images Inventory

**Extraction Method:** Figma MCP API (get_code, get_metadata)
**Source Node:** 68426:7203 (Dashboard Frame)
**Extraction Date:** 2025-10-04

## Limitation Notice

⚠️ **Figma MCP API provides limited image metadata.**
The following data is extracted from `get_code` and `get_metadata` outputs. Advanced properties (e.g., image fills, compression settings, layer blend modes) require Figma REST API or manual inspection.

---

## 1. Hero Card Image (Main Activity)

### Image Placeholder (Node: 68426:7273)
- **Figma Node ID:** 68426:7273
- **Type:** `rounded-rectangle`
- **Dimensions:** 327 × 189 px
- **Border Radius:** null (type identified as rounded-rectangle, but value not exposed)
- **Position:** x=0, y=0 (relative to Workout Frame 68426:7272)
- **Asset URL:** Not returned (likely image fill, not SVG/vector)
- **Crop Mode:** null
- **Object-Fit:** null
- **Object-Position:** null
- **Overlay Layering:** Below gradient overlay (Node 68426:7274)
- **Corner Handling:**
  - Corners clipped by parent rounded-rectangle shape
  - Radius applied before content (standard Figma behavior)
- **Notes:** Base layer of hero card; image fill not exposed via MCP; requires REST API `GET /v1/files/:key/nodes?ids=68426:7273` → `fills` array

---

## 2. Recommendation Card Images (3 Examples)

### Example 1: "Beine & Po" Card

#### Image Placeholder (Node: 68426:7323)
- **Figma Node ID:** 68426:7323
- **Name:** "Image Placeholder"
- **Type:** `rounded-rectangle`
- **Dimensions:** 155 × 180 px
- **Border Radius:** 20px (extracted from get_code: `rounded-[20px]`)
- Position: x=0, y=0 (relative to Workout Article 68426:7322)
- **Asset URL:** `http://localhost:3845/assets/70652ba5bab98c750983679383797de68521b1ee.png` (Ephemeral/Dev-Only)
  > **Note:** This URL is a local development artifact. For production, resolve the stable asset URL via Figma Export or the Content CDN.
- **Crop Mode:**
  - Object-fit: `cover` (extracted from get_code: `object-cover`)
  - Object-position: `50% 50%` (extracted from get_code: `object-50%-50%`)
- **Corner Handling:**
  - Radius: 20px (uniform corners)
  - Applied to `<img>` tag via `rounded-[20px]` class
  - Clipping: Image clipped to rounded bounds before overlay
- **Overlay Layering:**
  - Order: 1 (bottom layer)
  - Above: Gradient overlay (Node 68426:7324)
  - Above: Text container (Node 68426:7325)
- **CSS Classes (from get_code):**
  ```css
  position: absolute;
  inset: 0;
  max-width: none;
  object-fit: cover;
  object-position: 50% 50%;
  pointer-events: none;
  border-radius: 20px;
  width: 100%;
  height: 100%;
  ```
- **Notes:** Full-bleed image with centered crop; rounded corners applied to image element

---

### Example 2: "Rücken & Schulter" Card

#### Image Placeholder (Node: 68426:7329)
- **Figma Node ID:** 68426:7329
- **Name:** "Image Placeholder"
- **Type:** `rounded-rectangle`
- **Dimensions:** 155 × 180 px
- **Border Radius:** 20px (inferred from sibling card 68426:7323)
- **Position:** x=0, y=0 (relative to parent article frame 68426:7328)
- **Asset URL:** Not returned by get_code (requires separate call)
- **Crop Mode:** Likely same as Example 1 (`cover`, `50% 50%`)
- **Corner Handling:** Same as Example 1 (20px, clipped before overlay)
- **Overlay Layering:** Same as Example 1
- **Notes:** Metadata structure identical to Example 1; asset URL not fetched (get_code timed out for parent node 68426:7328)

---

### Example 3: "Ganzkörper" Card

#### Image Placeholder (Node: 68426:7335)
- **Figma Node ID:** 68426:7335
- **Name:** "Image Placeholder"
- **Type:** `rounded-rectangle`
- **Dimensions:** 155 × 180 px
- **Border Radius:** 20px (inferred)
- **Position:** x=0, y=0 (relative to parent article frame 68426:7334)
- **Asset URL:** Not returned
- **Crop Mode:** Likely same as Example 1
- **Corner Handling:** Same as Example 1
- **Overlay Layering:** Same as Example 1
- **Notes:** Metadata structure identical to Examples 1 & 2

---

## Image Overlay System

### Gradient Overlay (Applied to All Recommendation Cards)

**Node Example:** 68426:7324 (Highlight Overlay)
- **Type:** `frame` with gradient background
- **Dimensions:** 155 × 180 px (matches image)
- **Position:** `absolute inset-0` (covers entire image)
- **Gradient:**
  - Direction: `to-b` (top-to-bottom)
  - Color Stops:
    - 14.609%: `rgba(26, 26, 26, 0)` (transparent dark gray)
    - 95%: `#1A1A1A` (solid dark gray)
- **Border Radius:** 20px (same as image)
- **Layering Order:** 2 (above image, below text)
- **Purpose:** Create readable contrast for white text labels
- **CSS (from get_code):**
  ```css
  position: absolute;
  background: linear-gradient(to bottom, rgba(26, 26, 26, 0) 14.609%, #1A1A1A 95%);
  inset: 0;
  border-radius: 20px;
  ```

---

## Summary Table

| Card | Node ID | W×H | Radius | Asset URL | Object-Fit | Object-Position | Overlay |
|------|---------|-----|--------|-----------|------------|-----------------|---------|
| Hero Card | 68426:7273 | 327×189 | null | null | null | null | Gradient (68426:7274) |
| Rec. Card 1 | 68426:7323 | 155×180 | 20px | `...8521b1ee.png` | cover | 50% 50% | Gradient (68426:7324) |
| Rec. Card 2 | 68426:7329 | 155×180 | 20px | null | (inferred) | (inferred) | Gradient (68426:7330) |
| Rec. Card 3 | 68426:7335 | 155×180 | 20px | null | (inferred) | (inferred) | Gradient (68426:7336) |

**Total Images:** 4 (1 hero + 3 recommendations)
**Asset URLs Extracted:** 1/4 (25%)
**Border Radius Confirmed:** 1/4 (Rec. Card 1)
**Crop Mode Confirmed:** 1/4 (Rec. Card 1)

---

## Corner Handling Details

### Clipping Order (Figma Standard Behavior)
1. **Image Fill:** Applied to rounded-rectangle node
2. **Corner Radius:** Clipped to node shape (20px for cards, null for hero)
3. **Overlay:** Positioned above image with same radius
4. **Text:** Positioned above overlay (no clipping)

### Implementation Notes
- Flutter: Use `ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(...))`
- CSS: Apply `border-radius` to both `<img>` and overlay `<div>`
- Corner smoothing: Not exposed via MCP; default Figma smoothing likely applied

---

## Limitations

| Property | MCP API | REST API | Manual |
|----------|---------|----------|--------|
| Image dimensions | ✅ Yes | ✅ Yes | ✅ Yes |
| Border radius | ⚠️ Partial (via get_code Tailwind classes) | ✅ Yes | ✅ Yes |
| Asset URLs | ⚠️ Partial (some nodes only) | ✅ Yes | ✅ Yes |
| Object-fit/position | ⚠️ Partial (via get_code CSS classes) | ❌ No | ✅ Yes |
| Image fills (color, gradient, image) | ❌ No | ✅ Yes | ✅ Yes |
| Compression settings | ❌ No | ❌ No | ✅ Yes |
| Blend modes | ❌ No | ✅ Yes | ✅ Yes |
| Corner smoothing | ❌ No | ✅ Yes | ✅ Yes |

---

## Recommendations

1. **Extract Asset URLs:**
   - Use Figma REST API `GET /v1/files/:file_key/nodes?ids=68426:7329,68426:7335` → `fills[0].imageRef`
   - Then `GET /v1/images/:file_key?ids=...` to get download URLs

2. **Verify Corner Radius:**
   - Use REST API to get `cornerRadius` or `rectangleCornerRadii` for hero card (68426:7273)

3. **Confirm Crop Settings:**
   - Manual inspection in Figma Dev Mode → Inspect Panel → "Fill" section → image scaling

4. **Accessibility:**
   - Ensure alt text provided for all images (not exposed via Figma; requires manual implementation)
   - Verify overlay gradient provides sufficient contrast for text (see DASHBOARD_a11y_contrast_report.md)

---

## Next Steps

1. Call Figma REST API for missing asset URLs
2. Document image alt text requirements (from PRD/content spec)
3. Verify image compression/format (WebP for web, PNG for fallback)
4. Test responsive behavior (aspect ratio preservation, crop behavior at different sizes)
