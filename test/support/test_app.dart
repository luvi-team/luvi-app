import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

Widget buildLocalizedApp({
  Widget? home,
  GoRouter? router,
  ThemeData? theme,
}) {
  final appTheme = theme ?? AppTheme.buildAppTheme();
  final locale = const Locale('de');
  final supportedLocales = AppLocalizations.supportedLocales;
  final delegates = AppLocalizations.localizationsDelegates;
  if (router != null) {
    return MaterialApp.router(
      theme: appTheme,
      routerConfig: router,
      locale: locale,
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
    locale: locale,
    supportedLocales: supportedLocales,
    localizationsDelegates: delegates,
  );
}
