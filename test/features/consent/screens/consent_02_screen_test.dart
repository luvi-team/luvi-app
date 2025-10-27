import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
// ignore: unused_import
import '../../../support/test_config.dart';

void main() {
    testWidgets('Consent02Screen renders localized copy and actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Consent02Screen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenContext = tester.element(find.byType(Consent02Screen));
    final l10n = AppLocalizations.of(screenContext)!;

    expect(find.text(l10n.consent02Title), findsOneWidget);
    final scrollable = find.byType(Scrollable);
    expect(find.text(l10n.consent02CardHealth), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('consent02_card_required_ai_journal')),
      200,
      scrollable: scrollable,
    );
    expect(
      find.text(l10n.consent02CardAiJournal, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(ElevatedButton, l10n.consent02AcceptAll),
      findsOneWidget,
    );
    expect(find.text(l10n.consent02LinkPrivacyLabel), findsOneWidget);
  });
}
