/// Centralized query parameter constants for route navigation.
///
/// Use these constants instead of hardcoded strings to prevent typos
/// and ensure consistency across the codebase.
abstract final class RouteQueryParams {
  /// Query parameter name for skipping splash animation.
  static const String skipAnimation = 'skipAnimation';

  /// Boolean true value for query parameters.
  static const String trueValue = 'true';

  /// Complete query string for skipAnimation=true.
  ///
  /// Usage: `'${RoutePaths.splash}?${RouteQueryParams.skipAnimationTrueQuery}'`
  static String get skipAnimationTrueQuery => '$skipAnimation=$trueValue';
}
