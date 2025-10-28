import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('Consent welcome title renders spacing for de locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ConsentWelcome01Screen(),
      ),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(ConsentWelcome01Screen)),
    )!;
    final richTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains(l10n.welcome01TitleAccent.trim()),
    );
    expect(richTextFinder, findsOneWidget);
    final richText = tester.widget<RichText>(richTextFinder);
    final content = richText.text.toPlainText();
    final lines = content.split('\n');
    expect(lines.length, 2);
    expect(content.contains(l10n.welcome01TitleAccent.trim()), isTrue);
    expect(lines.first.contains(l10n.welcome01TitleSuffixLine1.trim()), isTrue);
    expect(lines.last.trim(), l10n.welcome01TitleSuffixLine2.trim());
  });

  testWidgets('Consent welcome title renders spacing for en locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ConsentWelcome01Screen(),
      ),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(ConsentWelcome01Screen)),
    )!;
    final richTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains(l10n.welcome01TitleAccent.trim()),
    );
    expect(richTextFinder, findsOneWidget);
    final richText = tester.widget<RichText>(richTextFinder);
    final content = richText.text.toPlainText();
    final lines = content.split('\n');
    expect(lines.length, 2);
    expect(content.contains(l10n.welcome01TitleAccent.trim()), isTrue);
    expect(lines.first.contains(l10n.welcome01TitleSuffixLine1.trim()), isTrue);
    expect(lines.last.trim(), l10n.welcome01TitleSuffixLine2.trim());
  });
}
