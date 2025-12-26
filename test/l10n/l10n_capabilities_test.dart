import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/l10n/l10n_capabilities.dart';
import '../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('BuildContextL10n extension', () {
    testWidgets('context.l10n returns AppLocalizations when configured',
        (tester) async {
      late AppLocalizations? result;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Builder(
            builder: (context) {
              result = context.l10n;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isNotNull,
          reason: 'context.l10n should return AppLocalizations');
      expect(result, isA<AppLocalizations>());
    });

    testWidgets('context.l10n asserts when localizations not configured',
        (tester) async {
      Object? caughtError;

      await tester.pumpWidget(
        MaterialApp(
          // No localizationsDelegates - should trigger assert
          home: Builder(
            builder: (context) {
              try {
                context.l10n;
              } catch (e) {
                caughtError = e;
              }
              return const SizedBox();
            },
          ),
        ),
      );

      expect(caughtError, isA<AssertionError>(),
          reason:
              'context.l10n should assert when localizations not configured');
    });
  });
}
