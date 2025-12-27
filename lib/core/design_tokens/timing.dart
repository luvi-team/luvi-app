/// Timing tokens for consistent animation and feedback durations.
///
/// These constants define reusable timing values for animations, delays,
/// and user feedback across the app. Use these tokens instead of hardcoded
/// Duration values to ensure consistency and maintainability.
class Timing {
  const Timing._();

  // ─── Feedback Durations ───

  /// SnackBar display duration for brief feedback messages (Figma: 1.5s)
  /// Used when navigation follows shortly after the feedback.
  static const Duration snackBarBrief = Duration(milliseconds: 1500);

  /// SnackBar display duration for standard messages (default: 4s)
  /// Used for messages that don't trigger navigation.
  static const Duration snackBarStandard = Duration(seconds: 4);

  /// Delay before navigation after showing feedback (e.g., SnackBar)
  /// Allows user to read the message before screen transition.
  static const Duration feedbackNavigationDelay = Duration(milliseconds: 1200);

  // ─── Raw millisecond values for test assertions ───

  /// Raw value for [snackBarBrief] in milliseconds (1500ms)
  static const int snackBarBriefMs = 1500;

  /// Raw value for [feedbackNavigationDelay] in milliseconds (1200ms)
  static const int feedbackNavigationDelayMs = 1200;
}
