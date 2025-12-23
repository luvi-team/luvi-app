import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/screens/consent_intro_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  /// Creates a test router for navigation tests.
  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: ConsentIntroScreen.routeName,
      routes: [
        GoRoute(
          path: ConsentIntroScreen.routeName,
          builder: (context, state) => const ConsentIntroScreen(),
        ),
        GoRoute(
          path: ConsentOptionsScreen.routeName,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('ConsentOptionsScreen')),
          ),
        ),
      ],
    );
  }

  group('ConsentIntroScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(ConsentIntroScreen), findsOneWidget);
    });

    testWidgets('renders with correct L10n (DE)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        locale: const Locale('de'),
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentIntroScreen));
      final l10n = AppLocalizations.of(context)!;

      // Verify locale is correct before checking strings
      expect(l10n.localeName, 'de');

      // Verify title and body text
      expect(find.text(l10n.consentIntroTitle), findsOneWidget);
      expect(find.text(l10n.consentIntroBody), findsOneWidget);
      expect(find.text(l10n.consentIntroCtaLabel), findsOneWidget);
    });

    testWidgets('renders with correct L10n (EN)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        locale: const Locale('en'),
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentIntroScreen));
      final l10n = AppLocalizations.of(context)!;

      // Verify locale is correct before checking strings
      expect(l10n.localeName, 'en');

      expect(find.text(l10n.consentIntroTitle), findsOneWidget);
      expect(find.text(l10n.consentIntroBody), findsOneWidget);
      expect(find.text(l10n.consentIntroCtaLabel), findsOneWidget);
    });

    testWidgets('has correct semantics header', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(buildTestApp(
          router: createTestRouter(),
        ));
        await tester.pumpAndSettle();

        // Verify there's a semantics header
        final headerFinder = find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.header == true),
        );
        expect(headerFinder, findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('CTA button navigates to ConsentOptionsScreen', (tester) async {
      await tester.pumpWidget(buildTestApp(
        locale: const Locale('de'),
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentIntroScreen));
      final l10n = AppLocalizations.of(context)!;

      // Find and tap the button
      final buttonFinder = find.text(l10n.consentIntroCtaLabel);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verify navigation to ConsentOptionsScreen
      expect(find.text('ConsentOptionsScreen'), findsOneWidget);
    });
  });
}
