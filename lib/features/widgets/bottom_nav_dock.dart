import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/painters/bottom_wave_border_painter.dart';
import 'package:luvi_app/features/widgets/painters/wave_clip.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';

/// Bottom navigation dock with violet wave top-border and center cutout.
/// Layout: 2 tabs left (Heute, Zyklus), center gap, 2 tabs right (Puls, Profil).
/// Props: activeIndex (0..3), onTap(int), cradleColor, height (96px default), padding.
///
/// Design tokens (from Figma audit 2025-10-06, Spec-JSON):
/// - Height: 96px (dockHeight from tokens)
/// - Tab icons: 32px (tabIconSize from tokens)
/// - Center gap: formula 2 × cutoutHalfWidth = 118px (centerGap from tokens)
/// - Horizontal padding: 16px (dockPadding from tokens)
/// - Punch-out: ClipPath removes white edge under button (WavePunchOutClipper)
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
    final dsTokens = Theme.of(context).extension<DsTokens>()!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Kodex: Use colorScheme.surface (not Colors.white) for dark-mode compatibility
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveCradleColor = cradleColor ?? dsTokens.accentPurple;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent outer, clipped child has surface color
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            blurRadius: 24.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipPath(
        clipper: const WavePunchOutClipper(), // Kodex: Removes white edge under button
        child: Container(
          color: effectiveBackgroundColor, // Surface color, clipped with punch-out
          child: CustomPaint(
            painter: BottomWaveBorderPainter(
              borderColor: effectiveCradleColor,
              borderWidth: borderWidth,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: dockPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left tabs (Heute, Zyklus)
                    for (int i = 0; i < 2; i++)
                      _buildTab(tabs[i], i, activeIndex == i, context),

                    // Kodex: Center gap from formula (2 × cutoutHalfWidth = 118px)
                    const SizedBox(width: centerGap),

                    // Right tabs (Puls, Profil)
                    for (int i = 2; i < 4; i++)
                      _buildTab(tabs[i], i, activeIndex == i, context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(DockTab tab, int index, bool isActive, BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = isActive
        ? colorScheme.primary // Gold #D9B18E when active
        : colorScheme.onSurface; // Black #030401 when inactive

    return Semantics(
      label: tab.label,
      selected: isActive,
      button: true,
      child: GestureDetector(
        onTap: () => onTabTap(index),
        child: Container(
          key: tab.key,
          width: minTapArea, // Figma spec: min 44×44 for accessibility (from tokens)
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
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
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

  const DockTab({
    required this.iconPath,
    required this.label,
    this.key,
  });
}
