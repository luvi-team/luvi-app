import 'package:flutter/material.dart';

/// Design token class for spacing values throughout the app.
///
/// All spacing values are defined as static constants.
/// For EdgeInsets, use the getter methods to maintain MUST-02 compliance
/// (no inline EdgeInsets in widget code).
class Spacing {
  static const double xl = 32.0; // extra large (e.g., hero to content)
  static const double l = 24.0; // large (e.g., section gaps)
  static const double m = 16.0; // medium (e.g., between CTAs)
  static const double s = 12.0; // small (title -> subtitle)
  static const double recommendationCardPadding =
      14.0; // aligns with DASHBOARD_spec card padding
  static const double heroInfoCardPadding =
      14.0; // medium-small padding for hero info card rail
  static const double xs = 8.0; // extra small (breathing space)
  static const double xxxs = 6.0; // between xxs(4) and xs(8) - edge case spacing
  static const double xxs = 4.0; // micro spacing (tight gaps)
  static const double micro = 2.0; // sub-xxs for tight layouts (e.g., heute_header)

  /// Standard horizontal screen padding (Figma: 24px)
  static const double screenPadding = l;
  static const double goalCardVertical =
      20.0; // dedicated padding for goal cards
  static const double goalCardIconGap =
      20.0; // spacing between icon and text in goal cards

  /// Top recommendation tile horizontal padding (Figma: 18px)
  static const double topRecommendationPadH = 18.0;

  /// Welcome content bottom padding (Figma: 52px from bottom edge)
  static const double welcomeBottomPadding = 52.0;

  /// Gap between subtitle and CTA on welcome screens (W5)
  static const double welcomeCtaGap = 40.0;

  /// Welcome CTA bottom spacing to home indicator (Figma Rebrand: 38px)
  static const double welcomeCtaBottomPadding = 38.0;

  /// Welcome Hero top offset from safeTop (Figma: 44px for 24px gap after dots)
  /// Calculation: dotsTop(16) + dotsHeight(4) + gap(24) = 44
  static const double welcomeHeroTopOffset = 44.0;

  /// Welcome Textblock heights per page (Figma SSOT)
  /// W1: 3 lines × 36px line-height = 108px
  /// W2: 2 lines × 38px + padding = 108px (same as W1 for consistency)
  /// W3: Headline 41px + gap 8px + Subline 26px = 75px
  static const double welcomeTextBlockHeightW1W2 = 108.0;
  static const double welcomeTextBlockHeightW3 = 75.0;

  /// Auth SignIn glass card vertical padding (Figma: 32px = l + xs)
  static const double authGlassCardVertical = l + xs;

  // ─── Onboarding Specific (Figma Onboarding 2024-12) ───

  /// Onboarding CTA button horizontal padding (Figma: 40px)
  static const double onboardingButtonHorizontal = 40.0;

  /// Calendar mini widget padding (Figma: 20px)
  static const double calendarMiniPadding = 20.0;

  // ─── O9 Success Screen Card Spacing (Figma O9 2024-12) ───

  /// Success Card 1 (left) top padding (Figma: 4px)
  static const double successCard1PaddingTop = 4.0;

  /// Success Card 1 (left) horizontal padding (Figma: 7px)
  static const double successCard1PaddingHorizontal = 7.0;

  /// Success Card 1 (left) bottom padding (Figma: 13px)
  static const double successCard1PaddingBottom = 13.0;

  /// Success Card 1 (left) gap between image and text (Figma: 3px)
  static const double successCard1Gap = 3.0;

  /// Success Card 2 (right) vertical padding (Figma: 15px)
  static const double successCard2PaddingVertical = 15.0;

  /// Success Card 2 (right) left padding (Figma: 5px)
  static const double successCard2PaddingLeft = 5.0;

  /// Success Card 2/3 (right/bottom) right padding - image spacing from border
  /// Changed from 0px to 5px for consistent spacing (matches successCard3Gap)
  static const double successCard2PaddingRight = 5.0;

  /// Success Card 2 (right) gap between text and image (Figma: 11px)
  static const double successCard2Gap = 11.0;

  /// Success Card 3 (bottom) gap between text and image (Figma: closer to text)
  /// Smaller gap than Card2 to bring image closer to text per Plan v3 Final
  static const double successCard3Gap = 5.0;

  // ─── EdgeInsets Getters (MUST-02 Compliance) ───

  /// Success Card 1 (left/top) padding with scale factor.
  /// Figma: 4px top, 7px horizontal, 13px bottom
  static EdgeInsets successCard1Padding(double scale) {
    assert(scale > 0 && scale <= 10, 'scale must be between 0 (exclusive) and 10');
    return EdgeInsets.fromLTRB(
      successCard1PaddingHorizontal * scale,
      successCard1PaddingTop * scale,
      successCard1PaddingHorizontal * scale,
      successCard1PaddingBottom * scale,
    );
  }

  /// Success Card 2/3 (horizontal cards) padding with scale factor.
  /// Figma: 15px vertical, 5px left, 5px right
  static EdgeInsets successCard2Padding(double scale) {
    assert(scale > 0 && scale <= 10, 'scale must be between 0 (exclusive) and 10');
    return EdgeInsets.fromLTRB(
      successCard2PaddingLeft * scale,
      successCard2PaddingVertical * scale,
      successCard2PaddingRight * scale,
      successCard2PaddingVertical * scale,
    );
  }

  Spacing._();
}
