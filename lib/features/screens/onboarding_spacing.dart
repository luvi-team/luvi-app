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
    required this.headerToQuestion,
    required this.questionToFirstCard,
    required this.cardGap,
    required this.lastCardToCta,
    required this.rhythm04,
    required this.dateToUnderline04,
    required this.calloutToCta04,
    required this.ctaToPicker04,
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

  static const double _designHeight = 926.0;
  static OnboardingSpacing of(BuildContext context) {
    final media = MediaQuery.of(context);
    final heightRatio = media.size.height / _designHeight;
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

    final heightScale = _interpolateHeight(heightRatio);
    final effectiveHeightScale = textScaleFactor > 1.0
        ? heightScale * textScaleFactor.clamp(1.0, 1.2)
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
    return 1.0;
  }

  static const double _headerToInstruction = 75.0;
  static const double _instructionToDate = 52.0;
  static const double _dateToUnderline = 58.0;
  static const double _underlineToCallout = 54.0;
  static const double _calloutToCta = 60.0;
  static const double _ctaToPicker = 54.0;

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
}
