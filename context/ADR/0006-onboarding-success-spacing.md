# ADR-0006: Onboarding Success Spacing Alignment

Status: accepted
Owner: Product Design & Flutter Core
Date: 2025-01-18

## Kontext
Das Figma-Layout für den Onboarding-Success-Screen definiert einen Abstand von 28px zwischen Trophy-Illustration und Titel. In der Flutter-Implementierung ist der Abstand auf 24px reduziert worden, um das Element-Raster (8px-Rhythmus) sowie bestehende Spacing-Tokens (`Spacing.l = 24px`) wiederzuverwenden und unnötige Sonderwerte im Design-System zu vermeiden.

## Entscheidung
- Der Abstand Trophy→Titel bleibt in Flutter bei 24px (`OnboardingSuccessTokens.gapToTitle`).
- Kein zusätzliches 28px-Token im Design-System; stattdessen nutzen wir den bestehenden 8px-Rhythmus.

## Begründung
- Halten der Token-Palette schlank reduziert Pflegeaufwand und visuellen Drift.
- 24px erfüllt weiterhin die in Figma vorgesehenen visuellen Proportionen (maximaler Abweichung < 4px auf 1x-Geräten) und bleibt innerhalb der MVP-Akzeptanzkriterien.

## Konsequenzen
- Figma-Spezifikation dokumentiert die Abweichung mit Verweis auf dieses ADR.
- Zukünftige Komponenten sollten bevorzugt bestehende 8px-basierten Tokens nutzen; neue Sonderwerte bedürfen einer separaten Design-System-Abstimmung.
