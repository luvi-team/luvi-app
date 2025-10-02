import 'package:flutter/widgets.dart';

/// Discrete spacing tokens for onboarding screens with gentle scaling.
class OnboardingSpacing {
  const OnboardingSpacing._({
    required this.horizontalPadding,
    required this.topPadding,
    required this.headerToInstruction,
    required this.instructionToDate,
    required this.dateToUnderline,
    required this.underlineToCallout,
    required this.calloutToCta,
    required this.ctaToPicker,
    required this.underlineWidth,
    required this.headerToInstruction01,
    required this.instructionToInput01,
    required this.inputToCta01,
    required this.headerToQuestion,
    required this.questionToFirstCard,
    required this.cardGap,
    required this.lastCardToCta,
    required this.rhythm04,
    required this.dateToUnderline04,
    required this.calloutToCta04,
    required this.ctaToPicker04,
    required this.headerToQuestion05,
    required this.questionToFirstOption05,
    required this.optionGap05,
    required this.lastOptionToCallout05,
    required this.calloutToCta05,
    required this.ctaToHome05,
    required this.headerToQuestion06,
    required this.questionToFirstOption06,
    required this.optionGap06,
    required this.lastOptionToCallout06,
    required this.calloutToCta06,
    required this.ctaToHome06,
    required this.headerToQuestion07,
    required this.questionToFirstOption07,
    required this.optionGap07,
    required this.lastOptionToFootnote07,
    required this.footnoteToCta07,
    required this.ctaToHome07,
    // New tokens for header migration (question becomes header)
    required this.headerToDate,
    required this.headerToFirstCard,
    required this.headerToDate04,
    required this.headerToFirstOption05,
    required this.headerToFirstOption06,
    required this.headerToFirstOption07,
  });

  final double horizontalPadding;
  final double topPadding;
  final double headerToInstruction;
  final double instructionToDate;
  final double dateToUnderline;
  final double underlineToCallout;
  final double calloutToCta;
  final double ctaToPicker;
  final double underlineWidth;
  // ONB_01 specific spacing
  final double headerToInstruction01;
  final double instructionToInput01;
  final double inputToCta01;

  // ONB_03 specific spacing
  final double headerToQuestion;
  final double questionToFirstCard;
  final double cardGap;
  final double lastCardToCta;

  // ONB_04 vertical rhythm (base: 59px, selectively tuned for visual balance)
  final double rhythm04;
  final double dateToUnderline04;
  final double calloutToCta04;
  final double ctaToPicker04;

  // ONB_05 specific spacing (from Figma audit ONB_05_measures.json)
  final double headerToQuestion05;
  final double questionToFirstOption05;
  final double optionGap05;
  final double lastOptionToCallout05;
  final double calloutToCta05;
  final double ctaToHome05;

  // ONB_06 specific spacing (from Figma audit ONB_06_measures.json)
  final double headerToQuestion06;
  final double questionToFirstOption06;
  final double optionGap06;
  final double lastOptionToCallout06;
  final double calloutToCta06;
  final double ctaToHome06;

  // ONB_07 specific spacing (from Figma audit ONB_07_measures.json)
  final double headerToQuestion07;
  final double questionToFirstOption07;
  final double optionGap07;
  final double lastOptionToFootnote07;
  final double footnoteToCta07;
  final double ctaToHome07;

  // New tokens for header migration (question becomes header)
  final double headerToDate;
  final double headerToFirstCard;
  final double headerToDate04;
  final double headerToFirstOption05;
  final double headerToFirstOption06;
  final double headerToFirstOption07;

  static const double _designHeight = 926.0;
  static OnboardingSpacing of(BuildContext context) {
    final media = MediaQuery.of(context);
    final heightRatio = media.size.height / _designHeight;
    final textScaleFactor = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 2.0)
        .scale(1.0);

    final heightScale = _interpolateHeight(heightRatio);
    final effectiveHeightScale = textScaleFactor > 1.0
        ? heightScale * textScaleFactor.clamp(1.0, 2.0)
        : heightScale;

