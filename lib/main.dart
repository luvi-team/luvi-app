import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'features/routes.dart' as routes;

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
    final router = GoRouter(
      routes: routes.featureRoutes,
      initialLocation: '/onboarding/w1',
      redirect: routes.supabaseRedirect,
    );
    return MaterialApp.router(
      title: 'LUVI',
      theme: AppTheme.buildAppTheme(), // <— WICHTIG
      routerConfig: router,
    );
  }
}
