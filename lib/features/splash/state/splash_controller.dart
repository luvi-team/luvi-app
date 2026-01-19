import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:luvi_app/core/analytics/analytics_recorder.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/core/utils/type_parsers.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/features/splash/data/splash_dependencies.dart';
import 'package:luvi_app/features/splash/state/splash_gate_functions.dart';
import 'package:luvi_app/features/splash/state/splash_state.dart';
import 'package:luvi_services/device_state_service.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_services/user_state_service.dart';

part 'splash_controller.g.dart';

/// Controller for splash screen gate orchestration.
///
/// Handles the sequential gate checks:
/// 1. Welcome gate (device-local)
/// 2. Auth gate (Supabase authentication)
/// 3. User state + Consent gate (with cache sync)
/// 4. Onboarding gate (with race-retry)
///
/// No BuildContext, no navigation - UI listens to state and navigates.
@riverpod
class SplashController extends _$SplashController {
  // Timeout constants for retry logic
  static const _primaryTimeout = Duration(seconds: 3);
  static const _retryTimeout = Duration(seconds: 2);

  /// Race-retry delay (configurable via constructor for tests).
  Duration _raceRetryDelay = const Duration(milliseconds: 500);

  int _runToken = 0;
  bool _inFlight = false;
  bool _disposed = false;
  int _manualRetryCount = 0;

  @override
  SplashState build() {
    ref.onDispose(() {
      _disposed = true;
      _runToken++;
    });
    return const SplashInitial();
  }

  /// Sets the race-retry delay. Call before [checkGates] for test isolation.
  void setRaceRetryDelay(Duration delay) {
    _raceRetryDelay = delay;
  }

  /// Starts the gate check sequence.
  ///
  /// Idempotent: does nothing if already in-flight or resolved.
  /// After completion, state is either [SplashResolved] or [SplashUnknown].
  Future<void> checkGates() async {
    if (_inFlight) return;
    if (state is SplashResolved) return;

    _inFlight = true;
    final token = ++_runToken;

    try {
      await _runGateSequence(token);
    } finally {
      if (token == _runToken) _inFlight = false;
    }
  }

  /// Manual retry from Unknown state.
  ///
  /// Increments retry counter and re-runs gate sequence.
  /// Does nothing if not in Unknown state or max retries exhausted.
  /// Shows spinner on retry button while retrying (stays on Unknown UI).
  Future<void> retry() async {
    if (state is! SplashUnknown) return;
    if (_manualRetryCount >= SplashUnknown.maxRetries) return;

    _manualRetryCount++;

    // Show spinner while retrying, stay on Unknown UI
    state = SplashUnknown(
      canRetry: true,
      retryCount: _manualRetryCount,
      isRetrying: true,
    );

    await checkGates();
    // After checkGates() completes, new state is set (without isRetrying)
  }

  /// The main gate sequence. Orchestrates gate checks in order.
  ///
  /// Each gate check returns true if it handled the state (navigation resolved
  /// or error shown), or false to continue to the next gate.
  Future<void> _runGateSequence(int token) async {
    final isAuth = ref.read(isAuthenticatedFnProvider)();
    final isTestMode = ref.read(initModeProvider) == InitMode.test;
    final useTimeout = kReleaseMode && !isTestMode;

    // Gate 1: Welcome (device-local)
    if (await _checkWelcomeGate(token)) return;

    // Gate 2: Auth (Supabase)
    if (_checkAuthGate(isAuth)) return;

    // Gate 3: User State + Consent
    final consentResult = await _checkConsentGate(
      token: token,
      isAuth: isAuth,
      useTimeout: useTimeout,
    );
    if (consentResult == null) return;

    // Gate 4: Onboarding
    await _checkOnboardingGate(
      token: token,
      consentResult: consentResult,
      useTimeout: useTimeout,
    );
  }

  /// Gate 1: Check welcome completion. Returns true if handled.
  Future<bool> _checkWelcomeGate(int token) async {
    final welcomeRoute = await _resolveWelcomeGate();
    if (!_isValidRun(token)) return true;
    if (welcomeRoute != null) {
      state = SplashResolved(welcomeRoute);
      return true;
    }
    return false;
  }

  /// Gate 2: Check authentication. Returns true if handled.
  bool _checkAuthGate(bool isAuth) {
    final authRoute = _resolveAuthGate(isAuth);
    if (authRoute != null) {
      state = SplashResolved(authRoute);
      return true;
    }
    return false;
  }

