import 'package:flutter/widgets.dart';

/// Spacing tokens specific to the consent flow.
class ConsentSpacing {
  const ConsentSpacing._();

  // Base page paddings (mirrors Figma 20px horizontal rhythm).
  static const double pageHorizontal = 20.0;
  static const double topBarSafeAreaOffset = 12.0;
  static const double topBarButtonToTitle = 7.0;

  // Card list paddings and gaps.
  static const double listPaddingTop = 24.0;
  static const double listPaddingBottom = 24.0;
  static const double cardGap = 20.0;
  static const double cardPaddingHorizontal = 16.0;
  static const double cardPaddingVertical = 35.0;

  // Footer spacing rhythm.
  static const double footerPaddingTop = 12.0;
  static const double footerHintToPrimaryCta = 12.0;
  static const double footerPrimaryToSecondaryCta = 15.0;
  static const double footerPaddingBottom = 20.0;
  static const double ctaBottomInset = 44.0;

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
