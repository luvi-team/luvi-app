// Bottom Navigation Design Tokens (Figma Audit 2025-10-06)
// All values derived from Spec-JSON and formulas (no magic numbers).
//
// Kodex: Formula-based constants for maintainability and dark-mode compatibility.

/// Dock container height (Figma spec: 96px, was 72px)
const double dockHeight = 96.0;

/// Wave cutout horizontal half-width (controls how wide the cradle opens)
/// Slightly wider → 86px.
const double cutoutHalfWidth = 86.0;

/// Wave cutout vertical depth (deepens the cradle). Was 38px; adjusted to 42px for better embed.
const double cutoutDepth = 42.0;

/// Desired visual gap between button bottom edge and wave top edge
/// Adds a touch more hover clearance → 12px.
const double desiredGapToWaveTop = 12.0;

/// Floating sync button outer diameter. Was 64px; reduced to 60px per visual feedback.
const double buttonDiameter = 60.0;

/// Button ring stroke width (Figma spec: 2.0px)
const double ringStrokeWidth = 2.0;

/// Icon fill ratio target (visible glyph / button diameter, Figma: 0.65 = 65%)
const double iconFillRatioK = 0.65;

/// Yin-Yang SVG glyph bounds / viewBox ratio (26px / 32px = 0.8125)
const double svgGlyphToViewBoxRatio = 26.0 / 32.0;

/// Recommended icon size for "tight" SVG export (no padding)
/// Formula: iconFillRatioK × buttonDiameter (keeps 65% fill across sizes)
const double iconSizeTight = iconFillRatioK * buttonDiameter; // e.g., 0.65 × 60 = 39px

/// Compensated icon size for current SVG (with 3px padding on all sides)
/// Formula: iconSizeTight / svgGlyphToViewBoxRatio = 39 / 0.8125 ≈ 48px
const double iconSizeCompensated = iconSizeTight / svgGlyphToViewBoxRatio;

/// Center gap between left and right tab groups (formula: 2 × cutoutHalfWidth)
/// = 2 × 86 = 172px (no hard-coded value)
const double centerGap = 2 * cutoutHalfWidth;

/// Small vertical inset to draw the wave path fully inside the dock to avoid
/// a subpixel AA hairline along the dock top edge.
const double waveTopInset = 1.0;

/// Sync button bottom position (distance from dock bottom to button bottom)
/// Formula: dockHeight - (cutoutDepth + waveTopInset) + desiredGap
const double syncButtonBottom =
    dockHeight - (cutoutDepth + waveTopInset) + desiredGapToWaveTop;

/// Punch-out radius for ClipPath (no white line under button)
/// Strategy: ensure the circular punch-out fully covers the wave stroke area.
/// - Option A (button-based): (buttonDiameter/2 + ringStrokeWidth/2) + epsilon
/// - Option B (coverage-based): cutoutDepth + 4px → extra AA headroom; guarantees coverage to y<=0
/// Use the safer of both values to avoid a faint line at the top edge on some devices.
const double _punchOutByButton = (buttonDiameter / 2) + (ringStrokeWidth / 2) + 2.0;
const double _punchOutByCoverage = cutoutDepth + 4.0;
const double punchOutRadius =
    _punchOutByButton > _punchOutByCoverage ? _punchOutByButton : _punchOutByCoverage;

/// Wave stroke width (Figma spec: 1.5px)
const double waveStrokeWidth = 1.5;

/// Wave cubic control point factors (for fine-tuning the silhouette)
/// alpha controls horizontal offset from endpoints (approximate circle arc = 0.55)
/// beta controls center-side proximity (0.275 is a balanced default)
const double waveCpAlpha = 0.58; // slightly further inward for smoother shoulders
const double waveCpBeta = 0.36; // less pointed in the center

/// Tab icon size (Figma spec: 32px, was 24px)
const double tabIconSize = 32.0;

/// Minimum tap area for accessibility (unchanged: 44px)
const double minTapArea = 44.0;

/// Horizontal padding for dock content (unchanged: 16px)
const double dockPadding = 16.0;

/// Conservative extra spacing inside the left and right tab groups
/// (between Home↔Flower and Diagram↔Profile). Keeps outer tabs anchored.
const double innerGapLeftGroup = 28.0;
const double innerGapRightGroup = 28.0;
