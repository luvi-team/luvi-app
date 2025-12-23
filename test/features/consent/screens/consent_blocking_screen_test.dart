import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/screens/consent_blocking_screen.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  /// Creates a test router for navigation tests.
  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: ConsentBlockingScreen.routeName,
      routes: [
        GoRoute(
          path: ConsentBlockingScreen.routeName,
          builder: (context, state) => const ConsentBlockingScreen(),
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

  group('ConsentBlockingScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(ConsentBlockingScreen), findsOneWidget);
    });

    testWidgets('renders with correct L10n (DE)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        locale: const Locale('de'),
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentBlockingScreen));
      final l10n = AppLocalizations.of(context)!;

      // Verify title and body text
      expect(find.text(l10n.consentBlockingTitle), findsOneWidget);
      expect(find.text(l10n.consentBlockingBody), findsOneWidget);
      expect(find.text(l10n.consentBlockingCtaBack), findsOneWidget);
    });

    testWidgets('renders with correct L10n (EN)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        locale: const Locale('en'),
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentBlockingScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.consentBlockingTitle), findsOneWidget);
      expect(find.text(l10n.consentBlockingBody), findsOneWidget);
      expect(find.text(l10n.consentBlockingCtaBack), findsOneWidget);
    });

    testWidgets('has only ONE button (no "App verlassen" button)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      // Should find exactly one ElevatedButton (the "Zurück & Zustimmen" button)
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Should NOT find any OutlinedButton (the old "App verlassen" button)
      expect(find.byType(OutlinedButton), findsNothing);
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

    testWidgets('back button navigates to ConsentOptionsScreen', (tester) async {
      await tester.pumpWidget(buildTestApp(
        locale: const Locale('de'),
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentBlockingScreen));
      final l10n = AppLocalizations.of(context)!;

      // Find and tap the back button
      final buttonFinder = find.text(l10n.consentBlockingCtaBack);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verify navigation to ConsentOptionsScreen
      expect(find.text('ConsentOptionsScreen'), findsOneWidget);
    });

    // Figma Spec: Consent Blocking Shield (Fix 5)
    // Visual requirement: Shield image must NOT have BoxShadow decoration
    // This test inspects widget tree directly because golden tests are not configured.
    // If widget structure changes, update the tree traversal path.
    // Reference: consent_blocking_screen.dart Fix 5
    testWidgets('Shield image has no BoxShadow decoration (Fix 5)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        router: createTestRouter(),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ConsentBlockingScreen));
      final l10n = AppLocalizations.of(context)!;

      // Find the shield via its Semantics label (targeted, not broad Container scan)
      final shieldSemantics = find.bySemanticsLabel(l10n.consentBlockingShieldSemantic);
      expect(shieldSemantics, findsOneWidget,
          reason: 'Shield should have Semantics label');

      // Find the Semantics widget and get the Container that is its direct child
      // Widget structure: Semantics(child: Container(child: Image))
      final semanticsWidget = tester.widget<Semantics>(shieldSemantics);
      final containerWidget = semanticsWidget.child;

      // Verify the child is a Container and check for BoxShadow
      expect(containerWidget, isA<Container>(),
          reason: 'Shield Semantics should wrap a Container');

      final container = containerWidget as Container;
      // Explicitly assert decoration state instead of silently passing
      // Either: no decoration at all (null) OR BoxDecoration without boxShadow
      final decoration = container.decoration;
      if (decoration == null) {
        // No decoration = no BoxShadow (explicit pass)
        expect(decoration, isNull,
            reason: 'Shield container has no decoration (no BoxShadow possible)');
      } else {
        // Has decoration - must be BoxDecoration without boxShadow
        expect(decoration, isA<BoxDecoration>(),
            reason: 'Shield decoration should be BoxDecoration if present');
        expect(
          (decoration as BoxDecoration).boxShadow,
          anyOf(isNull, isEmpty),
          reason: 'Shield container should not have BoxShadow (Fix 5)',
        );
      }
    });
  });
}
