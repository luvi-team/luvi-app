import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('Consent02Screen renders localized copy and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.buildAppTheme(),
          home: const Consent02Screen(
            appLinks: TestConfig.defaultAppLinks,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenContext = tester.element(find.byType(Consent02Screen));
    final l10n = AppLocalizations.of(screenContext)!;

    expect(find.text(l10n.consent02Title), findsOneWidget);
    expect(find.text(l10n.consent02CardHealth), findsOneWidget);

    // Verify the terms card (with links) exists (use skipOffstage for ListView items)
    expect(
      find.byKey(const Key('consent02_card_required_terms'), skipOffstage: false),
      findsOneWidget,
    );
    // Verify the analytics optional card exists (MVP scope)
    expect(
      find.text(l10n.consent02CardAnalytics, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(ElevatedButton, l10n.consent02AcceptAll),
      findsOneWidget,
    );

  });

  testWidgets('Consent footer button height matches elevated button theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('de'),
          theme: AppTheme.buildAppTheme(),
          home: const Consent02Screen(
            appLinks: TestConfig.defaultAppLinks,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final buttonFinder = find.byKey(const Key('consent02_btn_next'));
    expect(buttonFinder, findsOneWidget);

    final buttonContext = tester.element(buttonFinder);
    final theme = Theme.of(buttonContext);
    final minHeight = theme.elevatedButtonTheme.style?.minimumSize
        ?.resolve({})
        ?.height;


    expect(minHeight, isNotNull, reason: 'Theme elevatedButtonTheme.style.minimumSize.height should be defined');
    final buttonSize = tester.getSize(buttonFinder);
    expect(buttonSize.height, greaterThanOrEqualTo(minHeight!));
  });

  testWidgets('Consent footer toggles between accept and deselect all labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.buildAppTheme(),
          home: const Consent02Screen(
            appLinks: TestConfig.defaultAppLinks,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final screenContext = tester.element(find.byType(Consent02Screen));
    final l10n = AppLocalizations.of(screenContext)!;

    final bulkButtonFinder = find.widgetWithText(
      ElevatedButton,
      l10n.consent02AcceptAll,
    );
    expect(bulkButtonFinder, findsOneWidget);

    await tester.tap(bulkButtonFinder);

    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(ElevatedButton, l10n.consent02DeselectAll),
      findsOneWidget,
    );
  });
}
