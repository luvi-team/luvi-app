import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/go_router_refresh_stream.dart' as luvi_refresh;
import 'package:luvi_services/supabase_service.dart';
import 'core/config/app_links.dart';
import 'core/navigation/route_orientation_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/routes.dart' as routes;
import 'features/splash/screens/splash_screen.dart';
import 'core/init/supabase_init_controller.dart';
import 'package:luvi_services/init_mode.dart';
import 'core/init/init_mode.dart' show initModeProvider;
import 'package:luvi_app/features/auth/strings/auth_strings.dart' as auth_strings;
import 'core/init/init_diagnostics.dart';

// TODO(arwin): Greptile status check smoke test
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  late final GoRouter _router = _createRouter(_initialLocation);

  String get _initialLocation => kReleaseMode
      ? SplashScreen.routeName
      : const String.fromEnvironment(
          'INITIAL_LOCATION',
          defaultValue: SplashScreen.routeName,
        );

  GoRouter _createRouter(String initialLocation) {
    return GoRouter(
      routes: routes.featureRoutes,
      initialLocation: initialLocation,
      redirect: routes.supabaseRedirect,
      refreshListenable: _routerRefreshNotifier,
      observers: [widget.orientationController.navigatorObserver],
    );
  }

  @override
  void initState() {
    super.initState();
    _routerRefreshNotifier.ensureSupabaseListener();
    _listenForInitDiagnostics();
  }

  @override
  void dispose() {
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
    _routerRefreshNotifier.ensureSupabaseListener();

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
