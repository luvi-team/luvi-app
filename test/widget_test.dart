import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('App boots and shows Consent Welcome title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ConsentWelcome01Screen(),
      ),
    );
    final headlineFinder = find.byWidgetPredicate((w) {
      if (w is RichText) return w.text.toPlainText().contains('Im Einklang');
      if (w is Text) return (w.data?.contains('Im Einklang') ?? false);
      return false;
    });
    expect(headlineFinder, findsOneWidget);
  });
}
