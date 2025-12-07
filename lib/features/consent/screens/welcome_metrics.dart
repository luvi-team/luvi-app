// Single source of truth for Welcome screen metrics.
// Invariants: ONLY hero aspect & wave height. No style/text changes here.
//
// Figma reference: 393×852px (iPhone 14 Pro)
// Hero: 393×569px (full-width, top-aligned)
// Wave: 321px height, starts at Y=531
const double kWelcomeHeroAspect = 393 / 569; // ≈ 0.69
const double kWelcomeWaveHeight = 321; // Figma wave height
