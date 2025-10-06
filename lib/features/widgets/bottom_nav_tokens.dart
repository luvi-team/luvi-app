/// Bottom Navigation Design Tokens (Figma Audit 2025-10-06)
/// All values derived from Spec-JSON and formulas (no magic numbers).
///
/// Kodex: Formula-based constants for maintainability and dark-mode compatibility.
library;

/// Dock container height (Figma spec: 96px, was 72px)
const double dockHeight = 96.0;

/// Wave cutout horizontal half-width (Figma spec: 59px)
const double cutoutHalfWidth = 59.0;

/// Wave cutout vertical depth (Figma spec: 38px, was 25px)
const double cutoutDepth = 38.0;

/// Desired visual gap between button bottom edge and wave top edge (Figma: 9px)
const double desiredGapToWaveTop = 9.0;

/// Floating sync button outer diameter (Figma spec: 64px, was 52px)
const double buttonDiameter = 64.0;

/// Button ring stroke width (Figma spec: 2.0px)
const double ringStrokeWidth = 2.0;

/// Icon fill ratio target (visible glyph / button diameter, Figma: 0.65 = 65%)
const double iconFillRatioK = 0.65;

/// Yin-Yang SVG glyph bounds / viewBox ratio (26px / 32px = 0.8125)
const double svgGlyphToViewBoxRatio = 26.0 / 32.0;

/// Recommended icon size for "tight" SVG export (no padding)
/// Formula: iconFillRatioK × buttonDiameter = 0.65 × 64 ≈ 41.6 → 42px
const double iconSizeTight = 42.0;

/// Compensated icon size for current SVG (with 3px padding on all sides)
/// Formula: iconSizeTight / svgGlyphToViewBoxRatio = 42 / 0.8125 ≈ 51.7px
const double iconSizeCompensated = iconSizeTight / svgGlyphToViewBoxRatio;

/// Center gap between left and right tab groups (formula: 2 × cutoutHalfWidth)
/// = 2 × 59 = 118px (no hard-coded value)
const double centerGap = 2 * cutoutHalfWidth;

/// Sync button bottom position (formula: dockHeight - cutoutDepth - desiredGap)
/// = 96 - 38 - 9 = 49px (was 62px with old depth 25px)
const double syncButtonBottom = dockHeight - cutoutDepth - desiredGapToWaveTop;

/// Punch-out radius for ClipPath (no white line under button)
/// Formula: (buttonDiameter/2 + ringStrokeWidth/2) + epsilon
/// = (64/2 + 2/2) + 2 = 32 + 1 + 2 = 35px
const double punchOutRadius = (buttonDiameter / 2) + (ringStrokeWidth / 2) + 2.0;

/// Wave stroke width (Figma spec: 1.5px)
const double waveStrokeWidth = 1.5;

/// Tab icon size (Figma spec: 32px, was 24px)
const double tabIconSize = 32.0;

/// Minimum tap area for accessibility (unchanged: 44px)
const double minTapArea = 44.0;

/// Horizontal padding for dock content (unchanged: 16px)
const double dockPadding = 16.0;
