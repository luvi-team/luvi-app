import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('Consent welcome title renders for de locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ConsentWelcome01Screen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(ConsentWelcome01Screen)),
    )!;

    // Simplified title is now a single-line Text widget
    expect(find.text(l10n.welcome01Title), findsOneWidget);

    // Subtitle is present
    expect(find.text(l10n.welcome01Subtitle), findsOneWidget);
  });

  testWidgets('Consent welcome title renders for en locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ConsentWelcome01Screen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(ConsentWelcome01Screen)),
    )!;

    // Simplified title is now a single-line Text widget
    expect(find.text(l10n.welcome01Title), findsOneWidget);

    // Subtitle is present
    expect(find.text(l10n.welcome01Subtitle), findsOneWidget);
  });
}