  /// Gate 3: Check consent. Returns ConsentGateResult or null if handled.
  Future<ConsentGateResult?> _checkConsentGate({
    required int token,
    required bool isAuth,
    required bool useTimeout,
  }) async {
    final service = await _loadAndBindUserState(
      useTimeout: useTimeout,
      isAuth: isAuth,
      token: token,
    );
    if (!_isValidRun(token)) return null;
    if (service == null) return null;

    final consentResult = await _resolveConsentGate(
      service: service,
      useTimeout: useTimeout,
      token: token,
    );
    if (!_isValidRun(token)) return null;
    if (consentResult == null) return null;

    if (consentResult.consentRoute != null) {
      state = SplashResolved(consentResult.consentRoute!);
      return null;
    }
    return consentResult;
  }

  /// Gate 4: Check onboarding. Handles state based on result.
  Future<void> _checkOnboardingGate({
    required int token,
    required ConsentGateResult consentResult,
    required bool useTimeout,
  }) async {
    final gateResult = await _evaluateOnboardingGateWithRetry(
      initialRemoteGate: consentResult.remoteGate,
      localGate: consentResult.localGate,
      useTimeout: useTimeout,
      token: token,
    );

    if (!_isValidRun(token)) return;

    _handleOnboardingGateResult(gateResult);
  }

  /// Handles the onboarding gate result, setting appropriate state.
  void _handleOnboardingGateResult(OnboardingGateResult gateResult) {
    switch (gateResult) {
      case RouteResolved(:final route):
        state = SplashResolved(route);
      case StateUnknown():
        state = SplashUnknown(
          canRetry: _manualRetryCount < SplashUnknown.maxRetries,
          retryCount: _manualRetryCount,
        );
      case RaceRetryNeeded():
        // Unreachable: _evaluateOnboardingGateWithRetry handles internally.
        log.e(
          'unexpected RaceRetryNeeded after retry - logic error',
          tag: 'splash',
        );
        if (kDebugMode) {
          throw StateError(
            'RaceRetryNeeded should never reach _runGateSequence switch',
          );
        }
        state = SplashUnknown(
          canRetry: _manualRetryCount < SplashUnknown.maxRetries,
          retryCount: _manualRetryCount,
        );
    }
  }

