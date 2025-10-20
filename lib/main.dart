import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'package:luvi_app/services/supabase_service.dart';
import 'features/routes.dart' as routes;
import 'features/auth/screens/auth_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait-only as default app orientation during development and MVP.
  // TODO(video-orientation): When adding YouTube fullscreen video, allow
  // temporary landscape only on the dedicated fullscreen video route and
  // reset back to portrait on exit. Keep global portrait as the default.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SupabaseService.tryInitialize(envFile: '.env.development');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Allow overriding the initial route in development via --dart-define
    // Example: flutter run --dart-define=INITIAL_LOCATION=/onboarding/01
    final initialLocation = kReleaseMode
        ? AuthEntryScreen.routeName
        : const String.fromEnvironment(
            'INITIAL_LOCATION',
            defaultValue: AuthEntryScreen.routeName,
          );

    final router = GoRouter(
      routes: routes.featureRoutes,
      initialLocation: initialLocation,
      redirect: routes.supabaseRedirect,
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
