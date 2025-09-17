import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'features/consent/routes.dart' as consent;
import 'features/auth/screens/login_screen.dart';

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
    final router = GoRouter(
      routes: [
        ...consent.consentRoutes,
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
      initialLocation: '/onboarding/w1',
      redirect: (context, state) {
        final session = SupabaseService.client.auth.currentSession;
        final isLoggingIn = state.matchedLocation.startsWith('/auth/login');
        if (session == null && !isLoggingIn) return '/auth/login';
        if (session != null && isLoggingIn) return '/onboarding/w1';
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
