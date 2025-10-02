import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/constants/onboarding_constants.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/screens/onboarding_02.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

void main() {
  testWidgets(
      'renders title, handles back/re-navigation, and enables CTA after date picker interaction',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding01Screen.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 01')),
        ),
        GoRoute(
          path: Onboarding02Screen.routeName,
          builder: (context, state) => const Onboarding02Screen(),
        ),
        GoRoute(
          path: Onboarding03Screen.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding 03')),
        ),
      ],
      initialLocation: Onboarding02Screen.routeName,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Wann hast du'), findsOneWidget);
    expect(find.textContaining('Geburtstag'), findsOneWidget);
    expect(find.textContaining('Erzähl mir von dir'), findsNothing);
    final cta = find.byKey(const Key('onb_cta'));
    expect(cta, findsOneWidget);
    expect(tester.widget<ElevatedButton>(cta).onPressed, isNull);

    await tester.tap(find.byType(BackButtonCircle));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding 01'), findsOneWidget);

    router.go(Onboarding02Screen.routeName);
    await tester.pumpAndSettle();

    // Interact with date picker to enable CTA
    final picker = find.byType(CupertinoDatePicker);
    expect(picker, findsOneWidget);
    final pickerWidget = tester.widget<CupertinoDatePicker>(picker);
    expect(pickerWidget.minimumYear, kOnboardingMinBirthYear);
    expect(pickerWidget.maximumYear, kOnboardingMaxBirthYear);

    // Simulate picker interaction by dragging
    await tester.drag(picker, const Offset(0, -50));
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(cta).onPressed, isNotNull);
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.text('Onboarding 03'), findsOneWidget);
  });
}
