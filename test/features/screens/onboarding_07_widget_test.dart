import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';

void main() {
  testWidgets('option tap enables CTA and navigates to done', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: Onboarding07Screen.routeName, builder: (context, state) => const Onboarding07Screen()),
        GoRoute(path: '/onboarding/done', builder: (context, state) => const Scaffold(body: Text('Onboarding abgeschlossen'))),
      ],
      initialLocation: Onboarding07Screen.routeName,
    );

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.buildAppTheme(), routerConfig: router));
    await tester.pumpAndSettle();

    final cta = find.byKey(const Key('onb_cta'));
    expect(cta, findsOneWidget);
    // initially disabled
    expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNull);

    // tap first option (Text an Figma anpassen, z.B. 'Ziemlich regelmäßig')
    final firstOption = find.byKey(const Key('onb_option_0'));
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    // enabled & navigates
    expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNotNull);
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.text('Onboarding abgeschlossen'), findsOneWidget);
  });
}
