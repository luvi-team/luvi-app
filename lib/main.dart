import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'features/routes.dart' as routes;
import 'features/auth/screens/auth_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      routerConfig: router,
    );
  }
}
