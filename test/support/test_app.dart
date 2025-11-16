import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';

Widget buildLocalizedApp({
  Widget? home,
  GoRouter? router,
  ThemeData? theme,
  Locale? locale,
}) {
  final appTheme = theme ?? AppTheme.buildAppTheme();
  final appLocale = locale ?? const Locale('de');
  final supportedLocales = AppLocalizations.supportedLocales;
  final delegates = AppLocalizations.localizationsDelegates;
  if (router != null) {
    return MaterialApp.router(
      theme: appTheme,
      routerConfig: router,
      locale: appLocale,
      supportedLocales: supportedLocales,
      localizationsDelegates: delegates,
    );
  }
  assert(
    home != null,
    'Either provide a home widget or a router configuration.',
  );
  return MaterialApp(
    theme: appTheme,
    home: home!,
    locale: appLocale,
    supportedLocales: supportedLocales,
    localizationsDelegates: delegates,
  );
}

/// Convenience helper to wrap a test app with a Provider override.
/// Forces `InitMode.test` to disable network/timers in tests.
Widget buildTestApp({
  Widget? home,
  GoRouter? router,
  ThemeData? theme,
  Locale? locale,
}) {
  return ProviderScope(
    overrides: [initModeProvider.overrideWithValue(InitMode.test)],
    child: buildLocalizedApp(
      home: home,
      router: router,
      theme: theme,
      locale: locale,
    ),
  );
}
