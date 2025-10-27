import 'dart:ui' show lerpDouble;

/// Design tokens for the Onboarding Success screen.
/// All values sourced from the Figma audit (`ONB_SUCCESS_measures.json`).
class OnboardingSuccessTokens {
  const OnboardingSuccessTokens._();

  /// Illustration zone for the celebration animation or PNG fallback (308×300).
  static const double trophyWidth = 308.0;
  static const double trophyHeight = 300.0;

  /// Scale factor for the celebration Lottie inside the 308×300 zone.
  /// Ranges roughly from iPhone SE (≈2.6) to Plus/Max (≈2.9).
  static const double celebrationScale = 2.7;

  /// Allowed bleed (px) above the 308×300 zone for confetti/handles.
  static const double celebrationBleedTop = 72.0;

  /// Downward offset (px) to align the Lottie baseline with the title gap.
  /// Tuned between 58–72 px so smaller devices sit closer to the title.
  static const double celebrationBaselineOffset = 64.0;

  /// Target gap (in px) between the trophy illustration and the title.
  /// Keep in sync with `OnboardingSpacing._kOnboardingSuccessTrophyToTitleGap`.
  static const double gapToTitle = 24.0;

  /// Responsive config for the celebration animation based on viewport height.
  static OnboardingSuccessIllustrationConfig celebrationConfig({
    required double viewHeight,
    required double textScaleFactor,
  }) {
    final effectiveHeight = (viewHeight / textScaleFactor)
        .clamp(_minViewportHeight, _maxViewportHeight);
    final t = (effectiveHeight - _minViewportHeight) /
        (_maxViewportHeight - _minViewportHeight);
    final scale = lerpDouble(_minScaleValue, _maxScaleValue, t)!;
    final baselineOffset = lerpDouble(
      _minBaselineOffset,
      _maxBaselineOffset,
      t,
    )!;
    final config = OnboardingSuccessIllustrationConfig(
      scale: scale,
      baselineOffset: baselineOffset,
    );
    assert(
      config.scale >= _minScaleValue && config.scale <= _maxScaleValue,
      'Scale ${config.scale} outside range $_minScaleValue–$_maxScaleValue',
    );
    assert(
      config.baselineOffset >= _minBaselineOffset &&
          config.baselineOffset <= _maxBaselineOffset,
      'Baseline ${config.baselineOffset} outside range '
      '$_minBaselineOffset–$_maxBaselineOffset',
    );
    return config;
  }

  static const double _minViewportHeight = 760.0;
  static const double _maxViewportHeight = 1180.0;
  static const double _minScaleValue = 2.55;
  static const double _maxScaleValue = 2.85;
  static const double _minBaselineOffset = 58.0;
  static const double _maxBaselineOffset = 72.0;

  static double get minScale => _minScaleValue;
  static double get maxScale => _maxScaleValue;
  static double get minBaselineOffset => _minBaselineOffset;
  static double get maxBaselineOffset => _maxBaselineOffset;
}

/// Immutable config describing how the celebration illustration should render.
class OnboardingSuccessIllustrationConfig {
  const OnboardingSuccessIllustrationConfig({
    required this.scale,
    required this.baselineOffset,
  });

  final double scale;
  final double baselineOffset;
}
