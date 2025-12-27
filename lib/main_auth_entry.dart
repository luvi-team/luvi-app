import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'router.dart' as app_router;

/// Preview entrypoint to boot directly into Auth screens without global redirects.
/// Use --dart-define=INITIAL_LOCATION=/auth/reset to start at a specific route.
void main() {
  runApp(const ProviderScope(child: _AuthSignInPreviewApp()));
}

class _AuthSignInPreviewApp extends ConsumerStatefulWidget {
  const _AuthSignInPreviewApp();

  static const _initialLocation = String.fromEnvironment(
    'INITIAL_LOCATION',
    defaultValue: RoutePaths.authSignIn,
  );

  @override
  ConsumerState<_AuthSignInPreviewApp> createState() =>
      _AuthSignInPreviewAppState();
}

class _AuthSignInPreviewAppState extends ConsumerState<_AuthSignInPreviewApp> {
  // Router persists across rebuilds to maintain navigation state
  late GoRouter _router; // Initialized in initState where ref is available

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: app_router.buildAppRoutes(ref),
      // No redirect here so we can preview without auth/session
      initialLocation: _AuthSignInPreviewApp._initialLocation,
    );
  }

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
