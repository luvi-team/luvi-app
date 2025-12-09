import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_signin_screen.dart';
import 'core/navigation/routes.dart' as routes;
import 'l10n/app_localizations.dart';

/// Preview entrypoint to boot directly into AuthSignInScreen without global redirects.
void main() {
  runApp(const ProviderScope(child: _AuthSignInPreviewApp()));
}

class _AuthSignInPreviewApp extends StatelessWidget {
  const _AuthSignInPreviewApp();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: routes.featureRoutes,
      // No redirect here so we can preview without auth/session
      initialLocation: AuthSignInScreen.routeName,
    );

    return MaterialApp.router(
      title: 'LUVI - Auth SignIn Preview',
      theme: AppTheme.buildAppTheme(),
      routerConfig: router,
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
