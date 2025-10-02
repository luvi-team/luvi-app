import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/constants/onboarding_constants.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_04.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('picker interaction enables CTA and navigates', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding04Screen.routeName,
          builder: (context, state) => const Onboarding04Screen(),
        ),
        GoRoute(
          path: Onboarding05Screen.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 05 (Stub)')),
        ),
      ],
      initialLocation: Onboarding04Screen.routeName,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
      ),
    );
    await tester.pumpAndSettle();

    // CTA initially disabled
    final cta = find.byKey(const Key('onb_cta'));
    expect(cta, findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(cta).onPressed,
      isNull,
    );

    final picker = find.byType(CupertinoDatePicker);
    expect(picker, findsOneWidget);
    final pickerWidget = tester.widget<CupertinoDatePicker>(picker);
    expect(pickerWidget.minimumDate, isNotNull);
    expect(pickerWidget.maximumDate, isNotNull);
    final currentYear = DateTime.now().year;
    expect(pickerWidget.minimumDate!.year,
        currentYear - kOnboardingPeriodStartMaxYearsBack);
    expect(pickerWidget.maximumDate!.year, currentYear);

    // interact to enable
    await tester.drag(picker, const Offset(0, -50));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ElevatedButton>(cta).onPressed,
      isNotNull,
    );

    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('Onboarding 05 (Stub)'), findsOneWidget);
  });
}
