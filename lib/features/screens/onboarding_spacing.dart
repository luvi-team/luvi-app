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
}
