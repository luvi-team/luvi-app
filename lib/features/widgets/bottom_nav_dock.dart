import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/painters/bottom_wave_border_painter.dart';
import 'package:luvi_app/core/design_tokens/bottom_nav_tokens.dart';

/// Bottom navigation dock with violet wave top-border and center cutout.
/// Layout: 2 tabs left (Heute, Zyklus), center gap, 2 tabs right (Puls, Profil).
/// Props: activeIndex (0..3), onTap(int), cradleColor, height (96px default), padding.
///
/// Design tokens (from Figma audit 2025-10-06, Spec-JSON):
/// - Height: 96px (dockHeight from tokens)
/// - Tab icons: 32px (tabIconSize from tokens)
/// - Center gap: formula 2 × cutoutHalfWidth = 118px (centerGap from tokens)
/// - Horizontal padding: 16px (dockPadding from tokens)
///
/// Kodex: Formula-based parameters (no magic numbers), dark-mode ready (surface/tokens).
class BottomNavDock extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabTap;
  final List<DockTab> tabs;
  final double height;
  final Color? backgroundColor;
  final Color? cradleColor;
  final double borderWidth;

  const BottomNavDock({
    super.key,
    required this.activeIndex,
    required this.onTabTap,
    required this.tabs,
    this.height = dockHeight, // Figma spec: 96px (from tokens)
    this.backgroundColor,
    this.cradleColor,
    this.borderWidth = waveStrokeWidth, // Figma spec: 1.5px (from tokens)
  });

  @override
  Widget build(BuildContext context) {
    final dsTokens = Theme.of(context).extension<DsTokens>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Kodex: Use colorScheme.surface (not Colors.white) for dark-mode compatibility
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    // Safe fallback if theme extension is not registered (visible in release builds)
    assert(
      dsTokens != null,
      'BottomNavDock: DsTokens theme extension not found. '
      'Ensure DsTokens is registered in app_theme.dart extensions list.',
    );
    final effectiveCradleColor =
        cradleColor ?? dsTokens?.accentPurple ?? colorScheme.primary;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors
            .transparent, // Outer: transparent, inner carries surface color
        // Remove outer box shadow to avoid any top-edge halo/line
        boxShadow: [],
      ),
      // Important: No ClipPath punch-out → avoids transparent hole (grey disc from content behind)
      child: Container(
        color: Colors
            .transparent, // Painter handles fill; keep mulde transparent for underlay
        child: CustomPaint(
          painter: BottomWaveBorderPainter(
            borderColor: effectiveCradleColor,
            borderWidth: borderWidth,
            fillColor: effectiveBackgroundColor,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: dockPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Compute dynamic center gap to prevent overflow while keeping
                  // at least the visual clearance required by the wave cutout.
                  final double available = constraints.maxWidth;
                  const double tabW = minTapArea; // 44 px
                  const double leftGroupW = tabW + innerGapLeftGroup + tabW;
                  const double rightGroupW = tabW + innerGapRightGroup + tabW;
                  // Remainder for the center gap; allow it to shrink below the wave
                  // cutout width to avoid overflow on narrow viewports.
                  final double computedCenter =
                      available - leftGroupW - rightGroupW;
                  final double effectiveCenterGap = math.max(
                    0.0,
                    computedCenter,
                  );

                  final row = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left group: Home, inner gap, Flower (Home stays anchored)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab(tabs[0], 0, activeIndex == 0, context),
                          const SizedBox(width: innerGapLeftGroup),
                          _buildTab(tabs[1], 1, activeIndex == 1, context),
                        ],
                      ),

                      // Dynamic center gap (shrinks as needed to prevent overflow)
                      SizedBox(width: effectiveCenterGap),

                      // Right group: Diagram, inner gap, Profile (Profile stays anchored)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab(tabs[2], 2, activeIndex == 2, context),
                          const SizedBox(width: innerGapRightGroup),
                          _buildTab(tabs[3], 3, activeIndex == 3, context),
                        ],
                      ),
                    ],
                  );

                  if (computedCenter < 0.0) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: row,
                    );
                  }
                  return row;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    DockTab tab,
    int index,
    bool isActive,
    BuildContext context,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = isActive
        ? colorScheme
              .primary // Gold #D9B18E when active
        : colorScheme.onSurface; // Black #030401 when inactive

    return Semantics(
      label: tab.label,
      selected: isActive,
      button: true,
      child: GestureDetector(
        onTap: () => onTabTap(index),
        child: Container(
          key: tab.key,
          width:
              minTapArea, // Figma spec: min 44×44 for accessibility (from tokens)
          height: minTapArea,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: SvgPicture.asset(
              tab.iconPath,
              width: tabIconSize, // Figma spec: 32px (from tokens)
              height: tabIconSize,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab configuration for dock navigation.
class DockTab {
  final String iconPath;
  final String label;
  final Key? key;

  const DockTab({required this.iconPath, required this.label, this.key});
}
