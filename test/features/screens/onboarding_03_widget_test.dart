import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selects a goal and navigates', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding03Screen.routeName,
          builder: (context, state) => const Onboarding03Screen(),
        ),
        GoRoute(
          path: '/onboarding/04',
          builder: (context, state) => const Scaffold(
            body: Text('Onboarding 04 (Stub)'),
          ),
        ),
      ],
      initialLocation: Onboarding03Screen.routeName,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    final cta = find.byKey(const Key('onb_cta'));
    expect(cta, findsOneWidget);
    expect(tester.widget<ElevatedButton>(cta).onPressed, isNull);

    // tippe erstes Item
    final firstOption = find.byKey(const Key('onb_option_0'));
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(cta).onPressed, isNotNull);

    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('Onboarding 04 (Stub)'), findsOneWidget);
  });
}
