import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
// ignore: unused_import
import '../../support/test_config.dart';

void main() {
    TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('option tap enables CTA and navigates', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding05Screen.routeName,
          builder: (context, state) => const Onboarding05Screen(),
        ),
        GoRoute(
          path: '/onboarding/06',
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 06 (Stub)')),
        ),
      ],
      initialLocation: Onboarding05Screen.routeName,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
    await tester.pumpAndSettle();

    // CTA initially disabled
    final cta = find.byKey(const Key('onb_cta'));
    expect(cta, findsOneWidget);
    expect(tester.widget<ElevatedButton>(cta).onPressed, isNull);

    // Tap first option -> enable CTA
    final firstOption = find.byKey(const Key('onb_option_0'));
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(cta).onPressed, isNotNull);

    // Navigate
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.text('Onboarding 06 (Stub)'), findsOneWidget);
  });
}
