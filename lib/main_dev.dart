import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'features/consent/routes.dart';
import 'features/consent/screens/welcome_01.dart';
import 'features/consent/screens/welcome_02.dart';
import 'features/consent/screens/welcome_03.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env.development");
    await SupabaseService.initializeFromEnv();
  } catch (e) {
    debugPrint('Warning: Could not load environment or initialize Supabase: $e');
  }
  
  runApp(const ProviderScope(child: ConsentDevApp()));
}

class ConsentDevApp extends StatelessWidget {
  const ConsentDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LUVI Consent Dev',
      theme: buildAppTheme(brightness: Brightness.light),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: ConsentRoutes.welcome01Route,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('LUVI Dev Navigation'),
          backgroundColor: Colors.brown.shade300,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Screens',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go(ConsentRoutes.welcome01Route),
                child: const Text('Welcome Screen 01'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(ConsentRoutes.welcome02Route),
                child: const Text('Welcome Screen 02'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(ConsentRoutes.welcome03Route),
                child: const Text('Welcome Screen 03'),
              ),
            ],
          ),
        ),
      ),
    ),
    GoRoute(
      path: ConsentRoutes.welcome01Route,
      builder: (context, state) => const Welcome01Screen(),
    ),
    GoRoute(
      path: ConsentRoutes.welcome02Route,
      builder: (context, state) => const Welcome02Screen(),
    ),
    GoRoute(
      path: ConsentRoutes.welcome03Route,
      builder: (context, state) => const Welcome03Screen(),
    ),
  ],
);
