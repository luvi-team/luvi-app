import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/screens/onboarding_08.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding08Screen', () {
    testWidgets('option tap enables CTA and navigates to success screen', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding08Screen.routeName,
            builder: (context, state) => const Onboarding08Screen(),
          ),
          GoRoute(
            path: '/onboarding/success',
            builder: (context, state) =>
                const Scaffold(body: Text('Success Screen')),
          ),
        ],
        initialLocation: Onboarding08Screen.routeName,
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

      final cta = find.byKey(const Key('onb_cta'));
      expect(cta, findsOneWidget);
      expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNull);

      final firstOption = find.byKey(const Key('onb_option_0'));
      expect(firstOption, findsOneWidget);
      await tester.tap(firstOption);
      await tester.pumpAndSettle();

      expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNotNull);
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.text('Success Screen'), findsOneWidget);
    });

    testWidgets('back button navigates to 07 when canPop is false', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding07Screen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 07')),
          ),
          GoRoute(
            path: Onboarding08Screen.routeName,
            builder: (context, state) => const Onboarding08Screen(),
          ),
        ],
        initialLocation: Onboarding08Screen.routeName,
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

      expect(find.text('Wie fit fühlst du dich?'), findsOneWidget);
      expect(find.text('8/8'), findsOneWidget);

      final backButton = find.byType(BackButtonCircle);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Onboarding 07'), findsOneWidget);
    });

    testWidgets('displays all 4 fitness level options', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding08Screen.routeName,
            builder: (context, state) => const Onboarding08Screen(),
          ),
        ],
        initialLocation: Onboarding08Screen.routeName,
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

      expect(find.byKey(const Key('onb_option_0')), findsOneWidget);
      expect(find.byKey(const Key('onb_option_1')), findsOneWidget);
      expect(find.byKey(const Key('onb_option_2')), findsOneWidget);
      expect(find.byKey(const Key('onb_option_3')), findsOneWidget);

      expect(find.text('Ich fange gerade erst an'), findsOneWidget);
      expect(find.text('Trainiere ab und zu'), findsOneWidget);
      expect(find.text('Fühle mich ziemlich fit'), findsOneWidget);
      expect(find.text('Weiß ich nicht'), findsOneWidget);
      expect(
        find.text('Egal wo du startest - ich bin für dich da!'),
        findsOneWidget,
      );
    });
  });
}
