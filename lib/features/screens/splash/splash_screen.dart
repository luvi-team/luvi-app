import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/services/supabase_service.dart';
import 'package:luvi_app/services/user_state_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener(_handleAnimationStatus);
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
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          Assets.animations.splashScreen,
          controller: _controller,
          repeat: false,
          frameRate: FrameRate.composition,
          fit: BoxFit.contain,
          onLoaded: (composition) {
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
    final userState = await tryOrNullAsync(
      () => ref.read(userStateServiceProvider.future),
      tag: 'userState',
    );
    if (!mounted) return;
    final isAuth = SupabaseService.isAuthenticated;
    final hasSeenWelcome = userState?.hasSeenWelcome ?? false;
    final nextRoute = !hasSeenWelcome
        ? ConsentWelcome01Screen.routeName
        : (isAuth ? HeuteScreen.routeName : AuthEntryScreen.routeName);
    context.go(nextRoute);
  }
}
