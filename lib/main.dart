import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'features/consent/routes.dart' as consent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In DEV diese Datei laden. Für Releases später .env.production verwenden.
  try {
    await dotenv.load(fileName: ".env.development");
    await SupabaseService.initializeFromEnv();
  } catch (e) {
    // Handle missing .env file in CI/CD or when running without Supabase
    debugPrint('Warning: Could not load environment or initialize Supabase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        ...consent.consentRoutes,
      ],
      initialLocation: consent.consentWelcome1Path,
    );
    return MaterialApp.router(
      title: 'LUVI',
      theme: AppTheme.buildAppTheme(), // <— WICHTIG
      routerConfig: router,
    );
  }
}
