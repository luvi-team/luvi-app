import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/routes.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_screen.dart';
import 'services/supabase_service.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD9B18E)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: ConsentRoutes.consentWelcome,
  routes: [
    GoRoute(
      path: ConsentRoutes.consentWelcome,
      builder: (context, state) => const ConsentWelcomeScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Dev Navigation'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go(ConsentRoutes.consentWelcome),
                child: const Text('Go to Consent Welcome'),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
);