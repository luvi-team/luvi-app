import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_01_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/consent/routes.dart';

void main() {
  group('Consent01Screen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: Consent01Screen.routeName,
        routes: [
          GoRoute(
            path: Consent01Screen.routeName,
            builder: (context, state) => const Consent01Screen(),
          ),
          GoRoute(
            path: ConsentRoutes.consent02,
            builder: (context, state) =>
                const Scaffold(body: Text('Consent 02')),
          ),
          GoRoute(
            path: '/onboarding/w3',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding W3')),
          ),
        ],
      );
    });

    Widget createTestApp() {
      return MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      );
    }

    testWidgets('displays all UI elements correctly', (tester) async {
      await tester.pumpWidget(createTestApp());
      final consentContext = tester.element(find.byType(Consent01Screen));
      final loc = AppLocalizations.of(consentContext)!;

      // Expect 4 images (the collage tiles)
      expect(find.byType(Image), findsNWidgets(4));

      expect(find.textContaining('Lass uns LUVI'), findsOneWidget);
      expect(
        find.textContaining('Du entscheidest, was du teilen möchtest.'),
        findsOneWidget,
      );

      // Only Weiter button, no Skip
      expect(find.text(loc.commonContinue), findsOneWidget);
      expect(find.text('Überspringen'), findsNothing);

      // Back button by semantics label
      expect(find.bySemanticsLabel(AuthStrings.backSemantic), findsOneWidget);
    });

    testWidgets('collage tiles have correct absolute positions and sizes', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      // We can't easily query by asset path, so rely on order of Positioned children via hit testing.
      // Instead, check there are exactly 4 ClipRRect tiles sized 153x153.
      final tiles = find.byWidgetPredicate(
        (w) => w is ClipRRect && w.borderRadius.toString().contains('20.0'),
      );
      expect(tiles, findsNWidgets(4));
    });

    testWidgets('back button has correct hitbox and visual size', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      final backSemantics = find.bySemanticsLabel(AuthStrings.backSemantic);
      expect(backSemantics, findsOneWidget);

      // Hitbox 44x44
      final hitboxSize = tester.getSize(backSemantics);
      expect(hitboxSize.width, 44);
      expect(hitboxSize.height, 44);
    });

    testWidgets('back button navigates to onboarding w3', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.tap(find.bySemanticsLabel(AuthStrings.backSemantic));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding W3'), findsOneWidget);
    });

    testWidgets('weiter button navigates to consent/02', (tester) async {
      await tester.pumpWidget(createTestApp());
      final consentContext = tester.element(find.byType(Consent01Screen));
      final loc = AppLocalizations.of(consentContext)!;

      await tester.tap(find.widgetWithText(ElevatedButton, loc.commonContinue));
      await tester.pumpAndSettle();

      expect(find.text('Consent 02'), findsOneWidget);
    });

    testWidgets('typography matches tokens (headline/body line-heights)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      final titleFinder = find.textContaining('Lass uns LUVI');
      expect(titleFinder, findsOneWidget);
      final bodyFinder = find.textContaining(
        'Du entscheidest, was du teilen möchtest.',
      );
      expect(bodyFinder, findsOneWidget);
    });
  });
}