  /// Checks if current run is still valid (mounted + token match).
  bool _isValidRun(int token) {
    // For autoDispose, async work may outlive the provider instance.
    // We mark the run invalid on dispose by toggling [_disposed] + bumping [_runToken].
    return !_disposed && token == _runToken;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Gate Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gate 1: Check if device-local welcome has been completed.
  /// Returns route to welcome screen, or null to continue.
  /// Fail-closed: If device state cannot be loaded, show welcome (safe default).
  Future<String?> _resolveWelcomeGate() async {
    DeviceStateService deviceState;
    try {
      deviceState = await ref.read(deviceStateServiceProvider.future);
    } catch (e, st) {
      log.w(
        'device state load failed, defaulting to welcome',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
      // Fail-closed: Cannot verify welcome completion → show welcome
      return RoutePaths.welcome;
    }
    if (!deviceState.hasCompletedWelcome) {
      return RoutePaths.welcome;
    }
    return null;
  }

  /// Gate 2: Check authentication state.
  /// Returns route to sign-in screen, or null to continue.
  String? _resolveAuthGate(bool isAuth) {
    if (!isAuth) {
      return RoutePaths.authSignIn;
    }
    return null;
  }

  /// Gate 3a: Load and bind user state service.
  /// Returns service if successful, null on failure (sets state appropriately).
  Future<UserStateService?> _loadAndBindUserState({
    required bool useTimeout,
    required bool isAuth,
    required int token,
  }) async {
    UserStateService? service;
    try {
      service = await _loadUserStateWithRetry(useTimeout: useTimeout);
    } catch (e, st) {
      log.e(
        'state load failed after retry',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
    }

    if (!_isValidRun(token)) return null;

    if (service == null) {
      final fallbackTarget = determineFallbackRoute(isAuth: isAuth);
      state = SplashResolved(fallbackTarget);
      return null;
    }

    final uid = ref.read(currentUserIdFnProvider)();
    if (uid != null) {
      try {
        await service.bindUser(uid);
      } catch (e, st) {
        log.e('bindUser failed', tag: 'splash', error: sanitizeError(e), stack: st);
        if (!_isValidRun(token)) return null;
        state = SplashUnknown(
          canRetry: _manualRetryCount < SplashUnknown.maxRetries,
          retryCount: _manualRetryCount,
        );
        return null;
      }
    }

    return service;
  }

  /// Gate 3b: Resolve consent gate and sync caches.
  /// Returns record with consent route (if needed) and gate values for onboarding.
  /// Returns null if remote profile could not be loaded (sets unknownUI state).
  Future<ConsentGateResult?> _resolveConsentGate({
    required UserStateService service,
    required bool useTimeout,
    required int token,
  }) async {
    final localAcceptedVersion = service.acceptedConsentVersionOrNull;
    final localHasSeenWelcome = service.hasSeenWelcomeOrNull;

    final profileResult = await _loadRemoteProfile(useTimeout: useTimeout);
    if (!profileResult.loaded) {
      if (_isValidRun(token)) {
        state = SplashUnknown(
          canRetry: _manualRetryCount < SplashUnknown.maxRetries,
          retryCount: _manualRetryCount,
        );
      }
      return null;
    }

    final remoteValues = _parseRemoteProfile(profileResult.profile);

    await _syncRemoteCacheToLocal(
      service: service,
      remoteAcceptedVersion: remoteValues.acceptedVersion,
      remoteHasSeenWelcome: remoteValues.hasSeenWelcome,
      localAcceptedVersion: localAcceptedVersion,
      localHasSeenWelcome: localHasSeenWelcome,
    );

    final consentRoute = _evaluateConsentRoute(remoteValues.acceptedVersion);
    final localGate = service.hasCompletedOnboardingOrNull;
    final remoteGate = remoteValues.remoteGate;

    if (!_isValidRun(token)) return null;

    _maybeBackfillOnboarding(localGate: localGate, remoteGate: remoteGate);
    await _syncLocalOnboardingIfNeeded(
      service: service,
      remoteGate: remoteGate,
      localGate: localGate,
      token: token,
    );

    return (
      consentRoute: consentRoute,
      remoteGate: remoteGate,
      localGate: localGate,
    );
  }

  Future<({Map<String, dynamic>? profile, bool loaded})> _loadRemoteProfile({
    required bool useTimeout,
  }) async {
    try {
      final profile = await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
      return (profile: profile, loaded: true);
    } catch (e, st) {
      log.w(
        'remote profile fetch failed',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
      return (profile: null, loaded: false);
    }
  }

  ({int? acceptedVersion, bool? hasSeenWelcome, bool? remoteGate})
      _parseRemoteProfile(Map<String, dynamic>? profile) {
    return (
      acceptedVersion: parseNullableInt(profile?['accepted_consent_version']),
      hasSeenWelcome: parseNullableBool(profile?['has_seen_welcome']),
      remoteGate: parseNullableBool(profile?['has_completed_onboarding']),
    );
  }

  String? _evaluateConsentRoute(int? remoteAcceptedVersion) {
    final needsConsent = remoteAcceptedVersion == null ||
        remoteAcceptedVersion < ConsentConfig.currentVersionInt;
    return needsConsent ? RoutePaths.consentIntro : null;
  }

  void _maybeBackfillOnboarding({
    required bool? localGate,
    required bool? remoteGate,
  }) {
    if (localGate == true && remoteGate != true) {
      _performBackfill();
    }
  }

  Future<void> _syncLocalOnboardingIfNeeded({
    required UserStateService service,
    required bool? remoteGate,
    required bool? localGate,
    required int token,
  }) async {
    if (remoteGate == true && localGate != true) {
      try {
        await service.setHasCompletedOnboarding(true);
      } catch (e, st) {
        log.w(
          'local state sync failed',
          tag: 'splash',
          error: sanitizeError(e) ?? e.runtimeType,
          stack: st,
        );
        if (_isValidRun(token)) {
          ref.read(analyticsRecorderProvider).recordEvent(
            'splash_sync_failure',
            properties: {'operation': 'onboarding_sync'},
          );
        }
      }
    }
  }

  /// Loads UserStateService with one retry on failure.
  Future<UserStateService> _loadUserStateWithRetry({
    required bool useTimeout,
  }) async {
    try {
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(_primaryTimeout)
          : await serviceFuture;
    } catch (e, st) {
      log.w(
        'state load failed, retrying once',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
      if (_disposed) {
        Error.throwWithStackTrace(e, st);
      }
      // Invalidate provider to clear cached error before retry
      ref.invalidate(userStateServiceProvider);
      // One retry with shorter timeout
      final serviceFuture = ref.read(userStateServiceProvider.future);
      return useTimeout
          ? await serviceFuture.timeout(_retryTimeout)
          : await serviceFuture;
    }
  }

  /// Fetches the server profile with retry logic.
  Future<Map<String, dynamic>?> _fetchRemoteProfileWithRetry({
    required bool useTimeout,
  }) async {
    final fetcher = ref.read(profileFetcherProvider);
    try {
      final fetchFuture = fetcher();
      return useTimeout
          ? await fetchFuture.timeout(_primaryTimeout)
          : await fetchFuture;
    } catch (e, st) {
      log.w(
        'remote profile fetch failed, retrying once',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
      if (_disposed) {
        return null;
      }
      final fetchFuture = fetcher();
      return useTimeout
          ? await fetchFuture.timeout(_retryTimeout)
          : await fetchFuture;
    }
  }

  /// Best-effort backfill of local onboarding completion to server.
  void _performBackfill() {
    // Capture recorder before async to avoid ref access after dispose
    final recorder = ref.read(analyticsRecorderProvider);
    final backfill = ref.read(onboardingBackfillProvider);

    // Fire-and-forget, errors are logged but not propagated
    backfill(hasCompletedOnboarding: true).then((_) {
      // Success - no action needed
    }).catchError((Object e, StackTrace st) {
      log.w(
        'backfill to server failed',
        tag: 'splash',
        error: sanitizeError(e) ?? e.runtimeType,
        stack: st,
      );
      recorder.recordEvent(
        'splash_sync_failure',
        properties: {'operation': 'backfill'},
      );
      // No return value - proper void handling
    });
  }

  /// Syncs remote profile gates to local cache.
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
        log.w(
          'local consent version sync failed',
          tag: 'splash',
          error: sanitizeError(e) ?? e.runtimeType,
          stack: st,
        );
        if (!_disposed) {
          ref.read(analyticsRecorderProvider).recordEvent(
            'splash_sync_failure',
            properties: {'operation': 'consent_version'},
          );
        }
      }
    }

    // Welcome sync: monotonic, true from remote → sync to local
    if (remoteHasSeenWelcome == true && localHasSeenWelcome != true) {
      try {
        await service.markWelcomeSeen();
      } catch (e, st) {
        log.w(
          'local welcome sync failed',
          tag: 'splash',
          error: sanitizeError(e) ?? e.runtimeType,
          stack: st,
        );
        if (!_disposed) {
          ref.read(analyticsRecorderProvider).recordEvent(
            'splash_sync_failure',
            properties: {'operation': 'welcome_sync'},
          );
        }
      }
    }
  }

  /// Evaluates onboarding gate with race-retry support.
  Future<OnboardingGateResult> _evaluateOnboardingGateWithRetry({
    required bool? initialRemoteGate,
    required bool? localGate,
    required bool useTimeout,
    required int token,
  }) async {
    var remoteGate = initialRemoteGate;

    var gateResult = determineOnboardingGateRoute(
      remoteGate: remoteGate,
      localGate: localGate,
      homeRoute: RoutePaths.heute,
    );

    // Race-retry: local true + remote false → wait briefly and re-fetch
    if (gateResult is RaceRetryNeeded) {
      await Future<void>.delayed(_raceRetryDelay);
      if (!_isValidRun(token)) return const StateUnknown();

      try {
        final remoteProfile =
            await _fetchRemoteProfileWithRetry(useTimeout: useTimeout);
        remoteGate = parseNullableBool(
          remoteProfile?['has_completed_onboarding'],
        );
      } catch (e, st) {
        log.w(
          'race-retry fetch failed',
          tag: 'splash',
          error: sanitizeError(e) ?? e.runtimeType,
          stack: st,
        );
      }

      // Re-evaluate after race-retry
      gateResult = determineOnboardingGateRoute(
        remoteGate: remoteGate,
        localGate: localGate,
        homeRoute: RoutePaths.heute,
      );

      // If still RaceRetryNeeded after retry → go to Onboarding
      if (gateResult is RaceRetryNeeded) {
        return RouteResolved(RoutePaths.onboarding01);
      }
    }

    return gateResult;
  }
}
