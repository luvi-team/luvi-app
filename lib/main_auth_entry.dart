import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_signin_screen.dart';
import 'core/navigation/routes.dart' as routes;
import 'l10n/app_localizations.dart';

/// Preview entrypoint to boot directly into Auth screens without global redirects.
/// Use --dart-define=INITIAL_LOCATION=/auth/forgot to start at a specific route.
void main() {
  runApp(const ProviderScope(child: _AuthSignInPreviewApp()));
}

class _AuthSignInPreviewApp extends StatefulWidget {
  const _AuthSignInPreviewApp();

  static const _initialLocation = String.fromEnvironment(
    'INITIAL_LOCATION',
    defaultValue: AuthSignInScreen.routeName,
  );

  @override
  State<_AuthSignInPreviewApp> createState() => _AuthSignInPreviewAppState();
}

class _AuthSignInPreviewAppState extends State<_AuthSignInPreviewApp> {
  // Router persists across rebuilds to maintain navigation state
  late final GoRouter _router = GoRouter(
    routes: routes.featureRoutes,
    // No redirect here so we can preview without auth/session
    initialLocation: _AuthSignInPreviewApp._initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LUVI - Auth SignIn Preview',
      theme: AppTheme.buildAppTheme(),
      routerConfig: _router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
