import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_02_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('ConsentWelcome02Screen', () {
    group('German locale (DE)', () {
      testWidgets('renders localized headline and Weiter button', (
        tester,
      ) async {
        // 1. Render actual screen with DE locale
        await tester.pumpWidget(
          buildTestApp(
            home: const ConsentWelcome02Screen(),
            locale: const Locale('de'),
          ),
        );
        await tester.pumpAndSettle();

        // 2. Extract L10n from widget tree
        final context = tester.element(find.byType(ConsentWelcome02Screen));
        final l10n = AppLocalizations.of(context)!;

        // 3. Assertions against REAL L10n values (not hardcoded)
        expect(find.text(l10n.welcome02Title), findsOneWidget);
        expect(find.text(l10n.welcome02Subtitle), findsOneWidget);
        expect(
          find.widgetWithText(ElevatedButton, l10n.commonContinue),
          findsOneWidget,
        );
      });

      testWidgets('semantics header is present for accessibility', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestApp(
            home: const ConsentWelcome02Screen(),
            locale: const Locale('de'),
          ),
        );
        await tester.pumpAndSettle();

        // Verify semantics header for accessibility
        final handle = tester.ensureSemantics();
        try {
          final headerFinder = find.byWidgetPredicate(
            (w) => w is Semantics && (w.properties.header == true),
          );
          expect(headerFinder, findsOneWidget);
        } finally {
          handle.dispose();
        }
      });
    });

    group('English locale (EN)', () {
      testWidgets('renders localized headline and Continue button', (
        tester,
      ) async {
        // 1. Render actual screen with EN locale
        await tester.pumpWidget(
          buildTestApp(
            home: const ConsentWelcome02Screen(),
            locale: const Locale('en'),
          ),
        );
        await tester.pumpAndSettle();

        // 2. Extract L10n from widget tree
        final context = tester.element(find.byType(ConsentWelcome02Screen));
        final l10n = AppLocalizations.of(context)!;

        // 3. Assertions against REAL L10n values
        expect(find.text(l10n.welcome02Title), findsOneWidget);
        expect(find.text(l10n.welcome02Subtitle), findsOneWidget);
        expect(
          find.widgetWithText(ElevatedButton, l10n.commonContinue),
          findsOneWidget,
        );

        // 4. Verify it's actually English locale
        expect(l10n.localeName, 'en');
      });
    });
  });
}
