# ONB_05 Figma Specs: Periodendauer-Auswahl

**Quelle:** Figma `iQthMdxpCbl6afzXxvzqlt` / Node `68214:6243`
**Screen:** 05_Onboarding (Step 5/7)
**Datum:** 2025-10-01

---

## 1. Header (y=0–112)

| Element | x | y | w | h | Token | Notes |
|---------|---|---|---|---|-------|-------|
| Back Button | 20 | 59 | 40 | 40 | — | ⚠️ **Visuals 40×40, Hit-Area MUSS 44×44 sein** (WCAG 2.1 AA) |
| Titel "Erzähl mir von dir 💜" | center | 79 | 388 | 32 | — (Playfair 24/32, custom) | Gemeinsame Baseline y=79 |
| Step Indicator "5/7" | right (center+194) | 79 | — | 24 | `Callout` (Inter Medium 16/24) | Gemeinsame Baseline y=79 |

**Gemeinsame Baseline:** Alle 3 Elemente zentriert auf y=79.

---

## 2. Vertikales Spacing

| Von | Nach | Abstand (px) |
|-----|------|--------------|
| Header-Bottom (y=112) | Frage-Top (y=154) | **42** |
| Frage-Bottom (y=202) | 1. Option-Top (y=244) | **42** |
| **Option-Gap** (zwischen Karten) | — | **24** |
| Letzte Option-Bottom (y=546) | Callout-Top (y=612) | **66** |
| Callout-Bottom (y=758) | CTA-Top (y=800) | **42** |
| CTA-Bottom (y=850) | Home-Top (y=892) | **42** |

**Option-Details:**
- Option 1: y=244–307 (h=63)
- Option 2: y=307–371 (h=64) → Gap 24px vor y=307
- Option 3: y=395–458 (h=63) → Gap 24px vor y=395
- Option 4: y=482–546 (h=64) → Gap 24px vor y=482

---

## 3. Frage-Element

| Property | Value | Token |
|----------|-------|-------|
| **Text** | "Wie lange dauert deine Periode\nnormalerweise?" | — |
| **Typografie** | Figtree Regular 20/24 | `Body/Regular` |
| **Alignment** | Center | — |
| **Zeilen** | 2 | — |

---

## 4. Options-Karten (4× Single-Select Radio)

| Property | Value | Token | Notes |
|----------|-------|-------|-------|
| **Außenmaße** | w=346, h=63/64 | — | Höhe variiert (63 oder 64 px) |
| **Corner Radius** | 20 | — | |
| **Border** | none (default), 1px solid #1C1411 (selected) | `Grayscale/Black` | |
| **Shadow** | none | — | |
| **Innen-Padding** | 16 (horizontal), 20 (vertical) | — | |
| **Typografie** | Figtree Regular 16/24 | `Regular klein` | |
| **Max-Zeilen** | 1 (alle Labels einzeilig) | — | |
| **Single-Select** | ✅ Ja | — | Radio-Pattern (nur 1 aktiv) |

### States

| State | Background | Border | Radio Visual |
|-------|------------|--------|--------------|
| **default** | #F7F7F8 | none | Gray circle (outline, keine Füllung) |
| **selected** | #F7F7F8 | 1px solid #1C1411 | Gold circle (#D9B18E, keine zusätzliche Border) |

