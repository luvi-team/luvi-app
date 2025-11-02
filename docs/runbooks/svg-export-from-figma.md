# Asset Export aus Figma (SVG vs PNG)

## Format-Wahl: SVG oder PNG?

**Entscheidungsmatrix:**

| Asset-Typ | Empfohlenes Format | Begründung |
|-----------|-------------------|------------|
| Einfache Icons (< 10 Pfade) | ✅ SVG | Skalierbar, kleine Dateigröße |
| Logos, Buttons | ✅ SVG | Scharfe Kanten bei allen Größen |
| Flache Designs ohne Layering | ✅ SVG | Einfache Struktur, gut unterstützt |
| Komplexe Illustrationen (> 20 Elemente) | ✅ PNG | Pixel-perfect, keine Koordinaten-Probleme |
| Grafiken mit absoluten Positionen | ✅ PNG | Garantierte 1:1 Übereinstimmung mit Figma |
| Kompositionen aus mehreren Gruppen | ✅ PNG | Vermeidet viewBox/Transform-Probleme |

**Faustregel:** Wenn Unsicher → PNG (MIWF: "Make it work first")

---

## Problem (nur bei SVG)
Figma exportiert SVGs mit CSS-Variablen (`var(--fill-0, #HEXCOLOR)`), die `flutter_svg` nicht unterstützt. Das führt zu komplett schwarzen SVG-Renderings in der App.

## Symptom
- SVG wird in Figma korrekt mit Farben angezeigt
- Nach Export und Integration in Flutter: SVG ist komplett schwarz
- Keine Console-Errors, `flutter_svg` rendert ohne Fehler

## Root Cause
`flutter_svg` unterstützt keine CSS Custom Properties (CSS-Variablen). Figma exportiert standardmäßig mit Pattern `fill="var(--fill-0, #FBC343)"`, wobei nur der Fallback-Wert für uns relevant ist.

## Lösung

### Schritt 1: SVG aus Figma exportieren

1. Figma öffnen, gewünschte Node/Group auswählen
2. Export Settings:
   - Format: **SVG**
   - ✅ **Outline stroke** (optional, für bessere Kompatibilität)
   - ❌ **Flatten** NICHT aktivieren (verliert Layer-Struktur)
3. Exportieren nach `assets/images/<category>/`

### Schritt 2: CSS-Variablen durch Farben ersetzen

```bash
# Im Projekt-Root ausführen
python3 scripts/fix_svg_css_variables.py <pfad-zur-svg-datei>

# Beispiel:
python3 scripts/fix_svg_css_variables.py assets/images/onboarding/onboarding_success_trophy.svg
```

Das Script:
- Findet alle `var(--fill-N, FARBE)` Patterns
- Ersetzt sie durch die Fallback-Farbe (`FARBE`)
- Schreibt zunächst in eine temporäre Datei `<datei>.svg.tmp`; nur der abschließende Rename/Replace des Originals ist auf den meisten Dateisystemen atomar (das Original bleibt bis zu diesem finalen Schritt unverändert). Die Schreiboperation in die temporäre Datei selbst ist nicht atomar.
- Überschreibt die Originaldatei ohne automatisches Backup – Empfehlung: vor dem Lauf manuell eine Kopie anlegen, wenn du die Figma-Version behalten möchtest
- Gibt Statistik aus (gefundene/ersetzte CSS-Variablen)

### Schritt 3: Verifizieren

1. **Hot Restart** (nicht Hot Reload!) der Flutter-App
2. Visueller Check: Farben korrekt?
3. Vergleich mit Figma-Screenshot

## Wann ist dieser Fix NICHT nötig?

- SVG enthält keine CSS-Variablen (prüfe mit `grep "var(--" <datei>.svg`)
- Asset wird als PNG exportiert
- Figma-Plugin mit direkter Flutter-Export-Option genutzt (falls verfügbar)

## PNG Export (Empfohlene Methode für komplexe Assets)

**Wann PNG nutzen:**
- Komplexe Illustrationen (z.B. Onboarding Success Trophy: 48 Elemente)
- Grafiken mit Layering/Kompositionen
- Wenn pixel-perfect Match mit Figma kritisch ist
- Wenn SVG-Koordinaten-Probleme auftreten

**Vorteil:** Garantierte 1:1 Übereinstimmung, keine CSS-Probleme, keine Positionierungs-Bugs

1. Figma Export Settings: **PNG**
2. Drei Auflösungen exportieren:
   - `@1x` (Base size, z.B. 308×300)
   - `@2x` (Doppelte Größe)
   - `@3x` (Dreifache Größe)
3. Dateibenennung:
   ```
   assets/images/<category>/asset_name.png
   assets/images/<category>/asset_name@2x.png
   assets/images/<category>/asset_name@3x.png
   ```
4. Flutter-Code anpassen:
   ```dart
   // Von:
   SvgPicture.asset(Assets.images.assetName)

   // Zu:
   Image.asset(Assets.images.assetName)
   ```

**Trade-off:** PNG ist größer (Dateigröße), skaliert schlechter, aber garantiert 1:1 Übereinstimmung mit Figma.

## Häufige Fehler

### ❌ "Hot Reload statt Hot Restart"
**Symptom:** SVG bleibt schwarz nach Fix
**Lösung:** App komplett neu starten (`flutter run` oder `R` im Terminal)

### ❌ "Script findet Datei nicht"
**Symptom:** `FileNotFoundError`
**Lösung:** Relativer Pfad vom Projekt-Root, nicht von `scripts/`

### ❌ "SVG hat immer noch CSS-Variablen nach Script"
**Symptom:** `grep "var(--"` zeigt noch Treffer
**Lösung:** Script-Output prüfen; bei Regex-Edge-Case manuell ersetzen:
- Häufige Fälle: verschachtelte `var(--token, var(--fallback))`, vendor-prefixed Fallbacks (`-webkit-`, `-moz-`), oder Tokens mit Kommentaren am Zeilenende.
- Öffne das SVG im Editor oder nutze `rg "var\\(--" <datei>.svg`, finde z. B. `fill="var(--fill-4, #FBC343)"` und ersetze den gesamten Ausdruck durch `fill="#FBC343"`.
- Für mehrere Vorkommen kannst du den Python-Script anpassen oder manuell mit einem Editor mehrfach suchen/ersetzen
- Alternativ (nur macOS/Linux): `sed -E 's/var\\(--[^,]+, ([^)]*)\)/\1/g' asset.svg > asset_fixed.svg && mv asset_fixed.svg asset.svg`

## Checkliste (Asset-Integration)

- [ ] SVG aus Figma exportiert (korrekte Export Settings)
- [ ] `fix_svg_css_variables.py` ausgeführt
- [ ] `grep "var(--" <datei>.svg` → keine Treffer
- [ ] Asset-Pfad in `assets.dart` registriert
- [ ] Hot Restart durchgeführt
- [ ] Visueller Vergleich mit Figma-Screenshot ✅
- [ ] Widget-Test für Asset-Größe/Existenz geschrieben

## Verweise

- Script: `scripts/fix_svg_css_variables.py`
- UI-Checklist: `docs/engineering/checklists/ui.md` (Asset-Processing)
- Assets-Klasse: `lib/core/design_tokens/assets.dart`
- Figma Audit Template: `docs/audits/README.md`

## Changelog

- 2025-10-22: Initial version (Onboarding Success Trophy Fix)
