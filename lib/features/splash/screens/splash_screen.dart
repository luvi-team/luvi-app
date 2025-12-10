import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_app/core/logging/logger.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_handleAnimationStatus);
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
    try {
      final serviceFuture = ref.read(userStateServiceProvider.future);
      final useTimeout = kReleaseMode && !isTestMode;
      final service = useTimeout
          ? await serviceFuture.timeout(const Duration(seconds: 3))
          : await serviceFuture;
      final hasSeenWelcomeMaybe = service.hasSeenWelcomeOrNull;

      // Default target based on auth state (DRY extraction)
      final defaultTarget = isAuth ? HeuteScreen.routeName : AuthSignInScreen.routeName;

      // Only show consent flow for authenticated users who haven't seen welcome
      final target = (isAuth && hasSeenWelcomeMaybe == false)
          ? ConsentWelcome01Screen.routeName
          : defaultTarget;

      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.go(target);
    } catch (e, st) {
      log.e('routing error', tag: 'splash', error: e, stack: st);
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      final fallbackTarget = isAuth ? HeuteScreen.routeName : AuthSignInScreen.routeName;
      context.go(fallbackTarget);
    }
  }
}
