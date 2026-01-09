import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/splash/widgets/splash_video_player.dart';
import 'package:luvi_app/features/splash/widgets/unknown_state_ui.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/device_state_service.dart';
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
/// - Authenticated + needs consent (null or outdated version) → ConsentIntroScreen
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
    return ConsentIntroScreen.routeName;
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
/// - Authenticated → ConsentIntroScreen (safe entry point for gate flow)
///
/// This ensures consent/onboarding gates are never bypassed due to errors.
@visibleForTesting
String determineFallbackRoute({required bool isAuth}) {
  if (!isAuth) {
    return AuthSignInScreen.routeName;
  }
  // Safe fallback: Consent flow will re-check all gates properly.
  // Never go directly to Home when state is unknown.
  return ConsentIntroScreen.routeName;
}

/// Result type for [determineOnboardingGateRoute].
///
/// Three outcomes:
/// - [RouteResolved]: Navigation target determined
/// - [RaceRetryNeeded]: Local/remote mismatch (remote=false, local=true), retry required
/// - [StateUnknown]: Both gates null, or remote null with local true (offline but locally positive)
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

/// State is truly unknown: both gates null, or remote null with local true.
/// Caller should show fallback UI (never route to Home when server SSOT unavailable).
final class StateUnknown extends OnboardingGateResult {
  const StateUnknown();
}

