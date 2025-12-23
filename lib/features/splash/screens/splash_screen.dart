import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/features/splash/widgets/unknown_state_ui.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
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

/// Result type for [determineOnboardingGateRoute].
///
/// Three outcomes:
/// - [RouteResolved]: Navigation target determined
/// - [RaceRetryNeeded]: Local/remote mismatch (remote=false, local=true), retry required
/// - [StateUnknown]: Both gates null, cannot determine route
sealed class OnboardingGateResult {
  const OnboardingGateResult();
}

/// Navigation target has been determined.
final class RouteResolved extends OnboardingGateResult {
  const RouteResolved(this.route);
  final String route;
}

/// Race condition detected: local=true but remote=false.
/// Caller should retry after a short delay.
final class RaceRetryNeeded extends OnboardingGateResult {
  const RaceRetryNeeded();
}

/// Both remote and local gates are null - state is truly unknown.
/// Caller should show fallback UI.
final class StateUnknown extends OnboardingGateResult {
  const StateUnknown();
}

/// Determines the onboarding gate outcome based on remote and local state.
///
/// Returns:
/// - [RouteResolved] with home route if remote gate is true
/// - [RouteResolved] with onboarding route if either gate is explicitly false
/// - [RaceRetryNeeded] if remote=false but local=true (race condition)
/// - [StateUnknown] if both gates are null
@visibleForTesting
OnboardingGateResult determineOnboardingGateRoute({
  required bool? remoteGate,
  required bool? localGate,
  required String homeRoute,
}) {
  // Remote SSOT takes priority when available
  if (remoteGate == true) return RouteResolved(homeRoute);

  // Race-condition guard: local true + remote false → needs race-retry
  // Don't immediately route to Onboarding; let caller handle retry
  if (remoteGate == false && localGate == true) return const RaceRetryNeeded();

  // Remote false + local not true → Onboarding (first-time user)
  if (remoteGate == false) return RouteResolved(Onboarding01Screen.routeName);

  // Remote null (network unavailable) - use local as fallback
  // Fail-safe: never route to Home when server SSOT is unavailable.
  // Local cache may be stale or cross-account; only allow the safe direction.
  if (localGate == false) return RouteResolved(Onboarding01Screen.routeName);

  // Both null → truly unknown
  return const StateUnknown();
}

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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Timeout constants for retry logic (Point 3: DRY extraction)
  static const _primaryTimeout = Duration(seconds: 3);
  static const _retryTimeout = Duration(seconds: 2);

  /// Maximum number of manual retries before disabling the button.
  static const int _maxManualRetries = 3;

  late final AnimationController _controller;
  bool _hasNavigated = false;
  bool _skipAnimation = false;
  bool _showUnknownUI = false;
  int _manualRetryCount = 0;
  bool _isRetrying = false;

  /// Whether the user can retry (not exhausted attempts).
  bool get _canRetry => _manualRetryCount < _maxManualRetries;

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
    return UnknownStateUi(
      onRetry: _canRetry ? _handleRetry : null,
      onSignOut: _handleSignOut,
      canRetry: _canRetry,
      isRetrying: _isRetrying,
    );
  }

  void _handleRetry() {
    if (!mounted || !_canRetry) return;
    setState(() {
      _manualRetryCount++;
      _isRetrying = true;
      _showUnknownUI = false;
      _hasNavigated = false;
    });
    _navigateAfterAnimation();
  }

  Future<void> _handleSignOut() async {
    if (!mounted) return;
    try {
      await SupabaseService.client.auth.signOut();
      if (mounted) {
        context.go(AuthSignInScreen.routeName);
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
              onPressed: () { _handleSignOut(); },
            ),
          ),
        );
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _navigateAfterAnimation();
  }

  Future<void> _navigateAfterAnimation() async {
    if (_hasNavigated) return;
    // Avoid any async auth calls here; rely on immediate client state.
    final isAuth = SupabaseService.isAuthenticated;
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
      try {
        await service.bindUser(uid);
      } catch (e, st) {
        log.e('bindUser failed for uid=$uid',
            tag: 'splash', error: sanitizeError(e), stack: st);
        // Abort navigation - user binding is critical for data isolation
        if (mounted) {
          setState(() => _showUnknownUI = true);
        }
        return;
      }
    }

    try {
      await _flushPreAuthConsentIfNeeded(service);
    } catch (e, st) {
      log.w('flushPreAuthConsent failed',
          tag: 'splash', error: sanitizeError(e), stack: st);
      // Continue - consent flush is best-effort, not blocking
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
          _isRetrying = false;
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
    // Point 2: Preserve null semantics - no profile row = genuinely unknown
    var remoteGate = remoteProfile == null
        ? null
        : remoteProfile['has_completed_onboarding'] as bool?;

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

    // Determine final route using sealed class result
    var gateResult = determineOnboardingGateRoute(
      remoteGate: remoteGate,
      localGate: localGate,
      homeRoute: HeuteScreen.routeName,
    );

    // Race-retry: local true + remote false → wait briefly and re-fetch
    // This handles race conditions where server hasn't synced yet
    if (gateResult is RaceRetryNeeded) {
      await Future<void>.delayed(widget.raceRetryDelay);
      if (!mounted || _hasNavigated) return;

      try {
        remoteProfile =
            await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
        // Point 2: Preserve null semantics on race-retry as well
        remoteGate = remoteProfile == null
            ? null
            : remoteProfile['has_completed_onboarding'] as bool?;
      } catch (e, st) {
        log.w('race-retry fetch failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }

      if (!mounted || _hasNavigated) return;

      // Re-evaluate after race-retry
      gateResult = determineOnboardingGateRoute(
        remoteGate: remoteGate,
        localGate: localGate,
        homeRoute: HeuteScreen.routeName,
      );

      // If still RaceRetryNeeded after retry (remote still false, local true)
      // → go to Onboarding. Server genuinely has false, not a race condition.
      if (gateResult is RaceRetryNeeded) {
        _hasNavigated = true;
        context.go(Onboarding01Screen.routeName);
        return;
      }
    }

    // Handle sealed class result with pattern matching
    switch (gateResult) {
      case RouteResolved(:final route):
        _hasNavigated = true;
        context.go(route);
      case StateUnknown():
        // Both remote and local are null → show Unknown UI
        if (mounted) {
          setState(() {
            _isRetrying = false;
            _showUnknownUI = true;
          });
        }
      case RaceRetryNeeded():
        // Already handled above, but included for exhaustiveness
        break;
    }
  }

  Future<void> _flushPreAuthConsentIfNeeded(UserStateService service) async {
    final preAuthVersion = service.preAuthAcceptedConsentVersionOrNull;
    final preAuthScopes = service.preAuthConsentScopesOrNull;
    final preAuthPolicyVersion = service.preAuthConsentPolicyVersionOrNull;
    if (preAuthVersion == null ||
        preAuthVersion < ConsentConfig.currentVersionInt ||
        preAuthScopes == null ||
        preAuthScopes.isEmpty) {
      return;
    }

    // Best-effort flush: do not block navigation on failure.
    try {
      await ref.read(consentServiceProvider).accept(
            version: preAuthPolicyVersion ?? ConsentConfig.currentVersion,
            scopes: preAuthScopes,
          );
    } catch (e, st) {
      log.w(
        'preauth_consent_log_failed',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
    }

    var upsertOk = false;
    try {
      await SupabaseService.upsertConsentGate(
        acceptedConsentVersion: preAuthVersion,
        markWelcomeSeen: true,
      );
      upsertOk = true;
    } catch (e, st) {
      log.w(
        'preauth_consent_gate_upsert_failed',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
    }

    if (!upsertOk) return;
    try {
      await service.clearPreAuthConsent();
    } catch (e, st) {
      log.w(
        'preauth_consent_cache_clear_failed',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
    }
  }

  /// Loads UserStateService with one retry on failure.
  ///
  /// First attempt: 3 second timeout (release mode only)
  /// Retry: 2 second timeout
  Future<UserStateService> _loadUserStateWithRetry({
    required bool useTimeout,
  }) async {
    try {
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(_primaryTimeout)
          : await serviceFuture;
    } catch (e, st) {
      log.w('state load failed, retrying once',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      // Invalidate provider to clear cached error before retry
      ref.invalidate(userStateServiceProvider);
      // One retry with shorter timeout
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(_retryTimeout)
          : await serviceFuture;
    }
  }

  /// Fetches the server `public.profiles` row for the current user with retry
  /// logic (server SSOT for consent + onboarding gates).
  Future<Map<String, dynamic>?> _fetchRemoteProfileWithRetry({
    required bool useTimeout,
  }) async {
    try {
      final fetchFuture = SupabaseService.getProfile();
      return useTimeout
          ? await fetchFuture.timeout(_primaryTimeout)
          : await fetchFuture;
    } catch (e, st) {
      log.w('remote profile fetch failed, retrying once',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      final fetchFuture = SupabaseService.getProfile();
      return useTimeout
          ? await fetchFuture.timeout(_retryTimeout)
          : await fetchFuture;
    }
  }

  /// Best-effort backfill of local onboarding completion to server.
  void _performBackfill() {
    // Fire-and-forget, errors are logged but not propagated
    SupabaseService.upsertOnboardingGate(hasCompletedOnboarding: true)
        .then((_) {
          // Success - no action needed
        })
        .catchError((Object e, StackTrace st) {
          log.w('backfill to server failed',
              tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
          // No return value - proper void handling
        });
  }
}
