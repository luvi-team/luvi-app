### Summary
Verifizierung der Segmentfarben im `CycleInlineCalendar` fehlt aktuell im Widget-Test. Wir benötigen einen belastbaren Nachweis, dass die CustomPainter-Segmente die erwarteten Farbwerte zeichnen.

### Problem
- Der bestehende Test (`test/features/cycle/widgets/inline_calendar_semantics_test.dart`) prüft nur das Vorhandensein des `CustomPaint`, nicht aber die tatsächlich verwendeten Farbwerte.
- Ohne Sichtprüfung kann ein Theme- oder Token-Refactor falsche Farben einschleusen, ohne dass die Tests anschlagen.

### Options (evaluate & pick one)
1. **Debug Getter für Tests (bevorzugt, falls geringe Invasivität):**
   - Introduce a debug-only getter on `CycleInlineCalendar` oder `_SegmentPainter`, der Segment-Grenzen (`startIndex`, `endIndex`) und berechnete Farben exponiert.
   - Widget-Test liest die Debug-Daten aus und stellt sicher, dass Ovulation/Ovulation-Übergänge die spezifizierten Token-Farben mit korrekter Alpha-Komponente verwenden.
2. **Golden / Pixel-Match Test:**
   - Ergänze einen Golden-Test mit `flutter_test`/`matchesGoldenFile`, der die Wochenansicht während der Ovulationsphase rendert.
   - Dokumentiere Setup (z. B. `flutter test --update-goldens`) und Plattform-Pixelabweichungen, damit CodeRabbit & CI die Erwartungsdateien prüfen können.

### Acceptance Criteria
- Entscheidung und Implementierung für eine der Optionen sind dokumentiert.
- Tests schlagen fehl, falls Segment-Farben nicht den `CyclePhaseTokens` entsprechen.
- Begleitende Doku (README/Test-Guide) beschreibt das Handling der Debug-Gitter oder Golden-Dateien.
- CI (Flutter analyze/test) bleibt grün; Golden Assets werden versioniert falls Option 2 genutzt wird.

### Owners / Follow-up
- UI/Flutter Team · Tracking-ID: `ISSUE-CYCLE-COLORS`
- Verlinke abschließenden PR/Commit in diesem Issue-Dokument.

### Notes
- Prüfe bestehende `AppTheme`-Token, um Farbreferenzen zentral zu halten.
- Falls Debug Getter gewählt wird: nur im `assertions`-Block/`foundation.dart` aktivieren, um Release-Builds nicht zu beeinflussen.
