import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_entry_screen.dart';
import 'features/routes.dart' as routes;

/// Preview entrypoint to boot directly into AuthEntryScreen without global redirects.
void main() {
  runApp(const ProviderScope(child: _AuthEntryPreviewApp()));
}

class _AuthEntryPreviewApp extends StatelessWidget {
  const _AuthEntryPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: routes.featureRoutes,
      // IMPORTANT: No redirect here so we can preview without auth/session
      initialLocation: AuthEntryScreen.routeName,
    );

    return MaterialApp.router(
      title: 'LUVI - Auth Entry Preview',
      theme: AppTheme.buildAppTheme(),
      routerConfig: router,
    );
  }
}
