import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/navigation/go_router_refresh_stream.dart' as luvi_refresh;
import 'package:luvi_services/supabase_service.dart';
import 'core/config/app_links.dart';
import 'features/navigation/route_orientation_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/routes.dart' as routes;
import 'features/screens/splash/splash_screen.dart';
import 'core/init/supabase_init_controller.dart';
import 'core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';

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
  const bool kEnforceLinksInDebug =
      bool.fromEnvironment('ENFORCE_LINKS_IN_DEBUG', defaultValue: false);
  assert(
    !kEnforceLinksInDebug ||
        (appLinks.hasValidPrivacy && appLinks.hasValidTerms),
    'Set PRIVACY_URL and TERMS_URL via --dart-define to comply with consent requirements.',
  );

  // Explicit runtime validation in debug/profile when enforcement is enabled.
  // Asserts run only in debug; this runtime check ensures a clear failure
  // early during local development when configuration is invalid.
  if (!kReleaseMode && kEnforceLinksInDebug) {
    final hasValid = appLinks.hasValidPrivacy && appLinks.hasValidTerms;
    if (!hasValid) {
      const msg =
          'Legal links invalid in debug/profile. Provide PRIVACY_URL and TERMS_URL via --dart-define.\n'
          'Example: flutter run --dart-define=PRIVACY_URL=https://… --dart-define=TERMS_URL=https://…';
      debugPrint(msg);
      throw StateError(msg);
    }
  }

  // Release: hard runtime check (not via assert)
  if (kReleaseMode && (!appLinks.hasValidPrivacy || !appLinks.hasValidTerms)) {
    throw StateError(
      'Legal links invalid. Provide PRIVACY_URL and TERMS_URL via --dart-define.',
    );
  }

  runApp(
    ProviderScope(
      child: MyAppWrapper(orientationController: orientationController),
    ),
  );
}

class MyAppWrapper extends ConsumerWidget {
  const MyAppWrapper({required this.orientationController, super.key});
  final RouteOrientationController orientationController;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bind the InitMode bridge so lower layers can resolve the current mode
    // even without Riverpod context (e.g., in services). If tests have already
    // forced test mode before app bootstrap, respect that and do not override.
    if (InitModeBridge.resolve() != InitMode.test) {
      InitModeBridge.resolve = () => ref.read(initModeProvider);
    }
    // Ensure initialization controller is created and running.
    final envFile = kReleaseMode ? '.env.production' : '.env.development';
    // Note: supabaseInitController is an intentionally used global singleton
    // for startup/initialization orchestration (not a Riverpod provider).
    // Lifecycle: created once at app start and kept alive for the entire
    // process lifetime; it coordinates non-blocking Supabase init and retries.
    // Thread-safety: used on the main isolate only, state changes notify
    // listeners via ChangeNotifier; no cross-isolate sharing.
    // Rationale: this init path executes before ProviderScope is available
    // to ensure the app boots quickly and never crashes during backend init.
    // For a Riverpod-based alternative, consider exposing a provider-backed
    // controller once initialization may move later in the startup sequence.
    supabaseInitController.ensureInitialized(envFile: envFile);

    // Allow overriding the initial route in development via --dart-define
    // Example: flutter run --dart-define=INITIAL_LOCATION=/onboarding/01
    final initialLocation = kReleaseMode
        ? SplashScreen.routeName
        : const String.fromEnvironment(
            'INITIAL_LOCATION',
            defaultValue: SplashScreen.routeName,
          );

    // Rebuild MaterialApp (and thus router) when Supabase init state changes
    // so that refreshListenable attaches once the client is ready.
    return AnimatedBuilder(
      animation: supabaseInitController,
      builder: (context, _) {
        final app = MaterialApp.router(
          title: 'LUVI',
          theme: AppTheme.buildAppTheme(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _buildRouter(initialLocation),
          // Integrate the offline/init overlay inside MaterialApp to inherit
          // Directionality/Localizations. This avoids needing Directionality
          // wrappers in tests and keeps behavior consistent across app and tests.
          builder: (context, child) {
            // In test mode, skip overlay for stability.
            if (InitModeBridge.resolve() == InitMode.test) {
              return child ?? const SizedBox.shrink();
            }
            if (SupabaseService.isInitialized) {
              return child ?? const SizedBox.shrink();
            }
            return Stack(
              alignment: Alignment.topLeft,
              children: [
                child ?? const SizedBox.shrink(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    minimum: const EdgeInsets.all(12),
                    child: _InitBanner(
                      initState: supabaseInitController.state,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return app;
      },
    );
  }

  GoRouter _buildRouter(String initialLocation) {
    final refresh = SupabaseService.isInitialized
        ? luvi_refresh.GoRouterRefreshStream(
            SupabaseService.client.auth.onAuthStateChange,
          )
        : null;
    return GoRouter(
      routes: routes.featureRoutes,
      initialLocation: initialLocation,
      redirect: routes.supabaseRedirect,
      refreshListenable: refresh,
      observers: [orientationController.navigatorObserver],
    );
  }

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
    final message = isConfig
        ? 'Configuration error: Supabase credentials invalid. App is running offline.'
        : 'Connecting to server… (attempt $attempts/$maxAttempts)';

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
                    supabaseInitController.retryNow();
                  },
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      ),
    );
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
