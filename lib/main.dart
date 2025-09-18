import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'features/routes.dart' as features;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In DEV diese Datei laden. Für Releases später .env.production verwenden.
  try {
    await dotenv.load(fileName: ".env.development");
    await SupabaseService.initializeFromEnv();
  } catch (e) {
    // Handle missing .env file in CI/CD or when running without Supabase
    if (kDebugMode) {
      debugPrint(
        'Warning: Could not load environment or initialize Supabase: $e',
      );
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Allow overriding the initial route at build time for development/testing.
    // Usage: flutter run/build --dart-define=INITIAL_ROUTE=/your/path
    const initialLocation = String.fromEnvironment(
      'INITIAL_ROUTE',
      // Default to the Login screen in development unless explicitly overridden.
      defaultValue: '/auth/login',
    );

    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: initialLocation,
      redirect: (context, state) {
        // Allow auth routes while Supabase is initializing, and avoid touching
        // Supabase.instance before initialization completes to prevent asserts.
        final isAuthOpenRoute =
            state.matchedLocation.startsWith('/auth/login') ||
            state.matchedLocation.startsWith('/auth/signup') ||
            state.matchedLocation.startsWith('/auth/forgot') ||
            state.matchedLocation.startsWith('/auth/password/new') ||
            state.matchedLocation.startsWith('/auth/password/success') ||
            state.matchedLocation.startsWith('/auth/verify');

        if (!SupabaseService.initialized) {
          // Until Supabase is initialized, allow only open auth routes.
          return isAuthOpenRoute ? null : '/auth/login';
        }

        final session = SupabaseService.client.auth.currentSession;
        if (session == null && !isAuthOpenRoute) return '/auth/login';
        if (session != null && isAuthOpenRoute) return '/onboarding/w1';
        return null;
      },
    );
    return MaterialApp.router(
      title: 'LUVI',
      theme: AppTheme.buildAppTheme(), // <— WICHTIG
      routerConfig: router,
    );
  }
}
