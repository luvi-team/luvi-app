# UI/Frontend Checklist (Flutter · Riverpod · GoRouter)

Ziel: Schneller, konsistenter, DSGVO‑sicherer UI‑Output. 1‑Seiten‑Spickzettel für Reviews und Self‑Checks.

Architektur & Navigation
- Feature‑First Ordnerstruktur pro Feature (UI/State/Model zusammenhalten).
- GoRouter Redirects für Auth/Onboarding; Dev‑Bypässe nur per Flag.
- Keine unguarded Navigation auf geschützte Screens; Deep Links prüfen.

State & Theming
- Riverpod: Immutables, passende Provider (Notifier/Future/Stream), `AsyncValue.when` nutzen.
- Design‑Tokens zentral (Farben, Typo, Spacing); ThemeExtensions statt Magic Numbers.
- i18n per ARB (de/en); keine Hard‑Strings im Code.

Barrierefreiheit (WCAG 2.2 AA)
- Kontrast: Text ≥ 4.5:1; Icons/Grafik ≥ 3:1.
- Semantics/Labels für interaktive Icons/Controls vorhanden; Fokus‑Reihenfolge logisch.
- Dynamische Textskalierung ≥ 200% ohne Überlappungen; Touch‑Ziele ≥ 48dp.

Performance
- Start: teure Inits nach dem ersten Frame; lazy laden.
- Rebuilds minimieren (`const`, Teilbäume, selektive Provider‑Watches).
- Listen: `ListView.builder`/Slivers; Bilder in passender Größe, SVGs vorsichtig.
- Schwere Arbeit in Isolates (`compute`) auslagern.

Tests (DoD)
- ≥ 1 Unit + ≥ 1 Widget pro Story; Navigations‑/Semantics‑Tests bei Bedarf.
- L10n‑Smoke pro unterstützter Sprache.

Privacy by Design
- Keine PII in UI‑Logs; sensible Zustände nicht serialisieren.
- Screenshot‑Schutz/Blur für besonders sensible Screens erwägen.

Quick Wins
- `const` breit setzen; Contrast‑Check der Palette; `.builder` für lange Listen; `AsyncValue.when` durchgängig; `debugPrint` im Release unterbinden.

Review‑Fragen (Kurz)
- Sind Guards/Redirects korrekt? Sind Loading/Error/Empty‑Zustände präsent? Besteht A11y‑Kontrast/Labels? Gibt es unnötige Rebuild‑Hotspots?

