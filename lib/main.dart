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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait-only as default app orientation during development and MVP.
  // TODO(video-orientation): Register fullscreen routes in [RouteOrientationController.routeOverrides] when landscape is required.
  final orientationController = RouteOrientationController(
    defaultOrientations: const [DeviceOrientation.portraitUp],
  );
  await orientationController.applyDefault();
  final supabaseEnvFile = kReleaseMode ? '.env.production' : '.env.development';
  try {
    await SupabaseService.tryInitialize(envFile: supabaseEnvFile);
  } catch (error, stackTrace) {
    if (kReleaseMode) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    debugPrint('Supabase initialization failed for $supabaseEnvFile: $error');
  }

  const appLinks = ProdAppLinks();

  // Debug/Profil: Fail fast per assert (nur in Debug aktiv)
  // Commented out for development - using example.com is fine for testing
  // assert(
  //   appLinks.hasValidPrivacy && appLinks.hasValidTerms,
  //   'Set PRIVACY_URL and TERMS_URL via --dart-define to comply with consent requirements.',
  // );

  // Release: harte Laufzeitprüfung (nicht via assert)
  if (kReleaseMode && (!appLinks.hasValidPrivacy || !appLinks.hasValidTerms)) {
    throw StateError(
      'Legal links invalid. Provide PRIVACY_URL and TERMS_URL via --dart-define.',
    );
  }

  runApp(
    ProviderScope(child: MyApp(orientationController: orientationController)),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({required this.orientationController, super.key});

  final RouteOrientationController orientationController;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Allow overriding the initial route in development via --dart-define
    // Example: flutter run --dart-define=INITIAL_LOCATION=/onboarding/01
    final initialLocation = kReleaseMode
        ? SplashScreen.routeName
        : const String.fromEnvironment(
            'INITIAL_LOCATION',
            defaultValue: SplashScreen.routeName,
          );

    final refresh = SupabaseService.isInitialized
        ? luvi_refresh.GoRouterRefreshStream(
            SupabaseService.client.auth.onAuthStateChange,
          )
        : null;
    final router = GoRouter(
      routes: routes.featureRoutes,
      initialLocation: initialLocation,
      redirect: routes.supabaseRedirect,
      refreshListenable: refresh,
      observers: [orientationController.navigatorObserver],
    );
    return MaterialApp.router(
      title: 'LUVI',
      theme: AppTheme.buildAppTheme(), // <— WICHTIG
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
