import 'dart:async';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luvi_app/core/analytics/telemetry.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import 'core/navigation/go_router_refresh_stream.dart' as luvi_refresh;
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/user_state_service.dart';
import 'core/config/app_links.dart';
import 'core/navigation/password_recovery_navigation_driver.dart';
import 'core/navigation/route_orientation_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/routes.dart' as routes;
import 'core/navigation/route_paths.dart';
import 'router.dart' as app_router;
import 'core/init/supabase_init_controller.dart';
import 'package:luvi_services/init_mode.dart';
import 'core/init/init_mode.dart' show initModeProvider;
import 'package:luvi_app/features/auth/strings/auth_strings.dart' as auth_strings;
import 'core/init/init_diagnostics.dart';
import 'core/init/supabase_deep_link_handler.dart';
import 'features/consent/config/consent_config.dart';

// TODO(arwin): Greptile status check smoke test
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Drift-Check: Verify ConsentConfig version constants are in sync (debug only)
  ConsentConfig.assertVersionsMatch();
  // Portrait-only as default app orientation during development and MVP.
  // TODO(video-orientation): Register fullscreen routes in [RouteOrientationController.routeOverrides] when landscape is required.
  final orientationController = RouteOrientationController(
    defaultOrientations: const [DeviceOrientation.portraitUp],
  );
  await orientationController.applyDefault();
  // Resilient Supabase init: do not block startup and never crash in release.
  // Initialization runs via SupabaseInitController in the background with
  // classification (config vs transient) and backoff retries.

  const appLinks = ProdAppLinks();
  SupabaseService.configure(
    authConfig:
        SupabaseAuthDeepLinkConfig.fromUri(AppLinks.authCallbackUri),
  );
  // Legal links enforcement modes:
  // - Debug: asserts + optional runtime check when ENFORCE_LINKS_IN_DEBUG=true
  // - Profile: optional runtime check when ENFORCE_LINKS_IN_DEBUG=true
  // - Release: hard runtime check always (throws if links are missing/invalid)
  // Enable the optional debug/profile runtime check via:
  //   --dart-define=ENFORCE_LINKS_IN_DEBUG=true
  // Validate legal links at startup
  const bool kEnforceLinksInDebug =
      bool.fromEnvironment('ENFORCE_LINKS_IN_DEBUG', defaultValue: false);
  
  // Always enforce in release; optionally enforce in debug/profile via flag
  if (kReleaseMode || (!kReleaseMode && kEnforceLinksInDebug)) {
    final hasValid = appLinks.hasValidPrivacy && appLinks.hasValidTerms;
    if (!hasValid) {
      final msg = kReleaseMode
          ? 'Legal links invalid. Provide PRIVACY_URL and TERMS_URL via --dart-define.'
          : 'Legal links invalid in debug/profile. Provide PRIVACY_URL and TERMS_URL via --dart-define.\n'
            'Example: flutter run --dart-define=PRIVACY_URL=https://… --dart-define=TERMS_URL=https://…';
      if (!kReleaseMode) {
        log.e(
          'legal_links_invalid',
          tag: 'main',
          error: msg,
        );
      }
      throw StateError(msg);
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        supabaseEnvFileProvider.overrideWith((ref) {
          final mode = ref.watch(initModeProvider);
          return mode == InitMode.prod
              ? '.env.production'
              : '.env.development';
        }),
      ],
      child: MyAppWrapper(orientationController: orientationController),
    ),
  );
}

class MyAppWrapper extends ConsumerStatefulWidget {
  const MyAppWrapper({required this.orientationController, super.key});
  final RouteOrientationController orientationController;

