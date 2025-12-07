import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/widgets/localized_builder.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('LocalizedBuilder', () {
    testWidgets('calls builder with AppLocalizations when delegates present', (
      tester,
    ) async {
      AppLocalizations? capturedL10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: LocalizedBuilder(
            builder: (context, l10n) {
              capturedL10n = l10n;
              return Text(l10n.commonContinue);
            },
          ),
        ),
      );

      expect(capturedL10n, isNotNull);
      expect(find.text('Weiter'), findsOneWidget);
    });

    testWidgets('works correctly with English locale', (
      tester,
    ) async {
      // Verify LocalizedBuilder works with different supported locales
      AppLocalizations? capturedL10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: LocalizedBuilder(
            builder: (context, l10n) {
              capturedL10n = l10n;
              return Text(l10n.commonContinue);
            },
          ),
        ),
      );

      expect(capturedL10n, isNotNull);
      // English translation for commonContinue
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