    return OnboardingSpacing._(
      horizontalPadding: 20.0,
      topPadding: 12.0,
      headerToInstruction: _headerToInstruction * effectiveHeightScale,
      instructionToDate: _instructionToDate * effectiveHeightScale,
      dateToUnderline: _dateToUnderline * effectiveHeightScale,
      underlineToCallout: _underlineToCallout * effectiveHeightScale,
      calloutToCta: _calloutToCta * effectiveHeightScale,
      ctaToPicker: _ctaToPicker * effectiveHeightScale,
      underlineWidth: 197.0,
      headerToInstruction01: _headerToInstruction01,
      instructionToInput01: _instructionToInput01,
      inputToCta01: _inputToCta01,
      // ONB_03 specific spacing
      headerToQuestion: _headerToQuestion * effectiveHeightScale,
      questionToFirstCard: _questionToFirstCard * effectiveHeightScale,
      cardGap: _cardGap,
      lastCardToCta: _lastCardToCta * effectiveHeightScale,
      // ONB_04 vertical rhythm
      rhythm04: _rhythm04 * effectiveHeightScale,
      dateToUnderline04: _dateToUnderline04 * effectiveHeightScale,
      calloutToCta04: _calloutToCta04 * effectiveHeightScale,
      ctaToPicker04: _ctaToPicker04 * effectiveHeightScale,
      // ONB_05 specific spacing
      headerToQuestion05: _headerToQuestion05 * effectiveHeightScale,
      questionToFirstOption05: _questionToFirstOption05 * effectiveHeightScale,
      optionGap05: _optionGap05,
      lastOptionToCallout05: _lastOptionToCallout05 * effectiveHeightScale,
      calloutToCta05: _calloutToCta05 * effectiveHeightScale,
      ctaToHome05: _ctaToHome05 * effectiveHeightScale,
      // ONB_06 specific spacing
      headerToQuestion06: _headerToQuestion06 * effectiveHeightScale,
      questionToFirstOption06: _questionToFirstOption06 * effectiveHeightScale,
      optionGap06: _optionGap06,
      lastOptionToCallout06: _lastOptionToCallout06 * effectiveHeightScale,
      calloutToCta06: _calloutToCta06 * effectiveHeightScale,
      ctaToHome06: _ctaToHome06 * effectiveHeightScale,
      // ONB_07 specific spacing
      headerToQuestion07: _headerToQuestion07 * effectiveHeightScale,
      questionToFirstOption07: _questionToFirstOption07 * effectiveHeightScale,
      optionGap07: _optionGap07,
      lastOptionToFootnote07: _lastOptionToFootnote07 * effectiveHeightScale,
      footnoteToCta07: _footnoteToCta07 * effectiveHeightScale,
      ctaToHome07: _ctaToHome07 * effectiveHeightScale,
      // New tokens for header migration
      headerToDate: _headerToDate * effectiveHeightScale,
      headerToFirstCard: _headerToFirstCard * effectiveHeightScale,
      headerToDate04: _headerToDate04 * effectiveHeightScale,
      headerToFirstOption05: _headerToFirstOption05 * effectiveHeightScale,
      headerToFirstOption06: _headerToFirstOption06 * effectiveHeightScale,
      headerToFirstOption07: _headerToFirstOption07 * effectiveHeightScale,
    );
  }

  static double _interpolateHeight(double ratio) {
    const breakpoints = [0.8, 0.92, 1.0, 1.1, 1.25];
    const scales = [0.88, 0.95, 1.0, 1.06, 1.14];

    if (ratio <= breakpoints.first) {
      return scales.first;
    }
    if (ratio >= breakpoints.last) {
      return scales.last;
    }

    for (var i = 0; i < breakpoints.length - 1; i++) {
      final start = breakpoints[i];
      final end = breakpoints[i + 1];
      if (ratio >= start && ratio <= end) {
        final t = (ratio - start) / (end - start);
        final scaleStart = scales[i];
        final scaleEnd = scales[i + 1];
        return scaleStart + (scaleEnd - scaleStart) * t;
      }
    }
    throw StateError('Interpolation logic error: ratio $ratio should have been handled');
  }

  static const double _headerToInstruction = 75.0;
  static const double _instructionToDate = 52.0;
  static const double _dateToUnderline = 58.0;
  static const double _underlineToCallout = 54.0;
  static const double _calloutToCta = 60.0;
  static const double _ctaToPicker = 54.0;

  static const double _headerToInstruction01 = 84.0;
  static const double _instructionToInput01 = 84.0;
  static const double _inputToCta01 = 84.0;

  // ONB_03 specific spacing (from Figma audit)
  static const double _headerToQuestion = 80.0;
  static const double _questionToFirstCard = 23.0;
  static const double _cardGap = 24.0;
  static const double _lastCardToCta = 47.0;

  // ONB_04 vertical rhythm (tuned for visual balance with longer content)
  static const double _rhythm04 = 59.0; // header→question, question→date
  static const double _dateToUnderline04 = 45.0; // reduced for tighter spacing
  static const double _calloutToCta04 = 48.0; // balanced spacing before CTA
  static const double _ctaToPicker04 = 84.0; // 59 base + 25 saved = more space

  // ONB_05 specific spacing (from Figma audit ONB_05_measures.json)
  static const double _headerToQuestion05 = 42.0;
  static const double _questionToFirstOption05 = 42.0;
  static const double _optionGap05 = 24.0;
  static const double _lastOptionToCallout05 = 106.0;
  static const double _calloutToCta05 = 42.0;
  static const double _ctaToHome05 = 42.0;

  // ONB_06 specific spacing (from Figma audit ONB_06_measures.json)
  static const double _headerToQuestion06 = 48.0;
  static const double _questionToFirstOption06 = 48.0;
  static const double _optionGap06 = 24.0;
  static const double _lastOptionToCallout06 = 48.0;
  static const double _calloutToCta06 = 48.0;
  static const double _ctaToHome06 = 48.0;

  // ONB_07 specific spacing (from Figma audit ONB_07_measures.json)
  // Header baseline (79) → Question (202) = 90 px (header-to-question rhythm)
  // Question → First Option (316 - 202 - 24) = 90 px
  // Option gap = 24 px (consistent)
  // Last Option (491 + 63 = 554) → Footnote (645) = 91 px ≈ 90
  // Footnote (645 + 19 = 664) → CTA (754) = 90 px
  // CTA (754 + 50 = 804) → Home (894) = 90 px
  static const double _headerToQuestion07 = 90.0;
  static const double _questionToFirstOption07 = 90.0;
  static const double _optionGap07 = 24.0;
  static const double _lastOptionToFootnote07 = 90.0;
  static const double _footnoteToCta07 = 90.0;
  static const double _ctaToHome07 = 90.0;

  // New tokens for header migration (question becomes header)
  // Conservative 60% of sum (headerToInstruction + instructionToDate/Content)
  static const double _headerToDate = 76.0; // ONB_02: (75+52)*0.6
  static const double _headerToFirstCard = 62.0; // ONB_03: (80+23)*0.6
  static const double _headerToDate04 = 71.0; // ONB_04: (59+59)*0.6
  static const double _headerToFirstOption05 = 50.0; // ONB_05: (42+42)*0.6
  static const double _headerToFirstOption06 = 58.0; // ONB_06: (48+48)*0.6
  static const double _headerToFirstOption07 = 108.0; // ONB_07: (90+90)*0.6
}
