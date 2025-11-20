import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/dashboard/widgets/cycle_tip_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  group('CycleTipCard l10n', () {
    testWidgets('renders localized headline and body per phase (de)', (
      tester,
    ) async {
      final selectors = <Phase, ({
        String Function(AppLocalizations) headline,
        String Function(AppLocalizations) body,
      })>{
        Phase.menstruation: (
          headline: (l10n) => l10n.cycleTipHeadlineMenstruation,
          body: (l10n) => l10n.cycleTipBodyMenstruation,
        ),
        Phase.follicular: (
          headline: (l10n) => l10n.cycleTipHeadlineFollicular,
          body: (l10n) => l10n.cycleTipBodyFollicular,
        ),
        Phase.ovulation: (
          headline: (l10n) => l10n.cycleTipHeadlineOvulation,
          body: (l10n) => l10n.cycleTipBodyOvulation,
        ),
        Phase.luteal: (
          headline: (l10n) => l10n.cycleTipHeadlineLuteal,
          body: (l10n) => l10n.cycleTipBodyLuteal,
        ),
      };

      for (final phase in Phase.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildAppTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: Scaffold(body: CycleTipCard(phase: phase)),
          ),
        );
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(CycleTipCard));
        final l10n = AppLocalizations.of(ctx)!;
        final expected = selectors[phase]!;

        expect(find.text(expected.headline(l10n)), findsOneWidget);
        expect(find.text(expected.body(l10n)), findsOneWidget);
      }
    });
  });
}