  @override
  ConsumerState<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends ConsumerState<MyAppWrapper> {
  late final _RouterRefreshNotifier _routerRefreshNotifier =
      _RouterRefreshNotifier();
  late GoRouter _router; // Initialized in initState where ref is available
  PasswordRecoveryNavigationDriver? _passwordRecoveryDriver;
  SupabaseDeepLinkHandler? _deepLinkHandler;
  ProviderSubscription<InitState>? _initOrchestrationSubscription;
  StreamSubscription<AuthState>? _userStateAuthSyncSubscription;
  int _bindUserSequence = 0; // Sequence counter for auth state race condition prevention
  bool _orchestrationInProgress = false;

  String get _initialLocation => kReleaseMode
      ? RoutePaths.splash
      : const String.fromEnvironment(
          'INITIAL_LOCATION',
          defaultValue: RoutePaths.splash,
        );

  GoRouter _createRouter(String initialLocation) {
    return GoRouter(
      routes: app_router.buildAppRoutes(ref),
      initialLocation: initialLocation,
      redirect: routes.supabaseRedirect,
      refreshListenable: _routerRefreshNotifier,
      observers: [widget.orientationController.navigatorObserver],
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize router with routes from router.dart (ref is available here)
    _router = _createRouter(_initialLocation);
    // 1. Start deep-link handler early (queue URIs, DO NOT process yet)
    _initDeepLinkHandler();
    // 2. Diagnostics listener (existing)
    _listenForInitDiagnostics();
    // 3. Orchestration via listeners (NOT in build!)
    // Ensures correct sequence: RouterRefresh -> RecoveryListener -> processPendingUri
    _setupInitOrchestration();
  }

  @override
  void dispose() {
    _initOrchestrationSubscription?.close();
    unawaited(_userStateAuthSyncSubscription?.cancel());
    unawaited(_passwordRecoveryDriver?.dispose());
    unawaited(_deepLinkHandler?.dispose());
    _router.dispose();
    _routerRefreshNotifier.dispose();
    super.dispose();
  }

  bool _shouldRecordInitDiagnostics(InitState? previous, InitState next) {
    final prevHadError =
        previous != null && (previous.configError || previous.error != null);
    final nextHasError = _hasInitError(next);
    if (!nextHasError) {
      return false;
    }
    return !prevHadError;
  }

  bool _hasInitError(InitState state) {
    return state.configError ||
        state.error != null ||
        SupabaseService.lastInitializationError != null;
  }

  void _recordInitDiagnostics(WidgetRef ref) {
    final isNotTest = InitModeBridge.resolve() != InitMode.test;
    if (!isNotTest) return;
    try {
      ref.read(initDiagnosticsProvider.notifier).recordError();
    } catch (e) {
      if (!kReleaseMode) {
        log.w(
          'init_diagnostics_record_failed',
          tag: 'main',
          error: sanitizeError(e) ?? e.runtimeType,
        );
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(supabaseInitControllerProvider);
    // ✅ 100% PURE - keine Side-Effects!
    // All orchestration happens in _setupInitOrchestration() via ref.listenManual
    return _buildMaterialApp(initState);
  }

  void _listenForInitDiagnostics() {
    ref.listenManual<InitState>(
      supabaseInitControllerProvider,
      (previous, next) {
        final shouldRecord = _shouldRecordInitDiagnostics(previous, next);
        if (shouldRecord) {
          _recordInitDiagnostics(ref);
        }
      },
    );
  }

  Widget _buildMaterialApp(InitState initState) {
    return MaterialApp.router(
      title: 'LUVI',
      theme: AppTheme.buildAppTheme(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      builder: (context, child) =>
          _wrapWithInitBanner(context, child, initState),
    );
  }

  Widget _wrapWithInitBanner(
    BuildContext context,
    Widget? child,
    InitState initState,
  ) {
    final shouldShowBanner =
        InitModeBridge.resolve() != InitMode.test && !SupabaseService.isInitialized;
    final content = shouldShowBanner
        ? Stack(
            alignment: Alignment.topLeft,
            children: [
              child ?? const SizedBox.shrink(),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.all(12),
                  child: _InitBanner(initState: initState),
                ),
              ),
            ],
          )
        : child ?? const SizedBox.shrink();

    return LocaleChangeCacheReset(child: content);
  }

  /// Orchestriert Router-Refresh, Recovery-Listener und Pending-URI-Processing
  /// in der korrekten Reihenfolge, sobald Supabase initialisiert ist.
  ///
  /// Pattern: ref.listenManual mit fireImmediately (siehe reset_password_screen.dart:40)
  /// Reihenfolge KRITISCH für Recovery-Flow:
  /// 1. Router-Refresh aktivieren (braucht Supabase-Client)
  /// 2. Recovery-Listener registrieren (MUSS vor pending URI!)
  /// 3. Pending URI verarbeiten (Listener ist garantiert ready)
  void _setupInitOrchestration() {
    _initOrchestrationSubscription = ref.listenManual<InitState>(
      supabaseInitControllerProvider,
      (prev, next) async {
        if (!SupabaseService.isInitialized) return;
        // Reentrancy guard: prevent concurrent execution if provider emits rapidly
        if (_orchestrationInProgress) return;
        _orchestrationInProgress = true;
        try {
          // 1. Router-Refresh aktivieren (braucht Supabase-Client)
          _routerRefreshNotifier.ensureSupabaseListener();

          // 2. Recovery-Listener registrieren (MUSS vor pending URI!)
          _ensurePasswordRecoveryListener();

          // 2b. UserStateService account-scope sync (auth change → bind/clear)
          _ensureUserStateAuthSyncListener();

          // 3. ERST JETZT: Pending URI verarbeiten (Listener ist garantiert ready)
          final handler = _deepLinkHandler;
          if (handler != null && handler.hasPendingUri) {
            unawaited(handler.processPendingUri());
          }
        } catch (e, st) {
          // Log critical initialization failure (don't rethrow - would crash app)
          log.e('Init orchestration failed', tag: 'Main', error: e, stack: st);
        } finally {
          _orchestrationInProgress = false;
        }
      },
      fireImmediately: true, // Falls Supabase schon initialized
    );
  }

  /// Startet Deep-Link-Handler früh um URIs zu queuen (KEIN processing).
  /// Processing passiert erst in _setupInitOrchestration nach Listener-Setup.
  void _initDeepLinkHandler() {
    if (_deepLinkHandler != null) return;
    _deepLinkHandler = SupabaseDeepLinkHandler();
    unawaited(_deepLinkHandler!.start());
  }

  void _ensurePasswordRecoveryListener() {
    if (_passwordRecoveryDriver != null || !SupabaseService.isInitialized) {
      return;
    }
    final authEvents = SupabaseService.client.auth.onAuthStateChange.map(
      (authState) => authState.event,
    );
    _passwordRecoveryDriver = PasswordRecoveryNavigationDriver(
      authEvents: authEvents,
      onNavigateToCreatePassword: () {
        _router.go(RoutePaths.createNewPassword);
      },
    );
  }

  /// Keeps UserStateService cache account-scoped by binding it to the current
  /// authenticated user and clearing on sign-out/account switch.
  ///
  /// SSOT: `public.profiles` is the source of truth; this is only a cache, but
  /// it must never leak between accounts.
  void _ensureUserStateAuthSyncListener() {
    if (_userStateAuthSyncSubscription != null || !SupabaseService.isInitialized) {
      return;
    }

    // Bind once on startup (covers "already signed in" cases where no auth
    // event is emitted immediately).
    unawaited(_bindInitialUser());

    _userStateAuthSyncSubscription =
        SupabaseService.client.auth.onAuthStateChange.listen((authState) async {
      // Race condition prevention: track sequence to skip stale results
      final currentSequence = ++_bindUserSequence;
      try {
        final service = await ref.read(userStateServiceProvider.future);
        // Skip if a newer auth event has superseded this one
        if (currentSequence != _bindUserSequence) return;
        await service.bindUser(authState.session?.user.id);
      } catch (e) {
        // Skip error handling if superseded by newer auth event
        if (currentSequence != _bindUserSequence) return;
        // Always report to telemetry for production debugging
        Telemetry.maybeCaptureException(
          'user_state_bind_failed',
          error: e,
          data: {
            'auth_event': authState.event.name,
            'has_session': authState.session != null,
            'has_user_id': authState.session?.user.id != null,
          },
        );
        if (!kReleaseMode) {
          log.w(
            'user_state_bind_failed',
            tag: 'main',
            error: sanitizeError(e) ?? e.runtimeType,
          );
        }
      }
    });
  }

  /// Binds the initial user state on startup.
  Future<void> _bindInitialUser() async {
    try {
      final service = await ref.read(userStateServiceProvider.future);
      await service.bindUser(SupabaseService.currentUser?.id);
    } catch (e) {
      // Always report to telemetry for production debugging
      Telemetry.maybeCaptureException(
        'user_state_bind_initial_failed',
        error: e,
        data: {
          'has_current_user': SupabaseService.currentUser != null,
        },
      );
      if (!kReleaseMode) {
        log.w(
          'user_state_bind_initial_failed',
          tag: 'main',
          error: sanitizeError(e) ?? e.runtimeType,
        );
      }
    }
  }

}

/// Wrapper that observes locale changes from Localizations and resets the
/// AuthStrings cache when the locale changes to avoid stale cached strings.
class LocaleChangeCacheReset extends StatefulWidget {
  const LocaleChangeCacheReset({super.key, required this.child});
  final Widget child;

  @override
  State<LocaleChangeCacheReset> createState() => _LocaleChangeCacheResetState();
}

class _LocaleChangeCacheResetState extends State<LocaleChangeCacheReset> {
  Locale? _last;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = Localizations.maybeLocaleOf(context);
    if (current != null && _last != current) {
      // Reset localized string caches on locale change.
      // This ensures classes with static caches (e.g., AuthStrings) refresh.
      // Note: relies on single-threaded access on main isolate.
      // Clear localized string caches on locale changes via public API.
      auth_strings.AuthStrings.resetCache();
      _last = current;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _InitBanner extends ConsumerWidget {
  const _InitBanner({required this.initState});
  final InitState initState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = colorScheme.surface.withValues(alpha: 0.95);
    final text = colorScheme.onSurface;
    final border = colorScheme.outline.withValues(alpha: 0.4);
    final attempts = initState.attempts;
    final maxAttempts = initState.maxAttempts;
    final isConfig = initState.configError;
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(AppLocalizations.supportedLocales.first);
    final message = isConfig
        ? l10n.initBannerConfigError
        : l10n.initBannerConnecting(attempts, maxAttempts);

    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: message,
        liveRegion: true,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
            boxShadow: const [
              BoxShadow(blurRadius: 8, spreadRadius: 0, color: Colors.black26),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isConfig ? Icons.error_outline : Icons.wifi_off, color: text),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(color: text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              if (initState.canRetry)
                TextButton(
                  onPressed: () {
                    ref.read(supabaseInitControllerProvider.notifier).retryNow();
                  },
                  child: Text(l10n.initBannerRetry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  luvi_refresh.GoRouterRefreshStream? _authRefresh;

  void ensureSupabaseListener() {
    if (_authRefresh != null || !SupabaseService.isInitialized) {
      return;
    }
    final refresh = luvi_refresh.GoRouterRefreshStream(
      SupabaseService.client.auth.onAuthStateChange,
    )..addListener(_handleAuthChange);
    _authRefresh = refresh;
    // Trigger an initial router refresh since Supabase became available.
    notifyListeners();
  }

  void _handleAuthChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authRefresh?.removeListener(_handleAuthChange);
    _authRefresh?.dispose();
    super.dispose();
  }
}

// Backward compatibility for tests referencing MyApp directly.
class MyApp extends ConsumerWidget {
  const MyApp({required this.orientationController, super.key});
  final RouteOrientationController orientationController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MyAppWrapper(orientationController: orientationController);
  }
}
