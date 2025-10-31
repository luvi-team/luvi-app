import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets(
    'Consent02Screen enables Weiter after required, and disables Alle akzeptieren after selection',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const Consent02Screen(appLinks: TestConfig.defaultAppLinks),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );

      // Weiter disabled initially
      final weiter = find.byKey(const Key('consent02_btn_next'));
      expect(weiter, findsOneWidget);
      expect(tester.widget<ElevatedButton>(weiter).onPressed, isNull);

      // Tap required cards via deterministic keys
      final health = find.byKey(const Key('consent02_card_required_health'));
      final terms = find.byKey(const Key('consent02_card_required_terms'));
      final aiJournal = find.byKey(
        const Key('consent02_card_required_ai_journal'),
      );
      final list = find.byType(Scrollable);
      expect(health, findsOneWidget);
      expect(terms, findsOneWidget);
      await tester.tap(health);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(terms, 200, scrollable: list);
      // Nudge list a bit more so the card center isn't under the sticky CTA
      await tester.drag(list, const Offset(0, 120));
      await tester.pumpAndSettle();
      await tester.tap(terms);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(aiJournal, 200, scrollable: list);
      await tester.drag(list, const Offset(0, 120));
      await tester.pumpAndSettle();
      expect(aiJournal, findsOneWidget);
      await tester.tap(aiJournal);
      await tester.pumpAndSettle();

      // Weiter should now be enabled
      expect(tester.widget<ElevatedButton>(weiter).onPressed, isNotNull);

      // Tap "Alle akzeptieren" to select all optional scopes
      final allAcceptFinder = find.byKey(
        const Key('consent02_btn_toggle_optional'),
      );
      expect(allAcceptFinder, findsOneWidget);
      expect(find.text('Alle akzeptieren'), findsOneWidget);
      final toggleButtonBefore = tester.widget<ElevatedButton>(allAcceptFinder);
      expect(toggleButtonBefore.onPressed, isNotNull);
      await tester.tap(allAcceptFinder);
      await tester.pumpAndSettle();

      // Button switches to "Alle abwählen" with active handler for clearing selections
      final toggleButtonAfter = tester.widget<ElevatedButton>(allAcceptFinder);
      expect(toggleButtonAfter.onPressed, isNotNull);
      expect(find.text('Alle abwählen'), findsOneWidget);

      final screenContext = tester.element(find.byType(Consent02Screen));
      final container = ProviderScope.containerOf(screenContext, listen: false);
      final stateAfterSelect = container.read(consent02Provider);
      expect(stateAfterSelect.allOptionalSelected, isTrue);
      expect(stateAfterSelect.choices[ConsentScope.analytics], isTrue);
      expect(stateAfterSelect.choices[ConsentScope.marketing], isTrue);
      expect(stateAfterSelect.choices[ConsentScope.model_training], isTrue);

      await tester.tap(allAcceptFinder);
      await tester.pumpAndSettle();

      final stateAfterClear = container.read(consent02Provider);
      expect(stateAfterClear.allOptionalSelected, isFalse);
      expect(stateAfterClear.choices[ConsentScope.analytics], isFalse);
      expect(stateAfterClear.choices[ConsentScope.marketing], isFalse);
      expect(stateAfterClear.choices[ConsentScope.model_training], isFalse);
      expect(find.text('Alle akzeptieren'), findsOneWidget);

      // Ensure no explicit card titles are present
      expect(find.text('Gesundheitsdaten'), findsNothing);
      expect(
        find.text('Datenschutzerklärung & Nutzungsbedingungen'),
        findsNothing,
      );
    },
  );
}
