/// State hierarchy for the Splash Controller.
///
/// Three possible states:
/// - [SplashInitial]: Loading/Video playing, gates being checked
/// - [SplashResolved]: Target route determined, UI should navigate
/// - [SplashUnknown]: State cannot be determined, show retry UI
sealed class SplashState {
  const SplashState();
}

/// Initial state: Loading/Video is playing, gates are being checked.
final class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Resolved state: Target route has been determined.
/// UI should navigate to [targetRoute] exactly once.
final class SplashResolved extends SplashState {
  const SplashResolved(this.targetRoute);
  final String targetRoute;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashResolved && targetRoute == other.targetRoute;

  @override
  int get hashCode => targetRoute.hashCode;
}

/// Unknown state: State cannot be reliably determined.
/// UI should show retry/sign-out options.
final class SplashUnknown extends SplashState {
  const SplashUnknown({
    required this.canRetry,
    required this.retryCount,
  });

  final bool canRetry;
  final int retryCount;

  /// Maximum manual retry attempts before disabling retry button.
  static const int maxRetries = 3;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashUnknown &&
          canRetry == other.canRetry &&
          retryCount == other.retryCount;

  @override
  int get hashCode => Object.hash(canRetry, retryCount);
}