/// Determines the onboarding gate outcome based on remote and local state.
///
/// Returns:
/// - [RouteResolved] with home route if remote gate is true
/// - [RouteResolved] with onboarding route if either gate is explicitly false
/// - [RaceRetryNeeded] if remote=false but local=true (race condition)
/// - [StateUnknown] if both gates are null, or if remote is null and local is true
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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // Timeout constants for retry logic (Point 3: DRY extraction)
  static const _primaryTimeout = Duration(seconds: 3);
  static const _retryTimeout = Duration(seconds: 2);

  /// Maximum number of manual retries before disabling the button.
  static const int _maxManualRetries = 3;

  bool _hasNavigated = false;
  bool _skipAnimation = false;
  bool _showUnknownUI = false;
  int _manualRetryCount = 0;
  bool _isRetrying = false;
  bool _skipAnimationHandled = false;

  /// Whether the user can retry (not exhausted attempts).
  bool get _canRetry => _manualRetryCount < _maxManualRetries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read skipAnimation query param once (post-login redirect uses this)
    final routerState = GoRouterState.of(context);
    _skipAnimation = routerState.uri.queryParameters['skipAnimation'] == 'true';

    // skipAnimation=true: Navigate immediately without waiting for video
    // Must be handled independently of video loading (Plan Phase 3 fix)
    if (_skipAnimation && !_hasNavigated && !_skipAnimationHandled) {
      _skipAnimationHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasNavigated) {
          _navigateAfterAnimation();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      body: _showUnknownUI
          ? _buildUnknownUI(context, l10n)
          : _skipAnimation
              // skipAnimation: Show solid background (no 1-frame flash)
              ? Container(color: DsColors.splashBg)
              : SplashVideoPlayer(
                  assetPath: Assets.videos.splashScreen,
                  fallbackAsset: Assets.images.splashFallback,
                  onComplete: _navigateAfterAnimation,
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
              onPressed: _handleSignOut,
            ),
          ),
        );
      }
    }
  }

  Future<void> _navigateAfterAnimation() async {
    if (_hasNavigated) return;
    final isAuth = SupabaseService.isAuthenticated;
    final isTestMode = ref.read(initModeProvider) == InitMode.test;
    final useTimeout = kReleaseMode && !isTestMode;

    // ── Gate 1: Welcome ────────────────────────────────────────────────────
    final welcomeRoute = await _resolveWelcomeGate();
    if (!mounted || _hasNavigated) return;
    if (welcomeRoute != null) {
      _hasNavigated = true;
      context.go(welcomeRoute);
      return;
    }

    // ── Gate 2: Auth ───────────────────────────────────────────────────────
    final authRoute = _resolveAuthGate(isAuth);
    if (authRoute != null) {
      _hasNavigated = true;
      context.go(authRoute);
      return;
    }

    // ── Gate 3: User State + Consent ───────────────────────────────────────
    final service = await _loadAndBindUserState(
      useTimeout: useTimeout,
      isAuth: isAuth,
    );
    if (!mounted || _hasNavigated) return;
    if (service == null) return; // Abort (fallback navigated or unknownUI shown)

    final consentRoute = await _resolveConsentGate(
      service: service,
      useTimeout: useTimeout,
    );
    if (!mounted || _hasNavigated) return;
    if (consentRoute != null) {
      _hasNavigated = true;
      context.go(consentRoute);
      return;
    }

    // ── Gate 4: Onboarding ─────────────────────────────────────────────────
    final gateResult = await _evaluateOnboardingGateWithRetry(
      initialRemoteGate: _lastRemoteGate,
      localGate: _lastLocalGate,
      useTimeout: useTimeout,
    );

    if (!mounted || _hasNavigated) return;

    switch (gateResult) {
      case RouteResolved(:final route):
        _hasNavigated = true;
        context.go(route);
      case StateUnknown():
        if (mounted) {
          setState(() {
            _isRetrying = false;
            _showUnknownUI = true;
          });
        }
      case RaceRetryNeeded():
        // Unreachable: _evaluateOnboardingGateWithRetry handles race-retry internally
        // Defensive fallback: treat as unknown state
        log.w('unexpected RaceRetryNeeded after retry', tag: 'splash');
        if (mounted) {
          setState(() {
            _isRetrying = false;
            _showUnknownUI = true;
          });
        }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Gate Helpers (extracted for readability, DR-1)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gate 1: Check if device-local welcome has been completed.
  /// Returns route to welcome screen, or null to continue.
  Future<String?> _resolveWelcomeGate() async {
    DeviceStateService? deviceState;
    try {
      deviceState = await ref.read(deviceStateServiceProvider.future);
    } catch (e, st) {
      log.w('device state load failed',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
    }
    if (deviceState != null && !deviceState.hasCompletedWelcome) {
      return RoutePaths.welcome;
    }
    return null;
  }

  /// Gate 2: Check authentication state.
  /// Returns route to sign-in screen, or null to continue.
  String? _resolveAuthGate(bool isAuth) {
    if (!isAuth) {
      return AuthSignInScreen.routeName;
    }
    return null;
  }

  // State passed from _loadAndBindUserState to _evaluateOnboardingGateWithRetry
  bool? _lastRemoteGate;
  bool? _lastLocalGate;

  /// Gate 3a: Load and bind user state service.
  /// Returns service if successful, null on failure (navigates or shows unknownUI).
  Future<UserStateService?> _loadAndBindUserState({
    required bool useTimeout,
    required bool isAuth,
  }) async {
    UserStateService? service;
    try {
      service = await _loadUserStateWithRetry(useTimeout: useTimeout);
    } catch (e, st) {
      log.e('state load failed after retry',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
    }

    if (!mounted || _hasNavigated) return null;

    if (service == null) {
      _hasNavigated = true;
      final fallbackTarget = determineFallbackRoute(isAuth: isAuth);
      context.go(fallbackTarget);
      return null;
    }

    final uid = SupabaseService.currentUser?.id;
    if (uid != null) {
      try {
        await service.bindUser(uid);
      } catch (e, st) {
        log.e('bindUser failed',
            tag: 'splash', error: sanitizeError(e), stack: st);
        if (mounted) {
          setState(() => _showUnknownUI = true);
        }
        return null;
      }
    }

    return service;
  }

  /// Gate 3b: Resolve consent gate and sync caches.
  /// Returns consent route if needed, null to continue to onboarding gate.
  Future<String?> _resolveConsentGate({
    required UserStateService service,
    required bool useTimeout,
  }) async {
    final localAcceptedVersion = service.acceptedConsentVersionOrNull;
    final localHasSeenWelcome = service.hasSeenWelcomeOrNull;

    Map<String, dynamic>? remoteProfile;
    bool remoteProfileLoaded = false;
    try {
      remoteProfile = await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
      remoteProfileLoaded = true;
    } catch (e, st) {
      log.w('remote profile fetch failed',
          tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
    }

    if (!remoteProfileLoaded) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _showUnknownUI = true;
        });
      }
      return null;
    }

    final int? remoteAcceptedVersion = remoteProfileLoaded
        ? (remoteProfile?['accepted_consent_version'] as int?)
        : null;
    final bool? remoteHasSeenWelcome = remoteProfileLoaded
        ? (remoteProfile?['has_seen_welcome'] as bool?)
        : null;

    await _syncRemoteCacheToLocal(
      service: service,
      remoteAcceptedVersion: remoteAcceptedVersion,
      remoteHasSeenWelcome: remoteHasSeenWelcome,
      localAcceptedVersion: localAcceptedVersion,
      localHasSeenWelcome: localHasSeenWelcome,
    );

    final needsConsent = remoteAcceptedVersion == null ||
        remoteAcceptedVersion < ConsentConfig.currentVersionInt;
    if (needsConsent) {
      return ConsentIntroScreen.routeName;
    }

    // Prepare state for onboarding gate (Gate 4)
    _lastLocalGate = service.hasCompletedOnboardingOrNull;
    _lastRemoteGate = remoteProfile == null
        ? null
        : remoteProfile['has_completed_onboarding'] as bool?;

    if (!mounted || _hasNavigated) return null;

    // Backfill: if local true && remote != true, push to server
    if (_lastLocalGate == true && _lastRemoteGate != true) {
      _performBackfill();
    }

    // Sync local state if remote says true
    if (_lastRemoteGate == true && _lastLocalGate != true) {
      try {
        await service.setHasCompletedOnboarding(true);
      } catch (e, st) {
        log.w('local state sync failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }
    }

    return null;
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

  /// Syncs remote profile gates to local cache (P2.3 helper).
  ///
  /// Updates local consent version and welcome flag if remote has newer data.
  /// Best-effort: failures are logged but not propagated.
  Future<void> _syncRemoteCacheToLocal({
    required UserStateService service,
    required int? remoteAcceptedVersion,
    required bool? remoteHasSeenWelcome,
    required int? localAcceptedVersion,
    required bool? localHasSeenWelcome,
  }) async {
    // Consent version sync: remote > local → update local
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

    // Welcome sync: monotonic, true from remote → sync to local
    if (remoteHasSeenWelcome == true && localHasSeenWelcome != true) {
      try {
        await service.markWelcomeSeen();
      } catch (e, st) {
        log.w('local welcome sync failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }
    }
  }

  /// Evaluates onboarding gate with race-retry support (P2.3 helper).
  ///
  /// Returns the final [OnboardingGateResult] after handling race conditions.
  /// If remote=false and local=true, waits briefly and re-fetches.
  Future<OnboardingGateResult> _evaluateOnboardingGateWithRetry({
    required bool? initialRemoteGate,
    required bool? localGate,
    required bool useTimeout,
  }) async {
    var remoteGate = initialRemoteGate;

    var gateResult = determineOnboardingGateRoute(
      remoteGate: remoteGate,
      localGate: localGate,
      homeRoute: HeuteScreen.routeName,
    );

    // Race-retry: local true + remote false → wait briefly and re-fetch
    if (gateResult is RaceRetryNeeded) {
      await Future<void>.delayed(widget.raceRetryDelay);
      if (!mounted) return const StateUnknown();

      try {
        final remoteProfile =
            await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
        remoteGate = remoteProfile == null
            ? null
            : remoteProfile['has_completed_onboarding'] as bool?;
      } catch (e, st) {
        log.w('race-retry fetch failed',
            tag: 'splash', error: sanitizeError(e) ?? e.runtimeType, stack: st);
      }

      // Re-evaluate after race-retry
      gateResult = determineOnboardingGateRoute(
        remoteGate: remoteGate,
        localGate: localGate,
        homeRoute: HeuteScreen.routeName,
      );

      // If still RaceRetryNeeded after retry → go to Onboarding
      if (gateResult is RaceRetryNeeded) {
        return RouteResolved(Onboarding01Screen.routeName);
      }
    }

    return gateResult;
  }
}
