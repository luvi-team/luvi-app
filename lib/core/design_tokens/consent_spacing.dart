import 'package:flutter/widgets.dart';

/// Spacing tokens specific to the consent flow.
class ConsentSpacing {
  const ConsentSpacing._();

  // Base page paddings (mirrors Figma 24px horizontal rhythm).
  static const double pageHorizontal = 24.0;
  static const double topBarSafeAreaOffset = 12.0;
  static const double topBarButtonToTitle = 7.0;

  // Consent Screen Specific (Figma Refactor 2024-12)
  /// Gap between major consent sections. Used after dividers.
  /// Currently 16px per Figma; may differ from [checkboxItemGap] in future.
  static const double sectionGap = 16.0;
  static const double buttonGapC2 = 16.0; // Between buttons on C2 (Options) - 16px per Figma
  static const double buttonGapC3 = 16.0; // Between buttons on C3 (Blocking)
  static const double checkboxSize = 24.0;
  static const double checkboxInnerSize = 14.0;
  static const double checkboxBorderWidth = 2.0;

  // Consent Options Screen Specific (Figma Alignment 2026-01)
  /// Shield icon width from Figma (209px)
  static const double shieldIconWidth = 209.0;

  /// Shield icon height from Figma (117px)
  static const double shieldIconHeight = 117.0;

  /// Teal divider height from Figma (2px)
  static const double dividerHeight = 2.0;

  /// Gap between checkbox items (Health↔Terms): 16px.
  /// Semantically distinct from [sectionGap] - controls intra-section spacing.
  /// May diverge from [sectionGap] if Figma design evolves.
  static const double checkboxItemGap = 16.0;

  /// Gap between last checkbox item and divider: 11px
  static const double itemToDividerGap = 11.0;

  /// CTA button max width: 300px (responsive on smaller screens)
  static const double ctaButtonMaxWidth = 300.0;

  // Card list paddings and gaps.
  static const double listPaddingTop = 24.0;
  static const double listPaddingBottom = 24.0;
  static const double cardGap = 20.0;
  static const double cardPaddingHorizontal = 16.0;
  static const double cardPaddingVertical = 35.0;

  // Footer spacing rhythm.
  static const double footerPaddingTop = 8.0; // Reduced to bring buttons closer to bottom
  static const double footerHintToPrimaryCta = 12.0;
  static const double footerPrimaryToSecondaryCta = 15.0;
  static const double footerPaddingBottom = 20.0;
  static const double ctaBottomInset = 0.0; // Buttons sit directly above safe area per Figma

  /// Estimated height of the sticky footer to add as bottom padding to lists
  /// so content is not obscured by the footer overlay.
  static const double footerEstimatedHeight = 180.0;

  // Pre-baked paddings (kept here to avoid per-call allocations).
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(
    pageHorizontal,
    listPaddingTop,
    pageHorizontal,
    listPaddingBottom,
  );
  static const EdgeInsets footerPadding = EdgeInsets.fromLTRB(
    pageHorizontal,
    footerPaddingTop,
    pageHorizontal,
    footerPaddingBottom,
  );
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: cardPaddingHorizontal,
    vertical: cardPaddingVertical,
  );
}
