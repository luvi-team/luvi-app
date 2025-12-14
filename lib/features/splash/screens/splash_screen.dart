import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_app/core/logging/logger.dart';

/// Determines the target route based on auth state, consent version, and
/// onboarding completion.
///
/// Extracted for testability (Codex-Audit).
///
/// Logic:
/// - Not authenticated → AuthSignInScreen
/// - Authenticated + needs consent (null or outdated version) → ConsentWelcome01Screen
/// - Authenticated + consent OK + hasCompletedOnboarding != true → Onboarding01
/// - Authenticated + consent OK + hasCompletedOnboarding == true → defaultTarget
@visibleForTesting
String determineTargetRoute({
  required bool isAuth,
  required int? acceptedConsentVersion,
  required int currentConsentVersion,
  required bool hasCompletedOnboarding,
  required String defaultTarget,
}) {
  if (!isAuth) {
    return AuthSignInScreen.routeName;
  }
  // Consent-Version-Gate: Show consent if not accepted or version is outdated
  final needsConsent = acceptedConsentVersion == null ||
      acceptedConsentVersion < currentConsentVersion;
  if (needsConsent) {
    return ConsentWelcome01Screen.routeName;
  }
  // Onboarding Gate: User has completed consent but not onboarding
  if (!hasCompletedOnboarding) {
    return Onboarding01Screen.routeName;
  }
  return defaultTarget;
}

/// Determines a safe fallback route when state loading fails.
///
/// Fail-safe approach: Never route directly to Home when state is unknown.
/// - Not authenticated → AuthSignInScreen (login required anyway)
/// - Authenticated → ConsentWelcome01Screen (safe entry point for gate flow)
///
/// This ensures consent/onboarding gates are never bypassed due to errors.
@visibleForTesting
String determineFallbackRoute({required bool isAuth}) {
  if (!isAuth) {
    return AuthSignInScreen.routeName;
  }
  // Safe fallback: Consent flow will re-check all gates properly.
  // Never go directly to Home when state is unknown.
  return ConsentWelcome01Screen.routeName;
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasNavigated = false;
  bool _skipAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_handleAnimationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read skipAnimation query param once (post-login redirect uses this)
    final routerState = GoRouterState.of(context);
    _skipAnimation = routerState.uri.queryParameters['skipAnimation'] == 'true';
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.welcomeWaveBg,
      body: Center(
        child: Lottie.asset(
          Assets.animations.splashScreen,
          controller: _controller,
          repeat: false,
          frameRate: FrameRate.composition,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            if (!mounted) return;
            // UX-Fix: Skip animation if coming from post-login redirect
            if (_skipAnimation) {
              _navigateAfterAnimation();
              return;
            }
            _controller.duration = composition.duration;
            _controller.forward(from: 0);
          },
        ),
      ),
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _navigateAfterAnimation();
  }

  Future<void> _navigateAfterAnimation() async {
    if (_hasNavigated) return;
    // Avoid any async auth calls here; rely on immediate client state.
    final isAuth = SupabaseService.isInitialized && SupabaseService.currentUser != null;
    final isTestMode = ref.read(initModeProvider) == InitMode.test;
    final useTimeout = kReleaseMode && !isTestMode;

    // Attempt to load user state with retry on failure
    UserStateService? service;
    try {
      service = await _loadUserStateWithRetry(useTimeout: useTimeout);
    } catch (e, st) {
      log.e('state load failed after retry', tag: 'splash', error: e, stack: st);
    }

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    // If state loaded successfully, use normal gate logic
    if (service != null) {
      final target = determineTargetRoute(
        isAuth: isAuth,
        acceptedConsentVersion: service.acceptedConsentVersionOrNull,
        currentConsentVersion: ConsentConfig.currentVersionInt,
        hasCompletedOnboarding: service.hasCompletedOnboarding,
        defaultTarget: HeuteScreen.routeName,
      );
      context.go(target);
      return;
    }

    // Fail-safe: State unknown, use safe fallback (never direct to Home)
    final fallbackTarget = determineFallbackRoute(isAuth: isAuth);
    context.go(fallbackTarget);
  }

  /// Loads UserStateService with one retry on failure.
  ///
  /// First attempt: 3 second timeout (release mode only)
  /// Retry: 2 second timeout
  Future<UserStateService> _loadUserStateWithRetry({
    required bool useTimeout,
  }) async {
    const primaryTimeout = Duration(seconds: 3);
    const retryTimeout = Duration(seconds: 2);

    try {
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(primaryTimeout)
          : await serviceFuture;
    } catch (e, st) {
      log.w('state load failed, retrying once', tag: 'splash', error: e, stack: st);
      // Invalidate provider to clear cached error before retry
      ref.invalidate(userStateServiceProvider);
      // One retry with shorter timeout
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(retryTimeout)
          : await serviceFuture;
    }
  }
}
