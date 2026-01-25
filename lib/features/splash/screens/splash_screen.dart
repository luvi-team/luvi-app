import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/navigation/route_query_params.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/splash/state/splash_controller.dart';
import 'package:luvi_app/features/splash/state/splash_state.dart';
import 'package:luvi_app/features/splash/widgets/splash_video_player.dart';
import 'package:luvi_app/features/splash/widgets/unknown_state_ui.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a splash screen widget.
  ///
  /// [raceRetryDelay] controls the delay before retrying when a race condition
  /// is detected (local=true, remote=false). Defaults to 500ms for production.
  /// Tests can pass shorter durations for faster execution.
  const SplashScreen({
    super.key,
    this.raceRetryDelay = const Duration(milliseconds: 500),
  });

  static const String routeName = '/splash';

  /// Delay before race-retry when local/remote state mismatch is detected.
  /// Configurable via constructor for test isolation (no global state mutation).
  final Duration raceRetryDelay;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _skipAnimation = false;
  bool _skipAnimationHandled = false;
  bool _hasNavigated = false;
  bool _hasConfiguredDelay = false;
  bool _hasReadSkipAnimation = false;

  late final ProviderSubscription<SplashState> _subscription;

  @override
  void initState() {
    super.initState();

    // Listen to controller state and navigate exactly once when resolved
    _subscription = ref.listenManual<SplashState>(
      splashControllerProvider,
      (previous, next) {
        if (!mounted) return;
        if (next is SplashResolved && !_hasNavigated) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(next.targetRoute);
            }
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Configure race-retry delay once (immutable after construction)
    if (!_hasConfiguredDelay) {
      _hasConfiguredDelay = true;
      ref.read(splashControllerProvider.notifier).setRaceRetryDelay(
        widget.raceRetryDelay,
      );
    }

    // Read skipAnimation query param exactly once (cache regardless of value)
    if (!_hasReadSkipAnimation) {
      _hasReadSkipAnimation = true;
      final routerState = GoRouterState.of(context);
      _skipAnimation = routerState.uri.queryParameters[RouteQueryParams.skipAnimation] == RouteQueryParams.trueValue;
    }

    // skipAnimation=true: Navigate immediately without waiting for video
    if (_skipAnimation && !_hasNavigated && !_skipAnimationHandled) {
      _skipAnimationHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasNavigated) {
          _triggerGateCheck();
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  void _triggerGateCheck() {
    if (!mounted) return;
    ref.read(splashControllerProvider.notifier).checkGates();
  }

  void _handleRetry() {
    if (!mounted) return;
    ref.read(splashControllerProvider.notifier).retry();
  }

  Future<void> _handleSignOut() async {
    if (!mounted) return;
    try {
      await SupabaseService.client.auth.signOut();
      if (mounted) {
        context.go(RoutePaths.authSignIn);
      }
    } catch (e, st) {
      log.w('sign out failed', tag: 'splash', error: sanitizeError(e), stack: st);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.signOutErrorRetry),
            action: SnackBarAction(
              label: l10n.retry,
              onPressed: _handleSignOut,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final splashState = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      // Use pattern matching directly for type promotion (Dart 3)
      body: splashState is SplashUnknown
          ? _buildUnknownUI(context, l10n, splashState)
          : _skipAnimation
              // skipAnimation: Show solid background (no 1-frame flash)
              ? Container(color: DsColors.splashBg)
              : SplashVideoPlayer(
                  assetPath: Assets.videos.splashScreen,
                  fallbackAsset: Assets.images.splashFallback,
                  onComplete: _triggerGateCheck,
                ),
    );
  }

  Widget _buildUnknownUI(
    BuildContext context,
    AppLocalizations l10n,
    SplashUnknown unknown,
  ) {
    return UnknownStateUi(
      onRetry: unknown.canRetry ? _handleRetry : null,
      onSignOut: _handleSignOut,
      canRetry: unknown.canRetry,
      isRetrying: unknown.isRetrying,
    );
  }
}