**Radio Visual Details:**
- **Default:** Circle-Ellipse mit grauem Outline (kein Fill)
- **Selected:** Gold-filled circle (#D9B18E), **kein extra schwarzer Ring**

---

## 5. CTA Button

| Property | Value | Token | Notes |
|----------|-------|-------|-------|
| **Maße** | 388×50 | — | |
| **Corner Radius** | 12 | — | |
| **Label** | "Weiter" | — | |
| **Typografie** | Figtree Bold 20/24, Grayscale/White (#FFFFFF) | `Button` | brand-driven contrast exception; re-validate vs #D9B18E |
| **Background** | #D9B18E | `Primary color/100` | |
| **Disabled-State** | ⚠️ **nicht spezifiziert** | — | In Figma nicht vorhanden |

---

## 6. Callout (Hinweis-Box)

| Property | Value | Token | Notes |
|----------|-------|-------|-------|
| **Maße** | w=312, h=146 | — | |
| **Corner Radius** | ⚠️ nicht explizit (vermutlich 20, wie Option-Karten) | — | |
| **Border** | ⚠️ **nicht sichtbar** | — | Kein violett-border im Screenshot |
| **Padding** | implicit (Text centered) | — | Kein Box-Container im Code |
| **Typografie** | Figtree Regular 14/24 | `Regular klein 14` | |
| **Bold-Span** | ❌ Nein (plain paragraph) | — | Kein bold im Text |

**Text:** "Wir brauchen diesen Ausgangspunkt, um deine aktuelle Zyklusphase zu berechnen. Ich lerne mit dir mit und passt die Prognosen automatisch an, sobald du deine nächste Periode einträgst."

---

## 7. Tokens

| Token Name | Value | Type | Usage |
|------------|-------|------|-------|
| `Grayscale/White` | #FFFFFF | Color | Background, CTA label (brand-driven exception; verify contrast) |
| `Grayscale/Black` | #030401 | Color | Text (excludes CTA label), Selected Border |
| `Grayscale/100` | #F7F7F8 | Color | Option Card BG |
| `Primary color/100` | #D9B18E | Color | CTA BG, Selected Radio |
| `Body/Regular` | Figtree 20/24 | Typography | Frage |
| `Regular klein` | Figtree 16/24 | Typography | Option Labels |
| `Regular klein 14` | Figtree 14/24 | Typography | Callout |
| `Button` | Figtree Bold 20/24 | Typography | CTA label |
| `Callout` | Inter Medium 16/24 | Typography | Step Indicator (5/7) |

⚠️ **Titel-Typo (Playfair 24/32) nicht als Token vorhanden** → custom font (außerhalb Design-System).

---

## 8. A11y

| Element | Semantics Label | Tap Target | Notes |
|---------|----------------|------------|-------|
| Back Button | "Zurück" | ⚠️ **40×40 → erweitern zu 44×44** | WCAG 2.1 AA min. 44pt |
| Titel | "Schritt 5 von 7: Erzähl mir von dir" | — | Header (emoji excludeSemantics) |
| Frage | "Wie lange dauert deine Periode normalerweise?" | — | Heading |
| Option-Liste | "Periodendauer auswählen" | — | RadioGroup (single-select) |
| Option 1 | "Weniger als 3 Tage" | ✅ 346×63 (>44pt) | Radio button semantics |
| Option 2 | "Zwischen 3 und 5 Tage" | ✅ 346×64 (>44pt) | Radio button semantics |
| Option 3 | "Zwischen 5 und 7 Tage" | ✅ 346×63 (>44pt) | Radio button semantics |
| Option 4 | "Mehr als 7 Tage" | ✅ 346×64 (>44pt) | Radio button semantics |
| Callout | "Hinweis: [Text]" | — | Announcement (informational) |
| CTA | "Weiter" | ✅ 388×50 (>44pt) | Button |

---

## 9. Implementierungs-Notes

1. **Back Button Hit-Area:** Visuals 40×40, aber **semantische Tap-Area MUSS 44×44** sein (MaterialButton inkTapTargetSize: padded).
2. **Radio Visual:** Kein schwarzer Ring um gold circle bei selected-state (nur gold fill).
3. **Callout:** Kein expliziter Border im Design; Text plain (kein bold-Span).
4. **Disabled-State (CTA):** Nicht in Figma spezifiziert → Implementierung nach LUVI-Theme (z. B. opacity 0.5, grauer BG).
5. **Option-Gap:** Konsistent **24px** zwischen allen Karten.
6. **Titel-Font:** Playfair 24/32 (nicht im Token-System) → custom font declaration erforderlich.

---

## Changelog
- 2025-10-01: Initial specs from Figma node `68214:6243`
