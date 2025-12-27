import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/router.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('navigating to /auth/password/success renders SuccessScreen', (
    tester,
  ) async {
    final router = GoRouter(
      routes: testAppRoutes,
      initialLocation: SuccessScreen.passwordSavedRoutePath,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.buildAppTheme(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth_success_screen')), findsOneWidget);
  });
}
