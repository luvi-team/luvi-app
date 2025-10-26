import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/services/supabase_service.dart';
import 'core/navigation/route_orientation_controller.dart';
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
  // Try to initialize Supabase but don't crash if it fails
  try {
    await SupabaseService.tryInitialize(envFile: '.env.development');
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(ProviderScope(child: MyApp(orientationController: orientationController)));
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

    final router = GoRouter(
      routes: routes.featureRoutes,
      initialLocation: initialLocation,
      redirect: routes.supabaseRedirect,
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
