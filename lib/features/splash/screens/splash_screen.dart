import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;

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

/// Determines the onboarding gate outcome based on remote and local state.
///
/// Returns:
/// - Target route string if a clear decision can be made
/// - `null` if state needs race-retry or is truly unknown
///
/// Note: When `remoteGate == false && localGate == true`, returns `null` to
/// trigger race-retry logic (server may be out of sync due to race condition).
@visibleForTesting
String? determineOnboardingGateRoute({
  required bool? remoteGate,
  required bool? localGate,
  required String homeRoute,
}) {
  // Remote SSOT takes priority when available
  if (remoteGate == true) return homeRoute;

  // Race-condition guard: local true + remote false → needs race-retry
  // Don't immediately route to Onboarding; let caller handle retry
  if (remoteGate == false && localGate == true) return null;

  // Remote false + local not true → Onboarding (first-time user)
  if (remoteGate == false) return Onboarding01Screen.routeName;

  // Remote null (network unavailable) - use local as fallback
  // Fail-safe: never route to Home when server SSOT is unavailable.
  // Local cache may be stale or cross-account; only allow the safe direction.
  if (localGate == false) return Onboarding01Screen.routeName;

  // Both null → truly unknown
  return null;
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
  bool _showUnknownUI = false;
  bool _hasUsedManualRetry = false;

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DsColors.welcomeWaveBg,
      body: _showUnknownUI
          ? _buildUnknownUI(context, l10n)
          : Center(
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

  Widget _buildUnknownUI(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: DsColors.textPrimary,
              semanticLabel: l10n.splashGateUnknownTitle,
            ),
            const SizedBox(height: Spacing.l),
            Text(
              l10n.splashGateUnknownTitle,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.m),
            Text(
              l10n.splashGateUnknownBody,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xl),
            // Primary CTA: Retry (Welcome-style magenta pill button)
            SizedBox(
              width: double.infinity,
              child: WelcomeButton(
                label: l10n.splashGateRetryCta,
                onPressed: _hasUsedManualRetry ? null : _handleRetry,
              ),
            ),
            const SizedBox(height: Spacing.m),
            // Secondary CTA: Sign out (outline style)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DsColors.welcomeButtonBg,
                  side: const BorderSide(color: DsColors.welcomeButtonBg),
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.welcomeButtonPaddingVertical,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
                  ),
                ),
                child: Text(l10n.splashGateSignOutCta),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRetry() {
    if (!mounted) return;
    setState(() {
      _hasUsedManualRetry = true;
      _showUnknownUI = false;
      _hasNavigated = false;
    });
    _navigateAfterAnimation();
  }

  Future<void> _handleSignOut() async {
    if (!mounted) return;
    try {
      await SupabaseService.client.auth.signOut();
    } catch (e, st) {
      log.w('sign out failed', tag: 'splash', error: sanitizeError(e), stack: st);
    }
    if (mounted) {
      context.go(AuthSignInScreen.routeName);
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _navigateAfterAnimation();
  }

  Future<void> _navigateAfterAnimation() async {
    if (_hasNavigated) return;
    // Avoid any async auth calls here; rely on immediate client state.
    final isAuth =
        SupabaseService.isInitialized && SupabaseService.currentUser != null;
    final isTestMode = ref.read(initModeProvider) == InitMode.test;
    final useTimeout = kReleaseMode && !isTestMode;

    // Attempt to load user state with retry on failure
    UserStateService? service;
    try {
      service = await _loadUserStateWithRetry(useTimeout: useTimeout);
    } catch (e, st) {
      log.e('state load failed after retry',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
    }

    if (!mounted || _hasNavigated) return;

    // If state failed to load completely, use fallback routing
    if (service == null) {
      _hasNavigated = true;
      final fallbackTarget = determineFallbackRoute(isAuth: isAuth);
      context.go(fallbackTarget);
      return;
    }

    // Pre-onboarding gates: auth and consent
    if (!isAuth) {
      _hasNavigated = true;
      context.go(AuthSignInScreen.routeName);
      return;
    }

    // Ensure local cache is account-scoped to the currently authenticated user.
    // This prevents gate leakage between accounts on the same device.
    final uid = SupabaseService.currentUser?.id;
    if (uid != null) {
      await service.bindUser(uid);
    }

    final localAcceptedVersion = service.acceptedConsentVersionOrNull;
    final localHasSeenWelcome = service.hasSeenWelcomeOrNull;

    // Server SSOT: Try to fetch profiles row once and derive consent + onboarding
    // gates from it. Local SharedPreferences are treated as read-through cache.
    Map<String, dynamic>? remoteProfile;
    bool remoteProfileLoaded = false;
    try {
      remoteProfile = await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
      remoteProfileLoaded = true;
    } catch (e, st) {
      log.w('remote profile fetch failed',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
    }

    // Fail-safe: if we can't fetch server SSOT, do not route based on local
    // cache (prevents bypass in unknown/offline states). Let the user retry.
    if (!remoteProfileLoaded) {
      if (mounted) {
        setState(() {
          _showUnknownUI = true;
        });
      }
      return;
    }

    final int? remoteAcceptedVersion = remoteProfileLoaded
        ? (remoteProfile?['accepted_consent_version'] as int?)
        : null;
    final bool? remoteHasSeenWelcome = remoteProfileLoaded
        ? (remoteProfile?['has_seen_welcome'] as bool?)
        : null;

    // Cache refresh: if server has a consent version, sync it locally.
    if (remoteAcceptedVersion != null &&
        (localAcceptedVersion == null ||
            remoteAcceptedVersion > localAcceptedVersion)) {
      try {
        await service.setAcceptedConsentVersion(remoteAcceptedVersion);
      } catch (e, st) {
        log.w('local consent version sync failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }
    }

    // Cache refresh: welcome seen is monotonic, so sync true -> local.
    if (remoteHasSeenWelcome == true && localHasSeenWelcome != true) {
      try {
        await service.markWelcomeSeen();
      } catch (e, st) {
        log.w('local welcome sync failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }
    }

    // Server is SSOT for consent: local cache must not bypass consent gating.
    final needsConsent = remoteAcceptedVersion == null ||
        remoteAcceptedVersion < ConsentConfig.currentVersionInt;
    if (needsConsent) {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.go(ConsentWelcome01Screen.routeName);
      return;
    }

    final localGate = service.hasCompletedOnboardingOrNull;
    // Consent OK - now sync onboarding gate with server SSOT
    // No profile row = new user.
    bool? remoteGate =
        (remoteProfile?['has_completed_onboarding'] as bool?) ?? false;

    if (!mounted || _hasNavigated) return;

    // Backfill: if local true && remote != true, push to server
    if (localGate == true && remoteGate != true) {
      _performBackfill();
    }

    // Sync local state if remote says true
    if (remoteGate == true && localGate != true) {
      try {
        await service.setHasCompletedOnboarding(true);
      } catch (e, st) {
        log.w('local state sync failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }
    }

    if (!mounted || _hasNavigated) return;

    // Determine final route
    var targetRoute = determineOnboardingGateRoute(
      remoteGate: remoteGate,
      localGate: localGate,
      homeRoute: HeuteScreen.routeName,
    );

    // Race-retry: local true + remote false → wait briefly and re-fetch
    // This handles race conditions where server hasn't synced yet
    if (targetRoute == null && localGate == true && remoteGate == false) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted || _hasNavigated) return;

      try {
        remoteProfile =
            await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
        remoteGate =
            (remoteProfile?['has_completed_onboarding'] as bool?) ?? false;
      } catch (e, st) {
        log.w('race-retry fetch failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }

      if (!mounted || _hasNavigated) return;

      // Re-evaluate after race-retry
      targetRoute = determineOnboardingGateRoute(
        remoteGate: remoteGate,
        localGate: localGate,
        homeRoute: HeuteScreen.routeName,
      );

      // If still null after retry (remote still false, local true) → go to Onboarding
      // This means server genuinely has false, not a race condition
      if (targetRoute == null && remoteGate == false) {
        _hasNavigated = true;
        context.go(Onboarding01Screen.routeName);
        return;
      }
    }

    if (targetRoute != null) {
      _hasNavigated = true;
      context.go(targetRoute);
      return;
    }

    // Both remote and local are null → show Unknown UI
    if (mounted) {
      setState(() {
        _showUnknownUI = true;
      });
    }
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
      log.w('state load failed, retrying once',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      // Invalidate provider to clear cached error before retry
      ref.invalidate(userStateServiceProvider);
      // One retry with shorter timeout
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(retryTimeout)
          : await serviceFuture;
    }
  }

  /// Fetches the server `public.profiles` row for the current user with retry
  /// logic (server SSOT for consent + onboarding gates).
  Future<Map<String, dynamic>?> _fetchRemoteProfileWithRetry({
    required bool useTimeout,
  }) async {
    const primaryTimeout = Duration(seconds: 3);
    const retryTimeout = Duration(seconds: 2);

    try {
      final fetchFuture = SupabaseService.getProfile();
      return useTimeout
          ? await fetchFuture.timeout(primaryTimeout)
          : await fetchFuture;
    } catch (e, st) {
      log.w('remote profile fetch failed, retrying once',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      final fetchFuture = SupabaseService.getProfile();
      return useTimeout
          ? await fetchFuture.timeout(retryTimeout)
          : await fetchFuture;
    }
  }

  /// Best-effort backfill of local onboarding completion to server.
  void _performBackfill() {
    // Fire-and-forget, errors are logged but not propagated
    SupabaseService.upsertOnboardingGate(hasCompletedOnboarding: true)
        .catchError((Object e, StackTrace st) {
      log.w('backfill to server failed',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      return null;
    });
  }
}
