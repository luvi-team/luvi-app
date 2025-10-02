# Onboarding 02 – Figma Mismatches

Quellenreferenz: `docs/audits/ONB_02_figma_specs.md` (Stand: 2025-09-30).

## Abweichungen gegenüber Spezifikation

- Header-Abstand: Figma verlangt 79 px bis zur Header-Basislinie; Implementierung skaliert den Abstand dynamisch (`OnboardingSpacing.headerToInstruction`, Basis 75 px). Dokumentierte Abweichung akzeptiert (responsive Anpassung) – kein unmittelbarer Fix nötig, aber als bewusstes Delta markiert.
- CTA-Button: Figma definiert 50 px Höhe bei 388 px Breite; Implementierung nutzt Theme-Buttons ohne feste Breite. Breiten-Spannung stimmt (streckt auf 100 %), Höhe erfüllt 50 px. Kein Handlungsbedarf.
- Picker-Lokalisierung: Monatsnamen laut Spezifikation vollständig Deutsch. Implementierung übernimmt Monatsnamen via `_formatDateGerman`, deutsches Mapping vorhanden. ✓

### Status
Keine kritischen Mismatches offen; Dokumentation bestätigt, dass Abweichungen intentional bzw. durch responsive Tokens abgedeckt sind.
